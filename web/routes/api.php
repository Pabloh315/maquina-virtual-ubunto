<?php

use App\Http\Controllers\Api\Admin\CatalogController;
use App\Http\Controllers\Api\Admin\UserController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DatabaseHealthController;
use App\Http\Controllers\Api\HealthController;
use App\Http\Controllers\Api\V1\MaintenanceHistoryController;
use App\Http\Controllers\Api\V1\MaintenancePlanController;
use App\Http\Controllers\Api\V1\VehicleController;
use Illuminate\Support\Facades\Route;

Route::middleware('throttle:api')->group(function (): void {
    Route::get('/health', HealthController::class)->name('api.health');
    Route::post('/login', [AuthController::class, 'login'])
        ->middleware('throttle:login')
        ->name('api.login');

    if (app()->environment(['local', 'testing'])) {
        Route::get('/database', DatabaseHealthController::class)->name('api.database');
    }

    Route::middleware('auth:sanctum')->group(function (): void {
        Route::get('/me', [AuthController::class, 'me'])->name('api.me');
        Route::post('/logout', [AuthController::class, 'logout'])->name('api.logout');
        Route::get('/access-check', fn () => response()->json(['message' => 'Acceso autorizado.']))
            ->middleware('permission:vehicles.view')
            ->name('api.access-check');

        Route::middleware('permission:accounts.manage')->prefix('users')->name('api.users.')->group(function (): void {
            Route::get('/', [UserController::class, 'index'])->name('index');
            Route::post('/', [UserController::class, 'store'])->name('store');
            Route::get('/{user}', [UserController::class, 'show'])->name('show');
            Route::put('/{user}', [UserController::class, 'update'])->name('update');
            Route::patch('/{user}/role', [UserController::class, 'updateRole'])->name('update-role');
        });

        Route::middleware('permission:catalogs.manage')
            ->prefix('catalogs/{type}')
            ->name('api.catalogs.')
            ->whereIn('type', ['brands', 'categories', 'models'])
            ->group(function (): void {
                Route::get('/', [CatalogController::class, 'index'])->name('index');
                Route::post('/', [CatalogController::class, 'store'])->name('store');
                Route::put('/{id}', [CatalogController::class, 'update'])->name('update');
            });

        Route::prefix('v1')->name('api.v1.')->group(function (): void {
            Route::get('vehicles', [VehicleController::class, 'index'])
                ->middleware('permission:vehicles.view')
                ->name('vehicles.index');
            Route::get('vehicles/{vehicle}', [VehicleController::class, 'show'])
                ->middleware('permission:vehicles.view')
                ->name('vehicles.show');
            Route::post('vehicles', [VehicleController::class, 'store'])
                ->middleware('permission:vehicles.create')
                ->name('vehicles.store');
            Route::get('vehicles/{vehicle}/maintenance-histories', [MaintenanceHistoryController::class, 'index'])
                ->middleware('permission:vehicles.view')
                ->name('vehicles.maintenance-histories.index');
            Route::post('vehicles/{vehicle}/maintenance-histories', [MaintenanceHistoryController::class, 'store'])
                ->middleware('permission:vehicles.create')
                ->name('vehicles.maintenance-histories.store');
            Route::get('vehicles/{vehicle}/maintenance-histories/{maintenanceHistory}', [MaintenanceHistoryController::class, 'show'])
                ->middleware('permission:vehicles.view')
                ->name('vehicles.maintenance-histories.show');
            Route::get('vehicles/{vehicle}/maintenance-plans', [MaintenancePlanController::class, 'index'])
                ->middleware('permission:vehicles.view')
                ->name('vehicles.maintenance-plans.index');
            Route::post('vehicles/{vehicle}/maintenance-plans', [MaintenancePlanController::class, 'store'])
                ->middleware('permission:vehicles.create')
                ->name('vehicles.maintenance-plans.store');
            Route::get('vehicles/{vehicle}/maintenance-plans/{maintenancePlan}', [MaintenancePlanController::class, 'show'])
                ->middleware('permission:vehicles.view')
                ->name('vehicles.maintenance-plans.show');        });
    });
});
