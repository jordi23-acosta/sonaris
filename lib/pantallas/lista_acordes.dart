import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constantes/colores.dart';
import '../constantes/acordes.dart';
import 'ajustes.dart';

class PantallaListaAcordes extends StatelessWidget {
  final bool online;
  final bool verificando;
  final void Function(String acorde) alSeleccionar;
  final VoidCallback alVerificarConexion;
  final VoidCallback alAbrirApi;

  const PantallaListaAcordes({
    super.key,
    required this.online,
    required this.verificando,
    required this.alSeleccionar,
    required this.alVerificarConexion,
    required this.alAbrirApi,
  });

  static const _niveles = [
    _DatosNivel(
      id: 'básico',
      titulo: 'Básico',
      descripcion: 'Domina tus primeros 3 acordes',
      acordes: ['A', 'Am', 'D'],
      color: Color(0xFF00E676),
      icono: Icons.stairs_rounded,
      desbloqueado: true,
    ),
    _DatosNivel(
      id: 'intermedio',
      titulo: 'Intermedio',
      descripcion: 'Mantén el ritmo fluyendo',
      acordes: ['C'],
      color: Color(0xFF64B5F6),
      icono: Icons.speed_rounded,
      desbloqueado: false,
    ),
    _DatosNivel(
      id: 'difícil',
      titulo: 'Difícil',
      descripcion: 'Conviértete en una leyenda',
      acordes: ['F', 'Bm7'],
      color: Color(0xFFFFD54F),
      icono: Icons.emoji_events_rounded,
      desbloqueado: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(children: [
            const Text('Tu camino',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w200,
                    color: blanco,
                    letterSpacing: 0.5)),
            const Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          PantallaAjustes(alAbrirApiMonitor: alAbrirApi))),
              child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.settings_rounded, color: medio, size: 20)),
            ),
            const SizedBox(width: 4),
            _PuntoCon(
                online: online,
                verificando: verificando,
                alTocar: alVerificarConexion),
          ]),
        ),
        const SizedBox(height: 4),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text('3 niveles · 6 acordes · modelo MLP',
              style: TextStyle(fontSize: 11, color: medio)),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            physics: const BouncingScrollPhysics(),
            itemCount: _niveles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _TarjetaNivel(
              datos: _niveles[i],
              alSeleccionar: alSeleccionar,
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Datos de nivel ────────────────────────────────────────

class _DatosNivel {
  final String id;
  final String titulo;
  final String descripcion;
  final List<String> acordes;
  final Color color;
  final IconData icono;
  final bool desbloqueado;

  const _DatosNivel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.acordes,
    required this.color,
    required this.icono,
    required this.desbloqueado,
  });
}

// ── Tarjeta de nivel ──────────────────────────────────────

class _TarjetaNivel extends StatelessWidget {
  final _DatosNivel datos;
  final void Function(String) alSeleccionar;

  const _TarjetaNivel({required this.datos, required this.alSeleccionar});

  @override
  Widget build(BuildContext context) {
    final bloqueado = !datos.desbloqueado;

    return GestureDetector(
      onTap: bloqueado ? null : () => _abrirNivel(context),
      child: AnimatedOpacity(
        opacity: bloqueado ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: tarjeta,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: datos.desbloqueado
                  ? datos.color.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              // Ícono circular
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: datos.color.withValues(alpha: 0.12),
                ),
                child: Icon(datos.icono, color: datos.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(datos.titulo,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: blanco)),
                    const SizedBox(height: 3),
                    Text(datos.descripcion,
                        style: const TextStyle(fontSize: 12, color: medio)),
                  ])),
              // Candado o badge de acordes
              bloqueado
                  ? const Icon(Icons.lock_rounded, color: tenue, size: 20)
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: datos.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${datos.acordes.length} acordes',
                          style: TextStyle(
                              fontSize: 11,
                              color: datos.color,
                              fontWeight: FontWeight.w600)),
                    ),
            ]),
            if (datos.desbloqueado) ...[
              const SizedBox(height: 16),
              // Chips de acordes
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: datos.acordes
                    .map((a) => GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            alSeleccionar(a);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: datos.color.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: datos.color.withValues(alpha: 0.25)),
                            ),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(a,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: datos.color)),
                                  Text(nombreAcorde[a] ?? '',
                                      style: const TextStyle(
                                          fontSize: 9, color: medio)),
                                ]),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ]),
        ),
      ),
    );
  }

  void _abrirNivel(BuildContext context) {
    HapticFeedback.mediumImpact();
    // Abre la práctica con el primer acorde del nivel
    alSeleccionar(datos.acordes.first);
  }
}

// ── Punto de conexión ─────────────────────────────────────

class _PuntoCon extends StatelessWidget {
  final bool online;
  final bool verificando;
  final VoidCallback alTocar;

  const _PuntoCon({
    required this.online,
    required this.verificando,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    final color = verificando
        ? ambar
        : online
            ? verde
            : rojo;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: alTocar,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6)
          ],
        ),
      ),
    );
  }
}
