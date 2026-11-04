<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DatabaseHealthController;
use App\Http\Controllers\Api\HealthController;
use App\Http\Controllers\Api\V1\VehicleController;
use Illuminate\Support\Facades\Route;

Route::middleware('throttle:api')->group(function (): void {
    Route::get('/health', HealthController::class)->name('api.health');
    Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:login')->name('api.login');

    if (app()->environment(['local', 'testing'])) {
        Route::get('/database', DatabaseHealthController::class)->name('api.database');
    }

    Route::middleware('auth:sanctum')->group(function (): void {
        Route::get('/me', [AuthController::class, 'me'])->name('api.me');
        Route::post('/logout', [AuthController::class, 'logout'])->name('api.logout');
        Route::get('/access-check', fn () => response()->json(['message' => 'Acceso autorizado.']))
            ->middleware('permission:vehicles.view')->name('api.access-check');

        Route::prefix('v1')->name('api.v1.')->group(function (): void {
            Route::get('vehicles', [VehicleController::class, 'index'])->middleware('permission:vehicles.view');
            Route::get('vehicles/{vehicle}', [VehicleController::class, 'show'])->middleware('permission:vehicles.view');
            Route::post('vehicles', [VehicleController::class, 'store'])->middleware('permission:vehicles.create');
        });
    });
});
