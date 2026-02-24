import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/language_ids.dart';
import '../constants/languages.dart';
import '../constants/routes.dart';
import '../models/edit_profile_result.dart';
import '../repositories/api_users_repository.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../utils/image_helpers.dart';
import '../widgets/common/language_selector_bottom_sheet.dart';
import '../constants/dimensions.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.initialName,
    required this.initialNative,
    required this.initialLearning,
    this.initialAvatarPath,
    this.userId,
  });

  final String initialName;
  final String initialNative; // código
  final List<String> initialLearning; // códigos
  final String? initialAvatarPath;
  /// Si se pasa, al guardar se envían los cambios al backend (PUT profile, PUT native, POST learn).
  final String? userId;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late String _native; // código
  late List<String> _learning; // códigos
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _native = widget.initialNative;
    _learning = [...widget.initialLearning]; // copia
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: AppDimensions.imageQuality,
    );
    if (x != null) {
      setState(() => _pickedImage = File(x.path));
    }
  }

  void _addLearningLanguage() async {
    final available = AppLanguages.availableCodes
        .where((code) =>
            !_learning.contains(code) &&
            code != _native &&
            LanguageIds.learningCodesSupportedByBackend.contains(code))
        .toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No more languages to add')),
      );
      return;
    }

    String selected = available.first;
    await showLanguageSelectorBottomSheet(
      context,
      available,
      selected,
    ).then((value) {
      if (value is String && !_learning.contains(value)) {
        setState(() => _learning.add(value));
      }
    });
  }

  /// Guardar cambios. Si [userId] existe, llama al backend (PUT profile, PUT native, POST/DELETE learn, POST picture).
  Future<void> _save() async {
    if (!FormValidators.isFormValid(_formKey)) return;

    final userId = widget.userId;
    if (userId == null || userId.isEmpty) {
      if (!mounted) return;
      Navigator.pop(
        context,
        EditProfileResult(
          name: _nameCtrl.text.trim(),
          nativeLanguage: _native,
          learningLanguages: List.from(_learning),
          avatarFile: _pickedImage,
        ),
      );
      return;
    }

    final fullName = _nameCtrl.text.trim();
    final parts = fullName.split(RegExp(r'\s+'));
    final name = parts.isNotEmpty ? parts.first : '';
    final surname = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final repo = ApiUsersRepository();
    String? uploadedAvatarUrl;

    // 1. Subir foto de perfil si se seleccionó una nueva
    if (_pickedImage != null) {
      uploadedAvatarUrl = await repo.uploadProfilePicture(userId, _pickedImage!.path);
      if (uploadedAvatarUrl == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload profile picture')),
        );
        return;
      }
    }

    // 2. Actualizar perfil (nombre, apellido)
    final okProfile = await repo.updateProfile(userId, name: name, surname: surname, profilePictureUrl: null);
    if (!okProfile) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
      return;
    }

    // 3. Actualizar idioma nativo si cambió
    if (widget.initialNative != _native) {
      final okNative = await repo.updateNativeLanguage(userId, _native);
      if (!okNative) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update native language')),
        );
        return;
      }
    }

    final initialSet = widget.initialLearning.toSet();
    final currentSet = _learning.toSet();

    // 4. Eliminar idiomas que ya no están en la lista
    final removedLanguages = initialSet.difference(currentSet);
    for (final code in removedLanguages) {
      final ok = await repo.deleteLearningLanguage(userId, code);
      if (!ok) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove language ${AppLanguages.getName(code)}')),
        );
        return;
      }
    }

    // 5. Añadir idiomas nuevos
    final addedLanguages = currentSet.difference(initialSet);
    for (final code in addedLanguages) {
      if (!LanguageIds.learningCodesSupportedByBackend.contains(code)) continue;
      final ok = await repo.addLearningLanguage(userId, code, levelId: 1);
      if (!ok) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add language ${AppLanguages.getName(code)}')),
        );
        return;
      }
    }

    if (!mounted) return;
    Navigator.pop(
      context,
      EditProfileResult(
        name: fullName,
        nativeLanguage: _native,
        learningLanguages: List.from(_learning),
        avatarFile: _pickedImage,
        avatarUrl: uploadedAvatarUrl, // Nueva URL del backend
      ),
    );
  }

  /// Eliminar cuenta con confirmación
  Future<void> _deleteAccount() async {
    // Mostrar diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text('Delete account'),
        content: const Text(
          'Are you sure you want to delete your account?\n\n'
          'This action cannot be undone and you will lose all your data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Llamar al backend
    final repo = ApiUsersRepository();
    final ok = await repo.deleteAccount();

    if (!mounted) return;

    // Cerrar loading
    Navigator.pop(context);

    if (ok) {
      // Limpiar sesión
      await AuthService().logout();

      if (!mounted) return;

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your account has been deleted'),
          backgroundColor: Colors.green,
        ),
      );

      // Redirigir a login
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } else {
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete account. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarProvider = getAvatarImageProvider(
      pickedFile: _pickedImage,
      filePath: widget.initialAvatarPath,
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Edit profile'),
      ),
      body: SingleChildScrollView(
        padding: AppDimensions.paddingScreen,
        child: Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppTheme.card,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingInput.horizontal,
                vertical: AppDimensions.paddingInputVertical.vertical,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelStyle: TextStyle(color: AppTheme.text),
              floatingLabelStyle: TextStyle(
                color: AppTheme.text,
              ),
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // tarjeta avatar
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    border: Border.all(color: AppTheme.border),
                  ),
                  padding: AppDimensions.paddingCard,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: AppDimensions.avatarSizeM,
                        backgroundImage: avatarProvider, // ✅ usa avatarProvider
                        backgroundColor: AppTheme.panel,
                        child: avatarProvider == null
                            ? const Icon(
                                Icons.person,
                                size: AppDimensions.iconSizeXL,
                                color: AppTheme.subtle,
                              )
                            : null,
                      ),

                      const SizedBox(width: AppDimensions.spacingL),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library_rounded),
                          label: const Text('Change photo'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // tarjeta datos
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    border: Border.all(color: AppTheme.border),
                  ),
                  padding: AppDimensions.paddingCard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Etiqueta arriba del campo de texto
                      Text(
                        'Name',
                        style: TextStyle(
                          color: AppTheme.text,
                          fontSize: AppDimensions.fontSizeS,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingS),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          // sin labelText para que no aparezca dentro de la caja
                        ),
                        validator: FormValidators.validateNameRequired,
                      ),

                      const SizedBox(height: AppDimensions.spacingL),

                      // Etiqueta arriba del combo
                      Text(
                        'Native language',
                        style: TextStyle(
                          color: AppTheme.text,
                          fontSize: AppDimensions.fontSizeS,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingS),
                      DropdownButtonFormField<String>(
                        initialValue: _native,
                        decoration: const InputDecoration(
                          // también sin labelText
                        ),
                        items: AppLanguages.codeToName.entries
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _native = v);
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacingL),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Languages you are learning',
                          style: TextStyle(
                            color: AppTheme.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingSM),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final code in _learning)
                            Chip(
                              label: Text(
                                AppLanguages.getName(code),
                                style: TextStyle(
                                  color: AppTheme.text,
                                ),
                              ),
                              backgroundColor: AppTheme.panel,
                              onDeleted: () {
                                setState(() => _learning.remove(code));
                              },
                            ),
                          ActionChip(
                            label: const Text('Add'),
                            avatar: const Icon(Icons.add_rounded),
                            onPressed: _addLearningLanguage,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXXXL),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Save changes'),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSM),
                Text(
                  'Changes will apply when you return to the profile.',
                  style: TextStyle(color: AppTheme.subtle, fontSize: AppDimensions.fontSizeXS),
                ),
                const SizedBox(height: AppDimensions.spacingXXXL),
                // Botón para eliminar cuenta
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      foregroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
                      ),
                      padding: AppDimensions.paddingButtonLarge,
                    ),
                    onPressed: _deleteAccount,
                    icon: const Icon(Icons.delete_forever_rounded),
                    label: const Text('Delete profile'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

