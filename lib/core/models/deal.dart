import 'deal_item.dart';

enum DealType { bestValue, mostFilling, premiumChoice }

class Deal {
  final String id;
  final DealType type;
  final String name;
  final String description;
  final List<DealItem> items;
  final int numberOfPeople;
  final double totalBudget;
  double? dealScore;

  Deal({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.items,
    required this.numberOfPeople,
    required this.totalBudget,
    this.dealScore,
  });

  double get totalCost => items.fold(0, (sum, item) => sum + item.totalPrice);

  double get remainingBudget => (totalBudget - totalCost).clamp(0, totalBudget);

  double get costPerPerson => numberOfPeople > 0 ? totalCost / numberOfPeople : 0;

  double get budgetUtilization => (totalCost / totalBudget * 100).clamp(0, 100);

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isWithinBudget => totalCost <= totalBudget;

  Deal copyWith({
    String? id,
    DealType? type,
    String? name,
    String? description,
    List<DealItem>? items,
    int? numberOfPeople,
    double? totalBudget,
    double? dealScore,
  }) {
    return Deal(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      items: items ?? this.items,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      totalBudget: totalBudget ?? this.totalBudget,
      dealScore: dealScore ?? this.dealScore,
    );
  }
}
