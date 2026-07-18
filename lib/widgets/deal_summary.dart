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

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Deal Summary', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          _SummaryRow(
            label: 'Total Items',
            value: deal.itemCount.toString(),
            context: context,
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: 'Total Quantity',
            value: deal.items.fold(0, (sum, item) => sum + item.quantity).toString(),
            context: context,
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: 'Total Cost',
            value: 'Rs.${deal.totalCost.toStringAsFixed(0)}',
            context: context,
            highlight: true,
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: 'Remaining Budget',
            value: 'Rs.${deal.remainingBudget.toStringAsFixed(0)}',
            context: context,
            color: const Color(0xFF22C55E),
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: 'Cost Per Person',
            value: 'Rs.${avgPerPerson.toStringAsFixed(0)}',
            context: context,
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: 'Avg Items Per Person',
            value: itemsPerPerson.toStringAsFixed(1),
            context: context,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final BuildContext context;
  final bool highlight;
  final Color? color;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.context,
    this.highlight = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: highlight
              ? Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFFD62828),
              )
              : Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
              ),
        ),
      ],
    );
  }
}