import 'package:flutter/material.dart';
import '../../app/app_controller.dart';
import '../../app/app_routes.dart';
import '../../app/app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../shared/formatters.dart';
import '../../shared/widgets.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, this.workshopId});
  final String? workshopId;
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? _workshopId, _vehicleId, _service;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  String _time = '09:00';
  final String _key = 'movil-${DateTime.now().microsecondsSinceEpoch}';
  bool _initialized = false, _saving = false;
  String? _error;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final state = AppScope.of(context);
      _workshopId = widget.workshopId ?? state.workshops.firstOrNull?.id;
      _vehicleId = state.selectedVehicle?.id;
      _service = state.workshops
          .where((w) => w.id == _workshopId)
          .firstOrNull
          ?.specialties
          .firstOrNull;
      _initialized = true;
    }
  }

  Future<void> _save() async {
    if (_workshopId == null || _vehicleId == null || _service == null) {
      setState(() => _error = 'Selecciona taller, vehículo y servicio.');
      return;
    }
    final startsAt = '${isoDate(_date)}T$_time:00-04:00';
    if (!DateTime.parse(startsAt).isAfter(DateTime.now())) {
      setState(() => _error = 'Selecciona una fecha y hora futuras.');
      return;
    }
    final state = AppScope.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await state.repository.book(
        vehicleId: _vehicleId!,
        workshopId: _workshopId!,
        service: _service!,
        startsAt: startsAt,
        key: _key,
      );
      await state.refreshAppointments();
      if (!mounted) return;
      showMessage(context, 'Cita confirmada en la demostración.');
      Navigator.of(context).pushReplacementNamed(AppRoutes.appointments);
    } catch (e) {
      if (mounted) setState(() => _error = AppController.message(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final workshop = state.workshops
        .where((w) => w.id == _workshopId)
        .firstOrNull;
    return AppPage(
      title: 'Agendar cita',
      subtitle: 'Selecciona servicio, día y horario',
      tab: 2,
      children: [
        const FieldLabel('Taller'),
        DropdownButtonFormField<String>(
          initialValue: _workshopId,
          isExpanded: true,
          items: state.workshops
              .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
              .toList(),
          onChanged: _saving
              ? null
              : (v) => setState(() {
                  _workshopId = v;
                  _service = state.workshops
                      .firstWhere((w) => w.id == v)
                      .specialties
                      .firstOrNull;
                }),
        ),
        const FieldLabel('Vehículo'),
        DropdownButtonFormField<String>(
          initialValue: _vehicleId,
          isExpanded: true,
          items: state.vehicles
              .map((v) => DropdownMenuItem(value: v.id, child: Text(v.title)))
              .toList(),
          onChanged: _saving ? null : (v) => setState(() => _vehicleId = v),
        ),
        const FieldLabel('Servicio'),
        DropdownButtonFormField<String>(
          key: ValueKey(_workshopId),
          initialValue: _service,
          isExpanded: true,
          items: workshop?.specialties
              .map(
                (s) => DropdownMenuItem(value: s, child: Text(serviceName(s))),
              )
              .toList(),
          onChanged: _saving ? null : (v) => setState(() => _service = v),
        ),
        const FieldLabel('Fecha'),
        OutlinedButton.icon(
          icon: const Icon(Icons.calendar_today_outlined),
          label: Text(shortDate(_date)),
          onPressed: _saving
              ? null
              : () async {
                  final now = DateTime.now();
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _date.isBefore(now) ? now : _date,
                    firstDate: DateTime(now.year, now.month, now.day),
                    lastDate: DateTime(now.year + 1, now.month, now.day),
                  );
                  if (date != null && mounted) setState(() => _date = date);
                },
        ),
        const FieldLabel('Hora de la cita'),
        DropdownButtonFormField<String>(
          initialValue: _time,
          items: [
            '09:00',
            '10:00',
            '11:00',
            '14:00',
            '15:00',
            '16:00',
          ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: _saving ? null : (v) => setState(() => _time = v!),
        ),
        const SizedBox(height: 16),
        const Text(
          'Horario de Bolivia (America/La_Paz). El cupo se comprueba al confirmar.',
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 24),
        if (_error != null) Notice(_error!, error: true),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Confirmando…' : 'Confirmar cita'),
        ),
      ],
    );
  }
}

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});
  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  bool _busy = false;
  String? _error;
  Future<void> _cancel(Appointment appointment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Cancelar cita'),
        content: const Text('¿Deseas liberar este horario y cancelar la cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Conservar cita'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Cancelar cita'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final state = AppScope.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await state.repository.cancel(appointment.id);
      await state.refreshAppointments();
      if (mounted) showMessage(context, 'Cita cancelada.');
    } catch (e) {
      if (mounted) setState(() => _error = AppController.message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final appointments = state.appointments
        .where((a) => a.vehicleId == state.selectedVehicle?.id)
        .toList();
    return AppPage(
      title: 'Mis citas',
      subtitle: 'Próximas y anteriores',
      tab: 2,
      children: [
        const VehicleSelector(),
        if (_error != null) Notice(_error!, error: true),
        if (appointments.isEmpty)
          const Notice('Este vehículo no tiene citas registradas.'),
        ...appointments.map(
          (a) => InfoCard(
            title: serviceName(a.service),
            subtitle:
                '${shortDate(a.localDate)} · ${clockTime(a.localDate)}\n${state.workshopName(a.workshopId)}\nEstado: ${appointmentStatus(a.status)}',
            accent: a.status == 'confirmed' ? AppColors.blue : AppColors.muted,
            trailing: a.status != 'confirmed'
                ? null
                : IconButton(
                    tooltip: 'Cancelar cita',
                    onPressed: _busy ? null : () => _cancel(a),
                    icon: const Icon(
                      Icons.event_busy_outlined,
                      color: AppColors.muted,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.booking),
          child: const Text('+ Agendar otra cita'),
        ),
      ],
    );
  }
}
