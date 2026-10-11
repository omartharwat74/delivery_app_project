import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app_project/core/constants/app_assets.dart';
import 'package:delivery_app_project/core/network/auth_event_bus.dart';
import 'package:delivery_app_project/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:delivery_app_project/features/auth/presentation/pages/register_driver_page.dart';
import 'package:delivery_app_project/features/auth/presentation/widgets/phone_number_field.dart';
import 'package:delivery_app_project/l10n/app_localizations.dart';

import '../../auth_flow_test.dart';

void main() {
  late AuthEventBus eventBus;
  late MockAuthRepository authRepository;
  late AuthCubit authCubit;

  setUp(() {
    eventBus = AuthEventBus();
    authRepository = MockAuthRepository();
    authCubit = AuthCubit(
      authRepository: authRepository,
      authEventBus: eventBus,
    );
  });

  tearDown(() {
    authCubit.close();
    eventBus.dispose();
  });

  Widget buildTestableWidget({String? phone}) {
    return MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: RegisterDriverPage(phone: phone),
      ),
    );
  }

  testWidgets('initializes phone without leading 0 and sets field to readOnly', (tester) async {
    await tester.pumpWidget(buildTestableWidget(phone: '01064178619'));
    await tester.pumpAndSettle();

    final phoneFieldFinder = find.byType(PhoneNumberField);
    expect(phoneFieldFinder, findsOneWidget);

    final phoneNumberFieldWidget = tester.widget<PhoneNumberField>(phoneFieldFinder);
    expect(phoneNumberFieldWidget.readOnly, isTrue);
    expect(phoneNumberFieldWidget.controller.text, equals('1064178619'));

    // Check inner TextField
    final textFieldFinder = find.descendant(
      of: phoneFieldFinder,
      matching: find.byType(TextField),
    );
    expect(textFieldFinder, findsOneWidget);
    final textFieldWidget = tester.widget<TextField>(textFieldFinder);
    expect(textFieldWidget.readOnly, isTrue);
    expect(textFieldWidget.controller?.text, equals('1064178619'));
  });

  testWidgets('initializes phone correctly when +20 prefix is passed', (tester) async {
    await tester.pumpWidget(buildTestableWidget(phone: '+201064178619'));
    await tester.pumpAndSettle();

    final phoneFieldFinder = find.byType(PhoneNumberField);
    final phoneNumberFieldWidget = tester.widget<PhoneNumberField>(phoneFieldFinder);
    expect(phoneNumberFieldWidget.controller.text, equals('1064178619'));
  });

  testWidgets('displays profile_placeholder asset when no profile photo is selected', (tester) async {
    await tester.pumpWidget(buildTestableWidget(phone: '01064178619'));
    await tester.pumpAndSettle();

    final placeholderImageFinder = find.byWidgetPredicate(
      (w) => w is Image && w.image is AssetImage && (w.image as AssetImage).assetName == AppAssets.profilePlaceholder,
    );
    expect(placeholderImageFinder, findsOneWidget);
  });
}
