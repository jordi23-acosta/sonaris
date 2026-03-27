import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constantes/colores.dart';
import '../constantes/acordes.dart';
import '../services/turso_service.dart';
import '../services/sesion_service.dart';
import '../widgets/diagrama_acorde.dart';

// ── Modelo de pregunta ────────────────────────────────────

enum TipoPregunta {
  nombreAcorde,
  notasAcorde,
  descripcionAcorde,
  diagramaAcorde
}

class Pregunta {
  final TipoPregunta tipo;
  final String acorde; // respuesta correcta
  final String enunciado;
  final List<String> opciones;

  const Pregunta({
    required this.tipo,
    required this.acorde,
    required this.enunciado,
    required this.opciones,
  });
}

// ── Generador de preguntas ────────────────────────────────

List<Pregunta> generarPreguntas({int cantidad = 8}) {
  final rng = Random();
  final lista = <Pregunta>[];
  final tipos = TipoPregunta.values;

  for (int i = 0; i < cantidad; i++) {
    final acorde = acordes[rng.nextInt(acordes.length)];
    final tipo = tipos[rng.nextInt(tipos.length)];
    final otras = acordes.where((a) => a != acorde).toList()..shuffle(rng);
    final distractores = otras.take(3).toList();

    switch (tipo) {
      case TipoPregunta.nombreAcorde:
        final ops = [
          nombreAcorde[acorde]!,
          ...distractores.map((a) => nombreAcorde[a]!)
        ]..shuffle(rng);
        lista.add(Pregunta(
          tipo: tipo,
          acorde: acorde,
          enunciado: '¿Cómo se llama el acorde $acorde?',
          opciones: ops,
        ));

      case TipoPregunta.notasAcorde:
        final notasCorrectas = notasAcorde[acorde]!.join(' - ');
        final ops = [
          notasCorrectas,
          ...distractores.map((a) => notasAcorde[a]!.join(' - '))
        ]..shuffle(rng);
        lista.add(Pregunta(
          tipo: tipo,
          acorde: acorde,
          enunciado: '¿Qué notas forman el acorde $acorde?',
          opciones: ops,
        ));

      case TipoPregunta.descripcionAcorde:
        final ops = [acorde, ...distractores]..shuffle(rng);
        lista.add(Pregunta(
          tipo: tipo,
          acorde: acorde,
          enunciado: descripcionAcorde[acorde]!,
          opciones: ops,
        ));

      case TipoPregunta.diagramaAcorde:
        final ops = [acorde, ...distractores]..shuffle(rng);
        lista.add(Pregunta(
          tipo: tipo,
          acorde: acorde,
          enunciado: '¿Qué acorde representa este diagrama?',
          opciones: ops,
        ));
    }
  }
  return lista;
}

// ── Pantalla principal del quiz ───────────────────────────

class PantallaQuiz extends StatefulWidget {
  const PantallaQuiz({super.key});

  @override
  State<PantallaQuiz> createState() => _EstadoQuiz();
}

class _EstadoQuiz extends State<PantallaQuiz>
    with SingleTickerProviderStateMixin {
  late List<Pregunta> _preguntas;
  int _indice = 0;
  int _puntaje = 0;
  String? _seleccion;
  bool _respondida = false;
  bool _terminado = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _preguntas = generarPreguntas();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Pregunta get _actual => _preguntas[_indice];

  String _respuestaCorrecta() {
    final p = _actual;
    switch (p.tipo) {
      case TipoPregunta.nombreAcorde:
        return nombreAcorde[p.acorde]!;
      case TipoPregunta.notasAcorde:
        return notasAcorde[p.acorde]!.join(' - ');
      case TipoPregunta.descripcionAcorde:
      case TipoPregunta.diagramaAcorde:
        return p.acorde;
    }
  }

  void _responder(String opcion) {
    if (_respondida) return;
    HapticFeedback.selectionClick();
    final correcta = opcion == _respuestaCorrecta();
    if (correcta) {
      HapticFeedback.mediumImpact();
      _puntaje++;
    }
    setState(() {
      _seleccion = opcion;
      _respondida = true;
    });
  }

  void _siguiente() {
    if (_indice < _preguntas.length - 1) {
      _animCtrl.reset();
      setState(() {
        _indice++;
        _seleccion = null;
        _respondida = false;
      });
      _animCtrl.forward();
    } else {
      _guardarResultado();
      setState(() => _terminado = true);
    }
  }

  Future<void> _guardarResultado() async {
    final uid = context.read<SesionService>().usuarioId;
    if (uid == null) return;
    // Guardamos cada pregunta como un intento con acorde = "QUIZ"
    context
        .read<TursoService>()
        .registrarIntento(
          usuarioId: uid,
          acorde: 'QUIZ',
          correcto: _puntaje >= (_preguntas.length ~/ 2),
          confianza: (_puntaje / _preguntas.length) * 100,
        )
        .catchError((_) {});
  }

  void _reiniciar() {
    _animCtrl.reset();
    setState(() {
      _preguntas = generarPreguntas();
      _indice = 0;
      _puntaje = 0;
      _seleccion = null;
      _respondida = false;
      _terminado = false;
    });
    _animCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      body: SafeArea(
        child: _terminado ? _buildResultado() : _buildPregunta(),
      ),
    );
  }

  // ── Pantalla de resultado ─────────────────────────────

  Widget _buildResultado() {
    final porcentaje = (_puntaje / _preguntas.length * 100).round();
    final color = porcentaje >= 70
        ? verde
        : porcentaje >= 40
            ? ambar
            : rojo;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
              border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
            ),
            child: Center(
              child: Text('$porcentaje%',
                  style: TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w700, color: color)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            porcentaje >= 70
                ? '¡Excelente!'
                : porcentaje >= 40
                    ? 'Buen intento'
                    : 'Sigue practicando',
            style: const TextStyle(
                fontSize: 26, fontWeight: FontWeight.w700, color: blanco),
          ),
          const SizedBox(height: 8),
          Text('$_puntaje de ${_preguntas.length} correctas',
              style: const TextStyle(fontSize: 15, color: medio)),
          const SizedBox(height: 48),
          _BotonVerde(texto: 'Intentar de nuevo', onTap: _reiniciar),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text('Volver',
                style: TextStyle(color: medio, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // ── Pregunta activa ───────────────────────────────────

  Widget _buildPregunta() {
    final p = _actual;
    final correcta = _respuestaCorrecta();
    final progreso = (_indice + 1) / _preguntas.length;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close_rounded, color: medio, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progreso,
                  minHeight: 4,
                  backgroundColor: tarjeta2,
                  valueColor: const AlwaysStoppedAnimation(verde),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text('${_indice + 1}/${_preguntas.length}',
                style: const TextStyle(color: medio, fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              // Diagrama si aplica
              if (p.tipo == TipoPregunta.diagramaAcorde) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: tarjeta,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: DiagramaAcordeWidget(acorde: p.acorde, alto: 160),
                ),
                const SizedBox(height: 20),
              ],
              // Enunciado
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: tarjeta,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(p.enunciado,
                    style: const TextStyle(
                        fontSize: 17, color: blanco, height: 1.4)),
              ),
              const SizedBox(height: 20),
              // Opciones
              ...p.opciones.map((op) => _OpcionWidget(
                    texto: op,
                    seleccionada: _seleccion == op,
                    correcta: _respondida && op == correcta,
                    incorrecta:
                        _respondida && _seleccion == op && op != correcta,
                    onTap: () => _responder(op),
                  )),
              const SizedBox(height: 16),
              // Botón siguiente
              if (_respondida)
                AnimatedOpacity(
                  opacity: 1,
                  duration: const Duration(milliseconds: 200),
                  child: _BotonVerde(
                    texto: _indice < _preguntas.length - 1
                        ? 'Siguiente'
                        : 'Ver resultado',
                    onTap: _siguiente,
                  ),
                ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────

class _OpcionWidget extends StatelessWidget {
  final String texto;
  final bool seleccionada;
  final bool correcta;
  final bool incorrecta;
  final VoidCallback onTap;

  const _OpcionWidget({
    required this.texto,
    required this.seleccionada,
    required this.correcta,
    required this.incorrecta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.white.withValues(alpha: 0.07);
    Color bgColor = tarjeta;
    Color textColor = blanco;
    Widget? trailing;

    if (correcta) {
      borderColor = verde.withValues(alpha: 0.5);
      bgColor = verde.withValues(alpha: 0.08);
      textColor = verde;
      trailing = const Icon(Icons.check_circle_rounded, color: verde, size: 18);
    } else if (incorrecta) {
      borderColor = rojo.withValues(alpha: 0.5);
      bgColor = rojo.withValues(alpha: 0.08);
      textColor = rojo;
      trailing = const Icon(Icons.cancel_rounded, color: rojo, size: 18);
    } else if (seleccionada) {
      borderColor = verde.withValues(alpha: 0.3);
      bgColor = verde.withValues(alpha: 0.05);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(children: [
          Expanded(
              child: Text(texto,
                  style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                      fontWeight: FontWeight.w500))),
          if (trailing != null) trailing,
        ]),
      ),
    );
  }
}

class _BotonVerde extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;
  const _BotonVerde({required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
            color: verde, borderRadius: BorderRadius.circular(14)),
        child: Text(texto,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF080808))),
      ),
    );
  }
}
