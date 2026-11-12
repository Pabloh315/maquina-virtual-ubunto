<?php

namespace Tests\Unit;

use App\Models\MaintenancePlanService;
use App\Services\MaintenanceDueCalculator;
use Carbon\CarbonImmutable;
use PHPUnit\Framework\Attributes\Test;
use Tests\TestCase;

class MaintenanceDueCalculatorTest extends TestCase
{
    #[Test]
    public function it_calculates_the_next_mileage_and_date(): void
    {
        $service = new MaintenancePlanService(['interval_km' => 5000, 'interval_months' => 6, 'last_service_mileage' => 45000, 'last_service_date' => '2026-05-10']);
        $result = app(MaintenanceDueCalculator::class)->calculate($service, 48000, CarbonImmutable::parse('2026-08-01'));

        $this->assertSame(50000, $result['next_service_mileage']);
        $this->assertSame('2026-11-10', $result['next_service_date']);
        $this->assertFalse($result['is_overdue']);
    }

    #[Test]
    public function it_is_overdue_when_either_mileage_or_time_limit_is_reached(): void
    {
        $service = new MaintenancePlanService(['interval_km' => 5000, 'interval_months' => 6, 'last_service_mileage' => 45000, 'last_service_date' => '2026-05-10']);
        $calculator = app(MaintenanceDueCalculator::class);

        $this->assertTrue($calculator->calculate($service, 50000, CarbonImmutable::parse('2026-08-01'))['is_overdue']);
        $this->assertTrue($calculator->calculate($service, 48000, CarbonImmutable::parse('2026-11-10'))['is_overdue']);
    }

    #[Test]
    public function it_reports_insufficient_history_without_inventing_values(): void
    {
        $service = new MaintenancePlanService(['interval_km' => 5000, 'interval_months' => 6]);
        $result = app(MaintenanceDueCalculator::class)->calculate($service, 1000, CarbonImmutable::parse('2026-01-01'));

        $this->assertNull($result['next_service_mileage']);
        $this->assertNull($result['next_service_date']);
        $this->assertSame('informacion_historica_insuficiente', $result['mileage_status']);
        $this->assertSame('informacion_historica_insuficiente', $result['date_status']);
    }
}