<?php

namespace Tests\Feature;

use App\Models\Vehicle;
use App\Models\VehicleCategory;
use App\Models\VehicleModel;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\LazilyRefreshDatabase;
use PHPUnit\Framework\Attributes\Test;
use Tests\TestCase;

class PostgresForeignKeyTest extends TestCase
{
    use LazilyRefreshDatabase;

    #[Test]
    public function it_rejects_a_vehicle_with_a_missing_owner(): void
    {
        $category = VehicleCategory::factory()->create();
        $model = VehicleModel::factory()->create();

        $this->expectException(QueryException::class);
        Vehicle::factory()->create([
            'owner_id' => 999999999,
            'vehicle_category_id' => $category->id,
            'vehicle_model_id' => $model->id,
        ]);
    }
}
