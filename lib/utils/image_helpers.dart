import 'dart:io';
import 'package:flutter/material.dart';

/// Helper para gestionar ImageProvider de avatares
///
/// Prioridad:
/// 1. avatarUrl: URL remota (p. ej. desde GET /me)
/// 2. pickedFile: Archivo seleccionado recientemente
/// 3. filePath: Ruta de archivo local
/// 4. assetPath: Asset por defecto
///
/// Retorna null si todos los parámetros son null.
ImageProvider? getAvatarImageProvider({
  String? avatarUrl,
  File? pickedFile,
  String? filePath,
  String? assetPath,
}) {
  if (avatarUrl != null && avatarUrl.isNotEmpty) {
    return NetworkImage(avatarUrl);
  }
  if (pickedFile != null) {
    return FileImage(pickedFile);
  }
  if (filePath != null && filePath.isNotEmpty) {
    return FileImage(File(filePath));
  }
  if (assetPath != null && assetPath.isNotEmpty) {
    return AssetImage(assetPath);
  }
  return null;
}

