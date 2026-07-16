import 'menu_item.dart';

/// Restaurant represents a single restaurant that can be recommended to users.
/// 
/// It contains all necessary information for filtering, scoring, and displaying
/// restaurant recommendations. This model is deserialized from the local
/// restaurants.json asset file.
class Restaurant {
  /// Unique identifier for the restaurant
  final String id;
  
  /// The name of the restaurant
  final String name;
  
  /// Customer rating out of 5
  final double rating;
  
  /// Distance from user location in kilometers
  final double distance;
  
  /// The city where the restaurant is located
  final String city;
  
  /// Primary cuisine type (e.g., 'Fast Food', 'Chinese', 'Karahi')
  final String cuisine;
  
  /// Description or tagline of the restaurant
  final String description;
  
  /// Complete menu available at this restaurant
  final List<MenuItem> menu;
  
  /// Match score for recommendation (0-100)
  double? matchScore;

  /// Creates a Restaurant instance.
  /// 
  /// All parameters are required to ensure data consistency.
  Restaurant({
    required this.id,
    required this.name,
    required this.rating,
    required this.distance,
    required this.city,
    required this.cuisine,
    required this.description,
    required this.menu,
  });

  /// Creates a Restaurant from a JSON map.
  /// 
  /// This factory constructor is used when deserializing restaurant data
  /// from the local JSON assets. It recursively creates MenuItem objects
  /// from the menu array.
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    final menuList = (json['menu'] as List<dynamic>)
        .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      rating: (json['rating'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
      city: json['city'] as String,
      cuisine: json['cuisine'] as String,
      description: json['description'] as String,
      menu: menuList,
    );
  }

  /// Converts this Restaurant to a JSON map.
  /// 
  /// Useful for serialization or logging.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'rating': rating,
    'distance': distance,
    'city': city,
    'cuisine': cuisine,
    'description': description,
    'menu': menu.map((item) => item.toJson()).toList(),
  };

  /// Calculates the average cost per meal from the menu.
  /// 
  /// This is used by the recommendation algorithm to match against
  /// user budgets. Returns the average price of all menu items.
  double getAverageMealCost() {
    if (menu.isEmpty) return 0;
    final total = menu.fold<double>(0, (sum, item) => sum + item.price);
    return total / menu.length;
  }

  /// Finds the cheapest meal option at this restaurant.
  /// 
  /// Returns null if the menu is empty.
  MenuItem? getCheapestItem() {
    if (menu.isEmpty) return null;
    return menu.reduce(
      (a, b) => a.price < b.price ? a : b,
    );
  }

  /// Finds items within a specific price range.
  /// 
  /// Returns a filtered list of menu items between minPrice and maxPrice (inclusive).
  List<MenuItem> getItemsInPriceRange(double minPrice, double maxPrice) {
    return menu
        .where((item) => item.price >= minPrice && item.price <= maxPrice)
        .toList();
  }

  /// Creates a copy of this Restaurant with optional field overrides.
  Restaurant copyWith({
    String? id,
    String? name,
    double? rating,
    double? distance,
    String? city,
    String? cuisine,
    String? description,
    List<MenuItem>? menu,
    double? matchScore,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      distance: distance ?? this.distance,
      city: city ?? this.city,
      cuisine: cuisine ?? this.cuisine,
      description: description ?? this.description,
      menu: menu ?? this.menu,
    )..matchScore = matchScore ?? this.matchScore;
  }
}