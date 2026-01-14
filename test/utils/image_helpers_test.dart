import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_speakbuddy/utils/image_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('getAvatarImageProvider', () {
    test('debe retornar FileImage cuando hay pickedFile', () {
      // Crear un archivo temporal para la prueba
      final tempFile = File('test_avatar.jpg');
      
      try {
        tempFile.createSync();
        final provider = getAvatarImageProvider(
          pickedFile: tempFile,
          filePath: '/other/path.jpg',
          assetPath: 'assets/default.jpg',
        );

        expect(provider, isA<FileImage>());
        final fileImage = provider as FileImage;
        expect(fileImage.file.path, tempFile.path);
      } finally {
        if (tempFile.existsSync()) {
          tempFile.deleteSync();
        }
      }
    });

    test('debe retornar FileImage cuando hay filePath (sin pickedFile)', () {
      final provider = getAvatarImageProvider(
        filePath: '/path/to/avatar.jpg',
        assetPath: 'assets/default.jpg',
      );

      expect(provider, isA<FileImage>());
      final fileImage = provider as FileImage;
      expect(fileImage.file.path, '/path/to/avatar.jpg');
    });

    test('debe retornar AssetImage cuando solo hay assetPath', () {
      final provider = getAvatarImageProvider(
        assetPath: 'lib/assets/images/default.jpg',
      );

      expect(provider, isA<AssetImage>());
      final assetImage = provider as AssetImage;
      expect(assetImage.assetName, 'lib/assets/images/default.jpg');
    });

    test('debe priorizar pickedFile sobre filePath', () {
      final tempFile = File('test_avatar.jpg');
      
      try {
        tempFile.createSync();
        final provider = getAvatarImageProvider(
          pickedFile: tempFile,
          filePath: '/other/path.jpg',
        );

        expect(provider, isA<FileImage>());
        final fileImage = provider as FileImage;
        expect(fileImage.file.path, tempFile.path);
        expect(fileImage.file.path, isNot('/other/path.jpg'));
      } finally {
        if (tempFile.existsSync()) {
          tempFile.deleteSync();
        }
      }
    });

    test('debe priorizar filePath sobre assetPath', () {
      final provider = getAvatarImageProvider(
        filePath: '/path/to/avatar.jpg',
        assetPath: 'assets/default.jpg',
      );

      expect(provider, isA<FileImage>());
      expect(provider, isNot(isA<AssetImage>()));
    });

    test('debe retornar null cuando todos los parámetros son null', () {
      final provider = getAvatarImageProvider();
      expect(provider, isNull);
    });

    test('debe retornar null cuando todos los parámetros están vacíos', () {
      final provider = getAvatarImageProvider(
        filePath: null,
        assetPath: null,
      );
      expect(provider, isNull);
    });
  });
}
