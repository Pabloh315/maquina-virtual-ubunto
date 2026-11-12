<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreMaintenanceHistoryRequest;
use App\Http\Requests\Api\V1\StoreMaintenancePlanRequest;
use App\Models\ServiceCatalog;
use App\Models\Vehicle;
use App\Services\MaintenanceDueCalculator;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;

class VehicleMaintenanceController extends Controller
{
    public function show(Vehicle $vehicle, MaintenanceDueCalculator $calculator): View
    {
        $vehicle->load(['model.make', 'maintenanceHistories' => fn ($query) => $query->latest('performed_on'), 'maintenancePlans.services.serviceCatalog']);
        return view('vehicles.maintenance', compact('vehicle', 'calculator') + ['services' => ServiceCatalog::orderBy('name')->get()]);
    }

    public function storeHistory(StoreMaintenanceHistoryRequest $request, Vehicle $vehicle): RedirectResponse
    {
        $vehicle->maintenanceHistories()->create($request->safe()->only(['service_catalog_id', 'service_type', 'description', 'performed_on', 'mileage', 'notes', 'provider', 'cost']));
        return to_route('vehicles.maintenance.show', $vehicle)->with('status', 'Antecedente registrado.');
    }

    public function storePlan(StoreMaintenancePlanRequest $request, Vehicle $vehicle): RedirectResponse
    {
        $plan = $vehicle->maintenancePlans()->create($request->safe()->only(['name', 'recommendation_source', 'source_reference', 'is_active']));
        $plan->services()->createMany($request->validated('services'));
        return to_route('vehicles.maintenance.show', $vehicle)->with('status', 'Plan registrado.');
    }
}