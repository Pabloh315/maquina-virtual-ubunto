<?php

use Illuminate\Contracts\View\View;
use Illuminate\Support\Facades\Route;

Route::get('/', function (): View {
    return view('home', [
        'healthUrl' => route('api.health'),
        'databaseUrl' => Route::has('api.database') ? route('api.database') : null,
        'vehiclesUrl' => route('api.v1.vehicles.index'),
    ]);
})->name('home');
