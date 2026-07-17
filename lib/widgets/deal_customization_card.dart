import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/deal.dart';
import '../core/providers/deal_providers.dart';
import '../core/services/deal_customization_engine.dart';
import 'budget_meter.dart';

class DealCustomizationCard extends ConsumerWidget {
  final Deal deal;
  final VoidCallback onReset;

  const DealCustomizationCard({
    Key? key,
    required this.deal,
    required this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customEngine = ref.watch(dealCustomizationEngineProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(deal.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(deal.description, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(deal.dealScore ?? 0).toStringAsFixed(0)}/100',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BudgetMeter(deal: deal),
            const SizedBox(height: 20),
            Text('Items', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...deal.items.map((dealItem) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dealItem.item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text('Rs.${dealItem.item.price}', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            final updated = customEngine.decreaseQuantity(deal, dealItem.item.name);
                            ref.read(selectedDealProvider.notifier).state = updated;
                          },
                          icon: const Icon(Icons.remove),
                          constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                        ),
                        SizedBox(
                          width: 30,
                          child: Center(
                            child: Text(
                              '${dealItem.quantity}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            final (canAdd, msg) = customEngine.canAddItem(deal, dealItem.item);
                            if (canAdd) {
                              final updated = customEngine.increaseQuantity(deal, dealItem.item.name);
                              ref.read(selectedDealProvider.notifier).state = updated;
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(msg ?? 'Budget exceeded')),
                              );
                            }
                          },
                          icon: const Icon(Icons.add),
                          constraints: const BoxConstraints.tightFor(width: 40, height: 40),
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
                Text(
                  'Rs.${deal.costPerPerson.toStringAsFixed(0)}/person',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
