import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/restaurant.dart';
import '../models/user_preferences.dart';
import '../repositories/restaurant_repository.dart';
import '../services/recommendation_service.dart';

final repositoryProvider = Provider((ref) => RestaurantRepository());

final serviceProvider = Provider((ref) => RecommendationService());

final restaurantsProvider = FutureProvider<List<Restaurant>>((ref) async {
  return ref.watch(repositoryProvider).getRestaurants();
});

final citiesProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(repositoryProvider).getCities();
});

final cuisinesProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(repositoryProvider).getCuisines();
});

final userPreferencesProvider = StateProvider<UserPreferences>((ref) {
  return UserPreferences(
    numberOfPeople: 2,
    totalBudget: 3000,
    preferredCuisine: '',
    preferredCity: '',
  );
});

final recommendationsProvider = FutureProvider<List<Restaurant>>((ref) async {
  final restaurants = await ref.watch(restaurantsProvider.future);
  final prefs = ref.watch(userPreferencesProvider);
  final service = ref.watch(serviceProvider);
  return service.filterAndScore(restaurants, prefs);
});

final restaurantByIdProvider = FutureProvider.family<Restaurant?, String>((ref, id) async {
  return ref.watch(repositoryProvider).getRestaurantById(id);
});