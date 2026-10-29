import 'package:flutter/material.dart';
import '../../app/app_routes.dart';
import '../../app/app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/formatters.dart';
import '../../shared/widgets.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return AppPage(
      title: 'Alertas',
      subtitle: 'Mantén tu vehículo al día',
      children: [
        const VehicleSelector(),
        VehicleContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.alerts.isEmpty)
                const Notice('No hay alertas para este vehículo.'),
              ...state.alerts.map(
                (a) => InfoCard(
                  title: serviceName(a.service),
                  subtitle: a.reason,
                  accent: AppColors.orange,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.maintenance),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.maintenance),
                child: const Text('Ver mantenimientos'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
