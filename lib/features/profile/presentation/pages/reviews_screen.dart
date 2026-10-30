import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_app_project/core/theme/app_colors.dart';
import 'package:delivery_app_project/core/theme/text_styles.dart';
import 'package:delivery_app_project/core/widgets/error_state_view.dart';
import 'package:delivery_app_project/features/auth/presentation/bloc/auth_cubit.dart';
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
            return ErrorStateView(
              message: state.message,
              onRetry: () {
                context.read<ReviewsCubit>().loadReviews();
                try {
                  context.read<AuthCubit>().loadDriverProfile();
                } catch (_) {}
              },
            );
          }

          if (state is ReviewsLoaded) {
            if (state.reviews.isEmpty) {
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () =>
                    context.read<ReviewsCubit>().loadReviews(refresh: true),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  ),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                        child: Text(
                          l10n.noReviewsYet,
                          style: AppTextStyles.body(context).copyWith(
                            color: AppColors.paragraph(context),
                          ),
                        ),
                      ),
                    ),
                  ],
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
    if (isoString.trim().isEmpty) return '';
    final dt = DateTime.tryParse(isoString.replaceFirst(' ', 'T')) ??
        DateTime.tryParse(isoString);
    if (dt != null) {
      return '${dt.year}/${dt.month}/${dt.day}';
    }
    return isoString;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final userName = review.user.name.trim().isNotEmpty
        ? review.user.name
        : (l10n.localeName == 'ar' ? 'عميل' : l10n.drawerGuestName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Customer Name on start, Date on end (no user photo, no order ID)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'ExpoArabic',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(review.createdAt),
                    style: TextStyle(
                      fontFamily: 'ExpoArabic',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.paragraph(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Rating Stars Row (5 stars, no numeric text)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (starIndex) {
                  final starValue = starIndex + 1;
                  Widget starIcon;
                  if (review.rating >= starValue) {
                    starIcon = const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppColors.ratingStar,
                    );
                  } else if (review.rating >= starValue - 0.5) {
                    starIcon = Transform.flip(
                      flipX: isRtl,
                      child: const Icon(
                        Icons.star_half_rounded,
                        size: 14,
                        color: AppColors.ratingStar,
                      ),
                    );
                  } else {
                    starIcon = Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: isDark
                          ? const Color(0xFF333333)
                          : const Color(0xFFE5E5E5),
                    );
                  }

                  return Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: starIndex < 4 ? 4.0 : 0.0,
                    ),
                    child: starIcon,
                  );
                }),
              ),

              // Comment text (if any)
              if (review.comment.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  review.comment,
                  style: TextStyle(
                    fontFamily: 'ExpoArabic',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.paragraph(context),
                    height: 1.3,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        Divider(
          height: 1,
          thickness: 0.5,
          color: isDark ? AppColors.darkOutline : const Color(0xFFE5E5E5),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
