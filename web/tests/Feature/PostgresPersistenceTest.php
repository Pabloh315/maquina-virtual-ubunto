<?php

namespace Tests\Feature;

use App\Models\Make;
use App\Models\MaintenancePlan;
use App\Models\User;
use App\Models\Vehicle;
use App\Models\VehicleCategory;
use App\Models\VehicleModel;
use Illuminate\Database\QueryException;
use PHPUnit\Framework\Attributes\Test;
use Tests\TestCase;

class PostgresPersistenceTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        config()->set('database.default', 'pgsql');
        config()->set('database.connections.pgsql.host', '127.0.0.1');
        config()->set('database.connections.pgsql.port', 5433);
        config()->set('database.connections.pgsql.database', 'mantenimiento_vehiculos');
        config()->set('database.connections.pgsql.username', 'postgres');
    }
    #[Test]
    public function it_persists_related_entities_and_enforces_core_constraints(): void
    {
        $suffix = (string) hrtime(true);
        $owner = User::create(['name' => 'EDT Test', 'email' => "edt-{$suffix}@example.test", 'password' => 'test-password']);
        $category = VehicleCategory::create(['name' => "Test-{$suffix}"]);
        $make = Make::create(['name' => "Make-{$suffix}"]);
        $model = VehicleModel::create(['make_id' => $make->id, 'name' => 'Integration']);
        $vehicle = Vehicle::create([
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
