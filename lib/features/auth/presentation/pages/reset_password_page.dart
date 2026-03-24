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

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isPasswordDirty = false;
  bool _isConfirmDirty = false;

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

    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus && !_isPasswordDirty) {
        setState(() => _isPasswordDirty = true);
        _formKey.currentState?.validate();
      }
    });
    _confirmFocusNode.addListener(() {
      if (!_confirmFocusNode.hasFocus && !_isConfirmDirty) {
        setState(() => _isConfirmDirty = true);
        _formKey.currentState?.validate();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (!_isPasswordDirty) return null;
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirm(String? value) {
    if (!_isConfirmDirty) return null;
    if (value == null || value.isEmpty) return 'Confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  void _submit(BuildContext context) {
    setState(() {
      _isPasswordDirty = true;
      _isConfirmDirty = true;
    });
    if (_formKey.currentState?.validate() != true) return;
    context.read<AuthBloc>().add(
          UpdatePasswordRequested(_passwordController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          AppSnackBar.showError(context, message: state.message);
        } else if (state is PasswordUpdated) {
          AppSnackBar.showSuccess(
            context,
            message: 'Password successfully updated!',
          );
          // The deep-link already authenticated the user's session, 
          // so send them directly to Home.
          context.go(AppRoutes.home);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
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
                Icons.password_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 30,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'Create new password',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Your new password must be different from previous used passwords.",
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'New Password',
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            validator: _validatePassword,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            onChanged: (_) {
              if (_isPasswordDirty) _formKey.currentState?.validate();
            },
            onFieldSubmitted: (_) {
              _isPasswordDirty = true;
              _formKey.currentState?.validate();
              _confirmFocusNode.requestFocus();
            },
            hintText: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey.shade500,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 20),
          AppTextField(
            label: 'Confirm New Password',
            controller: _confirmController,
            focusNode: _confirmFocusNode,
            validator: _validateConfirm,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            onChanged: (_) {
              if (_isConfirmDirty) _formKey.currentState?.validate();
            },
            onFieldSubmitted: (_) {
              _isConfirmDirty = true;
              _formKey.currentState?.validate();
              _submit(context);
            },
            hintText: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey.shade500,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return AppButton(
          text: 'Update Password',
          onPressed: () => _submit(context),
          isLoading: isLoading,
        );
      },
    );
  }
}
