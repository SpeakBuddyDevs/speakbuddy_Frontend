import 'package:flutter/material.dart';
import '../../models/find_filters.dart';
import '../../theme/app_theme.dart';
import '../../constants/dimensions.dart';
import '../../constants/languages.dart';
import '../../constants/countries.dart';
import '../common/app_bottom_sheet_scaffold.dart';
import '../common/filter_widgets.dart';

List<String> get _availableLanguages => AppLanguages.searchFilterLanguageNames;

List<String> get _availableCountries => AppCountries.available;

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
  late bool _proOnly;
  late double _minRating;
  late String? _nativeLanguage;
  late String? _targetLanguage;
  late String? _country;

  @override
  void initState() {
    super.initState();
    _proOnly = widget.initialFilters.proOnly;
    _minRating = widget.initialFilters.minRating ?? 0.0;
    _nativeLanguage = widget.initialFilters.nativeLanguage;
    _targetLanguage = widget.initialFilters.targetLanguage;
    _country = widget.initialFilters.country;
  }

  void _resetFilters() {
    setState(() {
      _proOnly = false;
      _minRating = 0.0;
      _nativeLanguage = null;
      _targetLanguage = null;
      _country = null;
    });
  }

  void _applyFilters() {
    final filters = FindFilters(
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
    return AppBottomSheetScaffold(
      title: 'Filters',
      onReset: _resetFilters,
      actionLabel: 'Apply filters',
      onAction: _applyFilters,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FilterSectionTitle(title: 'Account'),
          FilterSwitch(
            label: 'Only PRO',
            value: _proOnly,
            onChanged: (v) => setState(() => _proOnly = v),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          const FilterSectionTitle(title: 'Minimum rating'),
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
                    _minRating > 0
                        ? _minRating.toStringAsFixed(1)
                        : 'All',
                  style: TextStyle(
                    color: AppTheme.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          const FilterSectionTitle(title: 'Native language'),
          FilterDropdown(
            label: 'Select native language',
            value: _nativeLanguage,
            items: _availableLanguages,
            onChanged: (v) => setState(() => _nativeLanguage = v),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          const FilterSectionTitle(title: 'Learning language'),
          FilterDropdown(
            label: 'Select learning language',
            value: _targetLanguage,
            items: _availableLanguages,
            onChanged: (v) => setState(() => _targetLanguage = v),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          const FilterSectionTitle(title: 'Country'),
          FilterDropdown(
            label: 'Select country',
            value: _country,
            items: _availableCountries,
            onChanged: (v) => setState(() => _country = v),
          ),
          const SizedBox(height: AppDimensions.spacingXXXL),
        ],
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
