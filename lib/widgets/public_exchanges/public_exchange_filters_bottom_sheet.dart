import 'package:flutter/material.dart';
import '../../models/public_exchange_filters.dart';
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

/// Lista de niveles disponibles
const List<String> _availableLevels = [
  'Principiante',
  'Intermedio',
  'Avanzado',
];

/// Bottom sheet para filtros de búsqueda de intercambios públicos
class PublicExchangeFiltersBottomSheet extends StatefulWidget {
  final PublicExchangeFilters initialFilters;

  const PublicExchangeFiltersBottomSheet({
    super.key,
    required this.initialFilters,
  });

  @override
  State<PublicExchangeFiltersBottomSheet> createState() =>
      _PublicExchangeFiltersBottomSheetState();
}

class _PublicExchangeFiltersBottomSheetState
    extends State<PublicExchangeFiltersBottomSheet> {
  late String? _requiredLevel;
  late DateTime? _minDate;
  late double _maxDuration;
  late String? _nativeLanguage;
  late String? _targetLanguage;

  @override
  void initState() {
    super.initState();
    _requiredLevel = widget.initialFilters.requiredLevel;
    _minDate = widget.initialFilters.minDate;
    _maxDuration = widget.initialFilters.maxDuration?.toDouble() ?? 0.0;
    _nativeLanguage = widget.initialFilters.nativeLanguage;
    _targetLanguage = widget.initialFilters.targetLanguage;
  }

  void _resetFilters() {
    setState(() {
      _requiredLevel = null;
      _minDate = null;
      _maxDuration = 0.0;
      _nativeLanguage = null;
      _targetLanguage = null;
    });
  }

  void _applyFilters() {
    final filters = PublicExchangeFilters(
      requiredLevel: _requiredLevel,
      minDate: _minDate,
      maxDuration: _maxDuration > 0 ? _maxDuration.toInt() : null,
      nativeLanguage: _nativeLanguage,
      targetLanguage: _targetLanguage,
    );
    Navigator.pop(context, filters);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _minDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.accent,
              onPrimary: Colors.white,
              surface: AppTheme.card,
              onSurface: AppTheme.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _minDate = picked);
    }
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
                  // Nivel requerido
                  _SectionTitle(title: 'Nivel requerido'),
                  _FilterDropdown(
                    label: 'Seleccionar nivel',
                    value: _requiredLevel,
                    items: _availableLevels,
                    onChanged: (v) => setState(() => _requiredLevel = v),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  // Fecha mínima
                  _SectionTitle(title: 'Fecha mínima'),
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                        border: Border.all(color: AppTheme.border),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingL,
                        vertical: AppDimensions.spacingMD,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              color: AppTheme.subtle, size: 20),
                          const SizedBox(width: AppDimensions.spacingMD),
                          Expanded(
                            child: Text(
                              _minDate != null
                                  ? '${_minDate!.day}/${_minDate!.month}/${_minDate!.year}'
                                  : 'Seleccionar fecha',
                              style: TextStyle(
                                color: _minDate != null
                                    ? AppTheme.text
                                    : AppTheme.subtle,
                              ),
                            ),
                          ),
                          if (_minDate != null)
                            IconButton(
                              icon: Icon(Icons.close_rounded,
                                  color: AppTheme.subtle, size: 20),
                              onPressed: () => setState(() => _minDate = null),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  // Duración máxima
                  _SectionTitle(title: 'Duración máxima (minutos)'),
                  Row(
                    children: [
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppTheme.accent,
                            inactiveTrackColor: AppTheme.border,
                            thumbColor: AppTheme.accent,
                            overlayColor:
                                AppTheme.accent.withValues(alpha: 0.2),
                          ),
                          child: Slider(
                            value: _maxDuration,
                            min: 0.0,
                            max: 120.0,
                            divisions: 24,
                            onChanged: (v) => setState(() => _maxDuration = v),
                          ),
                        ),
                      ),
                      Container(
                        width: 60,
                        alignment: Alignment.center,
                        child: Text(
                          _maxDuration > 0
                              ? _maxDuration.toInt().toString()
                              : 'Sin límite',
                          style: TextStyle(
                            color: AppTheme.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  // Idioma ofrecido
                  _SectionTitle(title: 'Idioma ofrecido'),
                  _FilterDropdown(
                    label: 'Seleccionar idioma ofrecido',
                    value: _nativeLanguage,
                    items: _availableLanguages,
                    onChanged: (v) => setState(() => _nativeLanguage = v),
                  ),
                  const SizedBox(height: AppDimensions.spacingL),
                  // Idioma buscado
                  _SectionTitle(title: 'Idioma buscado'),
                  _FilterDropdown(
                    label: 'Seleccionar idioma buscado',
                    value: _targetLanguage,
                    items: _availableLanguages,
                    onChanged: (v) => setState(() => _targetLanguage = v),
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
              AppDimensions.spacingL +
                  MediaQuery.of(context).padding.bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.spacingL),
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
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: AppTheme.subtle),
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
Future<PublicExchangeFilters?> showPublicExchangeFiltersBottomSheet(
  BuildContext context,
  PublicExchangeFilters currentFilters,
) {
  return showModalBottomSheet<PublicExchangeFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) =>
          PublicExchangeFiltersBottomSheet(
        initialFilters: currentFilters,
      ),
    ),
  );
}
