<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreMaintenanceHistoryRequest;
use App\Http\Resources\Api\V1\MaintenanceHistoryResource;
use App\Models\MaintenanceHistory;
use App\Models\Vehicle;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class MaintenanceHistoryController extends Controller
{
    public function index(Vehicle $vehicle): AnonymousResourceCollection
    {
        $histories = $vehicle->maintenanceHistories()
            ->orderByRaw('performed_on is null')
            ->orderByDesc('performed_on')
            ->orderByDesc('id')
            ->paginate(15);

        return MaintenanceHistoryResource::collection($histories);
    }

    public function store(StoreMaintenanceHistoryRequest $request, Vehicle $vehicle): JsonResponse
    {
        $history = $vehicle->maintenanceHistories()->create($request->safe()->only([
            'service_catalog_id', 'service_type', 'description', 'performed_on', 'mileage', 'notes', 'provider', 'cost',
        ]));

        return (new MaintenanceHistoryResource($history))->response()->setStatusCode(201);
    }

    public function show(Vehicle $vehicle, MaintenanceHistory $maintenanceHistory): MaintenanceHistoryResource
    {
        abort_unless($maintenanceHistory->vehicle_id === $vehicle->id, 404);

        return new MaintenanceHistoryResource($maintenanceHistory);
    }
}
