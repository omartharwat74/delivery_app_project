import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'drawer_item_tile.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  // Exact Figma colors extracted from node 8171-15319
  static const _colorHome = Color(0xFFA268D9); // Purple
  static const _colorOrders = Color(0xFFC83F44); // Red
  static const _colorSettings = Color(0xFF68D995); // Green
  static const _colorNotifications = Color(0xFF62CFDD); // Cyan
  static const _colorReviews = Color(0xFFEB78B0); // Pink
  static const _colorWallet = Color(0xFFF9CD13); // Yellow
  static const _colorSupport = Color(0xFFFC933C); // Orange
  static const _colorWorkHours = Color(0xFFFFE5D0); // Light Orange for circle
  static const _colorTerms = Color(0xFF0DA8E9); // Blue
  static const _colorLogout = Color(0xFFA3090F); // Primary Red

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, curr) => curr is AuthUnauthenticated,
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Drawer(
        // Figma: width=292, bg=#FFFFFF (Theme adaptive), cornerRadius=24 on the inner side
        width: 292,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(
            topEnd: Radius.circular(24),
            bottomEnd: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(top: 20, right: 16, left: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Header ─────────────────────────────────────────────
                      _DrawerHeader(l10n: l10n),

                      const SizedBox(height: 16),
                      Divider(height: 1, color: Theme.of(context).dividerColor),
                      const SizedBox(height: 16),

                      // ── Menu Items ─────────────────────────────────────────
                      DrawerItemTile(
                        title: l10n.drawerHome,
                        iconAsset: 'assets/images/ic_drawer_home.png',
                        iconBgColor: _colorHome,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      DrawerItemTile(
                        title: l10n.drawerOrders,
                        iconAsset: 'assets/images/ic_drawer_orders.png',
                        iconBgColor: _colorOrders,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push(RouteNames.orders);
                        },
                      ),
                      DrawerItemTile(
                        title: 'مواعيد العمل',
                        iconAsset: 'assets/images/ic_drawer_reviews.png',
                        iconBgColor: const Color(0xFFF8AC8E),
                        iconColor: Colors.white,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push(RouteNames.workHours);
                        },
                      ),
                      DrawerItemTile(
                        title: l10n.drawerGeneralSettings,
                        iconAsset: 'assets/images/ic_drawer_settings.png',
                        iconBgColor: _colorSettings,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push(RouteNames.settings);
                        },
                      ),
                      DrawerItemTile(
                        title: l10n.drawerNotifications,
                        iconAsset: 'assets/images/ic_drawer_notifications.png',
                        iconBgColor: _colorNotifications,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push(RouteNames.notifications);
                        },
                      ),
                      DrawerItemTile(
                        title: l10n.drawerReviews,
                        iconAsset: 'assets/images/ic_drawer_reviews.png',
                        iconBgColor: _colorReviews,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push(RouteNames.reviews);
                        },
                      ),
                      DrawerItemTile(
                        title: l10n.drawerWallet,
                        iconAsset: 'assets/images/ic_drawer_wallet.png',
                        iconBgColor: _colorWallet,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push(RouteNames.wallet);
                        },
                      ),
                      DrawerItemTile(
                        title: l10n.drawerSupport,
                        iconAsset: 'assets/images/ic_drawer_support.png',
                        iconBgColor: _colorSupport,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push(RouteNames.support);
                        },
                      ),
                      DrawerItemTile(
                        title: l10n.drawerTerms,
                        iconAsset: 'assets/images/ic_drawer_terms.png',
                        iconBgColor: _colorTerms,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push(RouteNames.termsAndConditions);
                        },
                        showDivider:
                            false, // hide the divider for the last item
                      ),
                    ]),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 16,
                      left: 16,
                      bottom: 24, // 24px safe area from bottom
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Logout (pinned at bottom) ───────────────────────────
                        const SizedBox(height: 16),
                        BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLogoutLoading;
                            return DrawerItemTile(
                              title: isLoading ? '...' : l10n.drawerLogout,
                              iconAsset: 'assets/images/ic_drawer_logout.png',
                              iconBgColor: _colorLogout,
                              isLogout: true,
                              showDivider: false, // no divider under logout
                              onTap: isLoading
                                  ? () {}
                                  : () => _confirmLogout(context, l10n),
                            );
                          },
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
    );
  }

  void _confirmLogout(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthCubit>().logout();
            },
            child: Text(
              l10n.confirm,
              style: const TextStyle(color: Color(0xFFA3090F)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 52,
      child: Row(
        children: [
          // START: Avatar + Name + Phone
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                context.push(RouteNames.profile);
              },
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage('assets/images/user_avatar.png'),
                  ),
                  const SizedBox(width: 12),
                  // Name + Phone
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // User name
                        Text(
                          l10n.drawerGuestName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color:
                                theme.textTheme.bodyMedium?.color ??
                                theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Phone
                        Text(
                          '+20 123 456 7890',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color:
                                theme.textTheme.bodySmall?.color ??
                                theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // END: back/close arrow
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                // Changed to arrow_forward_ios to match the other rows (< in RTL)
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.iconTheme.color ?? theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
