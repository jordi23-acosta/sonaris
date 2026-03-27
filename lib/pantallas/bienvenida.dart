import 'package:flutter/material.dart';
import '../constantes/colores.dart';
import 'login.dart';
import 'registro.dart';

class PantallaBienvenida extends StatelessWidget {
  const PantallaBienvenida({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      Image.asset('assets/fondo.png', fit: BoxFit.cover),
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
          // Logo / título
          const Text(
            'S O N A R I S',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: blanco,
              letterSpacing: 8,
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
            ),
          ),
          const Spacer(),
          // Texto inferior
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Column(children: [
              Text(
                'Toca. Aprende. Mejora.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: blanco,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Practica acordes con detección inteligente\nadaptada a tu nivel.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                  height: 1.5,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 32),
          // Indicadores de página
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                width: 24,
                height: 3,
                decoration: BoxDecoration(
                    color: verde, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 6),
            Container(
                width: 8,
                height: 3,
                decoration: BoxDecoration(
                    color: Color(0xFF444444),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 6),
            Container(
                width: 8,
                height: 3,
                decoration: BoxDecoration(
                    color: Color(0xFF444444),
                    borderRadius: BorderRadius.circular(2))),
          ]),
          const SizedBox(height: 40),
          // Botones
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: [
              Expanded(
                child: _BotonOutline(
                  texto: 'Iniciar sesión',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const PantallaLogin())),
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
    ]);
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
                fontSize: 15, fontWeight: FontWeight.w600, color: blanco)),
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
                color: Color(0xFF080808))),
      ),
    );
  }
}
