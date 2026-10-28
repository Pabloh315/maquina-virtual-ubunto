<?php

namespace Tests\Unit;

use App\Models\Appointment;
use App\Models\MaintenancePlan;
use App\Models\ServiceOrder;
use App\Models\Vehicle;
use App\Models\Workshop;
use PHPUnit\Framework\Attributes\Test;
use Tests\TestCase;

class Edt31ModelRelationsTest extends TestCase
{
    #[Test]
    public function core_models_expose_the_expected_relations(): void
    {
        $this->assertSame('owner_id', (new Vehicle())->owner()->getForeignKeyName());
        $this->assertSame('vehicle_id', (new MaintenancePlan())->vehicle()->getForeignKeyName());
        $this->assertSame('workshop_id', (new Appointment())->workshop()->getForeignKeyName());
        $this->assertSame('appointment_id', (new ServiceOrder())->appointment()->getForeignKeyName());
        $this->assertSame('workshop_id', (new Workshop())->appointments()->getForeignKeyName());
    }
}
