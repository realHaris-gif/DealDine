import '../models/menu_item.dart';
import '../models/restaurant.dart';
import '../services/kfc_api_service.dart';

class KfcRepository {
  final KfcApiService _api = KfcApiService();

  Future<Restaurant> getRestaurant() async {
    final data = await _api.fetchMenu();

    final menu = data.map<MenuItem>((item) {
      return MenuItem(
        id: item['id']?.toString() ?? '',
        name: item['name'] ?? 'Unknown Item',
        description: item['description'] ?? '',
        price: (item['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: item['imageUrl'] ?? '',
        category: item['category'] ?? 'Mains',
      );
    }).toList();
    print('Mapped ${menu.length} menu items');
    print(menu.first.name);
    print(menu.first.price);
    return Restaurant(
      id: '1',
      name: 'KFC',
      rating: 4.6,
      distance: 2.5,
      city: 'Lahore',
      cuisine: 'Fast Food',
      description: 'Live menu from KFC Pakistan',
      menu: menu,
    );
  }
}