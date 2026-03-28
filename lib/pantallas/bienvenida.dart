import 'package:flutter/material.dart';
import '../constantes/colores.dart';
import 'login.dart';
import 'registro.dart';

class PantallaBienvenida extends StatefulWidget {
  const PantallaBienvenida({super.key});

  @override
  State<PantallaBienvenida> createState() => _EstadoBienvenida();
}

class _EstadoBienvenida extends State<PantallaBienvenida> {
  final _pageCtrl = PageController();
  int _pagina = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      body: Stack(children: [
        PageView(
          controller: _pageCtrl,
          onPageChanged: (i) => setState(() => _pagina = i),
          children: const [
            _PaginaBienvenida(
              fondo: 'assets/fondo.png',
              titulo: 'Toca. Aprende.\nMejora.',
              subtitulo:
                  'Practica acordes con detección inteligente adaptada a tu nivel.',
            ),
            _PaginaBienvenida(
              fondo: 'assets/imagenFondo2.png',
              titulo: 'Detección con IA',
              subtitulo:
                  'Graba tu acorde y nuestra IA lo identifica en segundos con alta precisión.',
            ),
          ],
        ),
        // Indicadores y botones fijos abajo
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            child: Column(children: [
              // Dots
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _Dot(activo: _pagina == 0),
                const SizedBox(width: 6),
                _Dot(activo: _pagina == 1),
              ]),
              const SizedBox(height: 24),
              // Botones
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(children: [
                  Expanded(
                    child: _BotonOutline(
                      texto: 'Iniciar sesión',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PantallaLogin())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BotonVerde(
                      texto: 'Registrarse',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PantallaRegistro())),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── Página individual ─────────────────────────────────────

class _PaginaBienvenida extends StatelessWidget {
  final String fondo;
  final String titulo;
  final String subtitulo;

  const _PaginaBienvenida({
    required this.fondo,
    required this.titulo,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      Image.asset(fondo, fit: BoxFit.cover),
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x26000000),
              Color(0x73000000),
              Color(0xD9000000),
              Color(0xFF000000),
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
      ),
      SafeArea(
        child: Column(children: [
          const SizedBox(height: 48),
          const Text(
            'S O N A R I S',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: blanco,
              letterSpacing: 8,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'GUITAR',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: verde,
              letterSpacing: 6,
              decoration: TextDecoration.none,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 120),
            child: Column(children: [
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: blanco,
                  height: 1.2,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                  height: 1.5,
                  decoration: TextDecoration.none,
                ),
              ),
            ]),
          ),
        ]),
      ),
    ]);
  }
}

// ── Widgets ───────────────────────────────────────────────

class _Dot extends StatelessWidget {
  final bool activo;
  const _Dot({required this.activo});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: activo ? 24 : 8,
      height: 3,
      decoration: BoxDecoration(
        color: activo ? verde : const Color(0xFF444444),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _BotonOutline extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;
  const _BotonOutline({required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Text(texto,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: blanco,
                decoration: TextDecoration.none)),
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: verde,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(texto,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF080808),
                decoration: TextDecoration.none)),
      ),
    );
  }
}
