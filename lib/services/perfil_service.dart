import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class PerfilService extends ChangeNotifier {
  String? _fotoPath; // ruta local si eligió galería/cámara
  String? _avatarAsset; // asset si eligió avatar predefinido

  String? get fotoPath => _fotoPath;
  String? get avatarAsset => _avatarAsset;
  bool get tieneFoto => _fotoPath != null || _avatarAsset != null;

  final _picker = ImagePicker();

  static const List<String> avatares = [
    'assets/avatares/avatar1.png',
    'assets/avatares/avatar2.png',
    'assets/avatares/avatar3.png',
    'assets/avatares/avatar4.png',
  ];

  void seleccionarAvatar(String asset) {
    _avatarAsset = asset;
    _fotoPath = null;
    notifyListeners();
  }

  Future<void> seleccionarDeGaleria() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 400,
    );
    if (picked == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final dest = File('${dir.path}/avatar_perfil.jpg');
    await File(picked.path).copy(dest.path);
    _fotoPath = dest.path;
    _avatarAsset = null;
    notifyListeners();
  }

  Future<void> tomarFoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 400,
    );
    if (picked == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final dest = File('${dir.path}/avatar_perfil.jpg');
    await File(picked.path).copy(dest.path);
    _fotoPath = dest.path;
    _avatarAsset = null;
    notifyListeners();
  }

  void limpiar() {
    _fotoPath = null;
    _avatarAsset = null;
    notifyListeners();
  }
}
