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
        : l10n.drawerGuestName;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                userName,
                style: AppTextStyles.body(
                  context,
                ).copyWith(fontSize: 13, fontWeight: FontWeight.w600),
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
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
              (starIndex) => Padding(
                padding: EdgeInsetsDirectional.only(
                  end: starIndex < 4 ? 4.0 : 0.0,
                ),
                child: Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: starIndex < review.rating.round()
                      ? AppColors.ratingStar
                      : AppColors.border(context),
                ),
              ),
            ),
          ),
          if (review.comment.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              review.comment,
              style: AppTextStyles.body(context).copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.paragraph(context),
                height: 1.4,
              ),
              textAlign: TextAlign.start,
            ),
          ],
          const SizedBox(height: 10),
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: AppColors.border(context),
          ),
        ],
      ),
    );
  }
}
