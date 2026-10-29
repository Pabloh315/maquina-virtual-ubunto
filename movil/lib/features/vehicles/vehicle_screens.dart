import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../app/app_routes.dart';
import '../../app/app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/formatters.dart';
import '../../shared/widgets.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return AppPage(
      title: 'Mis vehículos',
      subtitle: 'Administra tus unidades',
      tab: 1,
      children: [
        ...state.vehicles.map(
          (v) => InfoCard(
            title: v.title,
            subtitle: '${v.plate} · ${kilometers(v.odometerKm)} km',
            accent: v.id == state.selectedVehicle?.id
                ? AppColors.blue
                : AppColors.muted,
            onTap: () {
              state.selectVehicle(v.id);
              Navigator.pushNamed(context, AppRoutes.vehicle);
            },
          ),
        ),
        if (state.vehicles.isEmpty)
          const Notice('Aún no tienes vehículos registrados.'),
        FilledButton(
          onPressed: () => showMessage(
            context,
            'El registro completo de vehículos se incorporará en la siguiente entrega. Selecciona un vehículo de demostración.',
          ),
          child: const Text('+ Añadir vehículo'),
        ),
        const SizedBox(height: 28),
        const Text(
          'Selecciona un vehículo para ver su ficha, alertas e historial.',
          style: TextStyle(color: AppColors.muted, height: 1.6),
        ),
      ],
    );
  }
}

class VehicleScreen extends StatelessWidget {
  const VehicleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final vehicle = AppScope.of(context).selectedVehicle;
    return AppPage(
      title: vehicle?.title ?? 'Ficha de vehículo',
      subtitle: vehicle == null
          ? 'Selecciona un vehículo'
          : 'Placa ${vehicle.plate} · ${vehicle.fuel}',
      tab: 1,
      children: [
        VehicleContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${kilometers(vehicle?.odometerKm ?? 0)} km',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kilometraje registrado',
                      style: TextStyle(color: Colors.white70),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) =>
                            OdometerDialog(controller: AppScope.of(context)),
                      ),
                      child: const Text('Actualizar km →'),
                    ),
                  ],
                ),
              ),
              const SectionTitle('Información'),
              InfoCard(
                title: 'Marca / modelo',
                subtitle: '${vehicle?.brand} · ${vehicle?.model}',
                accent: AppColors.blue,
              ),
              InfoCard(
                title: 'Año / placa',
                subtitle: '${vehicle?.year} · ${vehicle?.plate}',
                accent: AppColors.blue,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.maintenance),
                child: const Text('Ver mantenimientos'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.history),
                child: const Text('Ver historial'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OdometerDialog extends StatefulWidget {
  const OdometerDialog({super.key, required this.controller});
  final AppController controller;
  @override
  State<OdometerDialog> createState() => _OdometerDialogState();
}

class _OdometerDialogState extends State<OdometerDialog> {
  final _form = GlobalKey<FormState>();
  final _km = TextEditingController();
  String? _error;
  bool _saving = false;
  @override
  void dispose() {
    _km.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.controller.updateOdometer(int.parse(_km.text.trim()));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _error = AppController.message(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Actualizar kilometraje'),
    content: SingleChildScrollView(
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lectura actual: ${kilometers(widget.controller.selectedVehicle!.odometerKm)} km',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _km,
              enabled: !_saving,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nueva lectura (km)',
              ),
              validator: (v) =>
                  int.tryParse(v?.trim() ?? '') == null ||
                      int.parse(v!.trim()) < 0
                  ? 'Introduce un número entero positivo.'
                  : null,
            ),
            const SizedBox(height: 12),
            if (_error != null) Notice(_error!, error: true),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      TextButton(
        onPressed: _saving ? null : _save,
        child: Text(_saving ? 'Guardando…' : 'Guardar'),
      ),
    ],
  );
}
