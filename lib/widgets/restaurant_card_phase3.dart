import 'package:flutter/material.dart';
import '../core/models/restaurant.dart';

class RestaurantCardV2 extends StatelessWidget {
  final Restaurant restaurant;
  final int numberOfPeople;
  final VoidCallback onTap;

  const RestaurantCardV2({
    Key? key,
    required this.restaurant,
    required this.numberOfPeople,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avgCost = restaurant.getAverageMealCost();
    final totalCost = avgCost * numberOfPeople;
    final matchPercent = ((restaurant.matchScore ?? 0) / 100 * 100).toStringAsFixed(0);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          restaurant.cuisine,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$matchPercent%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text('${restaurant.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 16),
                  Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  Text('${restaurant.distance} km', style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 16),
                  Icon(Icons.location_city, size: 16),
                  const SizedBox(width: 4),
                  Text(restaurant.city, style: const TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Avg per person', style: Theme.of(context).textTheme.bodySmall),
                      Text(
                        'Rs ${avgCost.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Total ($numberOfPeople people)', style: Theme.of(context).textTheme.bodySmall),
                      Text(
                        'Rs ${totalCost.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
