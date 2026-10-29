<?php

namespace Tests\Feature\Http\Controllers\Api;

use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class DatabaseHealthControllerTest extends TestCase
{
    public function test_returns_200_when_postgresql_is_reachable(): void
    {
        $response = $this->getJson('/api/database');

        $response
            ->assertOk()
            ->assertExactJson([
                'status' => 'ok',
                'database' => 'reachable',
                'driver' => 'pgsql',
            ]);
    }

    public function test_returns_503_without_exposing_connection_details_when_database_is_unreachable(): void
    {
        config()->set('database.connections.pgsql.database', 'database_that_does_not_exist');
        DB::purge('pgsql');

        $response = $this->getJson('/api/database');

        $response
            ->assertServiceUnavailable()
            ->assertExactJson([
                'status' => 'error',
                'database' => 'unavailable',
            ])
            ->assertJsonMissingPath('exception')
            ->assertJsonMissingPath('trace');
    }
}
