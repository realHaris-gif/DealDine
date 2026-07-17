import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/actionable_suggestion.dart';
import '../models/deal.dart';
import '../services/budget_calculator.dart';
import '../services/deal_customization_engine.dart';
import '../services/deal_recommendation_engine.dart';
import '../services/suggestion_engine.dart';
import 'app_providers.dart';

final dealRecommendationEngineProvider = Provider((ref) => DealRecommendationEngine());
final dealCustomizationEngineProvider = Provider((ref) => DealCustomizationEngine());
final budgetCalculatorProvider = Provider((ref) => BudgetCalculator());
final suggestionEngineProvider = Provider((ref) => SuggestionEngine());

final selectedDealProvider = StateProvider<Deal?>((ref) => null);
final originalDealProvider = StateProvider<Deal?>((ref) => null);
final appliedSuggestionsProvider = StateProvider<Set<String>>((ref) => {});

final dealsForRestaurantProvider = FutureProvider.family<List<Deal>, String>((ref, restaurantId) async {
  final restaurant = await ref.watch(restaurantByIdProvider(restaurantId).future);
  if (restaurant == null) return [];

  final prefs = ref.watch(userPreferencesProvider);
  final engine = ref.watch(dealRecommendationEngineProvider);

  final deals = engine.generateDeals(
    restaurant,
    prefs.numberOfPeople,
    prefs.totalBudget,
  );

  return deals;
});

final actionableSuggestionsProvider = FutureProvider.family<List<ActionableSuggestion>, String>(
  (ref, restaurantId) async {
    final restaurant = await ref.watch(restaurantByIdProvider(restaurantId).future);
    final deal = ref.watch(selectedDealProvider);

    if (restaurant == null || deal == null) return [];

    final engine = ref.watch(suggestionEngineProvider);
    final suggestions = engine.generateActionableSuggestions(deal, restaurant);

    return suggestions;
  },
);

final selectedRestaurantProvider = StateProvider<String?>((ref) => null);