import 'package:flutter/material.dart';

import '../widgets/home_drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../orders/presentation/bloc/active_order_cubit.dart';
import '../../../orders/presentation/bloc/active_order_state.dart';
import '../../../orders/presentation/widgets/active_order_card.dart';
import '../../../../l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isOnline = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActiveOrderCubit, ActiveOrderState>(
      listenWhen: (previous, current) =>
          previous is ActiveOrderIdle && current is ActiveOrderAssigned,
      listener: (context, state) {
        // Play an alert sound here (e.g. Audioplayers.play('alert.mp3'))
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.trackingNewOrderBody),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Scaffold(
        drawer: const HomeDrawer(),

        body: SizedBox.expand(
          child: Stack(
            children: [
              // Background Map Placeholder
              Positioned.fill(
                child: Image.asset(
                  'assets/images/map_placeholder.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: Text('Map Placeholder')),
                  ),
                ),
              ),

              // Floating Overlays
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Hamburger Menu Button
                        Builder(
                          builder: (drawerCtx) => Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12.0),
                                onTap: () =>
                                    Scaffold.of(drawerCtx).openDrawer(),
                                child: Center(
                                  child: const Icon(
                                    Icons.menu,
                                    color: Color(0xFFA3090F),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Online/Offline Toggle
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isOnline = !_isOnline;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 60,
                            height: 32,
                            padding: const EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedAlign(
                                  duration: const Duration(milliseconds: 300),
                                  alignment: _isOnline
                                      ? AlignmentDirectional.centerEnd
                                      : AlignmentDirectional.centerStart,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _isOnline
                                          ? const Color(0xFF0C9D61)
                                          : const Color(0xFFD1D1D1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Active Order Card Overlay
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ActiveOrderCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
