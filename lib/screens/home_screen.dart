import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/app_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _peopleController;
  late final TextEditingController _budgetController;

  static const List<int> _peoplePresets = [1, 2, 3, 4, 5, 6, 8, 10];

  static const List<int> _budgetPresets = [
    1000,
    2000,
    3000,
    5000,
    8000,
    10000,
    15000,
    20000,
  ];

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(userPreferencesProvider);
    _peopleController = TextEditingController(
      text: prefs.numberOfPeople.toString(),
    );
    _budgetController = TextEditingController(
      text: prefs.totalBudget.round().toString(),
    );
  }

  @override
  void dispose() {
    _peopleController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _setPeople(int count) {
    final clamped = count.clamp(1, 50);
    ref.read(userPreferencesProvider.notifier).state =
        ref.read(userPreferencesProvider).copyWith(numberOfPeople: clamped);
    _peopleController.text = clamped.toString();
    _peopleController.selection = TextSelection.collapsed(
      offset: _peopleController.text.length,
    );
  }

  void _onPeopleTextChanged(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return;
    final parsed = int.tryParse(cleaned);
    if (parsed == null) return;
    ref.read(userPreferencesProvider.notifier).state =
        ref.read(userPreferencesProvider).copyWith(
              numberOfPeople: parsed.clamp(1, 50),
            );
  }

  void _setBudget(double amount) {
    final clamped = amount.clamp(100, 1000000).toDouble();
    ref.read(userPreferencesProvider.notifier).state =
        ref.read(userPreferencesProvider).copyWith(totalBudget: clamped);
    _budgetController.text = clamped.round().toString();
    _budgetController.selection = TextSelection.collapsed(
      offset: _budgetController.text.length,
    );
  }

  void _onBudgetTextChanged(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return;
    final parsed = double.tryParse(cleaned);
    if (parsed == null) return;
    ref.read(userPreferencesProvider.notifier).state =
        ref.read(userPreferencesProvider).copyWith(
              totalBudget: parsed.clamp(100, 1000000).toDouble(),
            );
  }

  void _commitFieldsBeforeSearch() {
    final peopleCleaned =
        _peopleController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final peopleParsed = int.tryParse(peopleCleaned);
    if (peopleParsed != null) {
      _setPeople(peopleParsed);
    } else {
      _setPeople(ref.read(userPreferencesProvider).numberOfPeople);
    }

    final budgetCleaned =
        _budgetController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final budgetParsed = double.tryParse(budgetCleaned);
    if (budgetParsed != null) {
      _setBudget(budgetParsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefs = ref.watch(userPreferencesProvider);
    final cities = ref.watch(citiesProvider);
    final cuisines = ref.watch(cuisinesProvider);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('DealDine')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find the best restaurant deals',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),

            // ---- People ----
            Text(
              'How many people?',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _peopleController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.group_outlined),
                hintText: 'e.g. 4',
                helperText: prefs.numberOfPeople == 1
                    ? '1 person'
                    : '${prefs.numberOfPeople} people',
                helperStyle: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              onChanged: _onPeopleTextChanged,
              onSubmitted: (value) {
                final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
                final parsed = int.tryParse(cleaned);
                if (parsed != null) {
                  _setPeople(parsed);
                } else {
                  _setPeople(1);
                }
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Quick picks',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _peoplePresets.map((count) {
                final selected = prefs.numberOfPeople == count;
                return ChoiceChip(
                  label: Text(count == 1 ? '1' : '$count'),
                  selected: selected,
                  onSelected: (_) => _setPeople(count),
                  selectedColor: colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: selected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // ---- Budget ----
            Text(
              'Total budget (PKR)',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(7),
              ],
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.payments_outlined),
                prefixText: 'Rs  ',
                hintText: 'e.g. 3000',
                helperText:
                    'About Rs ${(prefs.totalBudget / prefs.numberOfPeople).round()} per person',
                helperStyle: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              onChanged: _onBudgetTextChanged,
              onSubmitted: (value) {
                final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
                final parsed = double.tryParse(cleaned);
                if (parsed != null) _setBudget(parsed);
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Quick amounts',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _budgetPresets.map((amount) {
                final selected = prefs.totalBudget.round() == amount;
                return ChoiceChip(
                  label: Text('Rs $amount'),
                  selected: selected,
                  onSelected: (_) => _setBudget(amount.toDouble()),
                  selectedColor: colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: selected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // ---- Cuisine ----
            Text(
              'Cuisine (optional)',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            cuisines.when(
              data: (data) => InputDecorator(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.restaurant),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: prefs.preferredCuisine.isEmpty
                        ? ''
                        : prefs.preferredCuisine,
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Any cuisine'),
                      ),
                      ...data.map(
                        (c) => DropdownMenuItem(value: c, child: Text(c)),
                      ),
                    ],
                    onChanged: (val) =>
                        ref.read(userPreferencesProvider.notifier).state =
                            prefs.copyWith(preferredCuisine: val ?? ''),
                  ),
                ),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, st) => Text(
                'Error: $err',
                style: TextStyle(color: colorScheme.error),
              ),
            ),

            const SizedBox(height: 28),

            // ---- City ----
            Text(
              'City (optional)',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            cities.when(
              data: (data) => InputDecorator(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.location_city),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: prefs.preferredCity.isEmpty
                        ? ''
                        : prefs.preferredCity,
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Any city'),
                      ),
                      ...data.map(
                        (c) => DropdownMenuItem(value: c, child: Text(c)),
                      ),
                    ],
                    onChanged: (val) =>
                        ref.read(userPreferencesProvider.notifier).state =
                            prefs.copyWith(preferredCity: val ?? ''),
                  ),
                ),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, st) => Text(
                'Error: $err',
                style: TextStyle(color: colorScheme.error),
              ),
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _commitFieldsBeforeSearch();
                  context.go('/results');
                },
                child: const Text(
                  'Find best deals',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
