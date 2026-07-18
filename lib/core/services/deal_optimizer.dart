import '../models/deal.dart';
import '../models/deal_item.dart';
import '../models/menu_item.dart';
import '../models/restaurant.dart';
import 'budget_calculator.dart';

class DealOptimizer {
  final BudgetCalculator _calculator = BudgetCalculator();

  List<Deal> optimizeDealsWithBeamSearch(
    Restaurant restaurant,
    int numberOfPeople,
    double totalBudget,
  ) {
    final allCombinations = _generateBeamSearchCombinations(
      restaurant.menu,
      numberOfPeople,
      totalBudget,
      beamWidth: 50,
    );

    final scoredDeals = allCombinations.map((items) {
      final deal = Deal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: DealType.custom,
        name: 'Optimized Deal',
        description: '',
        items: items,
        numberOfPeople: numberOfPeople,
        totalBudget: totalBudget,
      );
      return (deal, _scoreDeals(deal, restaurant, numberOfPeople, totalBudget));
    }).toList();

    scoredDeals.sort((a, b) => b.$2.compareTo(a.$2));

    return scoredDeals.take(5).map((e) => e.$1).toList();
  }

  List<List<DealItem>> _generateBeamSearchCombinations(
    List<MenuItem> menu,
    int numberOfPeople,
    double totalBudget, {
    required int beamWidth,
  }) {
    final results = <List<DealItem>>[];
    final candidates = <(List<DealItem>, double)>[]; // (items, score)

    candidates.add(([], 0));

    for (var item in menu) {
      final newCandidates = <(List<DealItem>, double)>[];

      for (var (currentItems, currentScore) in candidates) {
        for (int qty = 1; qty <= 5; qty++) {
          final totalCost = currentItems.fold(0.0, (sum, di) => sum + (di.item.price * di.quantity)) + (item.price * qty);

          if (totalCost <= totalBudget) {
            final newItems = [...currentItems, DealItem(item: item, quantity: qty)];
            final score = _quickScoreCombination(newItems, numberOfPeople, totalBudget);
            newCandidates.add((newItems, score));
          }
        }

        newCandidates.add((currentItems, currentScore));
      }

      newCandidates.sort((a, b) => b.$2.compareTo(a.$2));
      candidates.clear();
      candidates.addAll(newCandidates.take(beamWidth));
    }

    for (var (items, _) in candidates) {
      if (items.isNotEmpty) results.add(items);
    }

    return results.take(5).toList();
  }

  double _quickScoreCombination(List<DealItem> items, int numberOfPeople, double totalBudget) {
    double score = 0;

    final totalCost = items.fold(0.0, (sum, di) => sum + (di.item.price * di.quantity));
    final utilization = (totalCost / totalBudget) * 100;

    if (utilization >= 90 && utilization <= 100) {
      score += 30;
    } else if (utilization >= 80 && utilization < 90) {
      score += 20;
    } else if (utilization >= 70 && utilization < 80) {
      score += 10;
    }

    score += _mealCompletenessScore(items) * 25;
    score += _varietyScore(items) * 15;
    score += _categoryBalanceScore(items) * 20;

    return score;
  }

  double _scoreDeals(Deal deal, Restaurant restaurant, int numberOfPeople, double totalBudget) {
    double score = 0;

    final budgetEfficiency = _scoreBudgetEfficiency(deal.totalCost, totalBudget);
    final completeness = _mealCompletenessScore(deal.items);
    final variety = _varietyScore(deal.items);
    final categoryBalance = _categoryBalanceScore(deal.items);
    final groupSuitability = _scoreGroupSuitability(deal.items, numberOfPeople);
    final savingsRatio = _savingsRatio(deal.totalCost, totalBudget);

    score += budgetEfficiency * 0.30;
    score += completeness * 0.25;
    score += variety * 0.15;
    score += categoryBalance * 0.15;
    score += groupSuitability * 0.10;
    score += savingsRatio * 0.05;

    return score;
  }

  double _scoreBudgetEfficiency(double cost, double budget) {
    final utilization = (cost / budget) * 100;
    if (utilization >= 90 && utilization <= 100) return 100;
    if (utilization >= 80 && utilization < 90) return 80;
    if (utilization >= 70 && utilization < 80) return 60;
    if (utilization >= 60 && utilization < 70) return 40;
    return 20;
  }

  double _mealCompletenessScore(List<DealItem> items) {
    if (items.isEmpty) return 0;

    final hasMain = items.any((di) => _isMainItem(di.item));
    final hasSide = items.any((di) => _isSideItem(di.item));
    final hasDrink = items.any((di) => _isDrinkItem(di.item));
    final hasCombo = items.any((di) => _isComboItem(di.item));

    int completeness = 0;
    if (hasCombo) completeness += 3;
    if (hasMain) completeness += 1;
    if (hasSide) completeness += 1;
    if (hasDrink) completeness += 1;

    return (completeness / 4.0).clamp(0, 1);
  }

  double _varietyScore(List<DealItem> items) {
    if (items.isEmpty) return 0;

    final uniqueItems = items.map((di) => di.item.name).toSet().length;
    final totalItems = items.fold(0, (sum, di) => sum + di.quantity);

    return (uniqueItems / totalItems).clamp(0, 1);
  }

  double _categoryBalanceScore(List<DealItem> items) {
    if (items.isEmpty) return 0;

    final categories = <String>{};
    for (var item in items) {
      categories.add(item.item.category);
    }

    return (categories.length / 4.0).clamp(0, 1);
  }

  double _scoreGroupSuitability(List<DealItem> items, int numberOfPeople) {
    final totalQty = items.fold(0, (sum, di) => sum + di.quantity);
    final qtyPerPerson = totalQty / numberOfPeople;

    if (qtyPerPerson >= 1.0 && qtyPerPerson <= 2.0) return 1.0;
    if (qtyPerPerson >= 0.5 && qtyPerPerson < 1.0) return 0.8;
    if (qtyPerPerson > 2.0 && qtyPerPerson <= 3.0) return 0.7;
    return 0.5;
  }

  double _savingsRatio(double cost, double budget) {
    final savings = budget - cost;
    return (savings / budget).clamp(0, 1);
  }

  bool _isMainItem(MenuItem item) {
    final cat = item.category.toLowerCase();
    return cat.contains('main') || cat.contains('burger') || cat.contains('pizza') || 
           cat.contains('biryani') || cat.contains('sandwich') || cat.contains('bucket') ||
           cat.contains('family');
  }

  bool _isSideItem(MenuItem item) {
    final cat = item.category.toLowerCase();
    return cat.contains('side') || cat.contains('fries') || cat.contains('coleslaw') ||
           cat.contains('salad');
  }

  bool _isDrinkItem(MenuItem item) {
    final cat = item.category.toLowerCase();
    return cat.contains('drink') || cat.contains('beverage') || cat.contains('shake') ||
           cat.contains('cola');
  }

  bool _isComboItem(MenuItem item) {
    final name = item.name.toLowerCase();
    return name.contains('combo') || name.contains('meal') || name.contains('deal') ||
           name.contains('bucket') || name.contains('family');
  }

  String generateExplanation(Deal deal, double totalBudget, int numberOfPeople) {
    final utilization = (deal.totalCost / totalBudget) * 100;
    final savings = totalBudget - deal.totalCost;
    final costPerPerson = deal.costPerPerson;
    final itemCount = deal.itemCount;
    final completeness = _mealCompletenessScore(deal.items);

    if (utilization >= 95) {
      return 'Uses ${utilization.toStringAsFixed(0)}% of budget • Rs.${savings.toStringAsFixed(0)} savings';
    } else if (costPerPerson < 500) {
      return 'Lowest cost per person: Rs.${costPerPerson.toStringAsFixed(0)} • $itemCount items';
    } else if (completeness > 0.7) {
      return 'Complete meal with variety • Rs.${costPerPerson.toStringAsFixed(0)}/person';
    } else if (numberOfPeople > 3) {
      return 'Great for $numberOfPeople people • Rs.${costPerPerson.toStringAsFixed(0)}/person';
    }
    return 'Balanced choice • ${(utilization).toStringAsFixed(0)}% budget used';
  }
}
