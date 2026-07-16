import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/restaurant.dart';

class RestaurantRepository {
  Future<List<Restaurant>> getRestaurants() async {
    final jsonString = await rootBundle.loadString('assets/restaurants.json');
    final jsonData = jsonDecode(jsonString) as List<dynamic>;
    return jsonData.map((item) => Restaurant.fromJson(item as Map<String, dynamic>)).toList();
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
    return restaurants.map((r) => r.city).toSet().toList()..sort();
  }

  Future<List<String>> getCuisines() async {
    final restaurants = await getRestaurants();
    return restaurants.map((r) => r.cuisine).toSet().toList()..sort();
  }
}