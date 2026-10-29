import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/formatters.dart';
import '../../shared/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final vehicle = state.selectedVehicle;
    return AppPage(
      title: 'Hola, ${state.userName.toLowerCase()} 👋',
      subtitle: 'Resumen de tu vehículo',
      actions: [
        IconButton(
          tooltip: 'Alertas',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.alerts),
          icon: const Icon(Icons.notifications_none, color: AppColors.navy),
        ),
        PopupMenuButton<String>(
          tooltip: 'Cuenta',
          onSelected: (_) async {
            await state.logout();
            if (context.mounted) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
          ],
        ),
      ],
      children: [
        VehicleContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.vehicle),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MI VEHÍCULO PRINCIPAL',
                          style: TextStyle(
                            color: Color(0xFFC9DDFC),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          vehicle?.title ?? '',
                          style: const TextStyle(
                            fontSize: 23,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Placa ${vehicle?.plate} · ${kilometers(vehicle?.odometerKm ?? 0)} km',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Ver detalle →',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SectionTitle('Próximos mantenimientos'),
              if (state.plans.isEmpty)
                const Notice(
                  'No hay mantenimientos programados para este vehículo.',
                ),
              ...state.plans
                  .take(2)
                  .map(
                    (p) => InfoCard(
                      title: serviceName(p.service),
                      subtitle: p.nextDueKm != null
                          ? 'Límite: ${kilometers(p.nextDueKm!)} km · ${p.nextDueDate == null ? '' : shortDate(p.nextDueDate!)}'
                          : 'Límite por fecha: ${p.nextDueDate == null ? 'Por confirmar' : shortDate(p.nextDueDate!)}',
                      accent: p.isDue(vehicle?.odometerKm ?? 0, DateTime.now())
                          ? Colors.red
                          : AppColors.orange,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.maintenance),
                    ),
                  ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.appointments),
          icon: const Icon(Icons.calendar_today_outlined, size: 18),
          label: const Text('Mis citas →'),
        ),
        const SectionTitle('Accesos rápidos'),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                label: 'Registrar servicio',
                icon: Icons.add,
                onTap: () => Navigator.pushNamed(context, AppRoutes.register),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _QuickAction(
                label: 'Buscar taller',
                icon: Icons.search,
                onTap: () => Navigator.pushNamed(context, AppRoutes.workshops),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
        child: Column(
          children: [
            Icon(icon, color: AppColors.blue),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.navy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
