import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/common/app_logo.dart';
import '../widgets/common/social_button.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../constants/routes.dart';
import '../constants/dimensions.dart';
import '../constants/languages.dart';
import '../constants/language_ids.dart';
import '../constants/countries.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  final _authService = AuthService();

  String? _nativeLang;
  String? _learningLang;
  String? _country;
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _acceptTerms = false;

  static const gradientStart = Color(0xFF4A90E2);
  static const gradientEnd = Color(0xFF8A49F7);

  void _onCreate() async { 
    // Validación extra: asegurarse de que seleccionó idiomas
    if (!_isFormValid) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Creating account...')));

    // Convertir código a ID del backend
    int? nativeId = LanguageIds.getId(_nativeLang ?? '');
    int? learnId = LanguageIds.getId(_learningLang ?? ''); // Aunque el registro backend actual igual no lo usa aún

    if (nativeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Invalid language')));
        return;
    }

    if (_country == null || _country!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select your country')));
        return;
    }

    final result = await _authService.register(
      _nameCtrl.text,
      _emailCtrl.text,
      _passCtrl.text,
      nativeId,
      learnId ?? 0,
      _country!,
    );

    if (!mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created. Please sign in.')));
      // Volver al login
      Navigator.pop(context); 
    } else {
      // Mostrar mensaje específico según el tipo de error
      String errorMessage;
      if (result.error != null) {
        errorMessage = result.error!.message;
      } else {
        errorMessage = 'Unexpected error. Please try again.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(errorMessage)));
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
    if (!FormValidators.isFormValid(_formKey)) return false;
    return _nativeLang != null &&
        _learningLang != null &&
        _country != null &&
        _country!.isNotEmpty &&
        _acceptTerms;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppDimensions.maxCardWidth),
            child: Card(
              elevation: 0,
              color: AppTheme.card,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXL)),
              child: Padding(
                padding: AppDimensions.paddingForm,
                child: Form(
                  key: _formKey,
                  onChanged: () => setState(() {}),
                  child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const AppLogo(),
                      const SizedBox(height: AppDimensions.spacingMD),
                      const Text('Join the community',
                          style: TextStyle(
                              fontSize: AppDimensions.fontSizeXL, fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppDimensions.spacingXS),
                      Text('Start your language learning journey',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: AppTheme.subtle)),
                      const SizedBox(height: AppDimensions.spacingXXL),

                      _label('Full name'),
                      TextFormField(
                        controller: _nameCtrl,
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => FormValidators.validateName(v, minLength: 3),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline),
                          hintText: 'Your name',
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingML),

                      _label('Email'),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: FormValidators.validateEmail,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined),
                          hintText: 'tu@email.com',
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingML),

                      Row(children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Native language'),
                              DropdownButtonFormField<String>(
                                initialValue: _nativeLang,
                                items: AppLanguages.availableCodes
                                    .map((code) => DropdownMenuItem(
                                          value: code,
                                          child: Text(AppLanguages.getName(code)),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() => _nativeLang = v),
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.public),
                                  hintText: 'Select',
                                ),
                                validator: (v) => FormValidators.validateRequired(v, 'Select a language'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingMD),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Learning'),
                              DropdownButtonFormField<String>(
                                initialValue: _learningLang,
                                items: AppLanguages.availableCodes
                                    .map((code) => DropdownMenuItem(
                                          value: code,
                                          child: Text(AppLanguages.getName(code)),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() => _learningLang = v),
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.public),
                                  hintText: 'Select',
                                ),
                                validator: (v) => FormValidators.validateRequired(v, 'Select a language'),
                              ),
                            ],
                          ),
                        ),
                      ]),
                      const SizedBox(height: AppDimensions.spacingML),

                      _label('Country'),
                      DropdownButtonFormField<String>(
                        value: _country,
                        items: AppCountries.available
                            .map((country) => DropdownMenuItem(
                                  value: country,
                                  child: Text(country),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _country = v),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.location_on_outlined),
                          hintText: 'Select your country',
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Select your country' : null,
                      ),
                      const SizedBox(height: AppDimensions.spacingML),

                      _label('Password'),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure1,
                        validator: (v) => FormValidators.validatePassword(v, minLength: 6),
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
                      const SizedBox(height: AppDimensions.spacingML),

                      _label('Confirm password'),
                      TextFormField(
                        controller: _pass2Ctrl,
                        obscureText: _obscure2,
                        validator: (v) => FormValidators.validatePasswordMatch(v, _passCtrl.text),
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
                      const SizedBox(height: AppDimensions.spacingM),

                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (v) =>
                              setState(() => _acceptTerms = v ?? false),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusXS)),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: AppTheme.text),
                              children: [
                                const TextSpan(text: 'I accept the '),
                                TextSpan(
                                  text: 'terms and conditions',
                                  style: const TextStyle(
                                      color: gradientStart,
                                      fontWeight: FontWeight.w600),
                                  recognizer: TapGestureRecognizer()..onTap = () {},
                                ),
                                const TextSpan(text: ' and the '),
                                TextSpan(
                                  text: 'privacy policy',
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
                      const SizedBox(height: AppDimensions.spacingS),

                      SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: Opacity(
                          opacity: _isFormValid ? 1 : AppDimensions.opacityDisabled,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [gradientStart, gradientEnd]),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                            ),
                            child: ElevatedButton(
                              onPressed: _isFormValid ? _onCreate : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text('Create account',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingML),

                      Row(children: [
                        Expanded(child: Divider(color: AppTheme.border.withValues(alpha: AppDimensions.opacityDivider))),
                        Padding(
                          padding: AppDimensions.paddingDivider,
                          child: Text('or sign up with',
                              style: TextStyle(color: AppTheme.subtle)),
                        ),
                        Expanded(child: Divider(color: AppTheme.border.withValues(alpha: AppDimensions.opacityDivider))),
                      ]),
                      const SizedBox(height: AppDimensions.spacingMD),

                      Row(children: const [
                        Expanded(child: SocialButton(text: 'Google', icon: 'G')),
                        SizedBox(width: AppDimensions.spacingMD),
                        Expanded(child: SocialButton(text: 'Facebook', icon: 'f')),
                      ]),
                      const SizedBox(height: AppDimensions.spacingL),

                      Wrap(alignment: WrapAlignment.center, children: [
                        const Text('Already have an account? '),
                        InkWell(
                          onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                          child: const Text('Sign in',
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
    );
  }

  Text _label(String t) => Text(t, style: TextStyle(color: AppTheme.text));
}

