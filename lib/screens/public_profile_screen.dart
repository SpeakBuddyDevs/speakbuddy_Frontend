import 'package:flutter/material.dart';
import '../models/public_user_profile.dart';
import '../navigation/public_profile_args.dart';
import '../navigation/chat_args.dart';
import '../repositories/api_users_repository.dart';
import '../constants/routes.dart';
import '../theme/app_theme.dart';
import '../constants/dimensions.dart';

/// Pantalla de perfil público de un usuario
class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({super.key});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final _repository = ApiUsersRepository();
  PublicUserProfile? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final args = ModalRoute.of(context)?.settings.arguments as PublicProfileArgs?;
    
    if (args == null) {
      setState(() {
        _error = 'No se proporcionaron argumentos';
        _isLoading = false;
      });
      return;
    }

    // Mostrar prefetched de inmediato si existe (p. ej. desde búsqueda o intercambio)
    if (args.prefetched != null) {
      setState(() {
        _profile = args.prefetched;
        _isLoading = false;
      });
    }

    // Cargar perfil completo desde la API (completa o reemplaza prefetched con país, descripción, valoración, intercambios)
    try {
      final profile = await _repository.getPublicProfile(args.userId);
      if (!mounted) return;
      setState(() {
        _profile = profile ?? _profile;
        _isLoading = false;
        if (profile == null && _profile == null) {
          _error = 'Usuario no encontrado';
        }
      });
    } catch (e) {
      if (!mounted) return;
      // Si teníamos prefetched, mantenerlo; si no, mostrar error
      setState(() {
        _isLoading = false;
        if (_profile == null) {
          _error = 'Error al cargar el perfil';
        }
      });
    }
  }

  void _onChat() {
    if (_profile == null) return;
    Navigator.pushNamed(
      context,
      AppRoutes.chat,
      arguments: ChatArgs(
        otherUserId: _profile!.id,
        prefetchedUser: _profile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Perfil',
          style: TextStyle(color: AppTheme.text),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.subtle),
            const SizedBox(height: AppDimensions.spacingL),
            Text(
              _error!,
              style: TextStyle(color: AppTheme.subtle, fontSize: AppDimensions.fontSizeM),
            ),
          ],
        ),
      );
    }

    if (_profile == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: AppDimensions.paddingScreen,
      child: Column(
        children: [
          _ProfileHeader(profile: _profile!),
          if (_profile!.bio != null && _profile!.bio!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingL),
            _DescriptionCard(description: _profile!.bio!),
          ],
          const SizedBox(height: AppDimensions.spacingL),
          _StatsRow(profile: _profile!),
          const SizedBox(height: AppDimensions.spacingL),
          _LanguagesCard(profile: _profile!),
          const SizedBox(height: AppDimensions.spacingXXXL),
          _ChatButton(onPressed: _onChat),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final PublicUserProfile profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppTheme.border),
      ),
      padding: AppDimensions.paddingCard,
      child: Column(
        children: [
          // Avatar con indicador online
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.panel,
                backgroundImage: profile.avatarUrl != null
                    ? NetworkImage(profile.avatarUrl!)
                    : null,
                child: profile.avatarUrl == null
                    ? Text(
                        profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: AppTheme.text,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              if (profile.isOnline)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.card, width: 3),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          // Nombre y badge PRO
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile.name,
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: AppDimensions.fontSizeXL,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (profile.isPro) ...[
                const SizedBox(width: AppDimensions.spacingSM),
                _ProBadge(),
              ],
            ],
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          // País (ocultar fila si vacío o mostrar '—')
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: AppTheme.subtle),
              const SizedBox(width: AppDimensions.spacingXS),
              Text(
                profile.country.isEmpty ? '—' : profile.country,
                style: TextStyle(color: AppTheme.subtle, fontSize: AppDimensions.fontSizeM),
              ),
            ],
          ),
          if (profile.isOnline) ...[
            const SizedBox(height: AppDimensions.spacingSM),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMD,
                vertical: AppDimensions.spacingXS,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
              ),
              child: Text(
                'En línea',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: AppDimensions.fontSizeXS,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSM,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppTheme.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5)),
      ),
      child: Text(
        'PRO',
        style: TextStyle(
          color: AppTheme.gold,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final PublicUserProfile profile;

  const _StatsRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.trending_up_rounded,
            label: 'Nivel',
            value: '${profile.level}',
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMD),
        Expanded(
          child: _StatCard(
            icon: Icons.star_rounded,
            label: 'Rating',
            value: profile.rating.toStringAsFixed(1),
            iconColor: AppTheme.gold,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMD),
        Expanded(
          child: _StatCard(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Intercambios',
            value: '${profile.exchanges}',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppTheme.border),
      ),
      padding: AppDimensions.paddingCard,
      child: Column(
        children: [
          Icon(icon, color: iconColor ?? AppTheme.subtle, size: 24),
          const SizedBox(height: AppDimensions.spacingSM),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.text,
              fontSize: AppDimensions.fontSizeL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.subtle,
              fontSize: AppDimensions.fontSizeXS,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguagesCard extends StatelessWidget {
  final PublicUserProfile profile;

  const _LanguagesCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppTheme.border),
      ),
      padding: AppDimensions.paddingCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Idiomas',
            style: TextStyle(
              color: AppTheme.text,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.translate_rounded, size: 20, color: AppTheme.subtle),
              const SizedBox(width: AppDimensions.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nativo: ${profile.nativeLanguage.isEmpty ? '—' : profile.nativeLanguage}',
                      style: TextStyle(color: AppTheme.text),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Text(
                      'Aprendiendo:',
                      style: TextStyle(color: AppTheme.text),
                    ),
                    if (profile.learningLanguages.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppDimensions.spacingXS),
                        child: Text('—', style: TextStyle(color: AppTheme.subtle)),
                      )
                    else
                      ...profile.learningLanguages.map((lang) => Padding(
                        padding: const EdgeInsets.only(top: AppDimensions.spacingXS),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                lang.level.isNotEmpty
                                    ? '${lang.name} (${lang.level})'
                                    : lang.name,
                                style: TextStyle(color: AppTheme.subtle),
                              ),
                            ),
                            if (lang.active)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.spacingS,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withValues(alpha: .15),
                                  border: Border.all(
                                    color: AppTheme.accent.withValues(alpha: .6),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusCircular,
                                  ),
                                ),
                                child: Text(
                                  'Activo',
                                  style: TextStyle(
                                    color: AppTheme.accent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: AppDimensions.fontSizeXS,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final String description;

  const _DescriptionCard({required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppTheme.border),
      ),
      padding: AppDimensions.paddingCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descripción del perfil',
            style: TextStyle(
              color: AppTheme.text,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          Text(
            description,
            style: TextStyle(
              color: AppTheme.subtle,
              height: AppDimensions.lineHeight,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ChatButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.chat_rounded),
        label: const Text('Chatear'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingL),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
        ),
      ),
    );
  }
}

