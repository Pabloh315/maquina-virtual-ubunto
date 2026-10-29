import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/app_controller.dart';
import '../../core/api/api_exception.dart';
import '../../data/models/models.dart';
import '../../data/repositories/real_api_repository.dart';
import '../../shared/widgets.dart';

class RealVehicleForm extends StatefulWidget {
  const RealVehicleForm({super.key, required this.repository, this.reference});
  final RealApiRepository repository;
  final Vehicle? reference;
  @override
  State<RealVehicleForm> createState() => _RealVehicleFormState();
}

class _RealVehicleFormState extends State<RealVehicleForm> {
  final _form = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _fields;
  bool _saving = false;
  String? _error;
  Map<String, dynamic> _errors = {};
  @override
  void initState() {
    super.initState();
    _fields = {
      'owner_id': TextEditingController(text: widget.reference?.ownerId ?? ''),
      'vehicle_category_id': TextEditingController(
        text: widget.reference?.categoryId ?? '',
      ),
      'vehicle_model_id': TextEditingController(
        text: widget.reference?.modelId ?? '',
      ),
      'license_plate': TextEditingController(),
      'vin': TextEditingController(),
      'year': TextEditingController(text: '${DateTime.now().year}'),
      'current_mileage': TextEditingController(text: '0'),
      'fuel_type': TextEditingController(),
      'color': TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _fieldError(String key) {
    final error = _errors[key];
    return error is List ? error.join('\n') : error?.toString();
  }

  Widget _field(
    String key,
    String label, {
    bool number = false,
    bool required = false,
    int? maxLength,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FieldLabel(label),
      TextFormField(
        key: ValueKey('field-$key'),
        controller: _fields[key],
        enabled: !_saving,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        inputFormatters: number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        maxLength: maxLength,
        decoration: InputDecoration(errorText: _fieldError(key)),
        onChanged: (_) {
          if (_errors.containsKey(key)) setState(() => _errors.remove(key));
        },
        validator: (value) {
          final text = value?.trim() ?? '';
          if (required && text.isEmpty) return 'Completa este campo.';
          if (number &&
              (int.tryParse(text) == null ||
                  int.parse(text) < (key == 'current_mileage' ? 0 : 1))) {
            return 'Introduce un número válido.';
          }
          if (key == 'year' &&
              (int.parse(text) < 1900 ||
                  int.parse(text) > DateTime.now().year + 1)) {
            return 'Revisa el año.';
          }
          if (key == 'vin' &&
              text.isNotEmpty &&
              !RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(text.toUpperCase())) {
            return 'El VIN debe tener 17 caracteres válidos.';
          }
          return null;
        },
      ),
    ],
  );
  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
      _errors = {};
    });
    final body = <String, dynamic>{
      for (final entry in _fields.entries) entry.key: entry.value.text.trim(),
    };
    for (final key in [
      'owner_id',
      'vehicle_category_id',
      'vehicle_model_id',
      'year',
      'current_mileage',
    ]) {
      body[key] = int.parse(body[key] as String);
    }
    body['license_plate'] = (body['license_plate'] as String).toUpperCase();
    body['vin'] = (body['vin'] as String).isEmpty
        ? null
        : (body['vin'] as String).toUpperCase();
    body['is_active'] = true;
    try {
      final vehicle = await widget.repository.createVehicle(body);
      if (mounted) Navigator.pop(context, vehicle);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = AppController.message(e);
          _errors = e is ApiException ? e.details : {};
        });
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: AppPage(
      title: 'Registrar vehículo',
      subtitle: 'Guardado real en la API de desarrollo',
      showNavigation: false,
      children: [
        const Notice(
          'Usa datos ficticios. Esta versión técnica necesita IDs existentes; el servidor aún no ofrece catálogos ni autenticación.',
        ),
        if (widget.reference != null)
          Notice(
            'Referencias iniciales tomadas de ${widget.reference!.plate}. Puedes ajustarlas a los catálogos del servidor.',
          ),
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field(
                'owner_id',
                'ID del propietario',
                number: true,
                required: true,
              ),
              _field(
                'vehicle_category_id',
                'ID de la categoría',
                number: true,
                required: true,
              ),
              _field(
                'vehicle_model_id',
                'ID del modelo',
                number: true,
                required: true,
              ),
              _field('license_plate', 'Placa', required: true, maxLength: 20),
              _field('year', 'Año', number: true, required: true),
              _field(
                'current_mileage',
                'Kilometraje',
                number: true,
                required: true,
              ),
              _field('vin', 'VIN (opcional)', maxLength: 17),
              _field('fuel_type', 'Combustible (opcional)', maxLength: 30),
              _field('color', 'Color (opcional)', maxLength: 50),
              if (_error != null) Notice(_error!, error: true),
              const SizedBox(height: 20),
              FilledButton(
                key: const Key('save-real-vehicle'),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text('Guardando en la API…'),
                        ],
                      )
                    : const Text('Guardar en la API'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
