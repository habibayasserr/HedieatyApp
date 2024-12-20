import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hedieaty_application/main.dart'; // Update with your actual app import
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full app integration test', (WidgetTester tester) async {
    // Step 1: Launch the app
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Step 2: Navigate to sign-in screen
    expect(find.byKey(const Key('sign_in_view_scaffold')), findsOneWidget);

    // Step 3: Perform sign-in
    await tester.enterText(
        find.byKey(const Key('email_text_field')), 'test@example.com');
    await tester.enterText(
        find.byKey(const Key('password_text_field')), 'password123');
    await tester.tap(find.byKey(const Key('sign_in_button')));
    await tester.pumpAndSettle();

    // Verify home screen
    expect(find.byKey(const Key('home_view_scaffold')), findsOneWidget);

    // Step 4: Test searching for a friend
    await tester.enterText(find.byKey(const Key('search_text_field')), 'John');
    await tester.pumpAndSettle();
    expect(find.text('John'), findsWidgets);

    // Step 5: Add a new friend
    await tester.tap(find.byKey(const Key('add_friend_fab')));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.enterText(
        find.byKey(const Key('add_friend_name_field')), 'Jane Doe');
    await tester.enterText(
        find.byKey(const Key('add_friend_phone_field')), '1234567890');
    await tester.tap(find.byKey(const Key('add_friend_confirm_button')));
    await tester.pumpAndSettle();
    expect(find.text('Jane Doe'), findsOneWidget);

    // Step 6: Navigate to notifications page
    await tester.tap(find.byKey(const Key('notification_icon_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('notification_page_scaffold')), findsOneWidget);

    // Step 7: Verify profile page
    await tester.tap(find.byKey(const Key('profile_icon_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile_view_scaffold')), findsOneWidget);

    // Test enabling notifications
    await tester.tap(find.byKey(const Key('enable_notifications_switch')));
    await tester.pumpAndSettle();
    expect(
        find.byKey(const Key('enable_notifications_switch')), findsOneWidget);

    // Navigate to pledged gifts
    await tester.tap(find.byKey(const Key('my_pledged_gifts_tile')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pledged_gifts_scaffold')), findsOneWidget);

    // Step 8: Create an event
    await tester.tap(find.byKey(const Key('create_event_button')));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.enterText(
        find.byKey(const Key('event_name_field')), 'Birthday Party');
    await tester.tap(find.byKey(const Key('add_event_confirm_button')));
    await tester.pumpAndSettle();
    expect(find.text('Birthday Party'), findsOneWidget);

    // Step 9: Test adding a gift
    await tester.tap(find.byKey(const Key('add_gift_fab')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('gift_details_scaffold')), findsOneWidget);
    await tester.enterText(
        find.byKey(const Key('gift_name_text_field')), 'Apple Watch');
    await tester.enterText(
        find.byKey(const Key('gift_price_text_field')), '3500');
    await tester.enterText(find.byKey(const Key('gift_description_text_field')),
        'A sleek smartwatch');
    await tester.tap(find.byKey(const Key('save_changes_button')));
    await tester.pumpAndSettle();
    expect(find.text('Apple Watch'), findsOneWidget);

    // Step 10: Test pledging a gift
    await tester
        .tap(find.byKey(const Key('pledge_button_0'))); // Pledge the first gift
    await tester.pumpAndSettle();
    expect(find.text('Pledged'), findsWidgets);

    // Step 11: Test notifications page updates
    await tester.tap(find.byKey(const Key('notification_icon_button')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Your Apple Watch has been pledged.'),
        findsOneWidget);

    // Step 12: Log out
    await tester.tap(find.byKey(const Key('sign_out_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sign_in_view_scaffold')), findsOneWidget);
  });
}
