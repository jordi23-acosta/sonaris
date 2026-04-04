import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../constantes/colores.dart';
import '../constantes/acordes.dart';
import '../widgets/diagrama_acorde.dart';

// ── Selector de acordes por nivel ────────────────────────
class SelectorAcordes extends StatelessWidget {
  final String? seleccionado;
  final void Function(String) alSeleccionar;
  const SelectorAcordes(
      {super.key, this.seleccionado, required this.alSeleccionar});

  static const _coloresNivel = {
    'básico': Color(0xFF00E676), // verde
    'intermedio': Color(0xFFFFD54F), // ambar
    'difícil': Color(0xFFFF5252), // rojo
  };

  static const _iconosNivel = {
    'básico': Icons.signal_cellular_alt_1_bar_rounded,
    'intermedio': Icons.signal_cellular_alt_2_bar_rounded,
    'difícil': Icons.signal_cellular_alt_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: acordesPorNivel.entries.map((entry) {
        final nivel = entry.key;
        final lista = entry.value;
        final color = _coloresNivel[nivel]!;
        final icono = _iconosNivel[nivel]!;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Etiqueta del nivel
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Row(children: [
              Icon(icono, color: color, size: 14),
              const SizedBox(width: 6),
              Text(nivel.toUpperCase(),
                  style:
                      TextStyle(fontSize: 10, color: color, letterSpacing: 2)),
            ]),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: lista.map((a) {
              final sel = seleccionado == a;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  alSeleccionar(a);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: sel ? color.withValues(alpha: 0.1) : tarjeta,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel
                          ? color.withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.06),
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Text(a,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: sel ? color : medio,
                      )),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ]);
      }).toList(),
    );
  }
}

// ── Tarjeta del acorde con diagrama y audio ───────────────
class TarjetaAcorde extends StatefulWidget {
  final String acorde;
  const TarjetaAcorde({super.key, required this.acorde});

  @override
  State<TarjetaAcorde> createState() => _EstadoTarjetaAcorde();
}

class _EstadoTarjetaAcorde extends State<TarjetaAcorde> {
  final AudioPlayer _player = AudioPlayer();
  bool _reproduciendo = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _reproducir() async {
    if (_reproduciendo) {
      await _player.stop();
      setState(() => _reproduciendo = false);
      return;
    }
    final sample = sampleAcorde[widget.acorde];
    if (sample == null) return;
    setState(() => _reproduciendo = true);
    await _player.play(AssetSource(sample));
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _reproduciendo = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notas = notasAcorde[widget.acorde] ?? [];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tarjeta,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Diagrama grande
          DiagramaAcordeWidget(acorde: widget.acorde, alto: 200),
          const SizedBox(width: 20),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(widget.acorde,
                    style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w100,
                        color: blanco,
                        height: 1)),
                const SizedBox(height: 4),
                Text(nombreAcorde[widget.acorde] ?? '',
                    style: const TextStyle(fontSize: 11, color: medio)),
                const SizedBox(height: 16),
                const Text('NOTAS',
                    style:
                        TextStyle(fontSize: 9, color: tenue, letterSpacing: 2)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: notas
                      .map((n) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(n,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: blanco,
                                    fontWeight: FontWeight.w500)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                // Botón escuchar
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _reproducir,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color:
                          _reproduciendo ? verde.withOpacity(0.12) : tarjeta2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: _reproduciendo
                              ? verde.withOpacity(0.4)
                              : Colors.white.withOpacity(0.08)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                          _reproduciendo
                              ? Icons.stop_rounded
                              : Icons.volume_up_rounded,
                          color: _reproduciendo ? verde : medio,
                          size: 14),
                      const SizedBox(width: 6),
                      Text(_reproduciendo ? 'Detener' : 'Escuchar',
                          style: TextStyle(
                              fontSize: 11,
                              color: _reproduciendo ? verde : medio)),
                    ]),
                  ),
                ),
              ])),
        ]),
        const SizedBox(height: 14),
        // Descripción
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: tarjeta2, borderRadius: BorderRadius.circular(10)),
          child: Text(descripcionAcorde[widget.acorde] ?? '',
              style: const TextStyle(fontSize: 12, color: medio, height: 1.5)),
        ),
      ]),
    );
  }
}

// ── Tarjeta de resultado ──────────────────────────────────
class TarjetaResultado extends StatelessWidget {
  final Map<String, dynamic> resultado;
  const TarjetaResultado({super.key, required this.resultado});

  @override
  Widget build(BuildContext context) {
    final correcto = resultado['es_correcto'] == true;
    final confianza = (resultado['confianza'] ?? 0).toStringAsFixed(0);
    final color = correcto ? verde : rojo;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.12),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)
            ],
          ),
          child: Icon(
            correcto ? Icons.check_rounded : Icons.close_rounded,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          correcto ? 'Correcto' : 'Incorrecto',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w300, color: color),
        ),
        const Spacer(),
        if (correcto)
          Text(
            '$confianza%',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w200, color: color),
          ),
      ]),
    );
  }
}
