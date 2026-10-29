import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/formatters.dart';
import '../../shared/widgets.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return AppPage(
      title: 'Historial',
      subtitle: 'Servicios registrados por vehículo',
      tab: 3,
      children: [
        const VehicleSelector(),
        VehicleContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.history.isEmpty)
                const Notice(
                  'Este vehículo aún no tiene servicios confirmados por un taller.',
                ),
              ...state.history.map(
                (h) => InfoCard(
                  title: '${shortDate(h.date)} · ${serviceName(h.service)}',
                  subtitle:
                      '${kilometers(h.odometerKm)} km · Bs ${h.cost.toStringAsFixed(2)}\nOrden: ${h.orderId} · Servicio confirmado',
                  accent: AppColors.green,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: state.history.isEmpty
                    ? null
                    : () async {
                        final text = [
                          state.selectedVehicle!.title,
                          ...state.history.map(
                            (h) =>
                                '${shortDate(h.date)} · ${serviceName(h.service)} · ${h.odometerKm} km · Bs ${h.cost.toStringAsFixed(2)}',
                          ),
                        ].join('\n');
                        await Clipboard.setData(ClipboardData(text: text));
                        if (context.mounted) {
                          showMessage(
                            context,
                            'Registro copiado al portapapeles.',
                          );
                        }
                      },
                icon: const Icon(Icons.copy),
                label: const Text('Copiar registro'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
