import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/models/actionable_suggestion.dart';
import '../core/models/menu_item.dart';
import '../core/models/restaurant.dart';
import '../core/providers/app_providers.dart';
import '../core/providers/deal_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/actionable_suggestion_card.dart';
import '../widgets/custom_button.dart';
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

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text(
          'Build Your Deal',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: restaurantAsync.when(
        data: (restaurant) {
          if (restaurant == null) {
            return Center(
              child: Text('Restaurant not found', style: Theme.of(context).textTheme.bodyLarge),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRestaurantHeader(context, restaurant),
                  const SizedBox(height: 32),
                  dealsAsync.when(
                    data: (deals) => _buildDealsSection(context, ref, deals, selectedDeal),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  if (selectedDeal != null) ...[
                    const SizedBox(height: 32),
                    _buildCustomizationSection(context, ref, restaurant, selectedDeal),
                    const SizedBox(height: 32),
                    DealSummary(deal: selectedDeal),
                    const SizedBox(height: 32),
                    suggestionsAsync.when(
                      data: (suggestions) => _buildSuggestionsSection(
                        context,
                        ref,
                        restaurant,
                        suggestions,
                        appliedSuggestions,
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 32),
                    _buildActionButtons(context, ref, restaurant, selectedDeal),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildRestaurantHeader(BuildContext context, dynamic restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          restaurant.name,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.star_rounded, size: 18, color: const Color(0xFFFFC107)),
            const SizedBox(width: 4),
            Text(
              '${restaurant.rating}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 16),
            Icon(Icons.location_on_rounded, size: 18, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(
              '${restaurant.distance.toStringAsFixed(1)} km',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDealsSection(BuildContext context, WidgetRef ref, List<dynamic> deals, dynamic selectedDeal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select a Deal Type',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: deals.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final deal = deals[index];
              final isSelected = selectedDeal?.id == deal.id;

              return GestureDetector(
                onTap: () {
                  ref.read(selectedDealProvider.notifier).state = deal;
                  ref.read(originalDealProvider.notifier).state = deal;
                  ref.read(appliedSuggestionsProvider.notifier).state = {};
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 140,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryPurple : AppTheme.surface,
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryPurple : AppTheme.divider,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isSelected ? [AppTheme.buttonShadow] : [AppTheme.cardShadow],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getIconForDealType(deal.type),
                          size: 32,
                          color: isSelected ? Colors.white : AppTheme.primaryPurple,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          deal.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rs.${deal.totalCost.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppTheme.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomizationSection(BuildContext context, WidgetRef ref, dynamic restaurant, dynamic activeDeal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customize Your Deal',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
        PremiumButton(
          label: 'Browse Full Menu',
          icon: Icons.restaurant_menu,
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
        ),
      ],
    );
  }

  Widget _buildSuggestionsSection(
    BuildContext context,
    WidgetRef ref,
    Restaurant restaurant,
    List<ActionableSuggestion> suggestions,
    Set<String> appliedSuggestions,
  ) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Smart Suggestions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: suggestions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final suggestion = suggestions[index];
            final isApplied = appliedSuggestions.contains(suggestion.id);

            return ActionableSuggestionCard(
              suggestion: suggestion,
              isApplied: isApplied,
              onApply: () {
                final deal = ref.read(selectedDealProvider);
                if (deal != null) {
                  final customEngine = ref.read(dealCustomizationEngineProvider);
                  final targetName = suggestion.targetItemName ?? suggestion.itemName;
                  MenuItem? targetItem;
                  for (final item in restaurant.menu) {
                    if (item.name == targetName) {
                      targetItem = item;
                      break;
                    }
                  }
                  final updatedDeal = customEngine.applySuggestion(
                    deal,
                    suggestion,
                    targetItem,
                  );
                  ref.read(selectedDealProvider.notifier).state = updatedDeal;
                  ref.read(appliedSuggestionsProvider.notifier).state = {
                    ...appliedSuggestions,
                    suggestion.id,
                  };
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, dynamic restaurant, dynamic activeDeal) {
    return Column(
      children: [
        PremiumButton(
          label: 'Confirm Deal',
          icon: Icons.check_rounded,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Deal confirmed! Total: Rs.${activeDeal.totalCost.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: AppTheme.primaryPurple,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => context.pop(),
          child: const Text('Choose Different Restaurant'),
        ),
      ],
    );
  }

  IconData _getIconForDealType(dynamic type) {
    final typeStr = type.toString();
    if (typeStr.contains('value')) return Icons.local_offer_rounded;
    if (typeStr.contains('filling')) return Icons.fastfood_rounded;
    if (typeStr.contains('premium')) return Icons.workspace_premium_rounded;
    return Icons.shopping_cart_rounded;
  }
}