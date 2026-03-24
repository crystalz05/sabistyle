import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_router.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  bool _isEmailDirty = false;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus && !_isEmailDirty) {
        setState(() => _isEmailDirty = true);
        _formKey.currentState?.validate();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (!_isEmailDirty) return null;
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegEx = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegEx.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  void _submit(BuildContext context) {
    setState(() => _isEmailDirty = true);
    if (_formKey.currentState?.validate() != true) return;
    context.read<AuthBloc>().add(
          ResetPasswordRequested(_emailController.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          AppSnackBar.showError(context, message: state.message);
        } else if (state is PasswordResetEmailSent) {
          AppSnackBar.showSuccess(
            context,
            message: 'Reset link sent! Please check your email.',
          );
          context.go(AppRoutes.login);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildForm(context),
                    const SizedBox(height: 28),
                    _buildSubmitButton(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.lock_reset_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 30,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'Reset password',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Enter your email and we'll send you a link to reset your password.",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey.shade500,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: AppTextField(
        label: 'Email address',
        controller: _emailController,
        focusNode: _emailFocusNode,
        validator: _validateEmail,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        onChanged: (_) {
          if (_isEmailDirty) _formKey.currentState?.validate();
        },
        onFieldSubmitted: (_) {
          _isEmailDirty = true;
          _formKey.currentState?.validate();
          _submit(context);
        },
        hintText: 'you@example.com',
        prefixIcon: Icons.mail_outline_rounded,
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return AppButton(
          text: 'Send Reset Link',
          onPressed: () => _submit(context),
          isLoading: isLoading,
        );
      },
    );
  }
}
