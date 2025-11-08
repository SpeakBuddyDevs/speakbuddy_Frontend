import 'package:flutter/material.dart';
import 'profile.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  static const gradientStart = Color(0xFF4A90E2);
  static const gradientEnd = Color(0xFF8A49F7);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF4F6FF), Colors.white],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 26,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _logo(),
                      const SizedBox(height: 12),
                      const Text(
                        'Bienvenido de nuevo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Continúa tu viaje de intercambio de idiomas',
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium!.copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 22),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Correo electrónico',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Introduce tu correo';
                          }
                          final ok = RegExp(
                            r'^[^@]+@[^@]+\.[^@]+',
                          ).hasMatch(v.trim());
                          return ok ? null : 'Correo no válido';
                        },
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined),
                          hintText: 'tu@email.com',
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          const Text(
                            'Contraseña',
                            style: TextStyle(color: Colors.black87),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                            ),
                            child: const Text('¿Olvidaste tu contraseña?'),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Introduce tu contraseña'
                            : null,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          hintText: '•••••••',
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [gradientStart, gradientEnd],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: _onLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: const Text('Ver perfil (modo prueba)'),
                      ),
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Colors.black12)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'o continúa con',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                          const Expanded(child: Divider(color: Colors.black12)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: const [
                          Expanded(
                            child: _SocialButton(text: 'Google', icon: 'G'),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _SocialButton(text: 'Facebook', icon: 'f'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          const Text('¿No tienes una cuenta? '),
                          InkWell(
                            onTap: () =>
                                Navigator.pushNamed(context, '/register'),
                            child: const Text(
                              'Regístrate aquí',
                              style: TextStyle(
                                color: gradientStart,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo() => Container(
    width: 62,
    height: 62,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gradientStart, gradientEnd],
      ),
    ),
    child: const Center(
      child: Icon(Icons.chat_bubble_outline, color: Colors.white, size: 30),
    ),
  );

  void _onLogin() {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Iniciando sesión...')));
  }
}

class _SocialButton extends StatelessWidget {
  final String text;
  final String icon;
  const _SocialButton({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: _MonoLogo(text: icon),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _MonoLogo extends StatelessWidget {
  final String text;
  const _MonoLogo({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
