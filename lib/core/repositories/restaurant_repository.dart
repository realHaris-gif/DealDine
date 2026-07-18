import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/restaurant.dart';
import 'kfc_repository.dart';
import 'dominos_repository.dart';

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
  for (final r in restaurants) {
  print('Restaurant ID: ${r.id} | Name: ${r.name}');
}
  try {
  final liveKfc = await KfcRepository().getRestaurant();

  final kfcIndex = restaurants.indexWhere(
    (restaurant) => restaurant.id == '1',
  );

  print("KFC index: $kfcIndex");

  if (kfcIndex != -1) {
    restaurants[kfcIndex] = liveKfc;
    print("KFC replaced: ${restaurants[kfcIndex].menu.length}");
  }
} catch (e) {
  print("KFC failed: $e");
}


try {
  final liveDominos = await DominosRepository().getRestaurant();

  final dominosIndex = restaurants.indexWhere(
    (restaurant) => restaurant.id == '4',
  );

  print("Domino's index: $dominosIndex");

  if (dominosIndex != -1) {
    restaurants[dominosIndex] = liveDominos;
    print("Domino's replaced: ${restaurants[dominosIndex].menu.length}");
  }
} catch (e) {
  print("Domino's failed: $e");
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