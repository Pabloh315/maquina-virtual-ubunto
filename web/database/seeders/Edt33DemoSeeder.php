<?php

namespace Database\Seeders;

use App\Models\Make;
use App\Models\Role;
use App\Models\User;
use App\Models\Vehicle;
use App\Models\VehicleCategory;
use App\Models\VehicleModel;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class Edt33DemoSeeder extends Seeder
{
    public function run(): void
    {
        $category = VehicleCategory::updateOrCreate(
            ['name' => 'AutomÃƒÂ³vil'],
            ['description' => 'VehÃƒÂ­culo liviano de demostraciÃƒÂ³n'],
        );
        $make = Make::firstOrCreate(['name' => 'Toyota']);
        $vehicleModel = VehicleModel::firstOrCreate([
            'make_id' => $make->id,
            'name' => 'Corolla Demo',
        ]);
        $owner = User::firstOrCreate(
            ['email' => 'propietario.demo@example.test'],
            [
                'name' => 'Propietario de demostraciÃƒÂ³n',
                'password' => Hash::make(Str::password(32)),
            ],
        );

        $owner->roles()->syncWithoutDetaching([Role::where('name', 'owner')->value('id')]);

        Vehicle::updateOrCreate(
            ['license_plate' => 'DEMO-001'],
            [
                'owner_id' => $owner->id,
                'vehicle_category_id' => $category->id,
                'vehicle_model_id' => $vehicleModel->id,
                'vin' => '1HGCM82633A004352',
                'year' => 2024,
                'color' => 'Azul',
                'fuel_type' => 'gasolina',
                'current_mileage' => 12500,
                'is_active' => true,
            ],
        );
    }
}
