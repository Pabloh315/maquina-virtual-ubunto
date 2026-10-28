<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('roles', function (Blueprint $table) {
            $table->id();
            $table->string('name', 80)->unique();
            $table->string('description')->nullable();
            $table->timestamps();
        });
        Schema::create('permissions', function (Blueprint $table) {
            $table->id();
            $table->string('name', 100)->unique();
            $table->string('description')->nullable();
            $table->timestamps();
        });
        Schema::create('role_user', function (Blueprint $table) {
            $table->foreignId('role_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->timestamps();
            $table->primary(['role_id', 'user_id']);
        });
        Schema::create('permission_role', function (Blueprint $table) {
            $table->foreignId('permission_id')->constrained()->cascadeOnDelete();
            $table->foreignId('role_id')->constrained()->cascadeOnDelete();
            $table->primary(['permission_id', 'role_id']);
        });
        Schema::create('vehicle_categories', function (Blueprint $table) {
            $table->id();
            $table->string('name', 80)->unique();
            $table->string('description')->nullable();
            $table->timestamps();
        });
        Schema::create('makes', function (Blueprint $table) {
            $table->id();
            $table->string('name', 80)->unique();
            $table->timestamps();
        });
        Schema::create('vehicle_models', function (Blueprint $table) {
            $table->id();
            $table->foreignId('make_id')->constrained()->restrictOnDelete();
            $table->string('name', 100);
            $table->timestamps();
            $table->unique(['make_id', 'name']);
        });
        Schema::create('vehicles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('owner_id')->constrained('users')->restrictOnDelete();
            $table->foreignId('vehicle_category_id')->constrained()->restrictOnDelete();
            $table->foreignId('vehicle_model_id')->constrained()->restrictOnDelete();
            $table->string('license_plate', 20)->unique();
            $table->string('vin', 17)->nullable()->unique();
            $table->unsignedSmallInteger('year');
            $table->string('color', 50)->nullable();
            $table->string('fuel_type', 30)->nullable();
            $table->unsignedInteger('current_mileage')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->index(['owner_id', 'is_active']);
        });
        Schema::create('mileage_readings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('vehicle_id')->constrained()->cascadeOnDelete();
            $table->unsignedInteger('mileage');
            $table->timestamp('recorded_at');
            $table->string('source', 40)->default('manual');
            $table->timestamps();
            $table->unique(['vehicle_id', 'recorded_at']);
            $table->index(['vehicle_id', 'mileage']);
        });
    }
    public function down(): void
    {
        Schema::dropIfExists('mileage_readings'); Schema::dropIfExists('vehicles');
        Schema::dropIfExists('vehicle_models'); Schema::dropIfExists('makes');
        Schema::dropIfExists('vehicle_categories'); Schema::dropIfExists('permission_role');
        Schema::dropIfExists('role_user'); Schema::dropIfExists('permissions'); Schema::dropIfExists('roles');
    }
};
