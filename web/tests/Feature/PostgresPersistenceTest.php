<?php

namespace Tests\Feature;

use App\Models\MaintenancePlan;
use App\Models\Make;
use App\Models\User;
use App\Models\Vehicle;
use App\Models\VehicleCategory;
use App\Models\VehicleModel;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\LazilyRefreshDatabase;
use PHPUnit\Framework\Attributes\Test;
use Tests\TestCase;

class PostgresPersistenceTest extends TestCase
{
    use LazilyRefreshDatabase;

    #[Test]
    public function it_persists_related_entities_and_enforces_core_constraints(): void
    {
        $suffix = (string) hrtime(true);
        $owner = User::factory()->create(['email' => "edt-{$suffix}@example.test"]);
        $category = VehicleCategory::factory()->create(['name' => "Test-{$suffix}"]);
        $make = Make::factory()->create(['name' => "Make-{$suffix}"]);
        $model = VehicleModel::factory()->create(['make_id' => $make->id, 'name' => 'Integration']);
        $vehicle = Vehicle::factory()->create([
            'owner_id' => $owner->id,
            'vehicle_category_id' => $category->id,
            'vehicle_model_id' => $model->id,
            'license_plate' => 'T'.substr($suffix, -7),
            'year' => 2024,
        ]);
        $plan = MaintenancePlan::create(['vehicle_id' => $vehicle->id, 'name' => 'Integration plan']);

        $this->assertSame($owner->id, $plan->vehicle->owner->id);
        $this->expectException(QueryException::class);
        VehicleCategory::create(['name' => $category->name]);
    }
}
