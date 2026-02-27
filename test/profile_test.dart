import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_management/screens/edit_profile_screen.dart';
import 'package:task_management/screens/profile_screen.dart';

void main() {
  group('Profile Update Tests', () {
    testWidgets('Edit Profile Screen - Image Upload Button Exists',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditProfileScreen(),
        ),
      );

      // Verify camera icon is present
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);

      // Verify avatar section is tappable
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('Profile Screen - Edit Mode Toggle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(),
        ),
      );

      // Wait for the widget to load
      await tester.pumpAndSettle();

      // Find edit button
      final editButton = find.byIcon(Icons.edit);
      expect(editButton, findsOneWidget);

      // Tap edit button
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Check if camera icon appears in edit mode
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('Profile Form Validation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditProfileScreen(),
        ),
      );

      // Find save button
      final saveButton = find.text('Save Changes');
      expect(saveButton, findsOneWidget);

      // Tap save without filling form
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter your name'), findsOneWidget);
    });

    testWidgets('Profile Screen - Stats Display', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileScreen(),
        ),
      );

      // Wait for async data to load
      await tester.pumpAndSettle();

      // Check if stats cards are displayed
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });
  });

  group('Error Handling Tests', () {
    testWidgets('Edit Profile - Empty Name Validation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditProfileScreen(),
        ),
      );

      // Clear name field
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, '');

      // Try to save
      final saveButton = find.text('Save Changes');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter your name'), findsOneWidget);
    });

    testWidgets('Edit Profile - Invalid Email Validation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EditProfileScreen(),
        ),
      );

      // Enter invalid email
      final emailField = find.byType(TextFormField).at(1);
      await tester.enterText(emailField, 'invalid-email');

      // Try to save
      final saveButton = find.text('Save Changes');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });
  });
}
