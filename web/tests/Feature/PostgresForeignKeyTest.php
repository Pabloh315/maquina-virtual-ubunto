<?php

namespace Tests\Feature;

use App\Models\Make;
use App\Models\Vehicle;
use App\Models\VehicleCategory;
use App\Models\VehicleModel;
use Illuminate\Database\QueryException;
use PHPUnit\Framework\Attributes\Test;
use Tests\TestCase;

class PostgresForeignKeyTest extends TestCase
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
    public function it_rejects_a_vehicle_with_a_missing_owner(): void
    {
        $suffix = (string) hrtime(true);
        $category = VehicleCategory::create(['name' => "FK-{$suffix}"]);
        $make = Make::create(['name' => "FK-Make-{$suffix}"]);
        $model = VehicleModel::create(['make_id' => $make->id, 'name' => 'FK Model']);

        $this->expectException(QueryException::class);
        Vehicle::create([
            'owner_id' => 999999999,
            'vehicle_category_id' => $category->id,
            'vehicle_model_id' => $model->id,
            'license_plate' => 'F'.substr($suffix, -7),
            'year' => 2024,
        ]);
    }
}
