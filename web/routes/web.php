<?php
use App\Http\Controllers\Web\AdminController; use Illuminate\Contracts\View\View; use Illuminate\Support\Facades\Route;
Route::get('/',function():View{return view('home',['healthUrl'=>route('api.health'),'databaseUrl'=>Route::has('api.database')?route('api.database'):null,'vehiclesUrl'=>url('/api/v1/vehicles')]);})->name('home');
Route::get('/admin',[AdminController::class,'index'])->middleware(['auth','permission:accounts.manage'])->name('admin.index');