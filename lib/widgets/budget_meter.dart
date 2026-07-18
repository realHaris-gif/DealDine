import 'package:flutter/material.dart';
import '../core/models/deal.dart';
import '../core/services/budget_calculator.dart';

class BudgetMeter extends StatelessWidget {
  final Deal deal;

  const BudgetMeter({Key? key, required this.deal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calc = BudgetCalculator();
    final result = calc.calculate(deal);
    
    Color getIndicatorColor(double util) {
      if (util < 80) return const Color(0xFF22C55E);
      if (util < 95) return const Color(0xFFF59E0B);
      return const Color(0xFFD62828);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Budget Used', style: Theme.of(context).textTheme.labelMedium),
            Text(
              '${result.utilization.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: getIndicatorColor(result.utilization),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (result.utilization / 100).clamp(0, 1),
            minHeight: 6,
            backgroundColor: const Color(0xFFE5E5E5),
            valueColor: AlwaysStoppedAnimation<Color>(getIndicatorColor(result.utilization)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Spent', style: Theme.of(context).textTheme.bodySmall),
                Text(
                  'Rs.${result.totalCost.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Remaining', style: Theme.of(context).textTheme.bodySmall),
                Text(
                  'Rs.${result.remainingBudget.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF22C55E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}