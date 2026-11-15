import 'package:clinicops/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login screen shows and signs in to the dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(const ClinicOpsApp());

    expect(find.text('ClinicOps'), findsOneWidget);
    expect(find.text('Klinik Naluri'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.textContaining('Good morning'), findsOneWidget);
  });
}
