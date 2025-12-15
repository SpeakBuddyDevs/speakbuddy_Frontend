import 'dart:io';

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

