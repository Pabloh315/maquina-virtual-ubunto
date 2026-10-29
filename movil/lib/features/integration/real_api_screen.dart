import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../../data/repositories/real_api_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart';
import '../../shared/formatters.dart';
import 'real_api_controller.dart';
import 'real_vehicle_screen.dart';
import 'real_vehicle_form.dart';

class RealApiScreen extends StatefulWidget {
  const RealApiScreen({
    super.key,
    required this.repository,
    required this.baseUrl,
  });
  final RealApiRepository repository;
  final String baseUrl;
  @override
  State<RealApiScreen> createState() => _RealApiScreenState();
}

class _RealApiScreenState extends State<RealApiScreen> {
  late final RealApiController _state;
  Vehicle? _created;
  @override
  void initState() {
    super.initState();
    _state = RealApiController(widget.repository);
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final created = await Navigator.push<Vehicle>(
      context,
      MaterialPageRoute(
        builder: (_) => RealVehicleForm(
          repository: widget.repository,
          reference: _state.vehicles.firstOrNull,
        ),
      ),
    );
    if (created == null || !mounted) return;
    setState(() => _created = created);
    await _state.connect();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _state,
    builder: (context, _) => AppPage(
      title: 'AutoCare',
      subtitle: 'Conexión y vehículos',
      showNavigation: false,
      children: [
        Text('Servidor', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SelectableText(
          widget.baseUrl,
          style: const TextStyle(fontSize: 13, color: AppColors.muted),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          key: const Key('connect-real-api'),
          onPressed: _state.busy ? null : _state.connect,
          icon: _state.busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.cloud_sync_outlined),
          label: Text(
            _state.busy
                ? 'Comprobando conexión…'
                : _state.checkedAt == null
                ? 'Conectar con API'
                : 'Volver a comprobar',
          ),
        ),
        const SectionTitle('Estado de conexión'),
        InfoCard(
          title: 'API',
          subtitle: _state.service == null
              ? (_state.apiError ?? 'Pendiente de comprobación')
              : 'Disponible · ${_state.service}',
          accent: _state.service != null
              ? AppColors.green
              : _state.apiError != null
              ? Colors.red
              : AppColors.muted,
        ),
        InfoCard(
          title: 'Base de datos',
          subtitle: _state.driver == null
              ? (_state.databaseError ?? 'Pendiente de comprobación')
              : 'Conectada · ${_state.driver}',
          accent: _state.driver != null
              ? AppColors.green
              : _state.databaseError != null
              ? Colors.red
              : AppColors.muted,
        ),
        if (_state.checkedAt != null)
          Text(
            'Última comprobación: ${clockTime(_state.checkedAt!)} · ${_state.elapsedMs} ms',
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        if (_state.apiError != null) Notice(_state.apiError!, error: true),
        if (_state.databaseError != null)
          const Notice(
            'La comprobación de base de datos puede estar deshabilitada fuera del entorno local. El listado se consulta de forma independiente.',
          ),
        const SectionTitle('Vehículos de la API'),
        if (_state.vehiclesError != null)
          Notice(_state.vehiclesError!, error: true),
        if (!_state.busy &&
            _state.service != null &&
            _state.vehiclesError == null) ...[
          Text(
            '${_state.vehicles.length} vehículos recibidos de la API real',
            key: const Key('real-vehicle-count'),
          ),
          const SizedBox(height: 16),
          if (_created != null)
            Notice(
              'Vehículo registrado: ${_created!.plate} · ID ${_created!.id}',
            ),
          if (_state.vehicles.isEmpty)
            const Notice(
              'La base no tiene vehículos. Puedes registrar uno con IDs de referencia válidos.',
            ),
          ..._state.vehicles.map(
            (v) => InfoCard(
              key: ValueKey('real-vehicle-${v.id}'),
              title: v.title,
              subtitle:
                  '${v.plate} · ${kilometers(v.odometerKm)} km\nRegistro real #${v.id}',
              accent: AppColors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RealVehicleScreen(
                    repository: widget.repository,
                    id: v.id,
                  ),
                ),
              ),
            ),
          ),
          FilledButton.icon(
            key: const Key('create-real-vehicle'),
            onPressed: _create,
            icon: const Icon(Icons.add),
            label: const Text('Registrar vehículo en la API'),
          ),
        ],
      ],
    ),
  );
}
