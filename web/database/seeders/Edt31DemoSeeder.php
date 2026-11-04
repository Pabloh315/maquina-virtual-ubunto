<?php

namespace Database\Seeders;

use App\Models\Make;
use App\Models\Permission;
use App\Models\Role;
use App\Models\ServiceCatalog;
use App\Models\VehicleCategory;
use Illuminate\Database\Seeder;

class Edt31DemoSeeder extends Seeder
{
    /** Development-only catalogue and role data; it contains no personal information. */
    public function run(): void
    {
        $owner = Role::firstOrCreate(['name' => 'owner'], ['description' => 'Vehicle owner']);
        $technician = Role::firstOrCreate(['name' => 'technician'], ['description' => 'Workshop technician']);
        $view = Permission::firstOrCreate(['name' => 'vehicles.view'], ['description' => 'View vehicle information']);
        $create = Permission::firstOrCreate(['name' => 'vehicles.create'], ['description' => 'Register vehicles']);
        $owner->permissions()->syncWithoutDetaching([$view->id, $create->id]);
        $technician->permissions()->syncWithoutDetaching([$view->id]);
        VehicleCategory::firstOrCreate(['name' => 'AutomÃ³vil']);
        Make::firstOrCreate(['name' => 'Toyota']);
        ServiceCatalog::firstOrCreate(['name' => 'Cambio de aceite']);
        ServiceCatalog::firstOrCreate(['name' => 'InspecciÃ³n general']);
    }
}
