import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  final _authService = AuthService();

  String? _nativeLang;
  String? _learningLang;
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _acceptTerms = false;

  static const gradientStart = Color(0xFF4A90E2);
  static const gradientEnd = Color(0xFF8A49F7);
  final _languages = const [
    'Español',
    'Inglés',
    'Francés',
    'Alemán',
    'Italiano',
    'Portugués',
    'Chino',
    'Japonés'
  ];

  final Map<String, int> _languageMap = {
    'Español': 1,
    'Inglés': 2,
    'Francés': 3,
    'Alemán': 4,
    // los demás idiomas que haya en la bd
  };

  void _onCreate() async { 
    // Validación extra: asegurarse de que seleccionó idiomas
    if (!_isFormValid) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Creando cuenta...')));

    // Convertir String a ID
    int? nativeId = _languageMap[_nativeLang];
    int? learnId = _languageMap[_learningLang]; // Aunque el registro backend actual igual no lo usa aún

    if (nativeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Idioma no válido')));
        return;
    }

    final success = await _authService.register(
      _nameCtrl.text,
      _emailCtrl.text,
      _passCtrl.text,
      nativeId,
      learnId ?? 0, 
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuenta creada. Por favor inicia sesión.')));
      // Volver al login
      Navigator.pop(context); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.red, content: Text('Error al registrar usuario')));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final form = _formKey.currentState;
    return form != null &&
        form.validate() &&
        _nativeLang != null &&
        _learningLang != null &&
        _acceptTerms;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFFF4F6FF), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
                child: Form(
                  key: _formKey,
                  onChanged: () => setState(() {}),
                  child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      _logo(),
                      const SizedBox(height: 12),
                      const Text('Únete a la comunidad',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Comienza tu aventura de aprendizaje de idiomas',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.black54)),
                      const SizedBox(height: 22),

                      _label('Nombre completo'),
                      TextFormField(
                        controller: _nameCtrl,
                        textCapitalization: TextCapitalization.words,
                        validator: (v) =>
                            (v == null || v.trim().length < 3)
                                ? 'Introduce tu nombre'
                                : null,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline),
                          hintText: 'Tu nombre',
                        ),
                      ),
                      const SizedBox(height: 14),

                      _label('Correo electrónico'),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Introduce tu correo';
                          final ok =
                              RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim());
                          return ok ? null : 'Correo no válido';
                        },
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined),
                          hintText: 'tu@email.com',
                        ),
                      ),
                      const SizedBox(height: 14),

                      Row(children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Idioma nativo'),
                              DropdownButtonFormField<String>(
                                initialValue: _nativeLang,
                                items: _languages
                                    .map((e) =>
                                        DropdownMenuItem(value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (v) => setState(() => _nativeLang = v),
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.public),
                                  hintText: 'Selecciona',
                                ),
                                validator: (v) =>
                                    v == null ? 'Selecciona un idioma' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Aprendiendo'),
                              DropdownButtonFormField<String>(
                                initialValue: _learningLang,
                                items: _languages
                                    .map((e) =>
                                        DropdownMenuItem(value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (v) => setState(() => _learningLang = v),
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.public),
                                  hintText: 'Selecciona',
                                ),
                                validator: (v) =>
                                    v == null ? 'Selecciona un idioma' : null,
                              ),
                            ],
                          ),
                        ),
                      ]),
                      const SizedBox(height: 14),

                      _label('Contraseña'),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure1,
                        validator: (v) => (v == null || v.length < 6)
                            ? 'Mínimo 6 caracteres'
                            : null,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          hintText: '•••••••',
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _obscure1 = !_obscure1),
                            icon: Icon(_obscure1
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      _label('Confirmar contraseña'),
                      TextFormField(
                        controller: _pass2Ctrl,
                        obscureText: _obscure2,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Repite la contraseña';
                          }
                          if (v != _passCtrl.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          hintText: '•••••••',
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _obscure2 = !_obscure2),
                            icon: Icon(_obscure2
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (v) =>
                              setState(() => _acceptTerms = v ?? false),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Colors.black87),
                              children: [
                                const TextSpan(text: 'Acepto los '),
                                TextSpan(
                                  text: 'términos y condiciones',
                                  style: const TextStyle(
                                      color: gradientStart,
                                      fontWeight: FontWeight.w600),
                                  recognizer: TapGestureRecognizer()..onTap = () {},
                                ),
                                const TextSpan(text: ' y la '),
                                TextSpan(
                                  text: 'política de privacidad',
                                  style: const TextStyle(
                                      color: gradientStart,
                                      fontWeight: FontWeight.w600),
                                  recognizer: TapGestureRecognizer()..onTap = () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 6),

                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: Opacity(
                          opacity: _isFormValid ? 1 : 0.5,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [gradientStart, gradientEnd]),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: _isFormValid ? _onCreate : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text('Crear cuenta',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Row(children: const [
                        Expanded(child: Divider(color: Colors.black12)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('o regístrate con',
                              style: TextStyle(color: Colors.black54)),
                        ),
                        Expanded(child: Divider(color: Colors.black12)),
                      ]),
                      const SizedBox(height: 12),

                      Row(children: const [
                        Expanded(child: _SocialButton(text: 'Google', icon: 'G')),
                        SizedBox(width: 12),
                        Expanded(child: _SocialButton(text: 'Facebook', icon: 'f')),
                      ]),
                      const SizedBox(height: 16),

                      Wrap(alignment: WrapAlignment.center, children: [
                        const Text('¿Ya tienes una cuenta? '),
                        InkWell(
                          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text('Inicia sesión',
                              style: TextStyle(
                                  color: gradientStart,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ]),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Text _label(String t) => Text(t, style: const TextStyle(color: Colors.black87));

  Widget _logo() => Container(
        width: 62,
        height: 62,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [gradientStart, gradientEnd]),
        ),
        child: const Center(
            child: Icon(Icons.chat_bubble_outline,
                color: Colors.white, size: 30)),
      );
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
