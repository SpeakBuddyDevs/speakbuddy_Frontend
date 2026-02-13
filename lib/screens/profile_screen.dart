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
import '../widgets/common/app_header.dart';
import '../constants/dimensions.dart';
import '../constants/language_ids.dart';
import '../constants/level_ids.dart';
import '../repositories/api_users_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Estado del perfil (puede ser nulo mientras carga)
  UserProfile? _profile;
  bool _isLoading = true;

  // Repositorio real conectado al Backend
  final _usersRepo = ApiUsersRepository();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    final profile = await _usersRepo.getMyProfile();

    if (!mounted) return;
    setState(() {
      if (profile != null) _profile = profile;
      _isLoading = false;
    });
  }

  Future<void> _editDescription() async {
    if (_profile == null) return;

    final controller = TextEditingController(text: _profile!.description);

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

    if (newText == null) return;

    // Guardar el valor anterior por si hay error
    final previousDescription = _profile!.description;

    // Actualización optimista de la UI
    setState(() {
      _profile = _profile!.copyWith(description: newText);
    });

    // Llamar al backend para persistir los cambios
    final ok = await _usersRepo.updateProfile(
      _profile!.id,
      description: newText,
    );

    if (!mounted) return;

    if (!ok) {
      // Revertir en caso de error
      setState(() {
        _profile = _profile!.copyWith(description: previousDescription);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar la descripción'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addLearningLanguage() async {
    if (_profile == null) return;
    if (_profile!.id.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se puede añadir; recarga el perfil e inténtalo de nuevo.',
          ),
        ),
      );
      return;
    }

    // Códigos ya en aprendizaje
    final existing = _profile!.learningLanguages
        .map((e) => e.code.trim().toLowerCase())
        .toSet();
    final nativeCode = _profile!.nativeLanguage.trim().toLowerCase();

    // Disponibles = catálogo - existentes - idioma nativo; solo los que soporta el backend
    final available = AppLanguages.availableCodes.where((rawCode) {
      final codeToCheck = rawCode.trim().toLowerCase();

      // Comprobaciones
      final isNotLearning = !existing.contains(codeToCheck);
      final isNotNative = codeToCheck != nativeCode;

      final isSupported = LanguageIds.learningCodesSupportedByBackend
          .map((e) => e.trim().toLowerCase())
          .contains(codeToCheck);

      return isNotLearning && isNotNative && isSupported;
    }).toList();

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

    final display = AppLanguages.getName(picked);
    final newItem = LanguageItem(
      code: picked,
      name: display,
      level: 'Principiante',
    );

    setState(() {
      _profile = _profile!.copyWith(
        learningLanguages: [..._profile!.learningLanguages, newItem],
        languagesCount: _profile!.learningLanguages.length + 1,
      );
    });

    final ok = await ApiUsersRepository().addLearningLanguage(
      _profile!.id,
      picked,
      levelId: 1,
    );
    if (!mounted) return;
    if (!ok) {
      setState(() {
        final updated = _profile!.learningLanguages
            .where((l) => l.code != picked)
            .toList();
        _profile = _profile!.copyWith(
          learningLanguages: updated,
          languagesCount: updated.length,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al añadir idioma $display')),
      );
      return;
    }
    _loadUserProfile();
  }

  void _onLanguageLongPress(LanguageItem lang) async {
    if (_profile == null) return;

    final isActive = lang.active;
    final action = await showLanguageActionBottomSheet(context, isActive);

    if (!mounted || action == null) return;

    // Opción 1a: Marcar como activo
    if (action == 'active') {
      // Guardar estado anterior
      final previousLanguages = List<LanguageItem>.from(_profile!.learningLanguages);

      // Actualización optimista
      setState(() {
        final updated = _profile!.learningLanguages.map((LanguageItem l) {
          final shouldBeActive = (l.code == lang.code);

          return LanguageItem(
            code: l.code,
            name: l.name,
            level: l.level,
            active: shouldBeActive,
          );
        }).toList();

        _profile = _profile!.copyWith(learningLanguages: updated);
      });

      // Llamada al backend
      final ok = await _usersRepo.setLearningLanguageActive(_profile!.id, lang.code);
      if (!mounted) return;
      if (!ok) {
        // Revertir en caso de error
        setState(() {
          _profile = _profile!.copyWith(learningLanguages: previousLanguages);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al activar el idioma'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Caso 1b: El usuario quiere DESACTIVAR este idioma (pasar a inactivo)
    if (action == 'unactive') {
      // Guardar estado anterior
      final previousLanguages = List<LanguageItem>.from(_profile!.learningLanguages);

      // Actualización optimista
      setState(() {
        final updated = _profile!.learningLanguages.map((LanguageItem l) {
          if (l.code == lang.code) {
            return LanguageItem(
              code: l.code,
              name: l.name,
              level: l.level,
              active: false,
            );
          }
          return l;
        }).toList();

        _profile = _profile!.copyWith(learningLanguages: updated);
      });

      // Llamada al backend
      final ok = await _usersRepo.setLearningLanguageInactive(_profile!.id, lang.code);
      if (!mounted) return;
      if (!ok) {
        // Revertir en caso de error
        setState(() {
          _profile = _profile!.copyWith(learningLanguages: previousLanguages);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al desactivar el idioma'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Opción 2: Configurar nivel
    if (action == 'level') {
      final levels = LevelIds.availableLevels;
      String selected = lang.level;

      // Si el nivel actual no está en la lista, usar el primero
      if (!levels.contains(selected)) {
        selected = levels.first;
      }

      final pickedLevel = await showLevelSelectorBottomSheet(
        context,
        levels,
        selected,
      );

      if (!mounted || pickedLevel == null) return;

      // Obtener el ID del nivel para el backend
      final levelId = LevelIds.getId(pickedLevel);
      if (levelId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nivel no válido'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Guardar estado anterior
      final previousLanguages = List<LanguageItem>.from(_profile!.learningLanguages);

      // Actualización optimista
      setState(() {
        final updated = _profile!.learningLanguages.map((LanguageItem l) {
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

        _profile = _profile!.copyWith(learningLanguages: updated);
      });

      // Llamada al backend
      final ok = await _usersRepo.updateLearningLevel(
        _profile!.id,
        lang.code,
        levelId,
      );
      if (!mounted) return;
      if (!ok) {
        // Revertir en caso de error
        setState(() {
          _profile = _profile!.copyWith(learningLanguages: previousLanguages);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar el nivel'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Opción 3: Eliminar idioma
    if (action == 'delete') {
      if (_profile!.learningLanguages.length <= 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debe haber al menos un idioma de aprendizaje.'),
          ),
        );
        return;
      }

      // Guardar estado anterior
      final previousLanguages = List<LanguageItem>.from(_profile!.learningLanguages);
      final previousCount = _profile!.languagesCount;

      // Actualización optimista
      setState(() {
        final updated = _profile!.learningLanguages
            .where((l) => l.code != lang.code)
            .toList();

        _profile = _profile!.copyWith(
          learningLanguages: updated,
          languagesCount: updated.length,
        );
      });

      // Llamada al backend
      final ok = await _usersRepo.deleteLearningLanguage(_profile!.id, lang.code);
      if (!mounted) return;
      if (!ok) {
        // Revertir en caso de error
        setState(() {
          _profile = _profile!.copyWith(
            learningLanguages: previousLanguages,
            languagesCount: previousCount,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar ${lang.name}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
            child: const Text(
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
    // 1. Loading
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. Error / No Profile
    if (_profile == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('Perfil')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Error cargando el perfil'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserProfile,
                child: const Text('Reintentar'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _onLogout,
                child: const Text("Cerrar sesión"),
              ),
            ],
          ),
        ),
      );
    }

    // 3. UI Principal con datos reales
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppHeader(
        userName: _profile!.name,
        level: _profile!.level,
        levelProgress: _profile!.progressPct,
        isPro: _profile!.isPro,
        onNotificationsTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notificaciones próximamente')),
          );
        },
        onProTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Pro próximamente')));
        },
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppDimensions.paddingScreen,
          child: Column(
            children: [
              _UserCard(profile: _profile!), // Perfil real
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
                    _profile!.description.isEmpty
                        ? 'Añade una descripción...'
                        : _profile!.description,
                    style: TextStyle(
                      color: AppTheme.text,
                      height: AppDimensions.lineHeight,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingL),
              _StatsRow(profile: _profile!),
              const SizedBox(height: AppDimensions.spacingL),
              _Section(
                title: 'Estadísticas Detalladas',
                child: Column(
                  children: [
                    _StatLine(
                      icon: Icons.access_time_rounded,
                      label: 'Horas totales',
                      value: '${_profile!.hoursTotal.toStringAsFixed(2)} h',
                    ),
                    Divider(color: AppTheme.border, height: 1),
                    _StatLine(
                      icon: Icons.local_fire_department_rounded,
                      label: 'Racha actual',
                      value: '${_profile!.currentStreakDays} días',
                    ),
                    Divider(color: AppTheme.border, height: 1),
                    _StatLine(
                      icon: Icons.emoji_events_rounded,
                      label: 'Mejor racha',
                      value: '${_profile!.bestStreakDays} días',
                    ),
                    Divider(color: AppTheme.border, height: 1),
                    _StatLine(
                      icon: Icons.military_tech_rounded,
                      label: 'Medallas',
                      value: '${_profile!.medals}',
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
                  children: _profile!.learningLanguages
                      .map(
                        (l) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppDimensions.spacingM,
                          ),
                          child: _LanguageTile(
                            lang: l,
                            onLongPress: () => _onLanguageLongPress(l),

                            // --- CORRECCIÓN 1: Añadido 'async' aquí ---
                            onTap: !l.active
                                ? () async {
                                    // 1. UI Optimista
                                    setState(() {
                                      final updated = _profile!
                                          .learningLanguages
                                          .map((item) {
                                            return item.code == l.code
                                                ? LanguageItem(
                                                    code: item.code,
                                                    name: item.name,
                                                    level: item.level,
                                                    active: true,
                                                  )
                                                : LanguageItem(
                                                    code: item.code,
                                                    name: item.name,
                                                    level: item.level,
                                                    active: false,
                                                  );
                                          })
                                          .toList();

                                      _profile = _profile!.copyWith(
                                        learningLanguages: updated,
                                      );
                                    });

                                    // 2. Llamada al Backend (Ahora sí funciona el await)
                                    final success = await _usersRepo
                                        .setLearningLanguageActive(
                                          _profile!.id,
                                          l.code,
                                        );

                                    if (!mounted)
                                      return; // Buena práctica comprobar mounted después de un await
                                    if (!success) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Error de conexión"),
                                        ),
                                      );
                                      _loadUserProfile();
                                    }
                                  }
                                : null,

                            // --- CORRECCIÓN 2: Añadido 'async' aquí también para desactivar ---
                            onActiveTap: () async {
                              setState(() {
                                final updated = _profile!.learningLanguages.map(
                                  (item) {
                                    if (item.code == l.code) {
                                      // Lo apagamos visualmente
                                      return LanguageItem(
                                        code: item.code,
                                        name: item.name,
                                        level: item.level,
                                        active: false,
                                      );
                                    }
                                    return item;
                                  },
                                ).toList();

                                _profile = _profile!.copyWith(
                                  learningLanguages: updated,
                                );
                              });

                              // 3. Llamada al Backend para DESACTIVAR
                              // NOTA: Necesitas crear este método en tu repo, ver punto 2 abajo
                              final success = await _usersRepo
                                  .setLearningLanguageInactive(
                                    _profile!.id,
                                    l.code,
                                  );

                              if (!mounted) return;
                              if (!success) {
                                _loadUserProfile(); // Si falla, recargamos para volver al estado real
                              }
                            },
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
                              initialName: _profile!.name,
                              initialNative: _profile!.nativeLanguage,
                              initialLearning: _profile!.learningLanguages
                                  .map((e) => e.code)
                                  .toList(),
                              initialAvatarPath: _profile!.avatarPath,
                              userId: _profile!.id.isEmpty
                                  ? null
                                  : _profile!.id,
                            ),
                          ),
                        );

                        if (!context.mounted || result == null) return;
                        if (result is EditProfileResult) {
                          setState(() {
                            _profile = _profile!.copyWith(
                              name: result.name,
                              nativeLanguage: result.nativeLanguage,
                            );

                            final updatedLearning = result.learningLanguages
                                .map((code) {
                                  final display = AppLanguages.getName(code);
                                  return LanguageItem(
                                    code: code,
                                    name: display,
                                    level: 'Principiante',
                                  );
                                })
                                .toList();

                            _profile = _profile!.copyWith(
                              learningLanguages: updatedLearning,
                              languagesCount: updatedLearning.length,
                            );

                            // Actualizar avatar: priorizar URL del backend sobre archivo local
                            if (result.avatarUrl != null) {
                              _profile = _profile!.copyWith(
                                avatarPath: result.avatarUrl,
                              );
                            } else if (result.avatarFile != null) {
                              _profile = _profile!.copyWith(
                                avatarPath: result.avatarFile!.path,
                              );
                            }
                          });
                          _loadUserProfile();
                        }
                      },
                    ),
                    Divider(color: AppTheme.border, height: 1),
                    _ActionTile(
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
      ),
    );
  }
}

/* ------------------------ UI Pieces (Clases originales) ------------------------ */

class _UserCard extends StatelessWidget {
  const _UserCard({required this.profile});
  final UserProfile profile;

  static bool _isUrl(String? s) =>
      s != null && (s.startsWith('http://') || s.startsWith('https://'));

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
                  avatarUrl: _isUrl(profile.avatarPath)
                      ? profile.avatarPath
                      : null,
                  filePath: _isUrl(profile.avatarPath)
                      ? null
                      : profile.avatarPath,
                  assetPath: 'lib/assets/images/image.png',
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
                      style: TextStyle(
                        color: AppTheme.subtle,
                        fontSize: AppDimensions.fontSizeS,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Row(
                      children: [
                        Icon(
                          Icons.public_rounded,
                          size: AppDimensions.iconSizeS,
                          color: AppTheme.subtle,
                        ),
                        const SizedBox(width: AppDimensions.spacingS),
                        Text(
                          '${AppLanguages.getName(profile.nativeLanguage)}  →  ${_getActiveLanguageName()}',
                          style: TextStyle(
                            color: AppTheme.subtle,
                            fontSize: AppDimensions.fontSizeS,
                          ),
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
                  style: TextStyle(
                    color: AppTheme.text,
                    fontWeight: FontWeight.w600,
                  ),
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
                  style: TextStyle(
                    color: AppTheme.subtle,
                    fontSize: AppDimensions.fontSizeXS,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _remaining(double pct) {
    final completed = (pct * 5).round();
    return (5 - completed).clamp(0, 5);
  }

  String _getActiveLanguageName() {
    // Buscar idioma activo, o el primero si no hay ninguno
    final activeLang = profile.learningLanguages.where((l) => l.active).firstOrNull;
    final targetLang = activeLang ??
        (profile.learningLanguages.isNotEmpty ? profile.learningLanguages.first : null);
    return targetLang != null ? AppLanguages.getName(targetLang.code) : '-';
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
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spacingL,
        AppDimensions.spacingML,
        AppDimensions.spacingL,
        AppDimensions.spacingMD,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (trailing != null)
                Theme(
                  data: Theme.of(context).copyWith(
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.text,
                      ),
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
  const _LanguageTile({
    required this.lang,
    this.onLongPress,
    this.onTap,
    this.onActiveTap,
  });
  final LanguageItem lang;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;
  final VoidCallback? onActiveTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radiusML),
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.panel,
          borderRadius: BorderRadius.circular(AppDimensions.radiusML),
          border: Border.all(color: AppTheme.border),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMD,
          vertical: AppDimensions.spacingMD,
        ),
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
                style: TextStyle(
                  color: AppTheme.text,
                  fontWeight: FontWeight.w700,
                ),
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
                    style: TextStyle(
                      color: AppTheme.subtle,
                      fontSize: AppDimensions.fontSizeXS,
                    ),
                  ),
                ],
              ),
            ),
            if (lang.active)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusCircular,
                  ),
                  onTap: onActiveTap, // Llama a la función para desactivar
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingM,
                      vertical: AppDimensions.spacingS,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Activo',
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w600,
                            fontSize: AppDimensions.fontSizeXS,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons
                              .close_rounded, // Icono visual para indicar "Cerrar/Desactivar"
                          size: 14,
                          color: AppTheme.accent,
                        ),
                      ],
                    ),
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
    final color = danger
        ? Colors.redAccent
        : (highlight ? AppTheme.gold : AppTheme.text);

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
