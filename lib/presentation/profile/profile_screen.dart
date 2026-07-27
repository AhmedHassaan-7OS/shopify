import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/widgets/app_empty_view.dart';
import '../../core/widgets/app_error_view.dart';
import '../../core/widgets/brand_app_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/shimmer_views.dart';
import '../../data/models/app_user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/auth_service.dart';
import '../../logic/auth/auth_cubit.dart';
import '../../logic/profile/profile_cubit.dart';
import '../../logic/profile/profile_state.dart';
import 'widgets/profile_info_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.authService, this.userRepository});

  static const String emptyMessage =
      'لا توجد بيانات محفوظة لحسابك بعد. حاول مرة أخرى.';

  static const String logoutLabel = 'تسجيل الخروج';

  final AuthService? authService;

  final UserRepository? userRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (BuildContext context) => ProfileCubit(
        authService: authService ?? AuthService(),
        userRepository: userRepository ?? UserRepository(),
      )..load(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const BrandAppBar(),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (BuildContext context, ProfileState state) {
          final double statusBarHeight = MediaQuery.paddingOf(context).top;
          final double navBarHeight = MediaQuery.paddingOf(context).bottom + 80;
          final double topInset =
              statusBarHeight + kToolbarHeight + AppDimens.s24;
          final EdgeInsetsDirectional padding = EdgeInsetsDirectional.only(
            start: AppDimens.s24,
            end: AppDimens.s24,
            top: topInset,
            bottom: AppDimens.s32 + navBarHeight,
          );

          return switch (state) {
            ProfileInitial() || ProfileLoading() => SingleChildScrollView(
              child: ProfileShimmer(padding: padding),
            ),
            ProfileLoaded(user: final AppUser user) => _ProfileContent(
              user: user,
              padding: padding,
            ),
            ProfileEmpty() => AppEmptyView(
              message: ProfileScreen.emptyMessage,
              icon: Symbols.person,
              padding: padding,
              action: OutlinedButton.icon(
                onPressed: () => context.read<ProfileCubit>().retry(),
                icon: const Icon(Symbols.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ),
            ProfileError(message: final String message) => Padding(
              padding: EdgeInsetsDirectional.only(top: topInset),
              child: AppErrorView(
                message: message,
                onRetry: () => context.read<ProfileCubit>().retry(),
              ),
            ),
          };
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.user, required this.padding});

  final AppUser user;
  final EdgeInsetsDirectional padding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(child: _ProfileAvatar(name: user.name)),
          const SizedBox(height: AppDimens.s24),
          Text(
            user.name.trim().isEmpty ? user.email : user.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: AppDimens.s8),
          Text(
            user.email,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimens.s8 / 2),
          Text(
            user.phone,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimens.s32),
          _ProfileInfoCard(user: user),
          const SizedBox(height: AppDimens.s32),
          PrimaryButton(
            label: ProfileScreen.logoutLabel,
            icon: Symbols.logout,
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.name});

  final String name;

  static String initialOf(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    return String.fromCharCode(trimmed.runes.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final String initial = initialOf(name);

    return Container(
      width: AppDimens.avatarSize,
      height: AppDimens.avatarSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.primary,
        border: Border.all(color: colors.surfaceContainerLowest, width: 4),
        boxShadow: AppDimens.softShadow,
      ),
      child: initial.isEmpty
          ? Icon(
              Symbols.person,
              size: AppDimens.s48,
              color: colors.onPrimary,
              semanticLabel: 'صورة الحساب',
            )
          : Text(
              initial,
              textAlign: TextAlign.center,
              style: theme.textTheme.displayLarge?.copyWith(
                color: colors.onPrimary,
              ),
            ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: AppDimens.brCard,
        boxShadow: AppDimens.softShadow,
      ),
      child: Column(
        children: <Widget>[
          ProfileInfoTile(
            icon: Symbols.person,
            label: 'الاسم',
            value: user.name,
          ),
          Divider(height: 1, color: colors.outlineVariant),
          ProfileInfoTile(
            icon: Symbols.phone_iphone,
            label: 'رقم الهاتف',
            value: user.phone,
          ),
          Divider(height: 1, color: colors.outlineVariant),
          ProfileInfoTile(
            icon: Symbols.mail,
            label: 'البريد الإلكتروني',
            value: user.email,
          ),
        ],
      ),
    );
  }
}
