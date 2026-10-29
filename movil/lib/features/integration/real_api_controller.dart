import 'package:flutter/foundation.dart';
import '../../app/app_controller.dart';
import '../../data/models/models.dart';
import '../../data/repositories/real_api_repository.dart';

class RealApiController extends ChangeNotifier {
  RealApiController(this.repository);
  final RealApiRepository repository;
  List<Vehicle> vehicles = [];
  bool busy = false;
  String? service, driver, apiError, databaseError, vehiclesError;
  DateTime? checkedAt;
  int? elapsedMs;

  Future<void> connect() async {
    if (busy) return;
    busy = true;
    service = null;
    driver = null;
    vehicles = [];
    apiError = null;
    databaseError = null;
    vehiclesError = null;
    checkedAt = null;
    elapsedMs = null;
    notifyListeners();
    final clock = Stopwatch()..start();
    try {
      service = await repository.health();
      try {
        driver = await repository.database();
      } catch (e) {
        databaseError = AppController.message(e);
      }
      try {
        vehicles = await repository.vehicles();
      } catch (e) {
        vehiclesError = AppController.message(e);
      }
    } catch (e) {
      apiError = AppController.message(e);
    } finally {
      clock.stop();
      elapsedMs = clock.elapsedMilliseconds;
      checkedAt = DateTime.now();
      busy = false;
      notifyListeners();
    }
  }
}
