import 'package:flutter/material.dart';

class DrawerItemTile extends StatelessWidget {
  const DrawerItemTile({
    super.key,
    required this.title,
    this.iconAsset,
    this.iconData,
    required this.iconBgColor,
    this.iconColor = Colors.white,
    required this.onTap,
    this.isLogout = false,
    this.showDivider = true,
  });

  final String title;
  final String? iconAsset;
  final IconData? iconData;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isLogout;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 64,
            child: Padding(
              // Add a small horizontal padding if the design needs it, or just rely on the parent padding
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Row(
                children: [
                  // START: Icon + Text
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon — 32×32 circle or rounded-rect (logout)
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: Center(
                          child: iconAsset != null
                              ? Image.asset(
                                  iconAsset!,
                                  width: 22,
                                  height: 22,
                                  // White icon inside colored background looks good in both modes
                                  color: iconColor,
                                )
                              : Icon(iconData, color: iconColor, size: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title — Expo Arabic 500
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'ExpoArabic',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodyMedium?.color ??
                                theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // END: trailing arrow (hidden for logout)
                  if (!isLogout)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color:
                          theme.iconTheme.color ??
                          theme.colorScheme.onSurfaceVariant,
                    )
                  else
                    const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ),
        // Divider (hidden for last item if showDivider=false)
        if (showDivider)
          Divider(height: 0.5, thickness: 0.5, color: theme.dividerColor),
      ],
    );
  }
}
