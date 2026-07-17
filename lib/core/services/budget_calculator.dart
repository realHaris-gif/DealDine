import '../models/deal.dart';

class BudgetCalculator {
  BudgetResult calculate(Deal deal) {
    final totalCost = deal.totalCost;
    final remainingBudget = deal.remainingBudget;
    final costPerPerson = deal.costPerPerson;
    final utilization = deal.budgetUtilization;

    return BudgetResult(
      totalCost: totalCost,
      remainingBudget: remainingBudget,
      costPerPerson: costPerPerson,
      utilization: utilization,
      isWithinBudget: deal.isWithinBudget,
    );
  }

  String getStatus(BudgetResult result) {
    if (result.utilization >= 95) return 'Optimal';
    if (result.utilization >= 80) return 'Good';
    if (result.utilization >= 60) return 'Fair';
    return 'Low';
  }

  (int red, int green, int blue) getColorForUtilization(double utilization) {
    if (utilization < 90) return (76, 175, 80);
    if (utilization < 100) return (255, 152, 0);
    return (244, 67, 54);
  }
}

class BudgetResult {
  final double totalCost;
  final double remainingBudget;
  final double costPerPerson;
  final double utilization;
  final bool isWithinBudget;

  BudgetResult({
    required this.totalCost,
    required this.remainingBudget,
    required this.costPerPerson,
    required this.utilization,
    required this.isWithinBudget,
  });
}
