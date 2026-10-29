import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_app_project/core/theme/app_colors.dart';
import 'package:delivery_app_project/core/theme/text_styles.dart';
import 'package:delivery_app_project/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:delivery_app_project/features/reviews/data/models/review_model.dart';
import 'package:delivery_app_project/features/reviews/presentation/bloc/reviews_cubit.dart';
import 'package:delivery_app_project/features/reviews/presentation/bloc/reviews_state.dart';
import 'package:delivery_app_project/l10n/app_localizations.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ReviewsCubit>().loadMoreReviews();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bg = AppColors.scaffoldBackground(context);
    final fg = AppColors.onSurface(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 16.0,
        title: Row(
          children: [
            const AuthBackButton(),
            const SizedBox(width: 4),
            Text(
              l10n.drawerReviews,
              style: AppTextStyles.appBarTitle(context),
            ),
          ],
        ),
      ),
      body: BlocBuilder<ReviewsCubit, ReviewsState>(
        builder: (context, state) {
          if (state is ReviewsLoading || state is ReviewsInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ReviewsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      style: AppTextStyles.body(context),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<ReviewsCubit>().loadReviews(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(l10n.confirm),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ReviewsLoaded) {
            if (state.reviews.isEmpty) {
              return Center(
                child: Text(
                  l10n.noReviewsYet,
                  style: AppTextStyles.body(context).copyWith(
                    color: AppColors.paragraph(context),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<ReviewsCubit>().loadReviews(refresh: true),
              color: AppColors.primary,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: state.reviews.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.reviews.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  }
                  final review = state.reviews[index];
                  return ReviewCard(review: review, l10n: l10n);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.review,
    required this.l10n,
  });

  final ReviewModel review;
  final AppLocalizations l10n;

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.year}/${dt.month}/${dt.day}';
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = review.user.name.trim().isNotEmpty
        ? review.user.name
        : (l10n.localeName == 'ar' ? 'عميل' : l10n.drawerGuestName);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border(context),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row: Customer Name, Order ID badge, Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.12),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(
                          context,
                        ).copyWith(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (review.orderId != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#${review.orderId}',
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'ExpoArabic',
                            color: AppColors.paragraph(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: AppTextStyles.caption(context).copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.paragraph(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Rating Stars Row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(
                5,
                (starIndex) => Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: starIndex < 4 ? 3.0 : 0.0,
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: starIndex < review.rating.round()
                        ? AppColors.ratingStar
                        : AppColors.border(context),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                review.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ratingStar,
                  fontFamily: 'ExpoArabic',
                ),
              ),
            ],
          ),

          // Comment
          if (review.comment.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: AppTextStyles.body(context).copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.paragraph(context),
                height: 1.4,
              ),
              textAlign: TextAlign.start,
            ),
          ],
        ],
      ),
    );
  }
}
