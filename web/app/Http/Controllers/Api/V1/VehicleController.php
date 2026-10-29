<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreVehicleRequest;
use App\Http\Resources\Api\V1\VehicleResource;
use App\Models\Vehicle;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class VehicleController extends Controller
{
    public function index(): AnonymousResourceCollection
    {
        $vehicles = Vehicle::query()
            ->with(['category', 'model.make'])
            ->orderByDesc('created_at')
            ->orderByDesc('id')
            ->paginate(15);

        return VehicleResource::collection($vehicles);
    }

    public function store(StoreVehicleRequest $request): JsonResponse
    {
        $vehicle = Vehicle::create($request->safe()->only([
            'owner_id',
            'vehicle_category_id',
            'vehicle_model_id',
            'license_plate',
            'vin',
            'year',
            'color',
            'fuel_type',
            'current_mileage',
            'is_active',
        ]));

        $vehicle->load(['category', 'model.make']);

        return (new VehicleResource($vehicle))
            ->response()
            ->setStatusCode(201);
    }

    public function show(Vehicle $vehicle): VehicleResource
    {
        $vehicle->load(['category', 'model.make']);

        return new VehicleResource($vehicle);
    }
}
