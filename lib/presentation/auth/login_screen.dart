import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/brand_app_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../logic/auth/auth_cubit.dart';

const double _kMaxContentWidth = 480.0;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthCubit>().signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _submitWithGoogle() {
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().signInWithGoogle();
  }

  void _openRegister() => Navigator.pushNamed(context, AppRoutes.register);

  void _onAuthState(BuildContext context, AuthState state) {
    if (state is AuthError) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(state.message, textAlign: TextAlign.start)),
        );
      return;
    }
    if (state is AuthAuthenticated) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.shell,
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          current is AuthError || current is AuthAuthenticated,
      listener: _onAuthState,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: const BrandAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.only(
              start: AppDimens.s24,
              end: AppDimens.s24,
              top: kToolbarHeight + AppDimens.s24,
              bottom: AppDimens.s32,
            ),
            child: Align(
              alignment: AlignmentDirectional.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'مرحبًا بعودتك',
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: AppDimens.s8),
                      Text(
                        'سجّل دخولك لمتابعة استعراض أحدث المنتجات.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: AppDimens.s32),
                      AppTextField(
                        label: 'البريد الإلكتروني',
                        controller: _emailController,
                        hintText: 'name@example.com',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[AutofillHints.email],
                        validator: Validators.email,
                        onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                      ),
                      const SizedBox(height: AppDimens.s16),
                      AppTextField(
                        label: 'كلمة المرور',
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const <String>[AutofillHints.password],
                        validator: Validators.password,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: AppDimens.s32),
                      _LoginActions(
                        onSubmit: _submit,
                        onSubmitWithGoogle: _submitWithGoogle,
                        onOpenRegister: _openRegister,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginActions extends StatelessWidget {
  const _LoginActions({
    required this.onSubmit,
    required this.onSubmitWithGoogle,
    required this.onOpenRegister,
  });

  final VoidCallback onSubmit;
  final VoidCallback onSubmitWithGoogle;
  final VoidCallback onOpenRegister;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (BuildContext context, AuthState state) {
        final bool isBusy = state is AuthLoading;
        final bool googleBusy = state is AuthLoading && state.googleFlow;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            PrimaryButton(
              label: 'تسجيل الدخول',
              isLoading: isBusy && !googleBusy,
              onPressed: isBusy ? null : onSubmit,
            ),
            const SizedBox(height: AppDimens.s16),
            SecondaryButton(
              label: 'المتابعة بحساب Google',
              isLoading: googleBusy,
              onPressed: isBusy ? null : onSubmitWithGoogle,
            ),
            const SizedBox(height: AppDimens.s16),
            _SwitchAuthLink(
              question: 'ليس لديك حساب؟',
              actionLabel: 'إنشاء حساب',
              onPressed: isBusy ? null : onOpenRegister,
            ),
          ],
        );
      },
    );
  }
}

class _SwitchAuthLink extends StatelessWidget {
  const _SwitchAuthLink({
    required this.question,
    required this.actionLabel,
    this.onPressed,
  });

  final String question;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(
          question,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.start,
        ),
        TextButton(onPressed: onPressed, child: Text(actionLabel)),
      ],
    );
  }
}
