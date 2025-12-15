import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/languages.dart';
import '../models/edit_profile_result.dart';
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
  });

  final String initialName;
  final String initialNative; // código
  final List<String> initialLearning; // códigos
  final String? initialAvatarPath;

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
        .where((code) => !_learning.contains(code) && code != _native)
        .toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay más idiomas para añadir')),
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

  void _save() {
    if (!FormValidators.isFormValid(_formKey)) return;
    Navigator.pop(
      context,
      EditProfileResult(
        name: _nameCtrl.text.trim(),
        nativeLanguage: _native,
        learningLanguages: _learning,
        avatarFile: _pickedImage,
      ),
    );
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
        title: const Text('Editar perfil'),
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
                          label: const Text('Cambiar foto'),
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
                        'Nombre',
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
                        'Idioma nativo',
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
                          'Idiomas que estás aprendiendo',
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
                            label: const Text('Añadir'),
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
                    label: const Text('Guardar cambios'),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSM),
                Text(
                  'Los cambios se aplicarán al volver al perfil.',
                  style: TextStyle(color: AppTheme.subtle, fontSize: AppDimensions.fontSizeXS),
                ),
                const SizedBox(height: AppDimensions.spacingXXXL),
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
                    onPressed: () {
                      // TODO: conectar con backend para eliminar la cuenta
                      // Por ahora solo interfaz
                    },
                    icon: const Icon(Icons.delete_forever_rounded),
                    label: const Text('Eliminar perfil'),
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

