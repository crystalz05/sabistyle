import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/profile_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileView();
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError && state.previousUser == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: colorScheme.error),
                    const SizedBox(height: 12),
                    Text(state.message,
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () =>
                          context.read<ProfileBloc>().add(FetchProfile()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final user = switch (state) {
            ProfileLoaded(:final user) => user,
            ProfileUpdated(:final user) => user,
            ProfileUpdating(:final user) => user,
            ProfileError(:final previousUser) => previousUser,
            _ => null,
          };

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          debugPrint('user.profileurl: ${user.avatarUrl}');

          return CustomScrollView(
            slivers: [
              // ── Header ─────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.secondary.withValues(alpha: 0.6),
                        colorScheme.surface,
                      ],
                    ),
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 24,
                    bottom: 32,
                    left: 24,
                    right: 24,
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.secondary,
                                ],
                              ),
                            ),
                            child: user.avatarUrl != null &&
                                    user.avatarUrl!.isNotEmpty
                                ? ClipOval(
                                    child: CachedNetworkImage(
                                      key: ValueKey(user.avatarUrl), // ← forces rebuild when URL changes
                                      imageUrl: user.avatarUrl!,
                                      fit: BoxFit.cover,
                                      width: 96,
                                      height: 96,
                                      placeholder: (_, __) => _InitialsBadge(name: user.fullName),
                                      errorWidget: (_, __, ___) => _InitialsBadge(name: user.fullName),
                                    ),
                                  )
                                : _InitialsBadge(name: user.fullName),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: textTheme.bodyMedium,
                      ),
                      if (user.phone != null && user.phone!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(user.phone!, style: textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Menu Items ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Account',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ProfileMenuCard(
                        children: [
                          _MenuItem(
                            icon: Icons.person_outline_rounded,
                            label: 'Edit Profile',
                            onTap: () => context.push(AppRoutes.editProfile),
                          ),
                          _Divider(),
                          _MenuItem(
                            icon: Icons.location_on_outlined,
                            label: 'My Addresses',
                            onTap: () =>
                                context.push(AppRoutes.profileAddresses),
                          ),
                          _Divider(),
                          _MenuItem(
                            icon: Icons.lock_outline_rounded,
                            label: 'Change Password',
                            onTap: () =>
                                context.push(AppRoutes.changePassword),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'More',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ProfileMenuCard(
                        children: [
                          _MenuItem(
                            icon: Icons.logout_rounded,
                            label: 'Logout',
                            iconColor: colorScheme.error,
                            labelColor: colorScheme.error,
                            onTap: () => _confirmLogout(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            child: Text('Logout',
                style: TextStyle(color: colorScheme.error)),
          ),
        ],
      ),
    );
  }
}

// ── Supporting Widgets ──────────────────────────────────────────────────────

class _InitialsBadge extends StatelessWidget {
  final String name;
  const _InitialsBadge({required this.name});

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  final List<Widget> children;
  const _ProfileMenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(children: children),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: iconColor ?? colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Divider(
      height: 1,
      indent: 58,
      color: colorScheme.outlineVariant,
    );
  }
}
