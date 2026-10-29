<?php

namespace Database\Factories;

use App\Models\Make;
use App\Models\VehicleModel;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<VehicleModel>
 */
class VehicleModelFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'make_id' => Make::factory(),
            'name' => 'Modelo '.fake()->bothify('??-###'),
        ];
    }
}
