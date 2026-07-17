import '../models/deal.dart';
import '../models/deal_item.dart';
import '../models/menu_item.dart';
import '../models/restaurant.dart';

class DealRecommendationEngine {
  List<Deal> generateDeals(
    Restaurant restaurant,
    int numberOfPeople,
    double totalBudget,
  ) {
    final budgetPerPerson = totalBudget / numberOfPeople;

    return [
      _bestValueDeal(restaurant, numberOfPeople, totalBudget, budgetPerPerson),
      _mostFillingDeal(restaurant, numberOfPeople, totalBudget, budgetPerPerson),
      _premiumChoiceDeal(restaurant, numberOfPeople, totalBudget, budgetPerPerson),
    ];
  }

  Deal _bestValueDeal(
    Restaurant restaurant,
    int numberOfPeople,
    double totalBudget,
    double budgetPerPerson,
  ) {
    final mains = restaurant.menu.where((m) => m.category.toLowerCase().contains('main') || m.category.toLowerCase().contains('burger') || m.category.toLowerCase().contains('sandwich')).toList();
    final sides = restaurant.menu.where((m) => m.category.toLowerCase().contains('side') || m.category.toLowerCase().contains('fries')).toList();
    final drinks = restaurant.menu.where((m) => m.category.toLowerCase().contains('drink')).toList();

    mains.sort((a, b) => a.price.compareTo(b.price));
    sides.sort((a, b) => a.price.compareTo(b.price));
    drinks.sort((a, b) => a.price.compareTo(b.price));

    final items = <DealItem>[];
    double spent = 0;

    for (int i = 0; i < numberOfPeople; i++) {
      if (mains.isNotEmpty) {
        final main = mains.first;
        if (spent + main.price <= totalBudget) {
          final existing = items.firstWhere(
            (item) => item.item.name == main.name,
            orElse: () => DealItem(item: main, quantity: 0),
          );
          if (existing.quantity == 0) items.add(existing);
          existing.quantity++;
          spent += main.price;
        }
      }
    }

    if (sides.isNotEmpty && spent + sides.first.price <= totalBudget) {
      final side = sides.first;
      items.add(DealItem(item: side, quantity: (numberOfPeople / 2).ceil()));
      spent += side.price * (numberOfPeople / 2).ceil();
    }

    if (drinks.isNotEmpty && spent + drinks.first.price <= totalBudget) {
      final drink = drinks.first;
      items.add(DealItem(item: drink, quantity: numberOfPeople));
      spent += drink.price * numberOfPeople;
    }

    final deal = Deal(
      id: 'best-value-${restaurant.id}',
      type: DealType.bestValue,
      name: 'Best Value',
      description: 'Maximum savings with essentials',
      items: items,
      numberOfPeople: numberOfPeople,
      totalBudget: totalBudget,
    );

    deal.dealScore = _calculateScore(deal, numberOfPeople);
    return deal;
  }

  Deal _mostFillingDeal(
    Restaurant restaurant,
    int numberOfPeople,
    double totalBudget,
    double budgetPerPerson,
  ) {
    final items = <DealItem>[];
    double spent = 0;

    final sortedByCategory = <String, List<MenuItem>>{};
    for (var item in restaurant.menu) {
      sortedByCategory.putIfAbsent(item.category, () => []).add(item);
    }

    for (var category in sortedByCategory.keys) {
      sortedByCategory[category]!.sort((a, b) => a.price.compareTo(b.price));
    }

    for (int i = 0; i < numberOfPeople; i++) {
      for (var category in sortedByCategory.keys) {
        final menu = sortedByCategory[category]!;
        if (menu.isNotEmpty && spent + menu.first.price <= totalBudget) {
          final item = menu.first;
          final existing = items.firstWhere(
            (di) => di.item.name == item.name,
            orElse: () => DealItem(item: item, quantity: 0),
          );
          if (existing.quantity == 0) items.add(existing);
          existing.quantity++;
          spent += item.price;
          break;
        }
      }
    }

    final remainingBudget = totalBudget - spent;
    for (var category in sortedByCategory.keys) {
      for (var item in sortedByCategory[category]!) {
        if (remainingBudget > item.price && items.length < numberOfPeople + 3) {
          if (!items.any((di) => di.item.name == item.name)) {
            items.add(DealItem(item: item, quantity: 1));
            spent += item.price;
            break;
          }
        }
      }
    }

    final deal = Deal(
      id: 'most-filling-${restaurant.id}',
      type: DealType.mostFilling,
      name: 'Most Filling',
      description: 'Variety with plenty of portions',
      items: items,
      numberOfPeople: numberOfPeople,
      totalBudget: totalBudget,
    );

    deal.dealScore = _calculateScore(deal, numberOfPeople);
    return deal;
  }

  Deal _premiumChoiceDeal(
    Restaurant restaurant,
    int numberOfPeople,
    double totalBudget,
    double budgetPerPerson,
  ) {
    final sortedByPrice = List<MenuItem>.from(restaurant.menu);
    sortedByPrice.sort((a, b) => b.price.compareTo(a.price));

    final items = <DealItem>[];
    double spent = 0;

    for (int i = 0; i < numberOfPeople; i++) {
      final main = sortedByPrice.firstWhere(
        (item) => item.price <= budgetPerPerson * 0.7 && spent + item.price <= totalBudget,
        orElse: () => sortedByPrice.first,
      );
      if (spent + main.price <= totalBudget) {
        final existing = items.firstWhere(
          (item) => item.item.name == main.name,
          orElse: () => DealItem(item: main, quantity: 0),
        );
        if (existing.quantity == 0) items.add(existing);
        existing.quantity++;
        spent += main.price;
      }
    }

    final remainingPerPerson = (totalBudget - spent) / numberOfPeople;
    for (var item in sortedByPrice) {
      if (item.price <= remainingPerPerson && spent + item.price <= totalBudget) {
        if (!items.any((di) => di.item.name == item.name)) {
          items.add(DealItem(item: item, quantity: (numberOfPeople / 2).ceil()));
          spent += item.price * (numberOfPeople / 2).ceil();
          break;
        }
      }
    }

    final deal = Deal(
      id: 'premium-${restaurant.id}',
      type: DealType.premiumChoice,
      name: 'Premium Choice',
      description: 'Quality items for a special treat',
      items: items,
      numberOfPeople: numberOfPeople,
      totalBudget: totalBudget,
    );

    deal.dealScore = _calculateScore(deal, numberOfPeople);
    return deal;
  }

  double _calculateScore(Deal deal, int numberOfPeople) {
    double score = 0;

    final utilization = deal.budgetUtilization / 100;
    score += utilization * 40;

    final itemsPerPerson = deal.itemCount / numberOfPeople;
    score += (itemsPerPerson.clamp(1, 5) / 5) * 30;

    const targetUtilization = 0.95;
    final utilizationDiff = (utilization - targetUtilization).abs();
    score += (1 - utilizationDiff.clamp(0, 1)) * 30;

    return score.clamp(0, 100);
  }
}
