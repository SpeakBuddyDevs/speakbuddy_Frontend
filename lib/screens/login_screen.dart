import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common/app_logo.dart';
import '../widgets/common/social_button.dart';
import '../utils/validators.dart';
import '../constants/routes.dart';
import '../constants/dimensions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _authService = AuthService(); // Instancia el servicio
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > AppDimensions.breakpointLarge;
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isLargeScreen ? AppDimensions.maxCardWidth : double.infinity,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 0 : AppDimensions.spacingL,
                  vertical: AppDimensions.spacingXXXL,
                ),
                child: Card(
                elevation: 0,
                color: AppTheme.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                ),
                child: Padding(
                padding: AppDimensions.paddingForm,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppLogo(),
                      const SizedBox(height: AppDimensions.spacingMD),
                      Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: AppDimensions.fontSizeXL,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.text,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXS),
                      Text(
                        'Continue your language exchange journey',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppTheme.subtle,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXXL),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email',
                          style: TextStyle(color: AppTheme.text),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingSM),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: FormValidators.validateEmail,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined),
                          hintText: 'tu@email.com',
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingL),

                      Row(
                        children: [
                          Text(
                            'Password',
                            style: TextStyle(color: AppTheme.text),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                            ),
                            child: Text(
                              'Forgot your password?',
                              style: TextStyle(color: AppTheme.accent),
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        validator: FormValidators.validatePasswordRequired,
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
                      const SizedBox(height: AppDimensions.spacingXL),

                      SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [gradientStart, gradientEnd],
                            ),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                          ),
                          child: ElevatedButton(
                            onPressed: _onLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Sign in',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXL),
                      const SizedBox(height: AppDimensions.spacingL),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, AppRoutes.main);
                        },
                        child: Text(
                          'View profile (test mode)',
                          style: TextStyle(color: AppTheme.accent),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppTheme.border.withValues(alpha: AppDimensions.opacityDivider),
                            ),
                          ),
                          Padding(
                            padding: AppDimensions.paddingDivider,
                            child: Text(
                              'or continue with',
                              style: TextStyle(color: AppTheme.subtle),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppTheme.border.withValues(alpha: AppDimensions.opacityDivider),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingMD),

                      Row(
                        children: const [
                          Expanded(
                            child: SocialButton(text: 'Google', icon: 'G'),
                          ),
                          SizedBox(width: AppDimensions.spacingMD),
                          Expanded(
                            child: SocialButton(text: 'Facebook', icon: 'f'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingXL),

                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account? ',
                            style: TextStyle(color: AppTheme.subtle),
                          ),
                          InkWell(
                            onTap: () =>
                                Navigator.pushNamed(context, AppRoutes.register),
                            child: Text(
                              'Sign up here',
                              style: TextStyle(
                                color: AppTheme.accent,
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
    ),
    ),
    );
  }

  void _onLogin() async { 
    final ok = FormValidators.isFormValid(_formKey);
    if (!ok) return;

    // Visual feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connecting to server...')),
    );

    // Llamar al backend
    final result = await _authService.login(
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
    );

    if (!mounted) return; // Buena práctica en Flutter async

    if (result.success) {
      // If login is correct, navigate to main screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful! Token saved.')),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else {
      // Show specific message depending on error type
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
}

