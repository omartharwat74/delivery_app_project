import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Driver order status representation for cards, tracking and filters.
/// Reflects the 3 states from the Driver App design:
/// 1. pending / assigned -> Badge: 'طلب جاري', Title: 'بإنتظار إستلام الطلب'
/// 2. onTheWay -> Badge: 'جاري التوصيل', Title: 'في الطريق الى العميل'
/// 3. completed / delivered -> Badge: 'طلب مغلق', Title: 'تم التسليم للعميل'
enum DriverOrderStatus {
  pending,
  onTheWay,
  completed,
  cancelled;

  static DriverOrderStatus fromString(String? status) {
    if (status == null) return DriverOrderStatus.pending;
    switch (status.toLowerCase().trim()) {
      case 'on_the_way':
      case 'delivering':
      case 'in_transit':
      case 'picked_up':
        return DriverOrderStatus.onTheWay;
      case 'delivered':
      case 'completed':
      case 'closed':
      case 'done':
        return DriverOrderStatus.completed;
      case 'cancelled':
      case 'canceled':
        return DriverOrderStatus.cancelled;
      case 'pending':
      case 'assigned':
      case 'accepted':
      case 'new':
      case 'waiting':
      default:
        return DriverOrderStatus.pending;
    }
  }

  /// Top badge label
  String badgeText(AppLocalizations l10n) {
    switch (this) {
      case DriverOrderStatus.pending:
        return l10n.orderStatusPendingBadge;
      case DriverOrderStatus.onTheWay:
        return l10n.orderStatusOnWayBadge;
      case DriverOrderStatus.completed:
        return l10n.orderStatusCompletedBadge;
      case DriverOrderStatus.cancelled:
        return l10n.orderStatusCancelled;
    }
  }

  /// Title below the badge
  String titleText(AppLocalizations l10n) {
    switch (this) {
      case DriverOrderStatus.pending:
        return l10n.orderStatusPendingTitle;
      case DriverOrderStatus.onTheWay:
        return l10n.orderStatusOnWayTitle;
      case DriverOrderStatus.completed:
        return l10n.orderStatusCompletedTitle;
      case DriverOrderStatus.cancelled:
        return l10n.orderStatusCancelled;
    }
  }

  /// Top badge text color:
  /// - Pending: yellow (AppColors.statusWarning)
  /// - On the way: yellow (AppColors.statusWarning)
  /// - Completed / Cancelled: grey / dark tone
  Color badgeColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (this) {
      case DriverOrderStatus.pending:
      case DriverOrderStatus.onTheWay:
        return AppColors.statusWarning;
      case DriverOrderStatus.completed:
      case DriverOrderStatus.cancelled:
        return isDark ? const Color(0xFFA0A0A0) : const Color(0xFF787878);
    }
  }

  /// Unified status icon for the Driver App across all statuses
  String get iconPath => AppAssets.orderStatusIcon;

  /// Progress bar active segment count (1 to 3)
  int get progressSegments {
    switch (this) {
      case DriverOrderStatus.pending:
        return 1;
      case DriverOrderStatus.onTheWay:
        return 2;
      case DriverOrderStatus.completed:
      case DriverOrderStatus.cancelled:
        return 3;
    }
  }
}
