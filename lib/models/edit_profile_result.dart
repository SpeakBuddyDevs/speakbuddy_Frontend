import 'dart:io';

/// Resultado que devolveremos al guardar
class EditProfileResult {
  final String name;
  final String nativeLanguage; // código: 'ES','EN','FR',...
  final List<String> learningLanguages; // lista de códigos
  final File? avatarFile; // foto nueva (si se cambió, archivo local)
  final String? avatarUrl; // URL del backend (si se subió exitosamente)

  EditProfileResult({
    required this.name,
    required this.nativeLanguage,
    required this.learningLanguages,
    this.avatarFile,
    this.avatarUrl,
  });
}

