/// MenuItem represents a single dish available at a restaurant.
/// 
/// Each menu item contains pricing and categorization information
/// that is used in the recommendation algorithm.
class MenuItem {
  /// The name of the dish
  final String name;
  
  /// The price of the dish in PKR
  final double price;
  
  /// The category this item belongs to (e.g., 'Main Course', 'Appetizer', 'Dessert')
  final String category;

  /// Creates a MenuItem instance.
  /// 
  /// All parameters are required.
  MenuItem({
    required this.name,
    required this.price,
    required this.category,
  });

  /// Creates a MenuItem from a JSON map.
  /// 
  /// This factory constructor is used when deserializing restaurant data
  /// from the local JSON assets.
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
    );
  }

  /// Converts this MenuItem to a JSON map.
  /// 
  /// Useful for serialization or logging.
  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'category': category,
  };
}