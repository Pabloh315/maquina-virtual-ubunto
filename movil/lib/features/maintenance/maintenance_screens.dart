import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../app/app_routes.dart';
import '../../app/app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/formatters.dart';
import '../../shared/widgets.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return AppPage(
      title: 'Mantenimiento',
      subtitle: 'Seguimiento preventivo y correctivo',
      tab: 1,
      children: [
        const VehicleSelector(),
        VehicleContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Notice(
                '${state.plans.length} planes de mantenimiento · Vence primero por fecha o kilómetros.',
              ),
              if (state.plans.isEmpty)
                const Notice('Este vehículo no tiene planes registrados.'),
              ...state.plans.map((p) {
                final due = p.isDue(
                  state.selectedVehicle?.odometerKm ?? 0,
                  DateTime.now(),
                );
                return InfoCard(
                  title: serviceName(p.service),
                  subtitle:
                      '${due ? 'Requiere atención' : 'Próximo'}\n'
                      '${p.nextDueKm == null ? '' : 'Límite: ${kilometers(p.nextDueKm!)} km'}'
                      '${p.nextDueDate == null ? '' : ' · ${shortDate(p.nextDueDate!)}'}\nOrigen: ${p.source.replaceAll('_', ' ')}',
                  accent: due ? Colors.red : AppColors.orange,
                );
              }),
              if (state.history.isNotEmpty) ...[
                const SectionTitle('Último servicio confirmado'),
                InfoCard(
                  title: serviceName(state.history.first.service),
                  subtitle:
                      'Realizado · ${shortDate(state.history.first.date)}',
                  accent: AppColors.green,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.history),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.register),
                child: const Text('+ Registrar mantenimiento'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RegisterServiceScreen extends StatefulWidget {
  const RegisterServiceScreen({super.key});
  @override
  State<RegisterServiceScreen> createState() => _RegisterServiceScreenState();
}

class _RegisterServiceScreenState extends State<RegisterServiceScreen> {
  final _form = GlobalKey<FormState>();
  final _notes = TextEditingController();
  String _service = 'oil_change';
  bool _known = true, _saving = false;
  DateTime? _date;
  String? _error;
  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_known && _date == null) {
      setState(() => _error = 'Selecciona la fecha del antecedente.');
      return;
    }
    final state = AppScope.of(context);
    final id = state.selectedVehicle?.id;
    if (id == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await state.repository.saveBackground(
        id,
        service: _service,
        known: _known,
        date: _date == null ? null : isoDate(_date!),
        notes: _notes.text.trim(),
      );
      if (!mounted) return;
      showMessage(
        context,
        'Antecedente guardado. El historial confirmado no cambia.',
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _error = AppController.message(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Nuevo mantenimiento',
    subtitle: 'Registra un antecedente de tu vehículo',
    tab: 1,
    children: [
      const Notice(
        'Este registro es un antecedente. Los servicios confirmados y sus intervalos se actualizan al cerrar una orden en el taller.',
      ),
      VehicleContent(
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const VehicleSelector(),
              const FieldLabel('Tipo de servicio'),
              DropdownButtonFormField<String>(
                initialValue: _service,
                isExpanded: true,
                items: serviceNames.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: _saving
                    ? null
                    : (v) => setState(() => _service = v!),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Conozco el antecedente'),
                subtitle: const Text(
                  'Desactiva si no sabes cuándo se realizó.',
                ),
                value: _known,
                onChanged: _saving ? null : (v) => setState(() => _known = v),
              ),
              if (_known) ...[
                const FieldLabel('Fecha de realización'),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(
                    _date == null ? 'Seleccionar fecha' : shortDate(_date!),
                  ),
                  onPressed: _saving
                      ? null
                      : () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _date ?? DateTime.now(),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                          );
                          if (date != null && mounted) {
                            setState(() => _date = date);
                          }
                        },
                ),
              ],
              const FieldLabel('Observaciones (opcional)'),
              TextFormField(
                controller: _notes,
                enabled: !_saving,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Información del antecedente',
                ),
              ),
              const SizedBox(height: 20),
              if (_error != null) Notice(_error!, error: true),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Guardando…' : 'Guardar antecedente'),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
