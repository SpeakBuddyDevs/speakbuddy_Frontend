import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Resultado que devolveremos al guardar
class EditProfileResult {
  final String name;
  final String nativeLanguage; // código: 'ES','EN','FR',...
  final List<String> learningLanguages; // lista de códigos
  final File? avatarFile; // foto nueva (si se cambió)

  EditProfileResult({
    required this.name,
    required this.nativeLanguage,
    required this.learningLanguages,
    this.avatarFile,
  });
}

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

  // catálogo simple de idiomas (código -> nombre)
  static const Map<String, String> _langs = {
    'ES': 'Español',
    'EN': 'Inglés',
    'FR': 'Francés',
    'DE': 'Alemán',
    'IT': 'Italiano',
    'PT': 'Portugués',
  };

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
      imageQuality: 85,
    );
    if (x != null) {
      setState(() => _pickedImage = File(x.path));
    }
  }

  void _addLearningLanguage() async {
    final available = _langs.keys
        .where((code) => !_learning.contains(code) && code != _native)
        .toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay más idiomas para añadir')),
      );
      return;
    }

    String selected = available.first;
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFF151B2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selected,
                dropdownColor: const Color(0xFF151B2C),
                style: const TextStyle(color: Color(0xFFE7EAF3)),
                decoration: const InputDecoration(labelText: 'Idioma'),
                items: available
                    .map(
                      (c) =>
                          DropdownMenuItem(value: c, child: Text(_langs[c]!)),
                    )
                    .toList(),
                onChanged: (v) => selected = v ?? selected,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, selected);
                  },
                  child: const Text('Añadir'),
                ),
              ),
            ],
          ),
        );
      },
    ).then((value) {
      if (value is String && !_learning.contains(value)) {
        setState(() => _learning.add(value));
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
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
    final bg = const Color(0xFF0E1320);
    final card = const Color(0xFF151B2C);
    final border = const Color(0xFF2B3246);
    final text = const Color(0xFFE7EAF3);
    final subtle = const Color(0xFF98A3B8);

    ImageProvider? avatarProvider;
    if (_pickedImage != null) {
      avatarProvider = FileImage(_pickedImage!);
    } else if (widget.initialAvatarPath != null) {
      avatarProvider = FileImage(File(widget.initialAvatarPath!));
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        title: const Text('Editar perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              fillColor: Color.fromARGB(255, 255, 255, 255),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 20,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelStyle: TextStyle(color: Color.fromARGB(255, 255, 0, 0)),
              floatingLabelStyle: TextStyle(color: Color.fromARGB(255, 255, 0, 0)),
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // tarjeta avatar
                Container(
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: avatarProvider, // ✅ usa avatarProvider
                        backgroundColor: const Color(0xFF111726),
                        child: avatarProvider == null
                            ? const Icon(
                                Icons.person,
                                size: 36,
                                color: Colors.white54,
                              )
                            : null,
                      ),

                      const SizedBox(width: 16),
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
                const SizedBox(height: 16),

                // tarjeta datos
                Container(
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Escribe tu nombre'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _native,
                        decoration: const InputDecoration(
                          labelText: 'Idioma nativo',
                        ),
                        items: _langs.entries
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() {
                            _native = v;
                            // si el nativo está en "aprendiendo", lo mantenemos (permitido),
                            // pero evitamos duplicados al añadir nuevos.
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Idiomas que estás aprendiendo',
                          style: TextStyle(
                            color: text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final code in _learning)
                            Chip(
                              label: Text(
                                _langs[code] ?? code,
                                style: const TextStyle(
                                  color: Color(0xFFE7EAF3),
                                ), // 👈 texto claro
                              ),
                              backgroundColor: const Color(0xFF111726),
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
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Guardar cambios'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Los cambios se aplicarán al volver al perfil.',
                  style: TextStyle(color: subtle, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
