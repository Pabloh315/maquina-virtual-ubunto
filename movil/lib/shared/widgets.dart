import 'package:flutter/material.dart';

import '../app/app_routes.dart';
import '../app/app_scope.dart';
import '../core/theme/app_theme.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.tab = 0,
    this.actions = const [],
    this.showNavigation = true,
  });
  final String title, subtitle;
  final List<Widget> children, actions;
  final int tab;
  final bool showNavigation;

  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: showNavigation
        ? AppBottomNavigation(selected: tab)
        : null,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
            children: [
              if (Navigator.of(context).canPop())
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: 'Volver',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: AppColors.navy),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  ...actions,
                ],
              ),
              const SizedBox(height: 8),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 30),
              ...children,
            ],
          ),
        ),
      ),
    ),
  );
}

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({super.key, required this.selected});
  final int selected;
  @override
  Widget build(BuildContext context) {
    const routes = [
      AppRoutes.home,
      AppRoutes.vehicles,
      AppRoutes.workshops,
      AppRoutes.history,
    ];
    const labels = ['Inicio', 'Vehículos', 'Talleres', 'Historial'];
    const icons = [
      Icons.home_outlined,
      Icons.directions_car_outlined,
      Icons.search,
      Icons.history,
    ];
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(
            4,
            (index) => Expanded(
              child: Semantics(
                selected: selected == index,
                button: true,
                child: InkWell(
                  onTap: () {
                    if (ModalRoute.of(context)?.settings.name !=
                        routes[index]) {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil(routes[index], (_) => false);
                    }
                  },
                  child: SizedBox(
                    height: 76,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icons[index],
                          color: selected == index
                              ? AppColors.blue
                              : AppColors.muted,
                          size: 25,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          labels[index],
                          style: TextStyle(
                            fontSize: 11,
                            color: selected == index
                                ? AppColors.blue
                                : AppColors.muted,
                            fontWeight: selected == index
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.accent,
    this.trailing,
  });
  final String title, subtitle;
  final VoidCallback? onTap;
  final Color? accent;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 88),
          decoration: BoxDecoration(
            border: accent == null
                ? null
                : Border(left: BorderSide(color: accent!, width: 5)),
          ),
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              ?trailing,
              if (onTap != null && trailing == null)
                const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 18),
    child: Text(text, style: Theme.of(context).textTheme.titleLarge),
  );
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 10),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
  );
}

class Notice extends StatelessWidget {
  const Notice(this.text, {super.key, this.error = false});
  final String text;
  final bool error;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: error ? const Color(0xFFFFE9E9) : const Color(0xFFE7EEFC),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        height: 1.5,
        color: error ? const Color(0xFF9B1C1C) : AppColors.navy,
      ),
    ),
  );
}

class VehicleContent extends StatelessWidget {
  const VehicleContent({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    if (state.selectedVehicle == null) {
      return const Notice('Aún no tienes vehículos registrados.');
    }
    if (state.loadingVehicle) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (state.vehicleError != null) {
      return Column(
        children: [
          Notice(state.vehicleError!, error: true),
          OutlinedButton(
            onPressed: () => state.selectVehicle(state.selectedVehicle!.id),
            child: const Text('Reintentar'),
          ),
        ],
      );
    }
    return child;
  }
}

class VehicleSelector extends StatelessWidget {
  const VehicleSelector({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        key: ValueKey(state.selectedVehicle?.id),
        initialValue: state.selectedVehicle?.id,
        decoration: const InputDecoration(labelText: 'Vehículo'),
        isExpanded: true,
        items: state.vehicles
            .map((v) => DropdownMenuItem(value: v.id, child: Text(v.title)))
            .toList(),
        onChanged: state.loadingVehicle
            ? null
            : (id) {
                if (id != null) state.selectVehicle(id);
              },
      ),
    );
  }
}

void showMessage(BuildContext context, String message) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(content: Text(message)));
