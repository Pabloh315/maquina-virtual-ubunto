<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreMaintenancePlanRequest;
use App\Models\MaintenancePlan;
use App\Models\Vehicle;
use App\Services\MaintenanceDueCalculator;
use Illuminate\Http\JsonResponse;

class MaintenancePlanController extends Controller
{
    public function __construct(private MaintenanceDueCalculator $calculator) {}

    public function index(Vehicle $vehicle): JsonResponse
    {
        return response()->json(['data' => $vehicle->maintenancePlans()->with('services.serviceCatalog')->get()->map(fn (MaintenancePlan $plan) => $this->serialize($plan, $vehicle->current_mileage))]);
    }

    public function store(StoreMaintenancePlanRequest $request, Vehicle $vehicle): JsonResponse
    {
        $plan = $vehicle->maintenancePlans()->create($request->safe()->only(['name', 'recommendation_source', 'source_reference', 'is_active']));
        $plan->services()->createMany(collect($request->validated('services'))->map(fn (array $service) => [
            ...$service,
            'next_service_mileage' => null,
            'next_service_date' => null,
        ])->all());

        return response()->json(['data' => $this->serialize($plan->load('services.serviceCatalog'), $vehicle->current_mileage)], 201);
    }

    public function show(Vehicle $vehicle, MaintenancePlan $maintenancePlan): JsonResponse
    {
        abort_unless($maintenancePlan->vehicle_id === $vehicle->id, 404);

        return response()->json(['data' => $this->serialize($maintenancePlan->load('services.serviceCatalog'), $vehicle->current_mileage)]);
    }

    /** @return array<string, mixed> */
    private function serialize(MaintenancePlan $plan, int $currentMileage): array
    {
        return [
            'id' => $plan->id, 'vehicle_id' => $plan->vehicle_id, 'name' => $plan->name,
            'recommendation_source' => $plan->recommendation_source, 'source_reference' => $plan->source_reference,
            'is_active' => $plan->is_active,
            'services' => $plan->services->map(fn ($service) => [
                'id' => $service->id, 'service_catalog_id' => $service->service_catalog_id,
                'service_name' => $service->serviceCatalog?->name, 'interval_km' => $service->interval_km,
                'interval_months' => $service->interval_months, 'last_service_mileage' => $service->last_service_mileage,
                'last_service_date' => $service->last_service_date?->toDateString(),
                'calculation' => $this->calculator->calculate($service, $currentMileage),
            ]),
        ];
    }
}