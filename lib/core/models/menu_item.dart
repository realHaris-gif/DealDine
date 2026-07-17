/// MenuItem represents a single dish available at a restaurant.
/// 
/// Each menu item contains pricing and categorization information
/// that is used in the recommendation algorithm.
class MenuItem {
  /// Unique identifier of the specific variant
  final String id;

  /// The name of the dish
  final String name;

  /// Detailed description or composition of the item
  final String description;
  
  /// The price of the dish in PKR
  final double price;

  /// Public asset location or remote network path for the food image
  final String imageUrl;
  
  /// The category this item belongs to (e.g., 'Main Course', 'Appetizer', 'Dessert')
  final String category;

  /// Creates a MenuItem instance.
  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  /// Creates a MenuItem from a JSON map.
  /// 
  /// This factory constructor handles deserialization safely from both
  /// local asset files and custom endpoint responses.
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    // Generate a unique fallback string identifier using properties if 'id' is completely missing
    final nameKey = json['name'] as String? ?? 'item';
    final generatedId = json['id']?.toString() ?? '${nameKey.toLowerCase().replaceAll(' ', '_')}';

    return MenuItem(
      id: generatedId,
      name: json['name'] as String? ?? 'Unknown Item',
      description: json['description'] as String? ?? json['desc'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String? ?? '',
      category: json['category'] as String? ?? 'Mains',
    );
  }

  /// Converts this MenuItem to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'imageUrl': imageUrl,
    'category': category,
  };
}