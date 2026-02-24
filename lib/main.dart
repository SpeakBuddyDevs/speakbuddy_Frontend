import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_shell.dart';
import 'screens/public_profile_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/public_exchanges_screen.dart';
import 'screens/create_exchange_screen.dart';
import 'screens/exchange_history_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/rate_participants_screen.dart';
import 'screens/favorite_topics_screen.dart';
import 'navigation/rate_participants_args.dart';
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
        AppRoutes.main: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final initialIndex = args is int ? args : null;
          return MainShell(initialIndex: initialIndex);
        },
        AppRoutes.publicProfile: (_) => const PublicProfileScreen(),
        AppRoutes.chat: (_) => const ChatScreen(),
        AppRoutes.publicExchanges: (_) => const PublicExchangesScreen(),
        AppRoutes.createExchange: (_) => const CreateExchangeScreen(),
        AppRoutes.exchangeHistory: (context) => const ExchangeHistoryScreen(),
        AppRoutes.notifications: (_) => const NotificationsScreen(),
        AppRoutes.rateParticipants: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as RateParticipantsArgs;
          return RateParticipantsScreen(args: args);
        },
        AppRoutes.favoriteTopics: (_) => const FavoriteTopicsScreen(),
      },
    );
  }
}
