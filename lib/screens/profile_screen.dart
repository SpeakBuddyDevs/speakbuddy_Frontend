import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import '../constants/languages.dart';
import '../constants/routes.dart';
import '../theme/app_theme.dart';
import '../models/language_item.dart';
import '../models/user_profile.dart';
import '../models/edit_profile_result.dart';
import '../services/auth_service.dart';
import '../utils/image_helpers.dart';
import '../widgets/common/language_selector_bottom_sheet.dart';
import '../widgets/common/language_action_bottom_sheet.dart';
import '../widgets/common/level_selector_bottom_sheet.dart';
import '../constants/dimensions.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // BACKEND: Cargar perfil real desde GET /api/auth/me o GET /api/profile
  // TODO(FE): Llamar al backend en initState y mostrar loading mientras carga
  // TODO(FE): Implementar UserProfile.fromJson para parsear respuesta
  var _profile = UserProfile(
    name: 'Sergio Arjona',
    email: 'sergioarjona@gmail.com',
    level: 5,
    progressPct: 0.40,
    exchanges: 12,
    rating: 4.8,
    languagesCount: 3,
    hoursTotal: 18,
    currentStreakDays: 5,
    bestStreakDays: 12,
    medals: 4,
    nativeLanguage: 'ES',
    learningLanguages: const [
      LanguageItem(code: 'ES', name: 'Español', level: 'Intermedio', active: true),
      LanguageItem(code: 'FR', name: 'Francés', level: 'Principiante'),
    ],
    isPro: true,
    avatarPath: null,
    description:
        '¡Hola! Soy Sergio, estudiante de idiomas. Quiero mejorar mi inglés '
        'para poder viajar y trabajar en el extranjero. Me encanta conocer '
        'gente de otros países y practicar a diario.', // 👈 texto ejemplo
  );

  Future<void> _editDescription() async {
    final controller = TextEditingController(text: _profile.description);

    final newText = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          title: const Text('Editar descripción'),
          content: TextField(
            controller: controller,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Descripción del perfil',
              alignLabelWithHint: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (newText == null || newText.isEmpty) return;

    setState(() {
      _profile = _profile.copyWith(description: newText);
    });
  }



  void _addLearningLanguage() async {
    // Códigos ya en aprendizaje
    final existing = _profile.learningLanguages.map((e) => e.code).toSet();

    // Disponibles = catálogo - existentes - idioma nativo
    final available = AppLanguages.availableCodes
        .where(
          (code) => !existing.contains(code) && code != _profile.nativeLanguage,
        )
        .toList();

    if (available.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay más idiomas disponibles para añadir'),
        ),
      );
      return;
    }

    String selected = available.first;

    final picked = await showLanguageSelectorBottomSheet(
      context,
      available,
      selected,
    );

    if (!mounted || picked == null) return;

    setState(() {
      // Crea un nuevo LanguageItem con nivel por defecto
      final display = AppLanguages.getName(picked);
      final newItem = LanguageItem(
        code: picked,
        name: display,
        level: 'Principiante',
      );
      _profile = _profile.copyWith(
        learningLanguages: [..._profile.learningLanguages, newItem],
        languagesCount: _profile.learningLanguages.length + 1,
      );
    });
  }

  void _onLanguageLongPress(LanguageItem lang) async {
    final isActive = lang.active;

    // Primer menú: qué acción quieres hacer
    final action = await showLanguageActionBottomSheet(
      context,
      isActive,
    );

    if (!mounted || action == null) return;

    // ✅ Opción 1: Marcar como activo
    if (action == 'active') {
      setState(() {
        final updated = _profile.learningLanguages.map((LanguageItem l) {
          if (l.code == lang.code) {
            return LanguageItem(
              code: l.code,
              name: l.name,
              level: l.level,
              active: true, // lo activamos (no tocamos los demás)
            );
          }
          return l;
        }).toList();

        _profile = _profile.copyWith(learningLanguages: updated);
      });
      return;
    }

    // ✅ Opción 1b: Desmarcar como activo
    if (action == 'unactive') {
      setState(() {
        final updated = _profile.learningLanguages.map((LanguageItem l) {
          if (l.code == lang.code) {
            return LanguageItem(
              code: l.code,
              name: l.name,
              level: l.level,
              active: false, // lo desmarcamos
            );
          }
          return l;
        }).toList();

        _profile = _profile.copyWith(learningLanguages: updated);
      });
      return;
    }

    // ✅ Opción 2: Configurar nivel (igual que ya tenías)
    if (action == 'level') {
      const levels = ['Principiante', 'Intermedio', 'Avanzado'];
      String selected = lang.level;

      final pickedLevel = await showLevelSelectorBottomSheet(
        context,
        levels,
        selected,
      );

      if (!mounted || pickedLevel == null) return;

      setState(() {
        final updated = _profile.learningLanguages.map((LanguageItem l) {
          if (l.code == lang.code) {
            return LanguageItem(
              code: l.code,
              name: l.name,
              level: pickedLevel,
              active: l.active,
            );
          }
          return l;
        }).toList();

        _profile = _profile.copyWith(learningLanguages: updated);
      });
      return;
    }

    // ✅ Opción 3: Eliminar idioma (igual que antes)
    if (action == 'delete') {
      if (_profile.learningLanguages.length <= 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debe haber al menos un idioma de aprendizaje.'),
          ),
        );
        return;
      }

      setState(() {
        final updated = _profile.learningLanguages
            .where((l) => l.code != lang.code)
            .toList();

        _profile = _profile.copyWith(
          learningLanguages: updated,
          languagesCount: updated.length,
        );
      });
    }
  }

  /// Cierra sesión y navega al login
  Future<void> _onLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await AuthService().logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error al cerrar sesión. Inténtalo de nuevo.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            _brandBadge(),
            const SizedBox(width: AppDimensions.spacingSM),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SpeakBuddy',
                  style: TextStyle(
                    color: AppTheme.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Nivel ${_profile.level}',
                      style: TextStyle(color: AppTheme.subtle, fontSize: AppDimensions.fontSizeXS),
                    ),
                    const SizedBox(width: AppDimensions.spacingSM),
                    _ProgressMini(
                      value: _profile.progressPct,
                      track: AppTheme.card,
                      fill: AppTheme.accent,
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            if (_profile.isPro) _proChip(),
            const SizedBox(width: AppDimensions.spacingSM),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications_none_rounded, color: AppTheme.subtle),
              tooltip: 'Notificaciones',
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: AppDimensions.paddingScreen,
        child: Column(
          children: [
            _UserCard(profile: _profile),
            const SizedBox(height: AppDimensions.spacingL),
            _Section(
              title: 'Descripción del perfil',
              trailing: IconButton(
                onPressed: _editDescription,
                icon: const Icon(Icons.edit_rounded),
                tooltip: 'Editar descripción',
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _profile.description,
                  style: TextStyle(
                    color: AppTheme.text,
                    height: AppDimensions.lineHeight,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            _StatsRow(profile: _profile),
            const SizedBox(height: AppDimensions.spacingL),
            _Section(
              title: 'Estadísticas Detalladas',
              child: Column(
                children: [
                  _StatLine(
                    icon: Icons.access_time_rounded,
                    label: 'Horas totales',
                    value: '${_profile.hoursTotal}h',
                  ),
                  Divider(color: AppTheme.border, height: 1),
                  _StatLine(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Racha actual',
                    value: '${_profile.currentStreakDays} días',
                  ),
                  Divider(color: AppTheme.border, height: 1),
                  _StatLine(
                    icon: Icons.emoji_events_rounded,
                    label: 'Mejor racha',
                    value: '${_profile.bestStreakDays} días',
                  ),
                  Divider(color: AppTheme.border, height: 1),
                  _StatLine(
                    icon: Icons.military_tech_rounded,
                    label: 'Medallas',
                    value: '${_profile.medals}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            _Section(
              title: 'Idiomas de Aprendizaje',
              trailing: TextButton.icon(
                onPressed: _addLearningLanguage,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Añadir'),
              ),
              child: Column(
                children: _profile.learningLanguages
                    .map(
                      (l) => Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                        child: _LanguageTile(
                          lang: l,
                          onLongPress: () => _onLanguageLongPress(l),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            _Section(
              title: 'Configuración',
              child: Column(
                children: [
                  _ActionTile(
                    icon: Icons.settings_rounded,
                    label: 'Ajustes',
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(
                            initialName: _profile.name,
                            initialNative: _profile.nativeLanguage,
                            initialLearning: _profile.learningLanguages
                                .map((e) => e.code)
                                .toList(),
                            initialAvatarPath: _profile.avatarPath,
                          ),
                        ),
                      );

                      if (!context.mounted || result == null) return;
                      if (result is EditProfileResult) {
                        setState(() {
                          // 1) nombre
                          _profile = _profile.copyWith(name: result.name);

                          // 2) idioma nativo
                          _profile = _profile.copyWith(
                            nativeLanguage: result.nativeLanguage,
                          );

                          // 3) idiomas aprendiendo (reconstruimos LanguageItem con niveles por defecto)
                          final updatedLearning = result.learningLanguages.map((
                            code,
                          ) {
                            final display = AppLanguages.getName(code);
                            return LanguageItem(
                              code: code,
                              name: display,
                              level: 'Principiante',
                            );
                          }).toList();
                          _profile = _profile.copyWith(
                            learningLanguages: updatedLearning,
                            languagesCount: updatedLearning.length,
                          );

                          // 4) foto
                          if (result.avatarFile != null) {
                            _profile = _profile.copyWith(
                              avatarPath: result.avatarFile!.path,
                            );
                          }
                        });
                      }
                    },
                  ),
                  Divider(color: AppTheme.border, height: 1),
                  _ActionTile(
                    // Reemplazo de Icons.crown_rounded (no existe en Material)
                    icon: Icons.workspace_premium_rounded,
                    label: 'Mejorar a Premium',
                    onTap: () {},
                    highlight: true,
                  ),
                  Divider(color: AppTheme.border, height: 1),
                  _ActionTile(
                    icon: Icons.logout_rounded,
                    label: 'Cerrar sesión',
                    danger: true,
                    onTap: () => _onLogout(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _brandBadge() {
    return Container(
      width: AppDimensions.badgeSize,
      height: AppDimensions.badgeSize,
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppTheme.border),
      ),
      alignment: Alignment.center,
      child: Text(
        'SB',
        style: TextStyle(color: AppTheme.text, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _proChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingM, vertical: AppDimensions.spacingS),
      decoration: BoxDecoration(
        color: AppTheme.gold.withValues(alpha: .12),
        border: Border.all(color: AppTheme.gold.withValues(alpha: .5)),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
      ),
      child: Row(
        children: [
          Icon(Icons.workspace_premium_rounded, size: AppDimensions.iconSizeS, color: AppTheme.gold),
          const SizedBox(width: AppDimensions.spacingS),
          Text(
            'Pro',
            style: TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/* ------------------------ UI Pieces ------------------------ */

class _UserCard extends StatelessWidget {
  const _UserCard({required this.profile});
  final UserProfile profile;

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
          Row(
            children: [
              CircleAvatar(
                radius: AppDimensions.avatarSizeS,
                backgroundImage: getAvatarImageProvider(
                  filePath: profile.avatarPath,
                  assetPath: 'lib/assets/images/ArjonaSergio.jpg',
                ),
                backgroundColor: AppTheme.panel,
              ),
              const SizedBox(width: AppDimensions.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: TextStyle(
                        color: AppTheme.text,
                        fontWeight: FontWeight.w700,
                        fontSize: AppDimensions.fontSizeL,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXS),
                    Text(
                      profile.email,
                      style: TextStyle(color: AppTheme.subtle, fontSize: AppDimensions.fontSizeS),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Row(
                      children: [
                        Icon(Icons.public_rounded, size: AppDimensions.iconSizeS, color: AppTheme.subtle),
                        const SizedBox(width: AppDimensions.spacingS),
                        Text(
                          '${AppLanguages.getName(profile.nativeLanguage)}  →  ${profile.learningLanguages.isNotEmpty ? AppLanguages.getName(profile.learningLanguages.first.code) : '-'}',
                          style: TextStyle(color: AppTheme.subtle, fontSize: AppDimensions.fontSizeS),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingML),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.panel,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppTheme.border),
            ),
            padding: AppDimensions.paddingCardSmall,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nivel ${profile.level}',
                  style: TextStyle(color: AppTheme.text, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppDimensions.spacingSM),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.spacingSM),
                  child: LinearProgressIndicator(
                    value: profile.progressPct,
                    minHeight: 10,
                    backgroundColor: AppTheme.progressBg,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSM),
                Text(
                  '${_remaining(profile.progressPct)} intercambios hasta nivel ${profile.level + 1}',
                  style: TextStyle(color: AppTheme.subtle, fontSize: AppDimensions.fontSizeXS),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _remaining(double pct) {
    // Maqueta: asumimos que 5 intercambios = 100%
    final completed = (pct * 5).round();
    return (5 - completed).clamp(0, 5);
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SmallStatCard(
            icon: Icons.chat_bubble_rounded,
            label: 'Intercambios',
            value: '${profile.exchanges}',
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        Expanded(
          child: _SmallStatCard(
            icon: Icons.star_rounded,
            label: 'Valoración',
            value: profile.rating.toStringAsFixed(1),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingM),
        Expanded(
          child: _SmallStatCard(
            icon: Icons.language_rounded,
            label: 'Idiomas',
            value: '${profile.languagesCount}',
          ),
        ),
      ],
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  const _SmallStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppTheme.border),
      ),
      padding: AppDimensions.paddingInput,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.panel,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.border),
            ),
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: Icon(icon, color: AppTheme.subtle),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.text,
              fontWeight: FontWeight.w700,
              fontSize: AppDimensions.fontSizeL,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: AppTheme.subtle, fontSize: AppDimensions.fontSizeXS)),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppTheme.border),
      ),
      padding: EdgeInsets.fromLTRB(AppDimensions.spacingL, AppDimensions.spacingML, AppDimensions.spacingL, AppDimensions.spacingMD),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(color: AppTheme.text, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (trailing != null)
                Theme(
                  data: Theme.of(context).copyWith(
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(foregroundColor: AppTheme.text),
                    ),
                  ),
                  child: trailing!,
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          child,
        ],
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.subtle),
            const SizedBox(width: AppDimensions.spacingML),
          Expanded(
            child: Text(label, style: TextStyle(color: AppTheme.text)),
          ),
          Text(
            value,
            style: TextStyle(color: AppTheme.text, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.lang, this.onLongPress});
  final LanguageItem lang;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // 👈 para detectar long press
      borderRadius: BorderRadius.circular(AppDimensions.radiusML),
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.panel,
          borderRadius: BorderRadius.circular(AppDimensions.radiusML),
          border: Border.all(color: AppTheme.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMD, vertical: AppDimensions.spacingMD),
        child: Row(
          children: [
            Container(
              width: AppDimensions.avatarSizeM,
              height: AppDimensions.avatarSizeM,
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: AppTheme.border),
              ),
              alignment: Alignment.center,
              child: Text(
                lang.code,
                style: TextStyle(color: AppTheme.text, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.name,
                    style: TextStyle(
                      color: AppTheme.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lang.level,
                    style: TextStyle(color: AppTheme.subtle, fontSize: AppDimensions.fontSizeXS),
                  ),
                ],
              ),
            ),
            if (lang.active)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingM,
                  vertical: AppDimensions.spacingS,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: .15),
                  border: Border.all(color: AppTheme.accent.withValues(alpha: .6)),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
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
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
    this.highlight = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.redAccent : (highlight ? AppTheme.gold : AppTheme.text);

    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      onTap: onTap,
      child: Padding(
        padding: AppDimensions.paddingButton,
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: AppDimensions.spacingMD),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.subtle),
          ],
        ),
      ),
    );
  }
}

class _ProgressMini extends StatelessWidget {
  const _ProgressMini({
    required this.value,
    required this.track,
    required this.fill,
  });
  final double value;
  final Color track;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppDimensions.progressBarWidth,
      height: AppDimensions.progressBarHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: track,
          valueColor: AlwaysStoppedAnimation<Color>(fill),
        ),
      ),
    );
  }
}

