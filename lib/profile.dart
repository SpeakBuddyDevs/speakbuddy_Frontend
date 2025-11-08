import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // TODO: Sustituir por datos reales desde el backend (/api/auth/me + /api/profile)
  final _profile = _MockProfile(
    name: 'María González',
    email: 'maria.gonzalez@email.com',
    level: 5,
    progressPct: 0.40,
    exchanges: 12,
    rating: 4.8,
    languagesCount: 3,
    hoursTotal: 18,
    currentStreakDays: 5,
    bestStreakDays: 12,
    medals: 4,
    learningLanguages: const [
      _LangItem(code: 'ES', name: 'Español', level: 'Intermedio', active: true),
      _LangItem(code: 'FR', name: 'Francés', level: 'Principiante'),
    ],
    isPro: true,
  );

  @override
  Widget build(BuildContext context) {
    final color = _Palette.of(context);

    return Scaffold(
      backgroundColor: color.bg,
      appBar: AppBar(
        backgroundColor: color.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            _brandBadge(),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LangExchange',
                    style: TextStyle(color: color.text, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Text('Nivel ${_profile.level}',
                        style: TextStyle(color: color.subtle, fontSize: 12)),
                    const SizedBox(width: 8),
                    _ProgressMini(
                        value: _profile.progressPct,
                        track: color.card,
                        fill: color.accent),
                  ],
                ),
              ],
            ),
            const Spacer(),
            if (_profile.isPro) _proChip(color),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications_none_rounded, color: color.subtle),
              tooltip: 'Notificaciones',
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          children: [
            _UserCard(profile: _profile),
            const SizedBox(height: 16),
            _StatsRow(profile: _profile),
            const SizedBox(height: 16),
            _Section(
              title: 'Estadísticas Detalladas',
              child: Column(
                children: [
                  _StatLine(
                      icon: Icons.access_time_rounded,
                      label: 'Horas totales',
                      value: '${_profile.hoursTotal}h'),
                  Divider(color: color.border, height: 1),
                  _StatLine(
                      icon: Icons.local_fire_department_rounded,
                      label: 'Racha actual',
                      value: '${_profile.currentStreakDays} días'),
                  Divider(color: color.border, height: 1),
                  _StatLine(
                      icon: Icons.emoji_events_rounded,
                      label: 'Mejor racha',
                      value: '${_profile.bestStreakDays} días'),
                  Divider(color: color.border, height: 1),
                  _StatLine(
                      icon: Icons.military_tech_rounded,
                      label: 'Medallas',
                      value: '${_profile.medals}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Idiomas de Aprendizaje',
              trailing: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded),
                label: const Text('Añadir'),
              ),
              child: Column(
                children: _profile.learningLanguages
                    .map((l) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _LanguageTile(lang: l),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Configuración',
              child: Column(
                children: [
                  _ActionTile(
                    icon: Icons.settings_rounded,
                    label: 'Ajustes',
                    onTap: () {},
                  ),
                  Divider(color: color.border, height: 1),
                  _ActionTile(
                    // Reemplazo de Icons.crown_rounded (no existe en Material)
                    icon: Icons.workspace_premium_rounded,
                    label: 'Mejorar a Premium',
                    onTap: () {},
                    highlight: true,
                  ),
                  Divider(color: color.border, height: 1),
                  _ActionTile(
                    icon: Icons.logout_rounded,
                    label: 'Cerrar sesión',
                    danger: true,
                    onTap: () {
                      // TODO: Llamar a vuestro logout real y navegar al Login
                      Navigator.of(context).maybePop();
                    },
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
    final color = _Palette.of(context);
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.border),
      ),
      alignment: Alignment.center,
      child: Text('LX',
          style: TextStyle(color: color.text, fontWeight: FontWeight.bold)),
    );
  }

  Widget _proChip(_Palette c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.gold.withOpacity(.12),
        border: Border.all(color: c.gold.withOpacity(.5)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(Icons.workspace_premium_rounded, size: 16, color: c.gold),
          const SizedBox(width: 6),
          Text('Pro',
              style: TextStyle(color: c.gold, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/* ------------------------ UI Pieces ------------------------ */

class _UserCard extends StatelessWidget {
  const _UserCard({required this.profile});
  final _MockProfile profile;

  @override
  Widget build(BuildContext context) {
    final c = _Palette.of(context);

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundImage:
                    AssetImage('assets/avatar_placeholder.jpg'), // TODO: NetworkImage si tenéis URL
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name,
                        style: TextStyle(
                            color: c.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(profile.email,
                        style: TextStyle(color: c.subtle, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.public_rounded, size: 16, color: c.subtle),
                        const SizedBox(width: 6),
                        Text('Español  →  Inglés', // TODO: construir desde datos reales
                            style:
                                TextStyle(color: c.subtle, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: c.panel,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.border),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nivel ${profile.level}',
                    style: TextStyle(
                        color: c.text, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: profile.progressPct,
                    minHeight: 10,
                    backgroundColor: c.progressBg,
                    valueColor: AlwaysStoppedAnimation<Color>(c.accent),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                    '${_remaining(profile.progressPct)} intercambios hasta nivel ${profile.level + 1}',
                    style: TextStyle(color: c.subtle, fontSize: 12)),
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
  final _MockProfile profile;

  @override
  Widget build(BuildContext context) {
    final c = _Palette.of(context);
    return Row(
      children: [
        Expanded(
            child: _SmallStatCard(
                icon: Icons.chat_bubble_rounded,
                label: 'Intercambios',
                value: '${profile.exchanges}')),
        const SizedBox(width: 10),
        Expanded(
            child: _SmallStatCard(
                icon: Icons.star_rounded,
                label: 'Valoración',
                value: profile.rating.toStringAsFixed(1))),
        const SizedBox(width: 10),
        Expanded(
            child: _SmallStatCard(
                icon: Icons.language_rounded,
                label: 'Idiomas',
                value: '${profile.languagesCount}')),
      ],
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  const _SmallStatCard(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = _Palette.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: c.panel,
              shape: BoxShape.circle,
              border: Border.all(color: c.border),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: c.subtle),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  color: c.text, fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: c.subtle, fontSize: 12)),
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
    final c = _Palette.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              Text(title,
                  style: TextStyle(color: c.text, fontWeight: FontWeight.w700)),
              const Spacer(),
              if (trailing != null)
                Theme(
                  data: Theme.of(context).copyWith(
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(foregroundColor: c.text),
                    ),
                  ),
                  child: trailing!,
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = _Palette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: c.subtle),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: TextStyle(color: c.text))),
          Text(value,
              style: TextStyle(color: c.text, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.lang});
  final _LangItem lang;

  @override
  Widget build(BuildContext context) {
    final c = _Palette.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.border),
            ),
            alignment: Alignment.center,
            child: Text(lang.code,
                style:
                    TextStyle(color: c.text, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.name,
                    style: TextStyle(
                        color: c.text, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(lang.level, style: TextStyle(color: c.subtle, fontSize: 12)),
              ],
            ),
          ),
          if (lang.active)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: c.accent.withOpacity(.15),
                border: Border.all(color: c.accent.withOpacity(.6)),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('Activo',
                  style: TextStyle(
                      color: c.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.danger = false,
      this.highlight = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final c = _Palette.of(context);
    final color = danger
        ? Colors.redAccent
        : (highlight ? c.gold : c.text);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style:
                        TextStyle(color: color, fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right_rounded, color: c.subtle),
          ],
        ),
      ),
    );
  }
}

class _ProgressMini extends StatelessWidget {
  const _ProgressMini(
      {required this.value, required this.track, required this.fill});
  final double value;
  final Color track;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 6,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: track,
          valueColor: AlwaysStoppedAnimation<Color>(fill),
        ),
      ),
    );
  }
}

/* ------------------------ Theme helpers ------------------------ */

class _Palette {
  final BuildContext context;
  _Palette.of(this.context);

  Color get bg => const Color(0xFF0E1320);
  Color get card => const Color(0xFF151B2C);
  Color get panel => const Color(0xFF111726);
  Color get border => const Color(0xFF2B3246);
  Color get text => const Color(0xFFE7EAF3);
  Color get subtle => const Color(0xFF98A3B8);
  Color get accent => const Color(0xFF4DA3FF);
  Color get progressBg => const Color(0xFF27334A);
  Color get gold => const Color(0xFFF3C86A);
}

class _LangItem {
  final String code;
  final String name;
  final String level;
  final bool active;
  const _LangItem(
      {required this.code,
      required this.name,
      required this.level,
      this.active = false});
}

class _MockProfile {
  final String name;
  final String email;
  final int level;
  final double progressPct;
  final int exchanges;
  final double rating;
  final int languagesCount;
  final int hoursTotal;
  final int currentStreakDays;
  final int bestStreakDays;
  final int medals;
  final List<_LangItem> learningLanguages;
  final bool isPro;

  const _MockProfile({
    required this.name,
    required this.email,
    required this.level,
    required this.progressPct,
    required this.exchanges,
    required this.rating,
    required this.languagesCount,
    required this.hoursTotal,
    required this.currentStreakDays,
    required this.bestStreakDays,
    required this.medals,
    required this.learningLanguages,
    required this.isPro,
  });
}