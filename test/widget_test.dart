import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foodsaver_flutter/main.dart';

void main() {
  testWidgets('FoodSaver shell smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PagkaingLigtasApp());

    // Verify that our app bar title is present
    expect(find.text('FOODSAVER'), findsOneWidget);
    
    // Verify that the Feed tab is selected by default
    expect(find.text('Feed'), findsOneWidget);
  });
}

