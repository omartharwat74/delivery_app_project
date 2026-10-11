import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app_project/core/error/failures.dart';
import 'package:delivery_app_project/features/auth/data/models/driver_model.dart';
import 'package:delivery_app_project/features/auth/presentation/pages/terms_and_conditions_screen.dart';
import 'package:delivery_app_project/features/settings/data/models/general_settings_model.dart';
import 'package:delivery_app_project/features/settings/domain/repositories/settings_repository.dart';
import 'package:delivery_app_project/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:delivery_app_project/l10n/app_localizations.dart';

class MockSettingsRepositoryForTerms implements SettingsRepository {
  String termsToReturn = '<p>هذه هي <b>الشروط</b> والأحكام</p>';

  @override
  Future<Either<Failure, GeneralSettingsModel>> getGeneralSettings() async {
    return Right(GeneralSettingsModel(terms: termsToReturn));
  }

  @override
  Future<DriverModel?> getCachedDriver() async => null;

  @override
  Future<Either<Failure, Map<String, dynamic>>> sendCurrentOtp() async => const Right({});

  @override
  Future<Either<Failure, Map<String, dynamic>>> sendNewPhoneOtp({required String phoneChangeToken, required String newPhone}) async => const Right({});

  @override
  Future<Either<Failure, DriverModel>> updateNotifications({required bool isNotify}) async => throw UnimplementedError();

  @override
  Future<Either<Failure, String>> verifyCurrentOtp({required String otp}) async => const Right('');

  @override
  Future<Either<Failure, DriverModel>> verifyNewPhoneOtp({required String phoneChangeToken, required String newPhone, required String otp}) async => throw UnimplementedError();
}

void main() {
  test('stripHtml correctly strips HTML tags and decodes entities', () {
    const html = '<p>مرحباً بك&nbsp;في التطبيق<br>يرجى قراءة <b>الشروط</b></p>';
    final stripped = TermsAndConditionsScreen.stripHtml(html);
    expect(stripped, contains('مرحباً بك في التطبيق'));
    expect(stripped, contains('يرجى قراءة الشروط'));
    expect(stripped.contains('<p>'), isFalse);
    expect(stripped.contains('<b>'), isFalse);
  });

  testWidgets('TermsAndConditionsScreen displays stripped HTML terms', (tester) async {
    final mockRepo = MockSettingsRepositoryForTerms();
    final cubit = SettingsCubit(settingsRepository: mockRepo);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: BlocProvider.value(
          value: cubit..loadTerms(),
          child: const TermsAndConditionsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('هذه هي الشروط والأحكام'), findsOneWidget);
  });
}
