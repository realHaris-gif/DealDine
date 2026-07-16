/// UserPreferences represents the criteria selected by the user
/// for finding restaurant recommendations.
/// 
/// This model captures all the user's selections on the home screen
/// and is passed to the recommendation engine for filtering and scoring.
class UserPreferences {
  /// Number of people the meal is for
  final int numberOfPeople;
  
  /// Total budget in PKR for all people
  final double totalBudget;
  
  /// Preferred cuisine type (nullable - empty string means no preference)
  final String preferredCuisine;
  
  /// Preferred city (nullable - empty string means no preference)
  final String preferredCity;

  /// Creates a UserPreferences instance.
  /// 
  /// All parameters are required.
  UserPreferences({
    required this.numberOfPeople,
    required this.totalBudget,
    required this.preferredCuisine,
    required this.preferredCity,
  });

  /// Calculates the budget per person.
  /// 
  /// This is used by the recommendation algorithm to match restaurants
  /// against user budget constraints.
  double getBudgetPerPerson() {
    if (numberOfPeople <= 0) return totalBudget;
    return totalBudget / numberOfPeople;
  }

  /// Returns whether a cuisine preference is specified.
  bool hasCuisinePreference() {
    return preferredCuisine.isNotEmpty;
  }

  /// Returns whether a city preference is specified.
  bool hasCityPreference() {
    return preferredCity.isNotEmpty;
  }

  /// Creates a copy of this UserPreferences with the specified fields replaced.
  /// 
  /// Useful for updating preferences without creating a new instance.
  UserPreferences copyWith({
    int? numberOfPeople,
    double? totalBudget,
    String? preferredCuisine,
    String? preferredCity,
  }) {
    return UserPreferences(
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      totalBudget: totalBudget ?? this.totalBudget,
      preferredCuisine: preferredCuisine ?? this.preferredCuisine,
      preferredCity: preferredCity ?? this.preferredCity,
    );
  }

  @override
  String toString() {
    return 'UserPreferences(people: $numberOfPeople, budget: $totalBudget, cuisine: $preferredCuisine, city: $preferredCity)';
  }
}