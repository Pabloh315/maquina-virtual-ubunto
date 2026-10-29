<?php

namespace Tests\Feature;

use Tests\TestCase;

class HomePageTest extends TestCase
{
    public function test_returns_200_with_the_technical_home_page(): void
    {
        $response = $this->get('/');

        $response
            ->assertOk()
            ->assertViewIs('home')
            ->assertViewHasAll(['healthUrl', 'databaseUrl', 'vehiclesUrl'])
            ->assertSeeText('Sistema de Gestión de Mantenimiento de Vehículos')
            ->assertSeeText('Estado de la integración')
            ->assertSee('/api/health', escape: false)
            ->assertSee('/api/v1/vehicles', escape: false);
    }
}
