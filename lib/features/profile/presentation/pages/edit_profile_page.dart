import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/profile_bloc.dart';
import '../../../widgets/app_snackbar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  String? _localImagePath;
  bool _initialised = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _initControllers(ProfileState state) {
    if (_initialised) return;
    final user = switch (state) {
      ProfileLoaded(:final user) => user,
      ProfileUpdated(:final user) => user,
      ProfileUpdating(:final user) => user,
      _ => null,
    };
    if (user == null) return;
    _nameCtrl = TextEditingController(text: user.fullName);
    _phoneCtrl = TextEditingController(text: user.phone ?? '');
    _initialised = true;
  }

  Future<void> _showImagePickerModal(BuildContext context) async {
    final theme = Theme.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Center(
                child: Text(
                  'Profile Photo',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: theme.colorScheme.primary),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: theme.colorScheme.primary),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (source != null && context.mounted) {
      await _pickImage(context, source); // ← must be awaited
    }
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final theme = Theme.of(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    debugPrint('[pickImage] Starting crop for: ${pickedFile.path}');

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Photo',
          toolbarColor: theme.colorScheme.primary,
          toolbarWidgetColor: theme.colorScheme.onPrimary,
          lockAspectRatio: true,
          hideBottomControls: true,
          aspectRatioPresets: [CropAspectRatioPreset.square], // ← add this
        ),
        IOSUiSettings(
          title: 'Crop Photo',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPresets: [CropAspectRatioPreset.square], // ← add this
        ),
      ],
    );

    debugPrint('[pickImage] Crop result: ${croppedFile?.path}');


    if (croppedFile == null) return;

    setState(() => _localImagePath = croppedFile.path);
    if (context.mounted) {
      context.read<ProfileBloc>().add(UploadAvatar(croppedFile.path));
    }
  }

  void _save(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileBloc>().add(
          UpdateProfile(
            fullName: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim().isEmpty
                ? null
                : _phoneCtrl.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        _initControllers(state);
        if (state is ProfileError) {
          AppSnackBar.showError(context, message: state.message);
        }
        if (state is ProfileUpdated) {
          AppSnackBar.showSuccess(context, message: 'Profile updated!');
          // Only pop after a non-avatar update (avatar updates stay on page)
          if (_localImagePath == null) {
            context.pop();
          } else {
            // Reset local path so next save works correctly
            setState(() => _localImagePath = null);
          }
        }
      },
      builder: (context, state) {
        _initControllers(state);

        final user = switch (state) {
          ProfileLoaded(:final user) => user,
          ProfileUpdated(:final user) => user,
          ProfileUpdating(:final user) => user,
          ProfileError(:final previousUser) => previousUser,
          _ => null,
        };

        final isLoading = state is ProfileLoading ||
            state is ProfileInitial ||
            state is ProfileUpdating;

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Edit Profile', style: textTheme.titleMedium),
            centerTitle: false,
            actions: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ── Avatar ────────────────────────────────────────────────
                  GestureDetector(
                    onTap: isLoading ? null : () => _showImagePickerModal(context),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.secondary,
                              ],
                            ),
                          ),
                          child: ClipOval(
                            child: _buildAvatarContent(
                              avatarUrl: user.avatarUrl,
                              localPath: _localImagePath,
                              name: user.fullName,
                              isLoading: isLoading,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 16,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to change photo',
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 32),

                  // ── Fields ────────────────────────────────────────────────
                  TextFormField(
                    controller: _nameCtrl,
                    enabled: !isLoading,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneCtrl,
                    enabled: !isLoading,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number (optional)',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Save button ───────────────────────────────────────────
                  ElevatedButton(
                    onPressed: isLoading ? null : () => _save(context),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarContent({
    required String? avatarUrl,
    required String? localPath,
    required String name,
    required bool isLoading,
  }) {
    if (isLoading && localPath != null) {
      return Container(
        color: Colors.black38,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
      );
    }
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: avatarUrl,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        placeholder: (_, __) => _buildInitials(name),
        errorWidget: (_, __, ___) => _buildInitials(name),
      );
    }
    return _buildInitials(name);
  }

  Widget _buildInitials(String name) {
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (name.isNotEmpty ? name[0].toUpperCase() : '?');
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 34,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
