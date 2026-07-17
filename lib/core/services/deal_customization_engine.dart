import '../models/actionable_suggestion.dart';
import '../models/deal.dart';
import '../models/deal_item.dart';
import '../models/menu_item.dart';

class DealCustomizationEngine {
  Deal increaseQuantity(Deal deal, String itemName) {
    final newItems = deal.items.map((item) => item.copyWith()).toList();
    final itemIndex = newItems.indexWhere((item) => item.item.name == itemName);

    if (itemIndex != -1) {
      final updatedItem = newItems[itemIndex].copyWith(
        quantity: newItems[itemIndex].quantity + 1,
      );
      newItems[itemIndex] = updatedItem;

      if (updatedItem.totalPrice + deal.totalCost - deal.items[itemIndex].totalPrice <= deal.totalBudget) {
        return deal.copyWith(items: newItems);
      }
    }

    return deal;
  }

  Deal decreaseQuantity(Deal deal, String itemName) {
    final newItems = deal.items.map((item) => item.copyWith()).toList();
    final itemIndex = newItems.indexWhere((item) => item.item.name == itemName);

    if (itemIndex != -1) {
      final item = newItems[itemIndex];
      if (item.quantity > 1) {
        newItems[itemIndex] = item.copyWith(quantity: item.quantity - 1);
      } else {
        newItems.removeAt(itemIndex);
      }
      return deal.copyWith(items: newItems);
    }

    return deal;
  }

  Deal addItem(Deal deal, MenuItem item) {
    final newItems = [...deal.items];
    final existing = newItems.firstWhere(
      (di) => di.item.name == item.name,
      orElse: () => DealItem(item: item, quantity: 0),
    );

    if (existing.quantity > 0) {
      final idx = newItems.indexOf(existing);
      if (deal.totalCost + item.price <= deal.totalBudget) {
        newItems[idx] = existing.copyWith(quantity: existing.quantity + 1);
        return deal.copyWith(items: newItems);
      }
    } else {
      if (deal.totalCost + item.price <= deal.totalBudget) {
        newItems.add(DealItem(item: item, quantity: 1));
        return deal.copyWith(items: newItems);
      }
    }

    return deal;
  }

  Deal setQuantity(Deal deal, String itemName, int quantity) {
    if (quantity < 1) return removeItem(deal, itemName);

    final newItems = deal.items.map((item) => item.copyWith()).toList();
    final itemIndex = newItems.indexWhere((item) => item.item.name == itemName);

    if (itemIndex != -1) {
      final oldCost = newItems[itemIndex].totalPrice;
      final newItem = newItems[itemIndex].copyWith(quantity: quantity);
      final newCost = newItem.totalPrice;
      final costDiff = newCost - oldCost;

      if (deal.totalCost + costDiff <= deal.totalBudget) {
        newItems[itemIndex] = newItem;
        return deal.copyWith(items: newItems);
      }
    }

    return deal;
  }

  Deal removeItem(Deal deal, String itemName) {
    final newItems = deal.items.where((item) => item.item.name != itemName).toList();
    return deal.copyWith(items: newItems);
  }

  (bool canAdd, String? message) canAddItem(Deal deal, MenuItem item) {
    if (deal.totalCost + item.price <= deal.totalBudget) {
      return (true, null);
    }

    final exceeded = (deal.totalCost + item.price) - deal.totalBudget;
    return (false, 'Adding ${item.name} would exceed budget by Rs.${exceeded.toStringAsFixed(0)}');
  }

  Deal applySuggestion(
    Deal deal,
    ActionableSuggestion suggestion,
    MenuItem? targetItem,
  ) {
    var newDeal = deal;

    switch (suggestion.type) {
      case SuggestionType.add:
        if (targetItem != null) {
          newDeal = addItem(newDeal, targetItem);
        }
        break;
      case SuggestionType.remove:
        newDeal = removeItem(newDeal, suggestion.itemName);
        break;
      case SuggestionType.increase:
        if (suggestion.targetQuantity != null) {
          newDeal = setQuantity(newDeal, suggestion.itemName, suggestion.targetQuantity!);
        }
        break;
      case SuggestionType.decrease:
        if (suggestion.targetQuantity != null) {
          newDeal = setQuantity(newDeal, suggestion.itemName, suggestion.targetQuantity!);
        }
        break;
      case SuggestionType.replace:
        if (suggestion.targetItemName != null && targetItem != null) {
          newDeal = removeItem(newDeal, suggestion.itemName);
          newDeal = addItem(newDeal, targetItem);
        }
        break;
      case SuggestionType.upgrade:
        if (suggestion.targetItemName != null && targetItem != null) {
          final item = newDeal.items.firstWhere((di) => di.item.name == suggestion.itemName);
          newDeal = removeItem(newDeal, suggestion.itemName);
          final newItem = DealItem(item: targetItem, quantity: item.quantity);
          newDeal = newDeal.copyWith(items: [...newDeal.items, newItem]);
        }
        break;
    }

    return newDeal;
  }
}
