import 'package:flutter/foundation.dart';
import 'turso_service.dart';

class SesionService extends ChangeNotifier {
  int? _usuarioId;
  String? _nombre;
  String? _email;

  int? get usuarioId => _usuarioId;
  String? get nombre => _nombre;
  String? get email => _email;
  bool get logueado => _usuarioId != null;

  final TursoService _turso;
  SesionService(this._turso);

  /// Registra un nuevo usuario y lo deja logueado
  Future<String?> registrar(
      String nombre, String email, String password) async {
    try {
      // Verificar si el email ya existe
      final existe = await _turso.buscarUsuarioPorEmail(email);
      if (existe != null) return 'El correo ya está registrado.';

      final id = await _turso.crearUsuarioConPassword(nombre, email, password);
      if (id == null) return 'Error al crear la cuenta.';
      _usuarioId = id;
      _nombre = nombre;
      _email = email;
      notifyListeners();
      return null; // null = éxito
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Inicia sesión con email y contraseña
  Future<String?> login(String email, String password) async {
    try {
      final usuario = await _turso.loginUsuario(email, password);
      if (usuario == null) return 'Correo o contraseña incorrectos.';
      _usuarioId = int.tryParse(usuario['id'].toString());
      _nombre = usuario['nombre'] as String?;
      _email = usuario['email'] as String?;
      notifyListeners();
      return null;
    } catch (e) {
      return 'Error: $e';
    }
  }

  void cerrarSesion() {
    _usuarioId = null;
    _nombre = null;
    _email = null;
    notifyListeners();
  }
}
