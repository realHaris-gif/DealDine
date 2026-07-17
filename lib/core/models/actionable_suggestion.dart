enum SuggestionType { add, remove, increase, decrease, replace, upgrade }

class ActionableSuggestion {
  final String id;
  final SuggestionType type;
  final String itemName;
  final String? targetItemName;
  final int? targetQuantity;
  final String text;
  final String reason;
  final double budgetImpact;
  int priority;
  bool applied;

  ActionableSuggestion({
    required this.id,
    required this.type,
    required this.itemName,
    this.targetItemName,
    this.targetQuantity,
    required this.text,
    required this.reason,
    required this.budgetImpact,
    required this.priority,
    this.applied = false,
  });

  ActionableSuggestion copyWith({bool? applied}) {
    return ActionableSuggestion(
      id: id,
      type: type,
      itemName: itemName,
      targetItemName: targetItemName,
      targetQuantity: targetQuantity,
      text: text,
      reason: reason,
      budgetImpact: budgetImpact,
      priority: priority,
      applied: applied ?? this.applied,
    );
  }
}