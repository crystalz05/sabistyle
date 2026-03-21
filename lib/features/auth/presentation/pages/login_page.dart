import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isEmailDirty = false;
  bool _isPasswordDirty = false;

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

    // Mark fields dirty on focus-loss for real-time error display
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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // ── Validators ──────────────────────────────────────────────────────────

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
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // ── Submit ───────────────────────────────────────────────────────────────

  void _submit(BuildContext context) {
    setState(() {
      _isEmailDirty = true;
      _isPasswordDirty = true;
    });
    if (_formKey.currentState?.validate() != true) return;
    context.read<AuthBloc>().add(
          LoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7FB),
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
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildForm(context),
                    const SizedBox(height: 28),
                    _buildSubmitButton(context),
                    const SizedBox(height: 24),
                    _buildDivider(),
                    const SizedBox(height: 24),
                    _buildSignUpRow(context),
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
        // Logo mark
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF6200EE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.shopping_bag_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Welcome back 👋',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in to continue shopping',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w400,
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
        children: [
          // ── Email field ────────────────────────────────────────────────
          _FieldLabel(label: 'Email address'),
          const SizedBox(height: 8),
          TextFormField(
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
            decoration: _inputDecoration(
              hint: 'you@example.com',
              icon: Icons.mail_outline_rounded,
            ),
          ),
          const SizedBox(height: 20),

          // ── Password field ─────────────────────────────────────────────
          _FieldLabel(label: 'Password'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            validator: _validatePassword,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onChanged: (_) {
              if (_isPasswordDirty) _formKey.currentState?.validate();
            },
            onFieldSubmitted: (_) {
              _isPasswordDirty = true;
              _formKey.currentState?.validate();
              _submit(context);
            },
            decoration: _inputDecoration(
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
            ).copyWith(
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
          ),
          const SizedBox(height: 12),

          // ── Forgot password ────────────────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6200EE),
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Forgot password?',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
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
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF6200EE)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isLoading
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFF6200EE).withAlpha(80),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: isLoading ? null : () => _submit(context),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }

  Widget _buildSignUpRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        TextButton(
          onPressed: () => context.go(AppRoutes.login), // update when sign-up route exists
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF6200EE),
            padding: const EdgeInsets.only(left: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Sign Up',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF6200EE), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            BorderSide(color: Theme.of(context).colorScheme.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
      ),
      errorStyle: TextStyle(
        color: Theme.of(context).colorScheme.error,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// ── Small helper widgets ──────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A2E),
        letterSpacing: 0.1,
      ),
    );
  }
}
