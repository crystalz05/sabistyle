import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/app_text_field.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  final _currentFocusNode = FocusNode();
  final _newFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _isCurrentDirty = false;
  bool _isNewDirty = false;
  bool _isConfirmDirty = false;

  bool _isReauthenticating = false;

  @override
  void initState() {
    super.initState();

    _currentFocusNode.addListener(() {
      if (!_currentFocusNode.hasFocus && !_isCurrentDirty) {
        setState(() => _isCurrentDirty = true);
        _formKey.currentState?.validate();
      }
    });

    _newFocusNode.addListener(() {
      if (!_newFocusNode.hasFocus && !_isNewDirty) {
        setState(() => _isNewDirty = true);
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
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _currentFocusNode.dispose();
    _newFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  String? _validateCurrentPassword(String? value) {
    if (!_isCurrentDirty) return null;
    if (value == null || value.isEmpty) return 'Current password is required';
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (!_isNewDirty) return null;
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (value == _currentPasswordCtrl.text) {
      return 'New password must be different from the old one';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (!_isConfirmDirty) return null;
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _newPasswordCtrl.text) return 'Passwords do not match';
    return null;
  }

  void _submit(BuildContext context) {
    setState(() {
      _isCurrentDirty = true;
      _isNewDirty = true;
      _isConfirmDirty = true;
    });

    if (_formKey.currentState?.validate() != true) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final email = authState.user.email;
      // First, re-authenticate using the current password
      setState(() => _isReauthenticating = true);
      context.read<AuthBloc>().add(
            LoginRequested(email: email, password: _currentPasswordCtrl.text),
          );
    } else {
      AppSnackBar.showError(context, message: 'You must be logged in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password', style: textTheme.titleMedium),
        centerTitle: false,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            setState(() => _isReauthenticating = false);
            AppSnackBar.showError(context, message: state.message);
          } else if (state is Authenticated && _isReauthenticating) {
            // Re-authentication successful! Now trigger the actual password update.
            setState(() => _isReauthenticating = false);
            context.read<AuthBloc>().add(
                  UpdatePasswordRequested(_newPasswordCtrl.text),
                );
          } else if (state is PasswordUpdated) {
            AppSnackBar.showSuccess(
              context,
              message: 'Password updated successfully.',
            );
            context.go(AppRoutes.profile);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading || _isReauthenticating;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Please enter your current password to verify your identity, then create a new strong password.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    label: 'Current Password',
                    controller: _currentPasswordCtrl,
                    focusNode: _currentFocusNode,
                    validator: _validateCurrentPassword,
                    obscureText: _obscureCurrent,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) {
                      if (_isCurrentDirty) _formKey.currentState?.validate();
                    },
                    onFieldSubmitted: (_) {
                      _isCurrentDirty = true;
                      _formKey.currentState?.validate();
                      _newFocusNode.requestFocus();
                    },
                    hintText: '••••••••',
                    prefixIcon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrent
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  AppTextField(
                    label: 'New Password',
                    controller: _newPasswordCtrl,
                    focusNode: _newFocusNode,
                    validator: _validateNewPassword,
                    obscureText: _obscureNew,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) {
                      if (_isNewDirty) _formKey.currentState?.validate();
                    },
                    onFieldSubmitted: (_) {
                      _isNewDirty = true;
                      _formKey.currentState?.validate();
                      _confirmFocusNode.requestFocus();
                    },
                    hintText: '••••••••',
                    prefixIcon: Icons.lock_reset_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNew
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'Confirm New Password',
                    controller: _confirmPasswordCtrl,
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
                    prefixIcon: Icons.lock_reset_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      onPressed: () => setState(
                          () => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  const SizedBox(height: 48),
                  AppButton(
                    text: 'Update Password',
                    onPressed: () => _submit(context),
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
