import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _minSplashDuration = Duration(milliseconds: 1500);

  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    Timer(_minSplashDuration, () {
      if (!mounted) return;

      // TODO: Revert this temporary auth bypass
      context.go('/home');
      // context.read<AuthCubit>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: BlocListener<AuthCubit, AuthState>(
        listenWhen: (prev, curr) =>
            curr is AuthAuthenticated || curr is AuthUnauthenticated,
        listener: (context, state) {
          if (_navigated) return;
          _navigated = true;
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Center(
                  child: Image.asset(
                    AppAssets.splashLogo,
                    width: 200,
                    height: 68,
                    fit: BoxFit.contain,
                  ),
                ),
                const PositionedDirectional(
                  start: 0,
                  end: 0,
                  bottom: 0,
                  child: _SplashStripes(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SplashStripes extends StatelessWidget {
  const _SplashStripes();

  static const _stripeHeight = 20.0;
  static const _stripeGap = 6.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.only(top: index == 0 ? 0 : _stripeGap),
          child: Image.asset(
            'assets/images/splash_bottom_stripe.png',
            height: _stripeHeight,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
        );
      }),
    );
  }
}
