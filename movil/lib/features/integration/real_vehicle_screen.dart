import 'package:flutter/material.dart';
import '../../app/app_controller.dart';
import '../../data/models/models.dart';
import '../../data/repositories/real_api_repository.dart';
import '../../shared/formatters.dart';
import '../../shared/widgets.dart';
import '../../core/theme/app_theme.dart';

class RealVehicleScreen extends StatefulWidget {
  const RealVehicleScreen({
    super.key,
    required this.repository,
    required this.id,
  });
  final RealApiRepository repository;
  final String id;
  @override
  State<RealVehicleScreen> createState() => _RealVehicleScreenState();
}

class _RealVehicleScreenState extends State<RealVehicleScreen> {
  late Future<Vehicle> _vehicle;
  @override
  void initState() {
    super.initState();
    _vehicle = widget.repository.vehicle(widget.id);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Vehicle>(
    future: _vehicle,
    builder: (context, snapshot) => AppPage(
      title: snapshot.data?.title ?? 'Detalle de vehículo',
      subtitle: 'Consulta real · Registro #${widget.id}',
      showNavigation: false,
      children: [
        if (snapshot.connectionState != ConnectionState.done)
          const Center(child: CircularProgressIndicator())
        else if (snapshot.hasError) ...[
          Notice(AppController.message(snapshot.error!), error: true),
          OutlinedButton(
            onPressed: () =>
                setState(() => _vehicle = widget.repository.vehicle(widget.id)),
            child: const Text('Reintentar consulta'),
          ),
        ] else if (snapshot.data case final v?) ...[
          const Notice(
            'Información obtenida de la API y almacenada en PostgreSQL.',
          ),
          InfoCard(
            title: v.plate,
            subtitle: 'ID ${v.id} · ${v.isActive ? 'Activo' : 'Inactivo'}',
            accent: AppColors.blue,
          ),
          InfoCard(
            title: '${kilometers(v.odometerKm)} km',
            subtitle: 'Kilometraje registrado',
            accent: AppColors.navy,
          ),
          InfoCard(
            title: 'Marca y modelo',
            subtitle: '${v.brand} · ${v.model}',
          ),
          InfoCard(
            title: 'Categoría y año',
            subtitle: '${v.category} · ${v.year}',
          ),
          InfoCard(
            title: 'Combustible y color',
            subtitle: '${v.fuel} · ${v.color ?? 'Sin especificar'}',
          ),
          if (v.vin != null) InfoCard(title: 'VIN', subtitle: v.vin!),
        ],
      ],
    ),
  );
}
