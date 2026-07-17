import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/restaurant.dart';
import 'kfc_repository.dart';

class RestaurantRepository {
  Future<List<Restaurant>> getRestaurants() async {
    final jsonString = await rootBundle.loadString(
      'assets/restaurants.json',
    );

    final jsonData = jsonDecode(jsonString) as List<dynamic>;

    final restaurants = jsonData
        .map(
          (item) => Restaurant.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();

    try {
      final liveKfc = await KfcRepository().getRestaurant();

  for (final r in restaurants) {
  print('Restaurant ID: ${r.id} | Name: ${r.name}');
}

final index = restaurants.indexWhere(
  (restaurant) => restaurant.id == '1',
);

print('Found index: $index');

if (index != -1) {
  restaurants[index] = liveKfc;
  print('Replaced KFC with ${restaurants[index].menu.length} items');
  print(restaurants[index].menu.first.name);
}
    } catch (e) {
      print('Unable to load live KFC menu: $e');
    }

    return restaurants;
  }

  Future<Restaurant?> getRestaurantById(String id) async {
    final restaurants = await getRestaurants();

    try {
      return restaurants.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> getCities() async {
    final restaurants = await getRestaurants();

    return restaurants
        .map((r) => r.city)
        .toSet()
        .toList()
      ..sort();
  }

  Future<List<String>> getCuisines() async {
    final restaurants = await getRestaurants();

    return restaurants
        .map((r) => r.cuisine)
        .toSet()
        .toList()
      ..sort();
  }
}