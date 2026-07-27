import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/catalog_repository.dart';
import 'data/repositories/favorites_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/services/auth_service.dart';
import 'logic/auth/auth_cubit.dart';
import 'logic/categories/categories_cubit.dart';
import 'logic/favorites/favorites_cubit.dart';
import 'logic/search/search_cubit.dart';
import 'presentation/auth/auth_gate.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/auth/register_screen.dart';
import 'presentation/shell/main_shell.dart';

class ShopifyApp extends StatelessWidget {
  const ShopifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final CatalogRepository catalogRepository = CatalogRepository();

    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(
            authService: authService,
            userRepository: UserRepository(),
          ),
        ),
        BlocProvider<CategoriesCubit>(
          create: (_) => CategoriesCubit(catalogRepository),
        ),
        BlocProvider<SearchCubit>(
          create: (_) => SearchCubit(catalogRepository: catalogRepository),
        ),
        BlocProvider<FavoritesCubit>(
          create: (_) => FavoritesCubit(
            favoritesRepository: FavoritesRepository(),
            authService: authService,
          ),
        ),
      ],
      child: Builder(
        builder: (BuildContext context) {
          return BlocListener<AuthCubit, AuthState>(
            listenWhen: (AuthState previous, AuthState current) =>
                current is AuthAuthenticated || current is AuthUnauthenticated,
            listener: (BuildContext context, AuthState state) {
              if (state is AuthAuthenticated) {
                context.read<FavoritesCubit>().load();
              } else if (state is AuthUnauthenticated) {
                context.read<FavoritesCubit>().clear();
              }
            },
            child: MaterialApp(
              title: 'Shopify',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              initialRoute: AppRoutes.root,
              onGenerateRoute: _onGenerateRoute,
            ),
          );
        },
      ),
    );
  }

  static Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.root:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AuthGate(),
        );
      case AppRoutes.login:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
      case AppRoutes.register:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const RegisterScreen(),
        );
      case AppRoutes.shell:
        final int initialIndex = (settings.arguments as int?) ?? 0;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => MainShell(initialIndex: initialIndex),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
    }
  }
}
