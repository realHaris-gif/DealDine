import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/models/actionable_suggestion.dart';
import '../core/providers/app_providers.dart';
import '../core/providers/deal_providers.dart';
import '../core/services/deal_customization_engine.dart';
import '../widgets/actionable_suggestion_card.dart';
import '../widgets/deal_customization_card.dart';
import '../widgets/deal_summary.dart';
import '../widgets/menu_browser_dialog.dart';

class DealBuilderScreen extends ConsumerWidget {
  final String restaurantId;

  const DealBuilderScreen({Key? key, required this.restaurantId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantAsync = ref.watch(restaurantByIdProvider(restaurantId));
    final dealsAsync = ref.watch(dealsForRestaurantProvider(restaurantId));
    final suggestionsAsync = ref.watch(actionableSuggestionsProvider(restaurantId));
    final selectedDeal = ref.watch(selectedDealProvider);
    final appliedSuggestions = ref.watch(appliedSuggestionsProvider);
    final customEngine = ref.watch(dealCustomizationEngineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Your Deal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/results'),
        ),
      ),
      body: dealsAsync.when(
        data: (deals) {
          if (deals.isEmpty) return const Center(child: Text('No deals available'));

          return restaurantAsync.when(
            data: (restaurant) {
              if (restaurant == null) return const Center(child: Text('Restaurant not found'));

              final activeDeal = selectedDeal ?? deals.first;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Recommended Deals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: deals.length,
                        itemBuilder: (ctx, idx) {
                          final deal = deals[idx];
                          final isSelected = activeDeal.id == deal.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                ref.read(selectedDealProvider.notifier).state = deal;
                                ref.read(originalDealProvider.notifier).state = deal;
                                ref.read(appliedSuggestionsProvider.notifier).state = {};
                              },
                              child: Card(
                                color: isSelected ? const Color(0xFF6366F1) : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(deal.name, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? Colors.white : null)),
                                      const SizedBox(height: 4),
                                      Text('Rs.${deal.totalCost.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: isSelected ? Colors.white70 : Colors.grey)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    DealCustomizationCard(
                      deal: activeDeal,
                      onReset: () {
                        final original = ref.read(originalDealProvider);
                        if (original != null) {
                          ref.read(selectedDealProvider.notifier).state = original;
                          ref.read(appliedSuggestionsProvider.notifier).state = {};
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    DealSummary(deal: activeDeal),
                    const SizedBox(height: 24),
                    const Text('Smart Suggestions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    suggestionsAsync.when(
                      data: (suggestions) {
                        if (suggestions.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: const Text('Perfect deal! No suggestions needed.'),
                          );
                        }

                        return Column(
                          children: suggestions.map((suggestion) {
                            final isApplied = appliedSuggestions.contains(suggestion.id);
                            final targetItem = suggestion.targetItemName != null
                                ? restaurant.menu.firstWhere((m) => m.name == suggestion.targetItemName, orElse: () => null as dynamic)
                                : null;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ActionableSuggestionCard(
                                suggestion: suggestion,
                                isApplied: isApplied,
                                onApply: () {
                                  final updated = customEngine.applySuggestion(activeDeal, suggestion, targetItem);
                                  ref.read(selectedDealProvider.notifier).state = updated;
                                  ref.read(appliedSuggestionsProvider.notifier).state = {...appliedSuggestions, suggestion.id};
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, st) => Text('Error: $err'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => MenuBrowserDialog(
                                  restaurant: restaurant,
                                  deal: activeDeal,
                                  onAddItem: (updatedDeal) {
                                    ref.read(selectedDealProvider.notifier).state = updatedDeal;
                                  },
                                ),
                              );
                            },
                            icon: const Icon(Icons.restaurant_menu),
                            label: const Text('Browse Menu'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Deal confirmed! Total: Rs.${activeDeal.totalCost.toStringAsFixed(0)}')),
                              );
                            },
                            child: const Text('Confirm Deal'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(child: Text('Error: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}