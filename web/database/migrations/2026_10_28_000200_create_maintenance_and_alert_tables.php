<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('service_catalogs', function (Blueprint $table) {
            $table->id(); $table->string('name', 120)->unique(); $table->text('description')->nullable(); $table->timestamps();
        });
        Schema::create('maintenance_plans', function (Blueprint $table) {
            $table->id(); $table->foreignId('vehicle_id')->constrained()->cascadeOnDelete();
            $table->string('name', 120); $table->string('recommendation_source', 100)->nullable(); $table->boolean('is_active')->default(true); $table->timestamps();
            $table->unique(['vehicle_id', 'name']);
        });
        Schema::create('maintenance_plan_services', function (Blueprint $table) {
            $table->id(); $table->foreignId('maintenance_plan_id')->constrained()->cascadeOnDelete(); $table->foreignId('service_catalog_id')->constrained()->restrictOnDelete();
            $table->unsignedInteger('interval_km')->nullable(); $table->unsignedSmallInteger('interval_months')->nullable();
            $table->unsignedInteger('last_service_mileage')->nullable(); $table->date('last_service_date')->nullable();
            $table->unsignedInteger('next_service_mileage')->nullable(); $table->date('next_service_date')->nullable(); $table->timestamps();
            $table->unique(['maintenance_plan_id', 'service_catalog_id']);
        });
        Schema::create('alerts', function (Blueprint $table) {
            $table->id(); $table->foreignId('vehicle_id')->constrained()->cascadeOnDelete(); $table->foreignId('maintenance_plan_service_id')->nullable()->constrained()->nullOnDelete();
            $table->string('type', 40); $table->string('status', 30)->default('pending'); $table->string('title', 160); $table->text('message')->nullable();
            $table->timestamp('due_at')->nullable(); $table->timestamp('read_at')->nullable(); $table->timestamp('resolved_at')->nullable(); $table->timestamps();
            $table->index(['vehicle_id', 'status']); $table->index(['status', 'due_at']);
        });
    }
    public function down(): void { Schema::dropIfExists('alerts'); Schema::dropIfExists('maintenance_plan_services'); Schema::dropIfExists('maintenance_plans'); Schema::dropIfExists('service_catalogs'); }
};
