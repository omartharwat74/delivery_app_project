import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app_project/core/widgets/app_otp_input.dart';
import 'package:delivery_app_project/l10n/app_localizations.dart';

void main() {
  Widget buildTestableWidget({
    bool isLoading = false,
    String? errorMessage,
    required ValueChanged<String> onSubmit,
    required VoidCallback onResend,
    Locale locale = const Locale('ar'),
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: AppOtpInput(
          isLoading: isLoading,
          errorMessage: errorMessage,
          onSubmit: onSubmit,
          onResend: onResend,
        ),
      ),
    );
  }

  testWidgets('renders 6 boxes with hyphen placeholders initially', (tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        onSubmit: (_) {},
        onResend: () {},
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('-'), findsNWidgets(6));
    expect(find.text('تحقق'), findsOneWidget);
    expect(find.text('إعادة إرسال الكود ؟'), findsOneWidget);
  });

  testWidgets('entering digits populates leftmost box first (LTR)', (tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        onSubmit: (_) {},
        onResend: () {},
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '7');
    await tester.pump();

    // 1 box with '7' and 5 boxes with '-'
    expect(
      find.byWidgetPredicate((w) => w is Text && w.data == '7'),
      findsOneWidget,
    );
    expect(find.text('-'), findsNWidgets(5));
  });

  testWidgets('verify button enabled only on 6 digits', (tester) async {
    String? submittedOtp;
    await tester.pumpWidget(
      buildTestableWidget(
        onSubmit: (otp) => submittedOtp = otp,
        onResend: () {},
      ),
    );
    await tester.pumpAndSettle();

    final buttonFinder = find.widgetWithText(ElevatedButton, 'تحقق');
    final elevatedButton = tester.widget<ElevatedButton>(buttonFinder);
    expect(elevatedButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();

    final enabledButton = tester.widget<ElevatedButton>(buttonFinder);
    expect(enabledButton.onPressed, isNotNull);

    await tester.tap(buttonFinder);
    await tester.pump();

    expect(submittedOtp, equals('123456'));
  });

  testWidgets('resend button enables when timer reaches 0', (tester) async {
    bool resendCalled = false;
    await tester.pumpWidget(
      buildTestableWidget(
        onSubmit: (_) {},
        onResend: () => resendCalled = true,
      ),
    );
    await tester.pump();

    final resendButtonFinder = find.widgetWithText(TextButton, 'إعادة إرسال الكود ؟');
    final initialButton = tester.widget<TextButton>(resendButtonFinder);
    expect(initialButton.onPressed, isNull);

    // Fast-forward timer by 60 seconds
    await tester.pump(const Duration(seconds: 60));

    final enabledResendButton = tester.widget<TextButton>(resendButtonFinder);
    expect(enabledResendButton.onPressed, isNotNull);

    await tester.tap(resendButtonFinder);
    await tester.pump();

    expect(resendCalled, isTrue);
  });
}
