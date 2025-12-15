import 'dart:io';
import 'package:flutter/material.dart';

/// Helper para gestionar ImageProvider de avatares
/// 
/// Esta función centraliza la lógica de creación de ImageProvider para avatares,
/// siguiendo una prioridad específica:
/// 1. pickedFile: Si hay un archivo seleccionado recientemente, se usa primero
/// 2. filePath: Si hay una ruta de archivo guardada, se usa como segunda opción
/// 3. assetPath: Si no hay archivos, se usa un asset por defecto
/// 
/// Retorna null si todos los parámetros son null.
ImageProvider? getAvatarImageProvider({
  File? pickedFile,
  String? filePath,
  String? assetPath,
}) {
  if (pickedFile != null) {
    return FileImage(pickedFile);
  }
  if (filePath != null) {
    return FileImage(File(filePath));
  }
  if (assetPath != null) {
    return AssetImage(assetPath);
  }
  return null;
}

