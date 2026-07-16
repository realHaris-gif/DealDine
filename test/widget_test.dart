import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dealdine/main.dart';

void main() {
  testWidgets('DealDine smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DealDineApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}