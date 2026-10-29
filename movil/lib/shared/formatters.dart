const serviceNames = {
  'oil_change': 'Cambio de aceite',
  'brakes': 'Revisión de frenos',
  'air_filter': 'Filtro de aire',
  'general': 'Mecánica general',
};
String serviceName(String code) => serviceNames[code] ?? code;
String kilometers(int km) => km.toString().replaceAllMapped(
  RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
  (m) => '${m[1]}.',
);
const _months = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];
String shortDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';
String isoDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
String clockTime(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
String appointmentStatus(String status) => switch (status) {
  'confirmed' => 'Confirmada',
  'finished' => 'Finalizada',
  'cancelled' => 'Cancelada',
  _ => status,
};
