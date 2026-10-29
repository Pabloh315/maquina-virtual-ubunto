<?php

namespace Tests\Feature\Http\Controllers\Api;

use Tests\TestCase;

class HealthControllerTest extends TestCase
{
    public function test_returns_200_with_the_public_service_status(): void
    {
        $response = $this->getJson('/api/health');

        $response
            ->assertOk()
            ->assertExactJson([
                'status' => 'ok',
                'service' => 'mantenimiento-vehiculos-api',
            ]);
    }
}
