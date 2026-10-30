import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
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
  static const _colorTerms = Color(0xFF0DA8E9); // Blue
  static const _colorLogout = Color(0xFFA3090F); // Primary Red

  Future<void> _navigate(BuildContext context, String routeName) async {
    Navigator.of(context).pop();
    await context.push(routeName);
    if (context.mounted) {
      context.read<AuthCubit>().loadDriverProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, curr) => curr is AuthUnauthenticated,
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          while (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          context.go(RouteNames.login);
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
                        onTap: () => _navigate(context, RouteNames.orders),
                      ),
                      DrawerItemTile(
                        title: l10n.workingHoursTitle,
                        iconAsset: 'assets/images/ic_drawer_reviews.png',
                        iconBgColor: const Color(0xFFF8AC8E),
                        iconColor: Colors.white,
                        onTap: () => _navigate(context, RouteNames.workHours),
                      ),
                      DrawerItemTile(
                        title: l10n.drawerGeneralSettings,
                        iconAsset: 'assets/images/ic_drawer_settings.png',
                        iconBgColor: _colorSettings,
                        onTap: () => _navigate(context, RouteNames.settings),
                      ),
                      DrawerItemTile(
                        title: l10n.drawerNotifications,
                        iconAsset: 'assets/images/ic_drawer_notifications.png',
                        iconBgColor: _colorNotifications,
                        onTap: () => _navigate(context, RouteNames.notifications),
                      ),
                      DrawerItemTile(
                        title: l10n.drawerReviews,
                        iconAsset: 'assets/images/ic_drawer_reviews.png',
                        iconBgColor: _colorReviews,
                        onTap: () => _navigate(context, RouteNames.reviews),
                      ),
                      DrawerItemTile(
                        title: l10n.drawerWallet,
                        iconAsset: 'assets/images/ic_drawer_wallet.png',
                        iconBgColor: _colorWallet,
                        onTap: () => _navigate(context, RouteNames.wallet),
                      ),
                      DrawerItemTile(
                        title: l10n.drawerSupport,
                        iconAsset: 'assets/images/ic_drawer_support.png',
                        iconBgColor: _colorSupport,
                        onTap: () => _navigate(context, RouteNames.support),
                      ),
                      DrawerItemTile(
                        title: l10n.drawerTerms,
                        iconAsset: 'assets/images/ic_drawer_terms.png',
                        iconBgColor: _colorTerms,
                        onTap: () => _navigate(context, RouteNames.termsAndConditions),
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
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await context.read<AuthCubit>().logout();
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

  static String _resolveUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('/')) {
      return 'https://mycar.msarweb.net$trimmed';
    }
    return 'https://mycar.msarweb.net/$trimmed';
  }

  static String _formatPhone(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('20')) {
      digits = digits.substring(2);
    }
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return digits.isNotEmpty ? '+20 $digits' : '+20';
  }

  Future<void> _navigate(BuildContext context, String routeName) async {
    Navigator.of(context).pop();
    await context.push(routeName);
    if (context.mounted) {
      context.read<AuthCubit>().loadDriverProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final driver = state is AuthAuthenticated
            ? state.driver
            : context.read<AuthCubit>().currentDriver;

        final displayName =
            (driver?.name != null && driver!.name.trim().isNotEmpty)
                ? driver.name
                : l10n.drawerGuestName;

        final rawPhone = driver?.phone ?? '';
        final displayPhone =
            rawPhone.isNotEmpty ? _formatPhone(rawPhone) : '+20';

        final imageUrl = driver?.image;
        final resolvedImageUrl =
            (imageUrl != null && imageUrl.trim().isNotEmpty)
                ? _resolveUrl(imageUrl)
                : null;

        return SizedBox(
          height: 52,
          child: Row(
            children: [
              // START: Avatar + Name + Phone
              Expanded(
                child: InkWell(
                  onTap: () => _navigate(context, RouteNames.profile),
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: resolvedImageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: resolvedImageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Image.asset(
                                    AppAssets.profilePlaceholder,
                                    fit: BoxFit.cover,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    AppAssets.profilePlaceholder,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset(
                                  AppAssets.profilePlaceholder,
                                  fit: BoxFit.cover,
                                ),
                        ),
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
                              displayName,
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
                            // Phone (forced LTR for +20 prefix)
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                displayPhone,
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
      },
    );
  }
}
