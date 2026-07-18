import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/restaurant.dart';
import 'kfc_repository.dart';
import 'dominos_repository.dart';
import 'brim_repository.dart';

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

      final kfcIndex = restaurants.indexWhere(
        (restaurant) => restaurant.id == '1',
      );



      if (kfcIndex != -1) {
        restaurants[kfcIndex] = liveKfc;
       
      }
    } catch (e) {
      print("KFC failed: $e");
    }
    

    // Replace Domino's with live data
    try {
      final liveDominos = await DominosRepository().getRestaurant();

      final dominosIndex = restaurants.indexWhere(
        (restaurant) => restaurant.id == '4',
      );



      if (dominosIndex != -1) {
        restaurants[dominosIndex] = liveDominos;
      }
    } catch (e) {
      print("Domino's failed: $e");
    }

    // Replace Brim Burgers with live data
   try {
  final brimIndex = restaurants.indexWhere(
    (restaurant) => restaurant.id == '21',
  );



  if (brimIndex != -1) {
    final liveBrim = await BrimRepository().getRestaurant();

    restaurants[brimIndex] = liveBrim;
  }
} catch (e) {
  print("Brim failed: $e");
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