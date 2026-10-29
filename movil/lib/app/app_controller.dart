import 'package:flutter/foundation.dart';

import '../core/api/api_exception.dart';
import '../data/models/models.dart';
import '../data/repositories/autocare_repository.dart';

class AppController extends ChangeNotifier {
  AppController(this.repository);
  final AutoCareRepository repository;
  bool signedIn = false, busy = false, loadingVehicle = false;
  String userName = 'Conductor';
  String? error, vehicleError;
  List<Vehicle> vehicles = [];
  List<Workshop> workshops = [];
  List<Appointment> appointments = [];
  List<MaintenancePlan> plans = [];
  List<HistoryEntry> history = [];
  List<VehicleAlert> alerts = [];
  Vehicle? selectedVehicle;
  int _selectionVersion = 0;

  static String message(Object e) => e is ApiException
      ? e.message
      : 'No se pudo completar la operación. Inténtalo de nuevo.';

  Future<bool> login(String email, String password) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      userName = await repository.login(email.trim(), password);
      final results = await Future.wait<Object>([
        repository.vehicles(),
        repository.workshops(),
        repository.appointments(),
      ]);
      vehicles = results[0] as List<Vehicle>;
      workshops = results[1] as List<Workshop>;
      appointments = results[2] as List<Appointment>;
      selectedVehicle = vehicles.firstOrNull;
      if (selectedVehicle != null) await _loadVehicle(selectedVehicle!.id);
      signedIn = true;
      return true;
    } catch (e) {
      repository.client.accessToken = null;
      signedIn = false;
      error = message(e);
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> _loadVehicle(String id) async {
    final version = ++_selectionVersion;
    final results = await Future.wait<Object>([
      repository.plans(id),
      repository.history(id),
      repository.alerts(id),
    ]);
    if (version != _selectionVersion) return;
    plans = results[0] as List<MaintenancePlan>;
    history = results[1] as List<HistoryEntry>;
    alerts = results[2] as List<VehicleAlert>;
  }

  Future<void> selectVehicle(String id) async {
    selectedVehicle = vehicles.firstWhere((v) => v.id == id);
    plans = [];
    history = [];
    alerts = [];
    loadingVehicle = true;
    vehicleError = null;
    notifyListeners();
    try {
      await _loadVehicle(id);
    } catch (e) {
      if (selectedVehicle?.id == id) vehicleError = message(e);
    } finally {
      if (selectedVehicle?.id == id) {
        loadingVehicle = false;
        notifyListeners();
      }
    }
  }

  Future<void> updateOdometer(int km) async {
    final id = selectedVehicle!.id;
    await repository.updateOdometer(id, km);
    vehicles = await repository.vehicles();
    await selectVehicle(id);
  }

  Future<void> refreshAppointments() async {
    appointments = await repository.appointments();
    notifyListeners();
  }

  String workshopName(String id) =>
      workshops.where((w) => w.id == id).firstOrNull?.name ?? 'Taller';

  Future<void> logout() async {
    try {
      await repository.logout();
    } catch (_) {
      /* La sesión local siempre se cierra. */
    }
    _selectionVersion++;
    signedIn = false;
    selectedVehicle = null;
    vehicles = [];
    workshops = [];
    appointments = [];
    plans = [];
    history = [];
    alerts = [];
    error = null;
    vehicleError = null;
    loadingVehicle = false;
    notifyListeners();
  }

  @override
  void dispose() {
    repository.close();
    super.dispose();
  }
}
