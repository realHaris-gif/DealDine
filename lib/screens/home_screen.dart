import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/models/restaurant.dart';
import '../core/providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/premium_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late TextEditingController _searchController;
  late TextEditingController _budgetController;
  late TextEditingController _peopleController;
  String _selectedCuisine = '';
  String _selectedCity = '';
  bool _showSearchDropdown = false;

  static const _peoplePresets = [1, 2, 3, 4, 5, 6, 8, 10];
  static const _budgetPresets = [1000, 2000, 3000, 5000, 8000, 10000];

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(userPreferencesProvider);
    _searchController = TextEditingController();
    _budgetController = TextEditingController(
      text: prefs.totalBudget.toStringAsFixed(0),
    );
    _peopleController = TextEditingController(
      text: '${prefs.numberOfPeople}',
    );
    _selectedCuisine = prefs.preferredCuisine;
    _selectedCity = prefs.preferredCity;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _budgetController.dispose();
    _peopleController.dispose();
    super.dispose();
  }

  void _syncPreferences({double? budget, int? people}) {
    final prefs = ref.read(userPreferencesProvider);
    ref.read(userPreferencesProvider.notifier).state = prefs.copyWith(
      totalBudget: budget ?? prefs.totalBudget,
      numberOfPeople: people ?? prefs.numberOfPeople,
      preferredCuisine: _selectedCuisine,
      preferredCity: _selectedCity,
    );
  }

  void _setPeople(int people) {
    final clamped = people.clamp(1, 50).toInt();
    _peopleController.text = '$clamped';
    _peopleController.selection = TextSelection.collapsed(offset: _peopleController.text.length);
    _syncPreferences(people: clamped);
  }

  void _setBudget(double amount) {
    final clamped = amount.clamp(0, 1000000).toDouble();
    _budgetController.text = clamped.toStringAsFixed(0);
    _budgetController.selection = TextSelection.collapsed(offset: _budgetController.text.length);
    _syncPreferences(budget: clamped);
  }

  /// Google-style relevance ranking for restaurant search.
  List<Restaurant> _searchRestaurants(List<Restaurant> restaurants) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return const [];

    final tokens = query.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    int score(Restaurant r) {
      final name = r.name.toLowerCase();
      final cuisine = r.cuisine.toLowerCase();
      final city = r.city.toLowerCase();
      final description = r.description.toLowerCase();
      var s = 0;

      if (name == query) {
        s += 1000;
      } else if (name.startsWith(query)) {
        s += 800;
      } else if (name.contains(query)) {
        s += 500;
      }

      if (cuisine == query || cuisine.startsWith(query)) {
        s += 300;
      } else if (cuisine.contains(query)) {
        s += 150;
      }

      if (city == query || city.startsWith(query)) {
        s += 200;
      } else if (city.contains(query)) {
        s += 100;
      }

      if (description.contains(query)) s += 40;

      for (final token in tokens) {
        if (name.contains(token)) s += 60;
        if (cuisine.contains(token)) s += 30;
        if (city.contains(token)) s += 25;
      }

      // Light boost for higher-rated / closer places when relevance is similar.
      s += (r.rating * 5).round();
      s += (20 - (r.distance * 2).clamp(0, 20)).round();

      if (_selectedCuisine.isNotEmpty && r.cuisine != _selectedCuisine) return -1;
      if (_selectedCity.isNotEmpty && r.city != _selectedCity) return -1;

      return s;
    }

    final scored = <({Restaurant r, int s})>[];
    for (final r in restaurants) {
      final s = score(r);
      if (s > 0) scored.add((r: r, s: s));
    }
    scored.sort((a, b) => b.s.compareTo(a.s));
    return scored.map((e) => e.r).take(10).toList();
  }

  List<Restaurant> _browseRestaurants(List<Restaurant> restaurants) {
    return restaurants.where((r) {
      final matchesCuisine =
          _selectedCuisine.isEmpty || r.cuisine == _selectedCuisine;
      final matchesCity = _selectedCity.isEmpty || r.city == _selectedCity;
      return matchesCuisine && matchesCity;
    }).toList()
      ..sort((a, b) {
        final rating = b.rating.compareTo(a.rating);
        if (rating != 0) return rating;
        return a.distance.compareTo(b.distance);
      });
  }

  @override
  Widget build(BuildContext context) {
    final cuisines = ref.watch(cuisinesProvider);
    final cities = ref.watch(citiesProvider);
    final prefs = ref.watch(userPreferencesProvider);
    final restaurantsAsync = ref.watch(restaurantsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() => _showSearchDropdown = false);
          },
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildGreeting(),
                  const SizedBox(height: 24),
                  _buildBudgetPeopleCard(prefs),
                  const SizedBox(height: 24),
                  _buildSearchSection(restaurantsAsync),
                  const SizedBox(height: 24),
                  _buildFiltersSection(cuisines, cities),
                  const SizedBox(height: 24),
                  _buildRestaurantList(restaurantsAsync),
                  const SizedBox(height: 24),
                  _buildStartButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find Your',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        Row(
          children: [
            Text(
              'Perfect ',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [AppTheme.primaryPurple, AppTheme.primaryDark],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                  ),
            ),
            Text(
              'Deal',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Save money on group food orders',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildBudgetPeopleCard(dynamic prefs) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget & Group',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Type a value or tap a quick option',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),

          // Budget — typeable only (no scroller)
          Text(
            'Total budget (Rs.)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _inputDecoration(
              prefixText: 'Rs. ',
              hintText: 'Type your budget, e.g. 3500',
            ),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryPurple,
                ),
            onChanged: (value) {
              final amount = double.tryParse(value);
              if (amount != null && amount >= 0) {
                _syncPreferences(budget: amount.clamp(0, 1000000).toDouble());
              }
            },
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _budgetPresets.map((amount) {
              final selected = (prefs.totalBudget as num).round() == amount;
              return _buildFilterButton(
                label: 'Rs. $amount',
                isSelected: selected,
                onTap: () => _setBudget(amount.toDouble()),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          const Divider(color: AppTheme.divider),
          const SizedBox(height: 16),

          // People — type OR select
          Text(
            'Number of people',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _peopleController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _inputDecoration(
                    hintText: 'Type number of people',
                    prefixIcon: Icons.group_rounded,
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  onChanged: (value) {
                    final people = int.tryParse(value);
                    if (people != null && people >= 1) {
                      _syncPreferences(people: people.clamp(1, 50).toInt());
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              _buildPeopleStepper(prefs.numberOfPeople as int),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _peoplePresets.map((n) {
              final selected = prefs.numberOfPeople == n;
              return _buildFilterButton(
                label: n == 1 ? '1 person' : '$n people',
                isSelected: selected,
                onTap: () => _setPeople(n),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            'Rs. ${prefs.getBudgetPerPerson().toStringAsFixed(0)} per person',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hintText,
    String? prefixText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
      prefixStyle: const TextStyle(
        color: AppTheme.primaryPurple,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.divider, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
      ),
      filled: true,
      fillColor: AppTheme.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildSearchSection(AsyncValue<List<Restaurant>> restaurantsAsync) {
    final matches = restaurantsAsync.maybeWhen(
      data: _searchRestaurants,
      orElse: () => <Restaurant>[],
    );
    final query = _searchController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search restaurants',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Type a name, cuisine, or city — results appear instantly',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(boxShadow: [AppTheme.cardShadow]),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search restaurants like Google…',
              prefixIcon: const Icon(Icons.search, size: 22),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _showSearchDropdown = false);
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppTheme.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppTheme.divider, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
              ),
              filled: true,
              fillColor: AppTheme.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            onChanged: (value) {
              setState(() {
                _showSearchDropdown = value.trim().isNotEmpty;
              });
            },
            onTap: () {
              if (_searchController.text.trim().isNotEmpty) {
                setState(() => _showSearchDropdown = true);
              }
            },
          ),
        ),
        if (_showSearchDropdown && query.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildSearchDropdown(matches, restaurantsAsync.isLoading, query),
        ],
      ],
    );
  }

  Widget _buildSearchDropdown(
    List<Restaurant> matches,
    bool isLoading,
    String query,
  ) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: AppTheme.surface,
      shadowColor: AppTheme.primaryPurple.withOpacity(0.18),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 340),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : matches.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.search_off_rounded, color: AppTheme.textSecondary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'No results for "$query". Try another name or cuisine.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 6),
                    itemCount: matches.length + 1,
                    separatorBuilder: (_, index) {
                      if (index == 0) return const SizedBox.shrink();
                      return const Divider(height: 1, color: AppTheme.divider);
                    },
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                          child: Text(
                            '${matches.length} result${matches.length == 1 ? '' : 's'} for "$query"',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryPurple,
                                ),
                          ),
                        );
                      }
                      final restaurant = matches[index - 1];
                      return _buildRestaurantTile(
                        restaurant,
                        query: query,
                        onTap: () {
                          _syncPreferences();
                          setState(() => _showSearchDropdown = false);
                          FocusScope.of(context).unfocus();
                          context.push('/restaurant-details?id=${restaurant.id}');
                        },
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildRestaurantTile(
    Restaurant restaurant, {
    String query = '',
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.lavender.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: AppTheme.primaryPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _highlightedText(
                    restaurant.name,
                    query,
                    Theme.of(context).textTheme.titleSmall!,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${restaurant.cuisine} · ${restaurant.city} · ${restaurant.distance.toStringAsFixed(1)} km',
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC107)),
                const SizedBox(width: 2),
                Text(
                  '${restaurant.rating}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Bold the matching portion of a restaurant name (Google-style).
  Widget _highlightedText(String text, String query, TextStyle baseStyle) {
    if (query.isEmpty) {
      return Text(text, style: baseStyle, maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    final lower = text.toLowerCase();
    final q = query.toLowerCase();
    final index = lower.indexOf(q);
    if (index < 0) {
      return Text(text, style: baseStyle, maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + q.length),
            style: baseStyle.copyWith(
              color: AppTheme.primaryPurple,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: text.substring(index + q.length)),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(
    AsyncValue<List<String>> cuisines,
    AsyncValue<List<String>> cities,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filters',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Choose any cuisine or city — updates the list below',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Text(
          'Cuisine',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 10),
        cuisines.when(
          data: (cuisineList) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterButton(
                label: 'Any Cuisine',
                isSelected: _selectedCuisine.isEmpty,
                onTap: () {
                  setState(() => _selectedCuisine = '');
                  _syncPreferences();
                },
              ),
              ...cuisineList.map(
                (cuisine) => _buildFilterButton(
                  label: cuisine,
                  isSelected: _selectedCuisine == cuisine,
                  onTap: () {
                    setState(() {
                      _selectedCuisine =
                          _selectedCuisine == cuisine ? '' : cuisine;
                    });
                    _syncPreferences();
                  },
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 20),
        Text(
          'City',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 10),
        cities.when(
          data: (cityList) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterButton(
                label: 'Any City',
                isSelected: _selectedCity.isEmpty,
                onTap: () {
                  setState(() => _selectedCity = '');
                  _syncPreferences();
                },
              ),
              ...cityList.map(
                (city) => _buildFilterButton(
                  label: city,
                  isSelected: _selectedCity == city,
                  onTap: () {
                    setState(() {
                      _selectedCity = _selectedCity == city ? '' : city;
                    });
                    _syncPreferences();
                  },
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildFilterButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryPurple : AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.primaryPurple : AppTheme.divider,
              width: 1.5,
            ),
            boxShadow: isSelected ? [AppTheme.cardShadow] : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  /// Full restaurant list for users who prefer browsing over search.
  Widget _buildRestaurantList(AsyncValue<List<Restaurant>> restaurantsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Browse restaurants',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'No need to search — pick from the list',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        restaurantsAsync.when(
          data: (restaurants) {
            final list = _browseRestaurants(restaurants);
            if (list.isEmpty) {
              return PremiumCard(
                child: Row(
                  children: [
                    const Icon(Icons.storefront_outlined, color: AppTheme.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No restaurants match your filters. Try “Any Cuisine”.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: [
                for (var i = 0; i < list.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _buildBrowseCard(list[i]),
                ],
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => Text(
            'Could not load restaurants',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildBrowseCard(Restaurant restaurant) {
    return PremiumCard(
      padding: const EdgeInsets.all(14),
      onTap: () {
        _syncPreferences();
        context.push('/restaurant-details?id=${restaurant.id}');
      },
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.lavender.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.restaurant_rounded, color: AppTheme.primaryPurple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${restaurant.cuisine} · ${restaurant.city}',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC107)),
                    const SizedBox(width: 2),
                    Text(
                      '${restaurant.rating}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.location_on_rounded, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 2),
                    Text(
                      '${restaurant.distance.toStringAsFixed(1)} km',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
        ],
      ),
    );
  }

  Widget _buildPeopleStepper(int people) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          _stepperButton(
            icon: Icons.remove_rounded,
            onTap: people > 1 ? () => _setPeople(people - 1) : null,
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$people',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          _stepperButton(
            icon: Icons.add_rounded,
            onTap: people < 50 ? () => _setPeople(people + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _stepperButton({required IconData icon, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 20,
            color: onTap == null ? AppTheme.divider : AppTheme.primaryPurple,
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return PremiumButton(
      label: 'Discover Deals',
      icon: Icons.arrow_forward_rounded,
      onPressed: () {
        _syncPreferences();
        context.push('/results');
      },
    );
  }
}
