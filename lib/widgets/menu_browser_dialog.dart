import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/deal.dart';
import '../core/models/menu_item.dart';
import '../core/models/restaurant.dart';
import '../core/services/deal_customization_engine.dart';
import '../core/services/recommendation_scorer.dart';

class MenuBrowserDialog extends ConsumerStatefulWidget {
  final Restaurant restaurant;
  final Deal deal;
  final Function(Deal) onAddItem;

  const MenuBrowserDialog({
    Key? key,
    required this.restaurant,
    required this.deal,
    required this.onAddItem,
  }) : super(key: key);

  @override
  ConsumerState<MenuBrowserDialog> createState() => _MenuBrowserDialogState();
}

class _MenuBrowserDialogState extends ConsumerState<MenuBrowserDialog> {
  final Map<String, int> _quantities = {};
  late RecommendationScorer _scorer;

  @override
  void initState() {
    super.initState();
    _scorer = RecommendationScorer();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<MenuItem>>{};
    for (var item in widget.restaurant.menu) {
      if (!grouped.containsKey(item.category)) grouped[item.category] = [];
      grouped[item.category]!.add(item);
    }

    return Dialog(
      backgroundColor: const Color(0xFF0A0A0A),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Add Items', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
          ),
          Expanded(
            child: ListView(
              children: grouped.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.key, style: const TextStyle(fontSize: 12, color: Color(0xFFCCFF00), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      ...e.value.map((item) {
                        final qty = _quantities[item.name] ?? 0;
                        final wouldExceed = widget.deal.totalCost + (item.price * (qty + 1)) > widget.deal.totalBudget;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: const TextStyle(fontSize: 13, color: Colors.white)),
                                    Text('Rs.${item.price}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  if (qty > 0)
                                    GestureDetector(
                                      onTap: () => setState(() => _quantities[item.name] = qty - 1),
                                      child: const Icon(Icons.remove, size: 16, color: Color(0xFFCCFF00)),
                                    ),
                                  if (qty > 0) Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('$qty', style: const TextStyle(color: Colors.white))),
                                  GestureDetector(
                                    onTap: () => _handleAdd(item),
                                    child: Icon(Icons.add, size: 16, color: wouldExceed ? Colors.red : const Color(0xFFCCFF00)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const Divider(color: Colors.grey),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _quantities.isEmpty ? null : _addAllItems,
                child: const Text('Add to Deal'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAdd(MenuItem item) {
    final wouldExceed = widget.deal.totalCost + item.price > widget.deal.totalBudget;
    if (wouldExceed) {
      _showBudgetWarning(item);
    } else {
      setState(() => _quantities[item.name] = (_quantities[item.name] ?? 0) + 1);
    }
  }

  void _showBudgetWarning(MenuItem item) {
    final exceeded = (widget.deal.totalCost + item.price) - widget.deal.totalBudget;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text('Budget Warning', style: TextStyle(color: Color(0xFFCCFF00))),
        content: Text(
          'This item will exceed your remaining budget by Rs.${exceeded.toStringAsFixed(0)}. Add anyway?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() => _quantities[item.name] = (_quantities[item.name] ?? 0) + 1);
              Navigator.pop(ctx);
            },
            child: const Text('Add Anyway'),
          ),
        ],
      ),
    );
  }

  void _addAllItems() {
    final customEngine = ref.read(DealCustomizationEngineProvider);
    var updatedDeal = widget.deal;

    for (var entry in _quantities.entries) {
      if (entry.value > 0) {
        final item = widget.restaurant.menu.firstWhere((m) => m.name == entry.key);
        for (int i = 0; i < entry.value; i++) {
          updatedDeal = customEngine.addItem(updatedDeal, item);
        }
      }
    }

    widget.onAddItem(updatedDeal);
    Navigator.pop(context);
  }
}

final DealCustomizationEngineProvider = Provider((ref) => DealCustomizationEngine());