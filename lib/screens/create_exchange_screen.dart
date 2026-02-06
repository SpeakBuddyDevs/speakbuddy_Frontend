import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../constants/dimensions.dart';
import '../constants/languages.dart';
import '../repositories/api_public_exchanges_repository.dart';

/// Pantalla para crear un nuevo intercambio (público o privado).
///
/// ESTRATEGIA (Plan 5.1): Se amplía esta pantalla en lugar de crear
/// CreatePublicExchangeScreen. El formulario ya tiene todos los campos
/// necesarios (descripción, idiomas, nivel, maxParticipants, topics, isPublic).
/// Ver create_exchange_strategy.md para detalles.
class CreateExchangeScreen extends StatefulWidget {
  const CreateExchangeScreen({super.key});

  @override
  State<CreateExchangeScreen> createState() => _CreateExchangeScreenState();
}

class _CreateExchangeScreenState extends State<CreateExchangeScreen> {
  final _repository = ApiPublicExchangesRepository();
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _topicsController = TextEditingController();

  // Estado del formulario
  String? _nativeLanguageCode; // Código del idioma (ej: 'ES')
  String? _targetLanguageCode; // Código del idioma (ej: 'EN')
  String? _requiredLevel;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isPublic = true; // Por defecto público
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    // Pre-seleccionar idiomas del usuario (mock)
    // BACKEND: Obtener desde perfil del usuario
    // Nota: availableCodes usa minúsculas (es, en, fr...), el value del Dropdown debe coincidir
    _nativeLanguageCode = 'es'; // Mock: idioma nativo del usuario
    _targetLanguageCode = 'en'; // Mock: primer idioma de aprendizaje activo
    _requiredLevel = 'Principiante';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _maxParticipantsController.dispose();
    _topicsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
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
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
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
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _onCreate() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar fecha y hora
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona fecha y hora')),
      );
      return;
    }

    // Combinar fecha y hora
    final dateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Validar que la fecha sea futura
    if (dateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha y hora deben ser futuras')),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final duration = int.parse(_durationController.text);
      final maxParticipants = int.parse(_maxParticipantsController.text);

      final topicsText = _topicsController.text.trim();
      final topics = topicsText.isEmpty
          ? null
          : topicsText
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();

      final nativeLanguage = _nativeLanguageCode != null
          ? AppLanguages.getName(_nativeLanguageCode!)
          : 'Español';
      final targetLanguage = _targetLanguageCode != null
          ? AppLanguages.getName(_targetLanguageCode!)
          : 'Inglés';

      await _repository.createExchange(
        title: _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : 'Intercambio',
        description: _descriptionController.text.trim(),
        nativeLanguage: nativeLanguage,
        targetLanguage: targetLanguage,
        requiredLevel: _requiredLevel ?? 'Principiante',
        date: dateTime,
        durationMinutes: duration,
        maxParticipants: maxParticipants,
        topics: topics?.isNotEmpty == true ? topics : null,
        isPublic: _isPublic,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Intercambio creado correctamente')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.isNotEmpty ? message : 'Error al crear intercambio'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
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
        title: const Text('Crear intercambio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppTheme.text,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppDimensions.paddingScreen,
        child: Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppTheme.card,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingInput.horizontal,
                vertical: AppDimensions.paddingInputVertical.vertical,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelStyle: TextStyle(color: AppTheme.text),
              floatingLabelStyle: TextStyle(color: AppTheme.text),
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título del intercambio',
                    hintText: 'Ej: Intercambio casual de idiomas',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El título es requerido';
                    }
                    if (value.trim().length < 3) {
                      return 'El título debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // Descripción
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Describe el intercambio...',
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La descripción es requerida';
                    }
                    if (value.trim().length < 10) {
                      return 'La descripción debe tener al menos 10 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // Idiomas (Row con dos dropdowns)
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _nativeLanguageCode,
                        decoration: const InputDecoration(
                          labelText: 'Idioma ofrecido',
                        ),
                        items: AppLanguages.availableCodes
                            .where((code) => code != _targetLanguageCode || _targetLanguageCode == null)
                            .map((code) {
                          final name = AppLanguages.getName(code);
                          return DropdownMenuItem<String>(
                            value: code,
                            child: Text(name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _nativeLanguageCode = value);
                        },
                        validator: (value) =>
                            value == null ? 'Selecciona un idioma' : null,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMD),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _targetLanguageCode,
                        decoration: const InputDecoration(
                          labelText: 'Idioma buscado',
                        ),
                        items: AppLanguages.availableCodes
                            .where((code) => code != _nativeLanguageCode || _nativeLanguageCode == null)
                            .map((code) {
                          final name = AppLanguages.getName(code);
                          return DropdownMenuItem<String>(
                            value: code,
                            child: Text(name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _targetLanguageCode = value);
                        },
                        validator: (value) =>
                            value == null ? 'Selecciona un idioma' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // Validación: idiomas diferentes
                if (_nativeLanguageCode != null &&
                    _targetLanguageCode != null &&
                    _nativeLanguageCode == _targetLanguageCode)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
                    child: Text(
                      'Los idiomas deben ser diferentes',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: AppDimensions.fontSizeS,
                      ),
                    ),
                  ),

                // Nivel requerido
                DropdownButtonFormField<String>(
                  value: _requiredLevel,
                  decoration: const InputDecoration(
                    labelText: 'Nivel requerido',
                  ),
                  items: const ['Principiante', 'Intermedio', 'Avanzado']
                      .map((level) => DropdownMenuItem<String>(
                            value: level,
                            child: Text(level),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _requiredLevel = value);
                  },
                  validator: (value) =>
                      value == null ? 'Selecciona un nivel' : null,
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // Fecha y hora
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                        child: Container(
                          padding: AppDimensions.paddingInput,
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  color: AppTheme.subtle),
                              const SizedBox(width: AppDimensions.spacingMD),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fecha',
                                      style: TextStyle(
                                        color: AppTheme.subtle,
                                        fontSize: AppDimensions.fontSizeXS,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _selectedDate != null
                                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                          : 'Seleccionar fecha',
                                      style: TextStyle(
                                        color: _selectedDate != null
                                            ? AppTheme.text
                                            : AppTheme.subtle,
                                        fontSize: AppDimensions.fontSizeS,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMD),
                    Expanded(
                      child: InkWell(
                        onTap: _selectTime,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                        child: Container(
                          padding: AppDimensions.paddingInput,
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time_rounded,
                                  color: AppTheme.subtle),
                              const SizedBox(width: AppDimensions.spacingMD),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hora',
                                      style: TextStyle(
                                        color: AppTheme.subtle,
                                        fontSize: AppDimensions.fontSizeXS,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _selectedTime != null
                                          ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                          : 'Seleccionar hora',
                                      style: TextStyle(
                                        color: _selectedTime != null
                                            ? AppTheme.text
                                            : AppTheme.subtle,
                                        fontSize: AppDimensions.fontSizeS,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // Duración y participantes
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _durationController,
                        decoration: InputDecoration(
                          labelText: 'Duración (min)',
                          hintText: 'Ej: 45',
                          hintStyle: TextStyle(
                            color: AppTheme.subtle.withOpacity(0.5),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requerido';
                          }
                          final duration = int.tryParse(value);
                          if (duration == null || duration < 15 || duration > 180) {
                            return 'Entre 15 y 180 min';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMD),
                    Expanded(
                      child: TextFormField(
                        controller: _maxParticipantsController,
                        decoration: InputDecoration(
                          labelText: 'Máx. participantes',
                          hintText: 'Ej: 10',
                          hintStyle: TextStyle(
                            color: AppTheme.subtle.withOpacity(0.5),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requerido';
                          }
                          final max = int.tryParse(value);
                          if (max == null || max < 2 || max > 50) {
                            return 'Entre 2 y 50';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // Temas (opcional)
                TextFormField(
                  controller: _topicsController,
                  decoration: const InputDecoration(
                    labelText: 'Temas (opcional)',
                    hintText: 'Viajes, turismo, cultura',
                    helperText: 'Separa los temas con comas',
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // Switch público/privado
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: SwitchListTile(
                    title: const Text('Intercambio público'),
                    subtitle: const Text(
                      'Si está desactivado, solo será accesible mediante enlace',
                      style: TextStyle(fontSize: AppDimensions.fontSizeXS),
                    ),
                    value: _isPublic,
                    onChanged: (value) {
                      setState(() => _isPublic = value);
                    },
                    activeTrackColor: AppTheme.accent,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXXXL),

                // Botones: Cancelar y Crear
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isCreating
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.text,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.spacingL,
                          ),
                          side: BorderSide(color: AppTheme.border),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusMD),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMD),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isCreating ? null : _onCreate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.spacingL,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusMD),
                          ),
                        ),
                        child: _isCreating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Crear intercambio'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
