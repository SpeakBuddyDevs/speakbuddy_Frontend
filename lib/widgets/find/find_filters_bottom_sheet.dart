import 'package:flutter/material.dart';
import '../../models/find_filters.dart';
import '../../theme/app_theme.dart';
import '../../constants/dimensions.dart';

/// Lista de idiomas disponibles para filtrar
const List<String> _availableLanguages = [
  'Español',
  'Inglés',
  'Francés',
  'Alemán',
  'Italiano',
  'Portugués',
  'Chino',
  'Japonés',
  'Ruso',
  'Árabe',
  'Coreano',
];

/// Lista de países disponibles para filtrar
const List<String> _availableCountries = [
  'Estados Unidos',
  'España',
  'México',
  'Francia',
  'Alemania',
  'Italia',
  'Brasil',
  'Argentina',
  'Reino Unido',
  'Japón',
  'China',
  'Rusia',
];

/// Bottom sheet para filtros de búsqueda de usuarios
class FindFiltersBottomSheet extends StatefulWidget {
  final FindFilters initialFilters;

  const FindFiltersBottomSheet({
    super.key,
    required this.initialFilters,
  });

  @override
  State<FindFiltersBottomSheet> createState() => _FindFiltersBottomSheetState();
}

class _FindFiltersBottomSheetState extends State<FindFiltersBottomSheet> {
  late bool _onlineOnly;
  late bool _proOnly;
  late double _minRating;
  late String? _nativeLanguage;
  late String? _targetLanguage;
  late String? _country;

  @override
  void initState() {
    super.initState();
    _onlineOnly = widget.initialFilters.onlineOnly;
    _proOnly = widget.initialFilters.proOnly;
    _minRating = widget.initialFilters.minRating ?? 0.0;
    _nativeLanguage = widget.initialFilters.nativeLanguage;
    _targetLanguage = widget.initialFilters.targetLanguage;
    _country = widget.initialFilters.country;
  }

  void _resetFilters() {
    setState(() {
      _onlineOnly = false;
      _proOnly = false;
      _minRating = 0.0;
      _nativeLanguage = null;
      _targetLanguage = null;
      _country = null;
    });
  }

  void _applyFilters() {
    final filters = FindFilters(
      onlineOnly: _onlineOnly,
      proOnly: _proOnly,
      minRating: _minRating > 0 ? _minRating : null,
      nativeLanguage: _nativeLanguage,
      targetLanguage: _targetLanguage,
      country: _country,
    );
    Navigator.pop(context, filters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppDimensions.spacingMD),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            child: Row(
              children: [
                Text(
                  'Filtros',
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: AppDimensions.fontSizeXL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    'Restablecer',
                    style: TextStyle(color: AppTheme.accent),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppTheme.border, height: 1),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Disponibilidad
                  _SectionTitle(title: 'Disponibilidad'),
                  _FilterSwitch(
                    label: 'Solo online',
                    value: _onlineOnly,
                    onChanged: (v) => setState(() => _onlineOnly = v),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  // Cuenta
                  _SectionTitle(title: 'Cuenta'),
                  _FilterSwitch(
                    label: 'Solo PRO',
                    value: _proOnly,
                    onChanged: (v) => setState(() => _proOnly = v),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  // Rating mínimo
                  _SectionTitle(title: 'Rating mínimo'),
                  Row(
                    children: [
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppTheme.accent,
                            inactiveTrackColor: AppTheme.border,
                            thumbColor: AppTheme.accent,
                            overlayColor: AppTheme.accent.withValues(alpha: 0.2),
                          ),
                          child: Slider(
                            value: _minRating,
                            min: 0.0,
                            max: 5.0,
                            divisions: 10,
                            onChanged: (v) => setState(() => _minRating = v),
                          ),
                        ),
                      ),
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: Text(
                          _minRating > 0 ? _minRating.toStringAsFixed(1) : 'Todos',
                          style: TextStyle(
                            color: AppTheme.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  // Idioma nativo
                  _SectionTitle(title: 'Idioma nativo'),
                  _FilterDropdown(
                    label: 'Seleccionar idioma nativo',
                    value: _nativeLanguage,
                    items: _availableLanguages,
                    onChanged: (v) => setState(() => _nativeLanguage = v),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  // Idioma aprendiendo
                  _SectionTitle(title: 'Idioma aprendiendo'),
                  _FilterDropdown(
                    label: 'Seleccionar idioma aprendiendo',
                    value: _targetLanguage,
                    items: _availableLanguages,
                    onChanged: (v) => setState(() => _targetLanguage = v),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  // País
                  _SectionTitle(title: 'País'),
                  _FilterDropdown(
                    label: 'Seleccionar país',
                    value: _country,
                    items: _availableCountries,
                    onChanged: (v) => setState(() => _country = v),
                  ),
                  const SizedBox(height: AppDimensions.spacingXXXL),
                ],
              ),
            ),
          ),
          // Botón aplicar
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.spacingL,
              AppDimensions.spacingMD,
              AppDimensions.spacingL,
              AppDimensions.spacingL + MediaQuery.of(context).padding.bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingL),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                ),
                child: const Text(
                  'Aplicar filtros',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSM),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.subtle,
          fontSize: AppDimensions.fontSizeS,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FilterSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FilterSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppTheme.border),
      ),
      child: SwitchListTile(
        title: Text(
          label,
          style: TextStyle(color: AppTheme.text),
        ),
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppTheme.accent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingL,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingL,
        vertical: AppDimensions.spacingXS,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            label,
            style: TextStyle(color: AppTheme.subtle),
          ),
          isExpanded: true,
          dropdownColor: AppTheme.card,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.subtle),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                'Todos',
                style: TextStyle(color: AppTheme.subtle),
              ),
            ),
            ...items.map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(color: AppTheme.text),
                  ),
                )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Función helper para mostrar el bottom sheet de filtros
Future<FindFilters?> showFindFiltersBottomSheet(
  BuildContext context,
  FindFilters currentFilters,
) {
  return showModalBottomSheet<FindFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => FindFiltersBottomSheet(
        initialFilters: currentFilters,
      ),
    ),
  );
}

