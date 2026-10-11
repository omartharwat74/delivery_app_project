import 'package:equatable/equatable.dart';

class GeneralSettingsModel extends Equatable {
  final String terms;
  final String? privacyPolicy;
  final String? aboutUs;
  final Map<String, dynamic> raw;

  const GeneralSettingsModel({
    required this.terms,
    this.privacyPolicy,
    this.aboutUs,
    this.raw = const {},
  });

  factory GeneralSettingsModel.fromJson(Map<String, dynamic> json) {
    return GeneralSettingsModel(
      terms: json['terms']?.toString() ?? '',
      privacyPolicy: json['privacy_policy']?.toString(),
      aboutUs: json['about_us']?.toString(),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'terms': terms,
      'privacy_policy': privacyPolicy,
      'about_us': aboutUs,
      ...raw,
    };
  }

  @override
  List<Object?> get props => [terms, privacyPolicy, aboutUs, raw];
}
