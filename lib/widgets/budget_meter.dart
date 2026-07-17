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
    final (r, g, b) = calc.getColorForUtilization(result.utilization);
    final color = Color.fromARGB(255, r, g, b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Budget Used', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (result.utilization / 100).clamp(0, 1),
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rs.${result.totalCost.toStringAsFixed(0)} / Rs.${deal.totalBudget.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${result.utilization.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Remaining: Rs.${result.remainingBudget.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
