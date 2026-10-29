<?php

use App\Http\Controllers\Api\DatabaseHealthController;
use App\Http\Controllers\Api\HealthController;
use App\Http\Controllers\Api\V1\VehicleController;
use Illuminate\Support\Facades\Route;

Route::middleware('throttle:api')->group(function (): void {
    Route::get('/health', HealthController::class)->name('api.health');

    if (app()->environment(['local', 'testing'])) {
        Route::get('/database', DatabaseHealthController::class)->name('api.database');
    }

    Route::prefix('v1')->name('api.v1.')->group(function (): void {
        Route::apiResource('vehicles', VehicleController::class)
            ->only(['index', 'store', 'show']);
    });
});
