import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app_project/core/widgets/error_state_view.dart';
import 'package:delivery_app_project/core/theme/app_colors.dart';
import 'package:delivery_app_project/l10n/app_localizations.dart';

void main() {
  testWidgets('ErrorStateView renders exact blocked UI with icon, message and retry button', (tester) async {
    bool retried = false;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: Scaffold(
          body: ErrorStateView(
            message: 'حسابك محظور. تواصل مع الدعم',
            onRetry: () {
              retried = true;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Icons.error_outline with size 48 and error color
    final iconFinder = find.byIcon(Icons.error_outline);
    expect(iconFinder, findsOneWidget);
    final iconWidget = tester.widget<Icon>(iconFinder);
    expect(iconWidget.size, 48);
    expect(iconWidget.color, AppColors.error);

    // Verify message text
    expect(find.text('حسابك محظور. تواصل مع الدعم'), findsOneWidget);

    // Verify button with 'إعادة المحاولة' and tap interaction
    final buttonFinder = find.widgetWithText(ElevatedButton, 'إعادة المحاولة');
    expect(buttonFinder, findsOneWidget);

    await tester.tap(buttonFinder);
    expect(retried, isTrue);
  });

  testWidgets('ErrorStateView cleans exception prefixes cleanly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: Scaffold(
          body: ErrorStateView(
            message: 'ForbiddenException: حسابك محظور. تواصل مع الدعم',
            onRetry: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('حسابك محظور. تواصل مع الدعم'), findsOneWidget);
    expect(find.textContaining('ForbiddenException:'), findsNothing);
  });
}
