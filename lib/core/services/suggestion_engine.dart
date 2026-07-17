import '../models/actionable_suggestion.dart';
import '../models/deal.dart';
import '../models/deal_item.dart';
import '../models/menu_item.dart';
import '../models/restaurant.dart';
import 'recommendation_scorer.dart';

class SuggestionEngine {
  final _scorer = RecommendationScorer();

  List<ActionableSuggestion> generateActionableSuggestions(
    Deal deal,
    Restaurant restaurant,
  ) {
    final suggestions = <ActionableSuggestion>[];
    int priority = 1;

    if (!_feedEveryoneCheck(deal)) {
      suggestions.addAll(_suggestQuantityIncrease(deal, restaurant, priority++));
    }

    suggestions.addAll(_suggestRemovals(deal, restaurant, priority++));

    if (deal.remainingBudget > 50) {
      suggestions.addAll(_suggestAdditions(deal, restaurant, priority++));
      suggestions.addAll(_suggestUpgrades(deal, restaurant, priority++));
    }

    suggestions.addAll(_suggestBetterValue(deal, restaurant, priority++));

    for (var s in suggestions) {
      final item = restaurant.menu.firstWhere((m) => m.name == s.itemName, orElse: () => null as dynamic);
      if (item != null) {
        s.priority = (_scorer.scoreItem(item as MenuItem, deal, deal.numberOfPeople) * 10).toInt().clamp(0, 100);
      }
    }

    suggestions.sort((a, b) => b.priority.compareTo(a.priority));

    return suggestions.where((s) => !s.applied).toList();
  }

  bool _feedEveryoneCheck(Deal deal) {
    final mains = deal.items.where((item) => _isMainCourse(item.item)).length;
    return mains >= deal.numberOfPeople;
  }

  bool _isMainCourse(MenuItem item) {
    final cat = item.category.toLowerCase();
    return cat.contains('main') || cat.contains('burger') || cat.contains('sandwich') || cat.contains('pizza') || cat.contains('biryani');
  }

  List<ActionableSuggestion> _suggestQuantityIncrease(
    Deal deal,
    Restaurant restaurant,
    int basePriority,
  ) {
    final suggestions = <ActionableSuggestion>[];
    final mains = deal.items.where((item) => _isMainCourse(item.item)).toList();

    if (mains.isNotEmpty) {
      final main = mains.first;
      if (main.quantity < deal.numberOfPeople) {
        final needed = deal.numberOfPeople - main.quantity;
        final costPerIncrease = main.item.price * needed;

        if (deal.totalCost + costPerIncrease <= deal.totalBudget) {
          suggestions.add(ActionableSuggestion(
            id: 'qty-${main.item.name}-${main.quantity + needed}',
            type: SuggestionType.increase,
            itemName: main.item.name,
            targetQuantity: deal.numberOfPeople,
            text: 'Increase ${main.item.name} to ${deal.numberOfPeople}',
            reason: 'Each person can receive one ${main.item.name} while staying within budget.',
            budgetImpact: costPerIncrease,
            priority: basePriority,
          ));
        }
      }
    }

    return suggestions;
  }

  List<ActionableSuggestion> _suggestRemovals(
    Deal deal,
    Restaurant restaurant,
    int basePriority,
  ) {
    final suggestions = <ActionableSuggestion>[];

    for (var item in deal.items) {
      if (deal.items.length > 1 && deal.budgetUtilization > 90) {
        final isSide = item.item.category.toLowerCase().contains('side') ||
            item.item.category.toLowerCase().contains('drink');

        if (isSide) {
          suggestions.add(ActionableSuggestion(
            id: 'remove-${item.item.name}',
            type: SuggestionType.remove,
            itemName: item.item.name,
            text: 'Remove ${item.item.name}',
            reason: 'This saves Rs.${item.totalPrice.toStringAsFixed(0)} while keeping everyone fed.',
            budgetImpact: -item.totalPrice,
            priority: basePriority + 1,
          ));
        }
      }
    }

    return suggestions;
  }

  List<ActionableSuggestion> _suggestAdditions(
    Deal deal,
    Restaurant restaurant,
    int basePriority,
  ) {
    final suggestions = <ActionableSuggestion>[];
    final remaining = deal.remainingBudget;

    final categories = ['Drinks', 'Sides', 'Desserts'];
    for (var cat in categories) {
      final items = restaurant.menu
          .where((m) => m.category == cat && !deal.items.any((di) => di.item.name == m.name))
          .toList()
        ..sort((a, b) => a.price.compareTo(b.price));

      if (items.isNotEmpty && items.first.price <= remaining) {
        final item = items.first;
        suggestions.add(ActionableSuggestion(
          id: 'add-${item.name}',
          type: SuggestionType.add,
          itemName: item.name,
          text: 'Add ${item.name}',
          reason: 'Still Rs.${(remaining - item.price).toStringAsFixed(0)} remaining after adding this.',
          budgetImpact: item.price,
          priority: basePriority,
        ));
      }
    }

    return suggestions;
  }

  List<ActionableSuggestion> _suggestUpgrades(
    Deal deal,
    Restaurant restaurant,
    int basePriority,
  ) {
    final suggestions = <ActionableSuggestion>[];

    for (var item in deal.items) {
      final category = item.item.category;
      final similar = restaurant.menu
          .where((m) =>
              m.category == category &&
              m.price > item.item.price &&
              !deal.items.any((di) => di.item.name == m.name))
          .toList()
        ..sort((a, b) => a.price.compareTo(b.price));

      if (similar.isNotEmpty) {
        final upgraded = similar.first;
        final upgradeCost = (upgraded.price - item.item.price) * item.quantity;

        if (deal.totalCost + upgradeCost <= deal.totalBudget && upgradeCost <= 150) {
          suggestions.add(ActionableSuggestion(
            id: 'upgrade-${item.item.name}-to-${upgraded.name}',
            type: SuggestionType.upgrade,
            itemName: item.item.name,
            targetItemName: upgraded.name,
            text: 'Upgrade to ${upgraded.name}',
            reason: 'Better quality for only Rs.${upgradeCost.toStringAsFixed(0)} extra.',
            budgetImpact: upgradeCost,
            priority: basePriority + 1,
          ));
        }
      }
    }

    return suggestions;
  }

  List<ActionableSuggestion> _suggestBetterValue(
    Deal deal,
    Restaurant restaurant,
    int basePriority,
  ) {
    final suggestions = <ActionableSuggestion>[];

    for (var item in deal.items) {
      final category = item.item.category;
      final sameCategory = restaurant.menu
          .where((m) =>
              m.category == category &&
              m.price > item.item.price &&
              !deal.items.any((di) => di.item.name == m.name))
          .toList();

      if (sameCategory.isNotEmpty) {
        final better = sameCategory.reduce((a, b) => a.price < b.price ? a : b);
        final diff = better.price - item.item.price;

        if (diff > 0 && diff <= 100 && deal.totalCost + (diff * item.quantity) <= deal.totalBudget) {
          suggestions.add(ActionableSuggestion(
            id: 'value-${item.item.name}',
            type: SuggestionType.replace,
            itemName: item.item.name,
            targetItemName: better.name,
            text: 'Switch to ${better.name}',
            reason: 'Better value for only Rs.${(diff * item.quantity).toStringAsFixed(0)} more.',
            budgetImpact: diff * item.quantity,
            priority: basePriority + 2,
          ));
        }
      }
    }

    return suggestions;
  }
}