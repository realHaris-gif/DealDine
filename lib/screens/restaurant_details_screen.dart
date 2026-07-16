import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/models/menu_item.dart';
import '../core/providers/app_providers.dart';

class RestaurantDetailsScreen extends ConsumerWidget {
  final String id;

  const RestaurantDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurant = ref.watch(restaurantByIdProvider(id));
    final prefs = ref.watch(userPreferencesProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onSurface = colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/results'),
        ),
      ),
      body: restaurant.when(
        data: (r) {
          if (r == null) {
            return Center(
              child: Text(
                'Restaurant not found',
                style: theme.textTheme.bodyLarge?.copyWith(color: onSurface),
              ),
            );
          }

          final budgetPerPerson = prefs.totalBudget / prefs.numberOfPeople;
          final grouped = <String, List<MenuItem>>{};
          for (final item in r.menu) {
            grouped.putIfAbsent(item.category, () => []).add(item);
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 180,
                  color: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.restaurant,
                    size: 80,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (r.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          r.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _Meta(
                            icon: Icons.star,
                            iconColor: Colors.amber,
                            label: '${r.rating}',
                            textColor: onSurface,
                          ),
                          _Meta(
                            icon: Icons.location_on_outlined,
                            label: '${r.distance} km',
                            textColor: onSurface,
                          ),
                          _Meta(
                            icon: Icons.location_city_outlined,
                            label: r.city,
                            textColor: onSurface,
                          ),
                          _Meta(
                            icon: Icons.local_dining_outlined,
                            label: r.cuisine,
                            textColor: onSurface,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Menu',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Avg per person: Rs ${r.getAverageMealCost().toStringAsFixed(0)}'
                        ' · Your budget: Rs ${budgetPerPerson.toStringAsFixed(0)} / person',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...grouped.entries.map((entry) {
                        final category = entry.key;
                        final items = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...items.map((item) {
                              final inBudget =
                                  item.price <= budgetPerPerson * 1.5;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: colorScheme.surface,
                                child: ListTile(
                                  title: Text(
                                    item.name,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    inBudget ? 'Within budget' : 'Above budget',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: inBudget
                                          ? colorScheme.secondary
                                          : colorScheme.error.withValues(
                                              alpha: 0.85,
                                            ),
                                    ),
                                  ),
                                  trailing: Text(
                                    'Rs ${item.price.toStringAsFixed(0)}',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 12),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(
          child: Text(
            'Error: $err',
            style: theme.textTheme.bodyLarge?.copyWith(color: onSurface),
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color textColor;
  final Color? iconColor;

  const _Meta({
    required this.icon,
    required this.label,
    required this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: iconColor ?? textColor.withValues(alpha: 0.8)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
