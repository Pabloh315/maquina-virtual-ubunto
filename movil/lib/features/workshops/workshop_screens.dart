import 'package:flutter/material.dart';
import '../../app/app_routes.dart';
import '../../app/app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/formatters.dart';
import '../../shared/widgets.dart';

class WorkshopsScreen extends StatefulWidget {
  const WorkshopsScreen({super.key});
  @override
  State<WorkshopsScreen> createState() => _WorkshopsScreenState();
}

class _WorkshopsScreenState extends State<WorkshopsScreen> {
  String _search = '', _service = '';
  bool _verified = false;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final brand = state.selectedVehicle?.brand;
    final workshops = state.workshops
        .where(
          (w) =>
              '${w.name} ${w.address}'.toLowerCase().contains(
                _search.toLowerCase(),
              ) &&
              (_service.isEmpty || w.specialties.contains(_service)) &&
              (!_verified || w.verifiedBrands.contains(brand)),
        )
        .toList();
    return AppPage(
      title: 'Talleres',
      subtitle: 'Encuentra atención para tu vehículo',
      tab: 2,
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: 'Buscar taller',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (v) => setState(() => _search = v),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _service,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Servicio'),
          items: [
            const DropdownMenuItem(
              value: '',
              child: Text('Todos los servicios'),
            ),
            ...serviceNames.entries.map(
              (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
            ),
          ],
          onChanged: (v) => setState(() => _service = v!),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Marca verificada${brand == null ? '' : ': $brand'}',
            style: const TextStyle(fontSize: 14),
          ),
          value: _verified,
          onChanged: brand == null
              ? null
              : (v) => setState(() => _verified = v),
        ),
        const SizedBox(height: 14),
        if (workshops.isEmpty)
          const Notice(
            'No hay talleres con esos filtros. Prueba otro servicio o nombre.',
          ),
        ...workshops.map(
          (w) => InfoCard(
            title: w.name,
            subtitle:
                '${w.address}\n${w.specialties.map(serviceName).join(' · ')}',
            accent: AppColors.blue,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.workshop,
              arguments: w.id,
            ),
          ),
        ),
      ],
    );
  }
}

class WorkshopScreen extends StatelessWidget {
  const WorkshopScreen({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context) {
    final workshop = AppScope.of(
      context,
    ).workshops.where((w) => w.id == id).firstOrNull;
    if (workshop == null) {
      return const AppPage(
        title: 'Taller',
        subtitle: 'Consulta de taller',
        tab: 2,
        children: [Notice('El taller no está disponible.')],
      );
    }
    return AppPage(
      title: workshop.name,
      subtitle: 'Servicios y atención',
      tab: 2,
      children: [
        InfoCard(
          title: workshop.address,
          subtitle: workshop.schedule,
          accent: AppColors.navy,
        ),
        if (workshop.verifiedBrands.isEmpty)
          const Notice(
            'Este taller declara sus especialidades. No tiene marcas verificadas en esta demostración.',
          )
        else
          Notice(
            'Marcas verificadas: ${workshop.verifiedBrands.join(', ')}. La verificación es distinta de la especialidad del taller.',
          ),
        const SectionTitle('Servicios disponibles'),
        ...workshop.specialties.map(
          (s) => InfoCard(
            title: serviceName(s),
            subtitle: 'Atención con reserva',
            accent: AppColors.blue,
          ),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: () => Navigator.pushNamed(
            context,
            AppRoutes.booking,
            arguments: workshop.id,
          ),
          child: const Text('Agendar una cita'),
        ),
      ],
    );
  }
}
