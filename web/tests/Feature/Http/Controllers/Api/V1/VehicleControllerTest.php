<?php

namespace Tests\Feature\Http\Controllers\Api\V1;

use App\Models\User;
use App\Models\Permission;
use App\Models\Role;
use Laravel\Sanctum\Sanctum;
use App\Models\Vehicle;
use App\Models\VehicleCategory;
use App\Models\VehicleModel;
use Illuminate\Foundation\Testing\LazilyRefreshDatabase;
use Tests\TestCase;

class VehicleControllerTest extends TestCase
{
    use LazilyRefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $permissions = collect(['vehicles.view', 'vehicles.create'])->map(fn ($name) => Permission::create(['name' => $name]));
        $role = Role::create(['name' => 'vehicle-manager']);
        $role->permissions()->sync($permissions->pluck('id'));
        $user = User::factory()->create();
        $user->roles()->attach($role);
        Sanctum::actingAs($user);
    }

    public function test_returns_200_with_paginated_vehicles_and_reference_data(): void
    {
        Vehicle::factory()->create([
            'license_plate' => 'OLD-100',
            'created_at' => now()->subMinute(),
        ]);
        $latestVehicle = Vehicle::factory()->create([
            'license_plate' => 'NEW-200',
            'created_at' => now(),
        ]);

        $response = $this->getJson('/api/v1/vehicles');

        $response
            ->assertOk()
            ->assertJsonPath('data.0.id', $latestVehicle->id)
            ->assertJsonPath('data.0.license_plate', 'NEW-200')
            ->assertJsonPath('data.0.category.name', $latestVehicle->category->name)
            ->assertJsonPath('data.0.model.make.name', $latestVehicle->model->make->name)
            ->assertJsonCount(2, 'data')
            ->assertJsonStructure([
                'data',
                'links' => ['first', 'last', 'prev', 'next'],
                'meta' => ['current_page', 'last_page', 'per_page', 'total'],
            ])
            ->assertJsonMissingPath('data.0.owner.email');
    }

    public function test_returns_200_with_one_vehicle(): void
    {
        $vehicle = Vehicle::factory()->create(['license_plate' => 'ONE-001']);

        $response = $this->getJson("/api/v1/vehicles/{$vehicle->id}");

        $response
            ->assertOk()
            ->assertJsonPath('data.id', $vehicle->id)
            ->assertJsonPath('data.license_plate', 'ONE-001')
            ->assertJsonPath('data.model.id', $vehicle->vehicle_model_id);
    }

    public function test_returns_404_when_vehicle_does_not_exist(): void
    {
        $response = $this->getJson('/api/v1/vehicles/999999');

        $response->assertNotFound();
    }

    public function test_valid_payload_creates_vehicle_and_returns_201(): void
    {
        $owner = User::factory()->create();
        $category = VehicleCategory::factory()->create();
        $vehicleModel = VehicleModel::factory()->create();
        $payload = [
            'owner_id' => $owner->id,
            'vehicle_category_id' => $category->id,
            'vehicle_model_id' => $vehicleModel->id,
            'license_plate' => 'abc-1234',
            'vin' => '1hgcm82633a004352',
            'year' => 2024,
            'color' => 'Azul',
            'fuel_type' => 'gasolina',
            'current_mileage' => 12000,
        ];

        $response = $this->postJson('/api/v1/vehicles', $payload);

        $response
            ->assertCreated()
            ->assertJsonPath('data.license_plate', 'ABC-1234')
            ->assertJsonPath('data.vin', '1HGCM82633A004352')
            ->assertJsonPath('data.current_mileage', 12000);
        $this->assertDatabaseHas('vehicles', [
            'owner_id' => $owner->id,
            'license_plate' => 'ABC-1234',
            'vin' => '1HGCM82633A004352',
        ]);
    }

    public function test_returns_422_with_required_field_messages_for_empty_payload(): void
    {
        $response = $this->postJson('/api/v1/vehicles', []);

        $response
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'owner_id',
                'vehicle_category_id',
                'vehicle_model_id',
                'license_plate',
                'year',
            ])
            ->assertJsonPath('errors.owner_id.0', 'El propietario es obligatorio.')
            ->assertJsonPath('errors.license_plate.0', 'La placa es obligatoria.');
    }

    public function test_returns_422_for_invalid_references_and_vehicle_values(): void
    {
        $response = $this->postJson('/api/v1/vehicles', [
            'owner_id' => 999999,
            'vehicle_category_id' => 999999,
            'vehicle_model_id' => 999999,
            'license_plate' => 'INVALID-1',
            'vin' => 'VIN-INVALIDO',
            'year' => 1800,
            'current_mileage' => -1,
        ]);

        $response
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                'owner_id',
                'vehicle_category_id',
                'vehicle_model_id',
                'vin',
                'year',
                'current_mileage',
            ]);
        $this->assertDatabaseMissing('vehicles', ['license_plate' => 'INVALID-1']);
    }

    public function test_unexpected_payload_key_cannot_override_vehicle_id(): void
    {
        $owner = User::factory()->create();
        $category = VehicleCategory::factory()->create();
        $vehicleModel = VehicleModel::factory()->create();

        $response = $this->postJson('/api/v1/vehicles', [
            'id' => 999999,
            'owner_id' => $owner->id,
            'vehicle_category_id' => $category->id,
            'vehicle_model_id' => $vehicleModel->id,
            'license_plate' => 'SAFE-001',
            'year' => 2024,
        ]);

        $response
            ->assertCreated()
            ->assertJsonMissing(['id' => 999999]);
        $this->assertDatabaseMissing('vehicles', ['id' => 999999]);
        $this->assertDatabaseHas('vehicles', ['license_plate' => 'SAFE-001']);
    }
}
