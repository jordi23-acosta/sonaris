import 'dart:convert';
import 'package:http/http.dart' as http;

class TursoService {
  static const String _url =
      'https://sonaris-jordanacosta24.aws-ap-northeast-1.turso.io/v2/pipeline';
  static const String _token =
      'eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9.eyJhIjoicnciLCJpYXQiOjE3NzQ2MjUwOTQsImlkIjoiMDE5ZDExMzEtNzUwMS03MmUwLWE1NGItYWM2NDY3MzkxYzIyIiwicmlkIjoiNDhjZjQ1YjMtMTc4NC00OWQ4LWI3MzMtZDgxNmZkOGQ1NDQyIn0.Ni9OjemzeYNUANQnAp5BfSpXvbFDEjxYl9MO6A5Ull-yGVoMiSC5MZVArEUbANmanox4CJr0wsmJwKfANuaSAA';

  Future<List<Map<String, dynamic>>> _execute(
      List<Map<String, dynamic>> stmts) async {
    final res = await http
        .post(
          Uri.parse(_url),
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'requests':
                stmts.map((s) => {'type': 'execute', 'stmt': s}).toList()
                  ..add({'type': 'close'})
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) throw Exception('Turso error ${res.statusCode}');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = data['results'] as List;
    return results
        .where((r) => r['type'] == 'ok' && r['response']?['type'] == 'execute')
        .map((r) => r['response'] as Map<String, dynamic>)
        .toList();
  }

  List<Map<String, dynamic>> _parseRows(Map<String, dynamic> response) {
    final result = response['result'] as Map<String, dynamic>?;
    if (result == null) return [];
    final cols =
        (result['cols'] as List).map((c) => c['name'] as String).toList();
    final rows = result['rows'] as List;
    return rows.map((row) {
      final cells = row as List;
      return {for (var i = 0; i < cols.length; i++) cols[i]: cells[i]['value']};
    }).toList();
  }

  // ── Usuarios ──────────────────────────────────────────────

  Future<int?> crearUsuario(String nombre, String email) async {
    final results = await _execute([
      {
        'sql': 'INSERT OR IGNORE INTO usuarios (nombre, email) VALUES (?, ?)',
        'args': [
          {'type': 'text', 'value': nombre},
          {'type': 'text', 'value': email},
        ],
      },
      {
        'sql': 'SELECT id FROM usuarios WHERE email = ?',
        'args': [
          {'type': 'text', 'value': email}
        ],
      },
    ]);
    if (results.length < 2) return null;
    final rows = _parseRows(results[1]);
    if (rows.isEmpty) return null;
    return int.tryParse(rows.first['id'].toString());
  }

  Future<int?> crearUsuarioConPassword(
      String nombre, String email, String password) async {
    final results = await _execute([
      {
        'sql':
            'INSERT INTO usuarios (nombre, email, password) VALUES (?, ?, ?)',
        'args': [
          {'type': 'text', 'value': nombre},
          {'type': 'text', 'value': email},
          {'type': 'text', 'value': password},
        ],
      },
      {
        'sql': 'SELECT id FROM usuarios WHERE email = ?',
        'args': [
          {'type': 'text', 'value': email}
        ],
      },
    ]);
    if (results.length < 2) return null;
    final rows = _parseRows(results[1]);
    if (rows.isEmpty) return null;
    return int.tryParse(rows.first['id'].toString());
  }

  Future<Map<String, dynamic>?> buscarUsuarioPorEmail(String email) async {
    final results = await _execute([
      {
        'sql': 'SELECT id, nombre, email FROM usuarios WHERE email = ?',
        'args': [
          {'type': 'text', 'value': email}
        ],
      },
    ]);
    final rows = _parseRows(results.first);
    return rows.isEmpty ? null : rows.first;
  }

  Future<Map<String, dynamic>?> loginUsuario(
      String email, String password) async {
    final results = await _execute([
      {
        'sql':
            'SELECT id, nombre, email FROM usuarios WHERE email = ? AND password = ?',
        'args': [
          {'type': 'text', 'value': email},
          {'type': 'text', 'value': password},
        ],
      },
    ]);
    final rows = _parseRows(results.first);
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, dynamic>>> getUsuarios() async {
    final results = await _execute([
      {'sql': 'SELECT * FROM usuarios ORDER BY creado_en DESC', 'args': []},
    ]);
    return _parseRows(results.first);
  }

  Future<void> actualizarNombre(int id, String nombre) async {
    await _execute([
      {
        'sql': 'UPDATE usuarios SET nombre = ? WHERE id = ?',
        'args': [
          {'type': 'text', 'value': nombre},
          {'type': 'integer', 'value': id.toString()},
        ],
      },
    ]);
  }

  Future<void> actualizarPassword(int id, String password) async {
    await _execute([
      {
        'sql': 'UPDATE usuarios SET password = ? WHERE id = ?',
        'args': [
          {'type': 'text', 'value': password},
          {'type': 'integer', 'value': id.toString()},
        ],
      },
    ]);
  }

  // ── Intentos ──────────────────────────────────────────────

  Future<void> registrarIntento({
    required int usuarioId,
    required String acorde,
    required bool correcto,
    required double confianza,
  }) async {
    await _execute([
      {
        'sql':
            'INSERT INTO intentos (usuario_id, acorde, correcto, confianza) VALUES (?, ?, ?, ?)',
        'args': [
          {'type': 'integer', 'value': usuarioId.toString()},
          {'type': 'text', 'value': acorde},
          {'type': 'integer', 'value': correcto ? '1' : '0'},
          {'type': 'float', 'value': confianza.toString()},
        ],
      },
    ]);
  }

  Future<List<Map<String, dynamic>>> getIntentos({int? usuarioId}) async {
    final sql = usuarioId != null
        ? 'SELECT * FROM intentos WHERE usuario_id = ? ORDER BY fecha DESC LIMIT 50'
        : 'SELECT * FROM intentos ORDER BY fecha DESC LIMIT 50';
    final args = usuarioId != null
        ? [
            {'type': 'integer', 'value': usuarioId.toString()}
          ]
        : [];
    final results = await _execute([
      {'sql': sql, 'args': args}
    ]);
    return _parseRows(results.first);
  }

  // ── Niveles ───────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getNiveles() async {
    final results = await _execute([
      {'sql': 'SELECT * FROM niveles ORDER BY orden', 'args': []},
    ]);
    return _parseRows(results.first);
  }

  // ── Progreso ──────────────────────────────────────────────

  Future<void> actualizarProgreso({
    required int usuarioId,
    required int nivelId,
    required bool completado,
  }) async {
    await _execute([
      {
        'sql': '''
          INSERT INTO progreso (usuario_id, nivel_id, completado)
          VALUES (?, ?, ?)
          ON CONFLICT(usuario_id, nivel_id) DO UPDATE SET completado = excluded.completado
        ''',
        'args': [
          {'type': 'integer', 'value': usuarioId.toString()},
          {'type': 'integer', 'value': nivelId.toString()},
          {'type': 'integer', 'value': completado ? '1' : '0'},
        ],
      },
    ]);
  }

  Future<List<Map<String, dynamic>>> getProgreso(int usuarioId) async {
    final results = await _execute([
      {
        'sql': 'SELECT * FROM progreso WHERE usuario_id = ?',
        'args': [
          {'type': 'integer', 'value': usuarioId.toString()}
        ],
      },
    ]);
    return _parseRows(results.first);
  }
}
