import 'menu_item.dart';

class DealItem {
  final MenuItem item;
  int quantity;

  DealItem({required this.item, required this.quantity});

  double get totalPrice => item.price * quantity;

  DealItem copyWith({MenuItem? item, int? quantity}) {
    return DealItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }
}
