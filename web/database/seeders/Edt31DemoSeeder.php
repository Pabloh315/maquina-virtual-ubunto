<?php

namespace Database\Seeders;

use App\Models\Make;
use App\Models\Role;
use App\Models\ServiceCatalog;
use App\Models\VehicleCategory;
use Illuminate\Database\Seeder;

class Edt31DemoSeeder extends Seeder
{
    /** Development-only catalogue data; it contains no personal information. */
    public function run(): void
    {
        Role::firstOrCreate(['name' => 'owner'], ['description' => 'Vehicle owner']);
        Role::firstOrCreate(['name' => 'technician'], ['description' => 'Workshop technician']);
        VehicleCategory::firstOrCreate(['name' => 'Automóvil']);
        Make::firstOrCreate(['name' => 'Toyota']);
        ServiceCatalog::firstOrCreate(['name' => 'Cambio de aceite']);
        ServiceCatalog::firstOrCreate(['name' => 'Inspección general']);
    }
}
