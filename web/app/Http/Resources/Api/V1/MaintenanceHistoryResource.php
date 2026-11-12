<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MaintenanceHistoryResource extends JsonResource
{
    /** @return array<string, mixed> */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'vehicle_id' => $this->vehicle_id,
            'service_catalog_id' => $this->service_catalog_id,
            'service_type' => $this->service_type,
            'description' => $this->description,
            'performed_on' => $this->performed_on?->toDateString(),
            'mileage' => $this->mileage,
            'notes' => $this->notes,
            'provider' => $this->provider,
            'cost' => $this->cost,
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}
