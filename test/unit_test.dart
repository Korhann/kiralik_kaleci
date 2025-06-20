import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiralik_kaleci/selleraddpage.dart';

void main() {
  group('PriceField Validator', () {
    testWidgets('Empty price returns error', (WidgetTester tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: priceField(controller: controller),
        ),
      ));

      // Try to validate with empty value
      final formField = find.byType(TextFormField);
      expect(formField, findsOneWidget);

      // Simulate validation
      final state = tester.firstState<FormFieldState<String>>(formField);
      expect(state.widget.validator?.call(''), "Fiyat bilgisi girmelisiniz!");
    });

    testWidgets('Non-numeric price returns error', (WidgetTester tester) async {
      final controller = TextEditingController(text: 'abc');
      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: priceField(controller: controller),
        ),
      ));

      final formField = find.byType(TextFormField);
      final state = tester.firstState<FormFieldState<String>>(formField);
      expect(state.widget.validator?.call('abc'), 'Fiyat bilgisi girmelisiniz');
    });

    testWidgets('Price below 250 returns error', (WidgetTester tester) async {
      final controller = TextEditingController(text: '200');
      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: priceField(controller: controller),
        ),
      ));

      final formField = find.byType(TextFormField);
      final state = tester.firstState<FormFieldState<String>>(formField);
      expect(state.widget.validator?.call('200'), "Fiyat 250 TL'den az olamaz!");
    });

    testWidgets('Valid price returns null', (WidgetTester tester) async {
      final controller = TextEditingController(text: '300');
      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: priceField(controller: controller),
        ),
      ));

      final formField = find.byType(TextFormField);
      final state = tester.firstState<FormFieldState<String>>(formField);
      expect(state.widget.validator?.call('300'), null);
    });
  });

  group('PriceFieldAfterMidnight Validator', () {
    testWidgets('Empty price returns error', (WidgetTester tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: priceFieldAfterMidnight(controller: controller),
        ),
      ));

      final formField = find.byType(TextFormField);
      final state = tester.firstState<FormFieldState<String>>(formField);
      expect(state.widget.validator?.call(''), "Fiyat bilgisi girmelisiniz!");
    });

    testWidgets('Non-numeric price returns error', (WidgetTester tester) async {
      final controller = TextEditingController(text: 'xyz');
      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: priceFieldAfterMidnight(controller: controller),
        ),
      ));

      final formField = find.byType(TextFormField);
      final state = tester.firstState<FormFieldState<String>>(formField);
      expect(state.widget.validator?.call('xyz'), "Geçerli bir sayı giriniz!");
    });

    testWidgets('Price below 250 returns error', (WidgetTester tester) async {
      final controller = TextEditingController(text: '100');
      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: priceFieldAfterMidnight(controller: controller),
        ),
      ));

      final formField = find.byType(TextFormField);
      final state = tester.firstState<FormFieldState<String>>(formField);
      expect(state.widget.validator?.call('100'), "Fiyat 250 TL'den az olamaz!");
    });

    testWidgets('Valid price returns null', (WidgetTester tester) async {
      final controller = TextEditingController(text: '400');
      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: priceFieldAfterMidnight(controller: controller),
        ),
      ));

      final formField = find.byType(TextFormField);
      final state = tester.firstState<FormFieldState<String>>(formField);
      expect(state.widget.validator?.call('400'), null);
    });
  });
}