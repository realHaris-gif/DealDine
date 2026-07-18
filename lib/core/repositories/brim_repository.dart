import '../models/menu_item.dart';
import '../models/restaurant.dart';
import '../services/brim_api_service.dart';

class BrimRepository {
  final BrimApiService _api = BrimApiService();

  Future<Restaurant> getRestaurant() async {
    final menu = await _api.fetchMenu();

    final items = menu.map<MenuItem>((item) {
      return MenuItem(
       id: item['id']?.toString() ?? '',
        name: item['name'] ?? 'Unknown Item',
        description: item['description'] ?? '',
        price: (item['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: item['imageUrl'] ?? '',
        category: item['category'] ?? 'Mains',
      );
    }).toList();

    return Restaurant(
      id: '21',
      name: 'Brim Burgers',
      rating: 4.5,
      distance: 2.5,
      city: 'Lahore',
      cuisine: 'Fast Food',
      description: 'Premium burgers, wraps, fries and more.',
      menu: items,
    );
  }
}