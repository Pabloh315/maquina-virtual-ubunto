typedef Json = Map<String, dynamic>;

class Vehicle {
  const Vehicle({
    required this.id,
    required this.plate,
    required this.brand,
    required this.model,
    required this.category,
    required this.year,
    required this.odometerKm,
    required this.fuel,
  });
  factory Vehicle.fromJson(Json j) => Vehicle(
    id: j['id'] as String,
    plate: j['plate'] as String,
    brand: j['brand'] as String,
    model: j['model'] as String,
    category: j['category'] as String,
    year: j['year'] as int,
    odometerKm: j['odometer_km'] as int,
    fuel: j['fuel'] as String? ?? 'Sin especificar',
  );
  final String id, plate, brand, model, category, fuel;
  final int year, odometerKm;
  String get title => '$brand $model $year';
}

class MaintenancePlan {
  MaintenancePlan.fromJson(Json j)
    : id = j['id'] as String,
      vehicleId = j['vehicle_id'] as String,
      service = j['service'] as String,
      source = j['source'] as String,
      nextDueKm = j['next_due_km'] as int?,
      nextDueDate = DateTime.tryParse(j['next_due_date'] as String? ?? '');
  final String id, vehicleId, service, source;
  final int? nextDueKm;
  final DateTime? nextDueDate;
  bool isDue(int km, DateTime now) =>
      (nextDueKm != null && km >= nextDueKm!) ||
      (nextDueDate != null &&
          !DateTime(now.year, now.month, now.day).isBefore(nextDueDate!));
}

class VehicleAlert {
  VehicleAlert.fromJson(Json j)
    : id = j['id'] as String,
      vehicleId = j['vehicle_id'] as String,
      service = j['service'] as String,
      status = j['status'] as String,
      reason = j['reason'] as String;
  final String id, vehicleId, service, status, reason;
}

class Workshop {
  Workshop.fromJson(Json j)
    : id = j['id'] as String,
      name = j['name'] as String,
      specialties = List<String>.from(j['specialties'] as List),
      verifiedBrands = List<String>.from(j['verified_brands'] as List),
      address = j['address'] as String? ?? 'Dirección por confirmar',
      schedule = j['schedule'] as String? ?? 'Horario por confirmar';
  final String id, name, address, schedule;
  final List<String> specialties, verifiedBrands;
}

class Appointment {
  Appointment.fromJson(Json j)
    : id = j['id'] as String,
      vehicleId = j['vehicle_id'] as String,
      workshopId = j['workshop_id'] as String,
      service = j['service'] as String,
      startsAt = j['starts_at'] as String,
      status = j['status'] as String;
  final String id, vehicleId, workshopId, service, startsAt, status;
  // La fecha del contrato se muestra en America/La_Paz, sin depender del equipo.
  DateTime get localDate =>
      DateTime.parse(startsAt).toUtc().subtract(const Duration(hours: 4));
}

class HistoryEntry {
  HistoryEntry.fromJson(Json j)
    : id = j['id'] as String,
      vehicleId = j['vehicle_id'] as String,
      service = j['service'] as String,
      date = DateTime.parse(j['date'] as String),
      odometerKm = j['odometer_km'] as int,
      cost = (j['cost'] as num).toDouble(),
      orderId = j['order_id'] as String;
  final String id, vehicleId, service, orderId;
  final DateTime date;
  final int odometerKm;
  final double cost;
}
