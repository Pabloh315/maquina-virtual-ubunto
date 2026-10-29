<?php

namespace Database\Factories;

use App\Models\User;
use App\Models\Vehicle;
use App\Models\VehicleCategory;
use App\Models\VehicleModel;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Vehicle>
 */
class VehicleFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'owner_id' => User::factory(),
            'vehicle_category_id' => VehicleCategory::factory(),
            'vehicle_model_id' => VehicleModel::factory(),
            'license_plate' => fake()->unique()->bothify('???-####'),
            'vin' => fake()->unique()->regexify('[A-HJ-NPR-Z0-9]{17}'),
            'year' => fake()->numberBetween(2000, (int) date('Y')),
            'color' => fake()->safeColorName(),
            'fuel_type' => fake()->randomElement(['gasolina', 'diésel', 'híbrido', 'eléctrico']),
            'current_mileage' => fake()->numberBetween(0, 250000),
            'is_active' => true,
        ];
    }
}
