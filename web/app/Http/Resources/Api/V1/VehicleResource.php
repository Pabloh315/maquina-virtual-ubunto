<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class VehicleResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'owner_id' => $this->owner_id,
            'license_plate' => $this->license_plate,
            'vin' => $this->vin,
            'year' => $this->year,
            'color' => $this->color,
            'fuel_type' => $this->fuel_type,
            'current_mileage' => $this->current_mileage,
            'is_active' => $this->is_active,
            'category' => $this->whenLoaded('category', fn (): array => [
                'id' => $this->category->id,
                'name' => $this->category->name,
            ]),
            'model' => $this->whenLoaded('model', fn (): array => [
                'id' => $this->model->id,
                'name' => $this->model->name,
                'make' => [
                    'id' => $this->model->make->id,
                    'name' => $this->model->make->name,
                ],
            ]),
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}
