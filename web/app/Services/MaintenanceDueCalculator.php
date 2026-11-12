<?php

namespace App\Services;

use App\Models\MaintenancePlanService;
use Carbon\CarbonImmutable;

class MaintenanceDueCalculator
{
    /** @return array<string, mixed> */
    public function calculate(MaintenancePlanService $service, ?int $currentMileage = null, ?CarbonImmutable $today = null): array
    {
        $today ??= CarbonImmutable::today();
        $nextMileage = $service->last_service_mileage !== null && $service->interval_km !== null
            ? $service->last_service_mileage + $service->interval_km : null;
        $nextDate = $service->last_service_date !== null && $service->interval_months !== null
            ? CarbonImmutable::instance($service->last_service_date)->addMonths($service->interval_months)->toDateString() : null;
        $overdueByMileage = $nextMileage !== null && $currentMileage !== null && $currentMileage >= $nextMileage;
        $overdueByTime = $nextDate !== null && $today->gte(CarbonImmutable::parse($nextDate));

        return [
            'next_service_mileage' => $nextMileage,
            'next_service_date' => $nextDate,
            'overdue_by_mileage' => $overdueByMileage,
            'overdue_by_time' => $overdueByTime,
            'is_overdue' => $overdueByMileage || $overdueByTime,
            'mileage_status' => $service->interval_km !== null && $nextMileage === null ? 'informacion_historica_insuficiente' : ($nextMileage === null ? 'no_aplica' : 'disponible'),
            'date_status' => $service->interval_months !== null && $nextDate === null ? 'informacion_historica_insuficiente' : ($nextDate === null ? 'no_aplica' : 'disponible'),
        ];
    }
}