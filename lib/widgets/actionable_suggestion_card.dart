import 'package:flutter/material.dart';
import '../core/models/actionable_suggestion.dart';

class ActionableSuggestionCard extends StatefulWidget {
  final ActionableSuggestion suggestion;
  final VoidCallback onApply;
  final bool isApplied;

  const ActionableSuggestionCard({
    Key? key,
    required this.suggestion,
    required this.onApply,
    required this.isApplied,
  }) : super(key: key);

  @override
  State<ActionableSuggestionCard> createState() => _ActionableSuggestionCardState();
}

class _ActionableSuggestionCardState extends State<ActionableSuggestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onApplyPressed() {
    widget.onApply();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final impact = widget.suggestion.budgetImpact;
    final impactColor = impact > 0 ? const Color(0xFFD62828) : const Color(0xFF22C55E);
    final impactSign = impact > 0 ? '+' : '';

    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedOpacity(
        opacity: widget.isApplied ? 0.5 : 1,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.suggestion.text,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.suggestion.reason,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: impactColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$impactSign Rs.${impact.abs().toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: impactColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.isApplied ? null : _onApplyPressed,
                  child: Text(widget.isApplied ? 'Applied' : 'Apply'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}