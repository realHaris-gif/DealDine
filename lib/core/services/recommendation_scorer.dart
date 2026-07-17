import '../models/deal.dart';
import '../models/menu_item.dart';

class RecommendationScorer {
  double scoreItem(MenuItem item, Deal deal, int numberOfPeople) {
    double score = 0;

    if (deal.totalCost + item.price > deal.totalBudget) return -999;

    final mainCount = deal.items.where((di) => _isMain(di.item)).length;
    if (_isMain(item) && mainCount < numberOfPeople) score += 40;
    else if (_isMain(item)) score += 25;

    final priceRatio = 100 / item.price;
    score += (priceRatio.clamp(0, 10) / 10) * 20;

    final category = item.category.toLowerCase();
    final hasDrink = deal.items.any((di) => di.item.category.toLowerCase().contains('drink'));
    final hasFood = deal.items.any((di) => !di.item.category.toLowerCase().contains('drink'));

    if (category.contains('drink') && !hasDrink && hasFood) score += 15;
    else if (!category.contains('drink') && category.contains('side') && numberOfPeople > deal.items.length) score += 12;

    final isDuplicate = deal.items.any((di) => di.item.name == item.name);
    if (!isDuplicate) score += 8;

    final utilAfterAdd = ((deal.totalCost + item.price) / deal.totalBudget * 100);
    if (utilAfterAdd >= 90 && utilAfterAdd <= 100) score += 10;
    else if (utilAfterAdd < 90) score += 5;

    return score;
  }

  String explainScore(MenuItem item, Deal deal, int numberOfPeople) {
    if (deal.totalCost + item.price > deal.totalBudget) {
      return 'Exceeds budget';
    }

    final reasons = <String>[];
    final mainCount = deal.items.where((di) => _isMain(di.item)).length;

    if (_isMain(item) && mainCount < numberOfPeople) {
      reasons.add('Feeds someone new');
    }

    final isDuplicate = deal.items.any((di) => di.item.name == item.name);
    if (!isDuplicate) {
      reasons.add('Adds variety');
    }

    final category = item.category.toLowerCase();
    if (category.contains('drink') && !deal.items.any((di) => di.item.category.toLowerCase().contains('drink'))) {
      reasons.add('Includes drinks');
    }

    final utilAfterAdd = ((deal.totalCost + item.price) / deal.totalBudget * 100);
    if (utilAfterAdd >= 90 && utilAfterAdd <= 100) {
      reasons.add('Maximizes budget');
    }

    return reasons.isNotEmpty ? reasons.join(' • ') : 'Good addition';
  }

  bool _isMain(MenuItem item) {
    final cat = item.category.toLowerCase();
    return cat.contains('main') || cat.contains('burger') || cat.contains('pizza') || cat.contains('biryani') || cat.contains('sandwich');
  }
}
