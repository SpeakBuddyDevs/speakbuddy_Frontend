import 'package:flutter/material.dart';
import '../../models/public_exchange_filters.dart';
import '../../theme/app_theme.dart';
import '../../constants/dimensions.dart';
import '../common/app_bottom_sheet_scaffold.dart';
import '../common/filter_widgets.dart';

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
    return AppBottomSheetScaffold(
      title: 'Filtros',
      onReset: _resetFilters,
      actionLabel: 'Aplicar filtros',
      onAction: _applyFilters,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FilterSectionTitle(title: 'Nivel requerido'),
          FilterDropdown(
            label: 'Seleccionar nivel',
            value: _requiredLevel,
            items: _availableLevels,
            onChanged: (v) => setState(() => _requiredLevel = v),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          const FilterSectionTitle(title: 'Fecha mínima'),
          InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMD),
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
          const FilterSectionTitle(title: 'Duración máxima (minutos)'),
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
          const FilterSectionTitle(title: 'Idioma ofrecido'),
          FilterDropdown(
            label: 'Seleccionar idioma ofrecido',
            value: _nativeLanguage,
            items: _availableLanguages,
            onChanged: (v) => setState(() => _nativeLanguage = v),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          const FilterSectionTitle(title: 'Idioma buscado'),
          FilterDropdown(
            label: 'Seleccionar idioma buscado',
            value: _targetLanguage,
            items: _availableLanguages,
            onChanged: (v) => setState(() => _targetLanguage = v),
          ),
          const SizedBox(height: AppDimensions.spacingXXXL),
        ],
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
