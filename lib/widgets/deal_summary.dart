import 'package:flutter/material.dart';
import '../core/models/deal.dart';

class DealSummary extends StatelessWidget {
  final Deal deal;

  const DealSummary({Key? key, required this.deal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avgPerPerson = deal.costPerPerson;
    final itemsPerPerson = deal.itemCount / deal.numberOfPeople;
    final savings = deal.totalBudget - deal.totalCost;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deal Summary', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _SummaryRow('Total Items', deal.itemCount.toString()),
            _SummaryRow('Total Quantity', deal.items.fold(0, (sum, item) => sum + item.quantity).toString()),
            _SummaryRow('Total Cost', 'Rs.${deal.totalCost.toStringAsFixed(0)}'),
            _SummaryRow('Remaining Budget', 'Rs.${deal.remainingBudget.toStringAsFixed(0)}'),
            _SummaryRow('Savings', 'Rs.${savings.toStringAsFixed(0)}'),
            _SummaryRow('Cost Per Person', 'Rs.${avgPerPerson.toStringAsFixed(0)}'),
            _SummaryRow('Avg Items Per Person', itemsPerPerson.toStringAsFixed(1)),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
