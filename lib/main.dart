import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/main_shell.dart';
import 'screens/public_profile_screen.dart';
import 'screens/chat_screen.dart';
import 'theme/app_theme.dart';
import 'constants/routes.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Proyecto Idiomas',
      theme: AppTheme.darkTheme(),
      routes: {
        AppRoutes.home: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.main: (_) => const MainShell(),
        AppRoutes.publicProfile: (_) => const PublicProfileScreen(),
        AppRoutes.chat: (_) => const ChatScreen(),
      },
    );
  }
}
