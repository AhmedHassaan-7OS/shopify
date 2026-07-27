import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/brand_app_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../logic/auth/auth_cubit.dart';

const double _kMaxContentWidth = 480.0;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthCubit>().signUp(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _goToLogin() {
    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    navigator.pushReplacementNamed(AppRoutes.login);
  }

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
        appBar: const BrandAppBar(showBack: true),
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
                        'أنشئ حسابك',
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: AppDimens.s8),
                      Text(
                        'بيانات قليلة تكفي لتبدأ التسوّق فورًا.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: AppDimens.s32),
                      AppTextField(
                        label: 'الاسم',
                        controller: _nameController,
                        hintText: 'الاسم بالكامل',
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[AutofillHints.name],
                        validator: Validators.name,
                        onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
                      ),
                      const SizedBox(height: AppDimens.s16),
                      AppTextField(
                        label: 'رقم الهاتف',
                        controller: _phoneController,
                        focusNode: _phoneFocus,
                        hintText: '+201234567890',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[
                          AutofillHints.telephoneNumber,
                        ],
                        validator: Validators.phone,
                        onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                      ),
                      const SizedBox(height: AppDimens.s16),
                      AppTextField(
                        label: 'البريد الإلكتروني',
                        controller: _emailController,
                        focusNode: _emailFocus,
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
                        autofillHints: const <String>[
                          AutofillHints.newPassword,
                        ],
                        validator: Validators.password,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: AppDimens.s32),
                      _RegisterActions(
                        onSubmit: _submit,
                        onOpenLogin: _goToLogin,
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

class _RegisterActions extends StatelessWidget {
  const _RegisterActions({required this.onSubmit, required this.onOpenLogin});

  final VoidCallback onSubmit;
  final VoidCallback onOpenLogin;

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
              label: 'إنشاء حساب',
              isLoading: isBusy && !googleBusy,
              onPressed: isBusy ? null : onSubmit,
            ),
            const SizedBox(height: AppDimens.s16),
            _SwitchAuthLink(
              question: 'لديك حساب بالفعل؟',
              actionLabel: 'تسجيل الدخول',
              onPressed: isBusy ? null : onOpenLogin,
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
