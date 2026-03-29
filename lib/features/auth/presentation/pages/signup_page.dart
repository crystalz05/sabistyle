import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  bool _isNameDirty = false;
  bool _isEmailDirty = false;
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

    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus && !_isNameDirty) {
        setState(() => _isNameDirty = true);
        _formKey.currentState?.validate();
      }
    });

    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus && !_isEmailDirty) {
        setState(() => _isEmailDirty = true);
        _formKey.currentState?.validate();
      }
    });

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (!_isNameDirty) return null;
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    return null;
  }

  String? _validateEmail(String? value) {
    if (!_isEmailDirty) return null;
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegEx = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegEx.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (!_isPasswordDirty) return null;
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (!_isConfirmDirty) return null;
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  void _submit(BuildContext context) {
    setState(() {
      _isNameDirty = true;
      _isEmailDirty = true;
      _isPasswordDirty = true;
      _isConfirmDirty = true;
    });
    if (_formKey.currentState?.validate() != true) return;
    context.read<AuthBloc>().add(
          SignUpRequested(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          AppSnackBar.showError(context, message: state.message);
        }
        if (state is AwaitingVerification) {
          context.go(
            '${AppRoutes.verifyEmail}?email=${Uri.encodeComponent(state.email)}',
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
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
                    const SizedBox(height: 56),
                    _buildHeader(context),
                    const SizedBox(height: 40),
                    _buildForm(context),
                    const SizedBox(height: 28),
                    _buildSubmitButton(context),
                    const SizedBox(height: 24),
                    _buildDivider(context),
                    const SizedBox(height: 24),
                    _buildLoginRow(context),
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

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 54,
              height: 54,
              child: Image.asset(
                theme.brightness == Brightness.dark
                    ? AppAssets.darkThemeIcon
                    : AppAssets.lightThemeIcon,
                color: theme.brightness == Brightness.dark 
                    ? theme.colorScheme.primary 
                    : null,
                width: 100,
                height: 100,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              "Sabistyle",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
                letterSpacing: -0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'Create an account',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Join us to start shopping',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.grey.shade500,
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
            label: 'Full Name',
            controller: _nameController,
            focusNode: _nameFocusNode,
            validator: _validateName,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            onChanged: (_) {
              if (_isNameDirty) _formKey.currentState?.validate();
            },
            onFieldSubmitted: (_) {
              _isNameDirty = true;
              _formKey.currentState?.validate();
              _emailFocusNode.requestFocus();
            },
            hintText: 'John Doe',
            prefixIcon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 20),
          AppTextField(
            label: 'Email address',
            controller: _emailController,
            focusNode: _emailFocusNode,
            validator: _validateEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onChanged: (_) {
              if (_isEmailDirty) _formKey.currentState?.validate();
            },
            onFieldSubmitted: (_) {
              _isEmailDirty = true;
              _formKey.currentState?.validate();
              _passwordFocusNode.requestFocus();
            },
            hintText: 'you@example.com',
            prefixIcon: Icons.mail_outline_rounded,
          ),
          const SizedBox(height: 20),
          AppTextField(
            label: 'Password',
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
            label: 'Confirm Password',
            controller: _confirmController,
            focusNode: _confirmFocusNode,
            validator: _validateConfirmPassword,
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
          text: 'Sign Up',
          onPressed: () => _submit(context),
          isLoading: isLoading,
        );
      },
    );
  }

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Divider(color: theme.dividerColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(child: Divider(color: theme.dividerColor, thickness: 1)),
      ],
    );
  }

  Widget _buildLoginRow(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        TextButton(
          onPressed: () => context.go(AppRoutes.login),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.only(left: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Sign In',
            style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
