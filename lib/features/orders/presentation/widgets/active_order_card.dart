import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/active_order_cubit.dart';
import '../bloc/active_order_state.dart';
import 'dashed_line_painter.dart';

class ActiveOrderCard extends StatelessWidget {
  const ActiveOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActiveOrderCubit, ActiveOrderState>(
      listenWhen: (previous, current) => current is ActiveOrderActionError,
      listener: (context, state) {
        if (state is ActiveOrderActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ActiveOrderIdle || state is ActiveOrderLoading) {
          return const SizedBox.shrink();
        }

        final l10n = AppLocalizations.of(context)!;

        // Stage discrimination
        final isOffer = state is ActiveOrderOfferReceived;
        final inProgress = state is ActiveOrderInProgress;

        final OrderEntity? order = isOffer
            ? (state).offer.order
            : inProgress
                ? (state).order
                : null;

        if (order == null) {
          return const SizedBox.shrink();
        }

        final isAssigned = inProgress && order.isAssigned;
        final isOnTheWay = inProgress && order.isOnTheWay;

        final isAccepting = isOffer && (state).isAccepting;
        final isUpdatingStatus = inProgress && (state).isUpdatingStatus;

        // Price formatting
        final displayPrice = order.totalPrice > 0
            ? order.totalPrice.toStringAsFixed(0)
            : order.deliveryFee.toStringAsFixed(0);

        final itemsCountStr = order.totalItems > 0
            ? order.totalItems.toString()
            : (order.items.isNotEmpty ? order.items.length.toString() : '1');

        final orderIdStr = order.code.isNotEmpty ? order.code : order.id.toString();

        final fromAddress = order.pickupAddress.isNotEmpty
            ? order.pickupAddress
            : (order.restaurantName.isNotEmpty ? order.restaurantName : 'المتجر');

        final toAddress = order.deliveryAddress.isNotEmpty
            ? order.deliveryAddress
            : 'عنوان العميل';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Price, Items, Order ID)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$displayPrice ج.م',
                          style: AppTextStyles.inputText(
                            context,
                          ).copyWith(color: AppColors.onSurface(context)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.trackingItems(itemsCountStr),
                          style: AppTextStyles.caption(
                            context,
                          ).copyWith(color: AppColors.onSurface(context)),
                        ),
                      ],
                    ),
                    Text(
                      l10n.trackingOrderNo(orderIdStr),
                      style: AppTextStyles.inputText(
                        context,
                      ).copyWith(color: AppColors.onSurface(context)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(
                  color: Theme.of(context).colorScheme.outline,
                  height: 1,
                ),
                const SizedBox(height: 12),

                // Store Details in Stage 1 / All stages
                if (order.restaurantName.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.storefront_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            order.restaurantName,
                            style: AppTextStyles.body(context).copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface(context),
                            ),
                          ),
                        ],
                      ),
                      if (order.store?.phone != null &&
                          order.store!.phone!.isNotEmpty)
                        Row(
                          children: [
                            Text(
                              order.store!.phone!,
                              style: AppTextStyles.caption(context).copyWith(
                                color: AppColors.onSurface(context),
                              ),
                              textDirection: TextDirection.ltr,
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.phone_outlined,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Route Timeline
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Timeline Graphic
                      Column(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: CustomPaint(
                                size: const Size(1, double.infinity),
                                painter: DashedLinePainter(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Route Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.trackingFrom(fromAddress),
                              style: AppTextStyles.body(
                                context,
                              ).copyWith(color: AppColors.onSurface(context)),
                            ),
                            // TODO(API): static for now
                            Text(
                              l10n.trackingExpectedDistanceShort('2.5'),
                              style: AppTextStyles.caption(
                                context,
                              ).copyWith(color: AppColors.paragraph(context)),
                            ),
                            const Spacer(),
                            const SizedBox(height: 12),
                            Text(
                              l10n.trackingTo(toAddress),
                              style: AppTextStyles.body(
                                context,
                              ).copyWith(color: AppColors.onSurface(context)),
                            ),
                            // TODO(API): static for now
                            Text(
                              l10n.trackingExpectedDistanceShort('2.5'),
                              style: AppTextStyles.caption(
                                context,
                              ).copyWith(color: AppColors.paragraph(context)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Divider(
                  color: Theme.of(context).colorScheme.outline,
                  height: 1,
                ),
                const SizedBox(height: 12),

                // Customer Details (ONLY shows in Stages 2 & 3 after acceptance!)
                if (!isOffer && order.customerName.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.trackingCustomerDetails,
                        style: AppTextStyles.heading4(
                          context,
                        ).copyWith(color: AppColors.onSurface(context)),
                      ),
                      Row(
                        children: [
                          Text(
                            order.customerName,
                            style: AppTextStyles.inputText(
                              context,
                            ).copyWith(color: AppColors.onSurface(context)),
                          ),
                          if (order.customerPhone.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              order.customerPhone,
                              style: AppTextStyles.body(
                                context,
                              ).copyWith(color: AppColors.onSurface(context)),
                              textDirection: TextDirection.ltr,
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.phone_outlined,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(
                    color: Theme.of(context).colorScheme.outline,
                    height: 1,
                  ),
                  const SizedBox(height: 12),
                ],

                // Action Button / Footer per Stage
                if (isOffer) ...[
                  // Stage 1: Expected distance info + "قبول الطلب"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // TODO(API): static for now
                      Text(
                        l10n.trackingExpectedTotalDistance('7.5'),
                        style: AppTextStyles.buttonHeading(
                          context,
                        ).copyWith(color: AppColors.onSurface(context)),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_outward,
                        color: AppColors.onSurface(context),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: isAccepting
                        ? null
                        : () => context.read<ActiveOrderCubit>().acceptOffer(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isAccepting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            l10n.trackingAcceptOrder,
                            style: AppTextStyles.buttonHeading(
                              context,
                            ).copyWith(color: Colors.white),
                          ),
                  ),
                ] else if (isAssigned) ...[
                  // Stage 2: "تم استلام الطلب"
                  ElevatedButton(
                    onPressed: isUpdatingStatus
                        ? null
                        : () => context.read<ActiveOrderCubit>().confirmPickup(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isUpdatingStatus
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            l10n.trackingConfirmPickup,
                            style: AppTextStyles.buttonHeading(
                              context,
                            ).copyWith(color: Colors.white),
                          ),
                  ),
                ] else if (isOnTheWay) ...[
                  // Stage 3: "تم تسليم الطلب"
                  ElevatedButton(
                    onPressed: isUpdatingStatus
                        ? null
                        : () => context.read<ActiveOrderCubit>().confirmDelivery(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isUpdatingStatus
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            l10n.trackingConfirmDelivery,
                            style: AppTextStyles.buttonHeading(
                              context,
                            ).copyWith(color: Colors.white),
                          ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
