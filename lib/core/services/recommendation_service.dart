import '../models/restaurant.dart';
import '../models/user_preferences.dart';

class RecommendationService {
  List<Restaurant> filterAndScore(
    List<Restaurant> restaurants,
    UserPreferences prefs,
  ) {
    final budgetPerPerson = prefs.totalBudget / prefs.numberOfPeople;
    
    var filtered = restaurants.where((r) {
      if (prefs.preferredCity.isNotEmpty && r.city != prefs.preferredCity) {
        return false;
      }
      if (prefs.preferredCuisine.isNotEmpty && r.cuisine != prefs.preferredCuisine) {
        return false;
      }
      return true;
    }).toList();

    for (var r in filtered) {
      final avgCost = r.getAverageMealCost();
      final costDiff = (avgCost - budgetPerPerson).abs();
      final costScore = 100 - (costDiff / budgetPerPerson * 100).clamp(0, 100);
      
      final ratingScore = r.rating * 20; // 0-5 → 0-100
      final distanceScore = 100 - ((r.distance / 5) * 100).clamp(0, 100); // max 5km
      
      final score = (costScore * 0.5) + (ratingScore * 0.3) + (distanceScore * 0.2);
      r.matchScore = score;
    }

    filtered.sort((a, b) => (b.matchScore ?? 0).compareTo(a.matchScore ?? 0));
    return filtered.take(5).toList();
  }
}