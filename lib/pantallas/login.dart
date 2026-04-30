import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constantes/colores.dart';
import '../services/sesion_service.dart';
import '../pantallas/home.dart';
import 'registro.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _EstadoLogin();
}

class _EstadoLogin extends State<PantallaLogin> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _verPassword = false;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Completa todos los campos.');
      return;
    }
    setState(() {
      _cargando = true;
      _error = null;
    });
    final err = await context.read<SesionService>().login(email, pass);
    if (!mounted) return;
    setState(() => _cargando = false);
    if (err != null) {
      setState(() => _error = err);
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PantallaHome()),
          (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      body: Stack(fit: StackFit.expand, children: [
        // Fondo desenfocado
        Image.asset('assets/fondo.png', fit: BoxFit.cover),
        Container(color: const Color(0xCC080808)),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 16),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: blanco, size: 20),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 32),
              const Text('Hola de nuevo',
                  style: TextStyle(fontSize: 14, color: medio)),
              const SizedBox(height: 6),
              const Text('Iniciar sesión',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: blanco)),
              const SizedBox(height: 40),
              const _Label('Correo electrónico'),
              const SizedBox(height: 8),
              _Campo(
                controller: _emailCtrl,
                hint: 'ejemplo@correo.com',
                teclado: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              const _Label('Contraseña'),
              const SizedBox(height: 8),
              _Campo(
                controller: _passCtrl,
                hint: '••••••••',
                obscure: !_verPassword,
                sufijo: IconButton(
                  icon: Icon(
                      _verPassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_off_rounded,
                      color: medio,
                      size: 20),
                  onPressed: () => setState(() => _verPassword = !_verPassword),
                ),
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerRight,
                child: Text('¿Olvidaste tu contraseña?',
                    style: TextStyle(fontSize: 13, color: blanco)),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!,
                    style: const TextStyle(color: rojo, fontSize: 13)),
              ],
              const SizedBox(height: 32),
              _BotonPrincipal(
                texto: 'Continuar',
                cargando: _cargando,
                onTap: _login,
              ),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('¿No tienes cuenta? ',
                    style: TextStyle(color: medio, fontSize: 14)),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PantallaRegistro())),
                  child: const Text('Regístrate',
                      style: TextStyle(
                          color: blanco,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── Widgets compartidos ───────────────────────────────────

class _Label extends StatelessWidget {
  final String texto;
  const _Label(this.texto);
  @override
  Widget build(BuildContext context) =>
      Text(texto, style: const TextStyle(fontSize: 13, color: blanco));
}

class _Campo extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType teclado;
  final Widget? sufijo;

  const _Campo({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.teclado = TextInputType.text,
    this.sufijo,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: teclado,
      style: const TextStyle(color: blanco, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: tenue, fontSize: 15),
        suffixIcon: sufijo,
        filled: true,
        fillColor: const Color(0xFF1C1C1C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }
}

class _BotonPrincipal extends StatelessWidget {
  final String texto;
  final bool cargando;
  final VoidCallback onTap;
  const _BotonPrincipal(
      {required this.texto, required this.cargando, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: cargando ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: verde,
          borderRadius: BorderRadius.circular(14),
        ),
        child: cargando
            ? const Center(
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFF080808))))
            : Text(texto,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF080808))),
      ),
    );
  }
}
