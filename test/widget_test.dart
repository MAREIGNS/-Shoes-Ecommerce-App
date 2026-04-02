import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoescomm/main.dart';

void main() {
  testWidgets('MyApp builds without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
