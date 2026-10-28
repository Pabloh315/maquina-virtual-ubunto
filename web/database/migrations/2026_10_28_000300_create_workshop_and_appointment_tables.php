<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('workshops', function (Blueprint $table) {
            $table->id(); $table->string('name', 140); $table->string('tax_id', 40)->nullable()->unique(); $table->string('phone', 30); $table->string('email')->nullable(); $table->string('address'); $table->unsignedSmallInteger('appointment_capacity')->default(1); $table->boolean('is_active')->default(true); $table->timestamps();
        });
        Schema::create('workshop_specialties', function (Blueprint $table) {
            $table->id(); $table->foreignId('workshop_id')->constrained()->cascadeOnDelete(); $table->string('name', 100); $table->timestamps(); $table->unique(['workshop_id', 'name']);
        });
        Schema::create('workshop_services', function (Blueprint $table) {
            $table->id(); $table->foreignId('workshop_id')->constrained()->cascadeOnDelete(); $table->foreignId('service_catalog_id')->constrained()->restrictOnDelete(); $table->decimal('base_price', 12, 2)->nullable(); $table->boolean('is_active')->default(true); $table->timestamps(); $table->unique(['workshop_id', 'service_catalog_id']);
        });
        Schema::create('workshop_brand_authorizations', function (Blueprint $table) {
            $table->id(); $table->foreignId('workshop_id')->constrained()->cascadeOnDelete(); $table->foreignId('make_id')->constrained()->restrictOnDelete(); $table->boolean('is_officially_authorized')->default(false); $table->string('authorization_reference', 100)->nullable(); $table->date('valid_until')->nullable(); $table->timestamps(); $table->unique(['workshop_id', 'make_id']);
        });
        Schema::create('workshop_hours', function (Blueprint $table) {
            $table->id(); $table->foreignId('workshop_id')->constrained()->cascadeOnDelete(); $table->unsignedTinyInteger('weekday'); $table->time('opens_at')->nullable(); $table->time('closes_at')->nullable(); $table->boolean('is_closed')->default(false); $table->timestamps(); $table->unique(['workshop_id', 'weekday']);
        });
        Schema::create('appointments', function (Blueprint $table) {
            $table->id(); $table->foreignId('vehicle_id')->constrained()->restrictOnDelete(); $table->foreignId('workshop_id')->constrained()->restrictOnDelete(); $table->timestamp('scheduled_at'); $table->unsignedSmallInteger('duration_minutes')->default(60); $table->string('status', 30)->default('scheduled'); $table->text('reason')->nullable(); $table->timestamp('cancelled_at')->nullable(); $table->string('cancellation_reason')->nullable(); $table->foreignId('rescheduled_from_id')->nullable()->constrained('appointments')->nullOnDelete(); $table->timestamps(); $table->index(['workshop_id', 'scheduled_at']); $table->index(['vehicle_id', 'status']);
        });
    }
    public function down(): void { Schema::dropIfExists('appointments'); Schema::dropIfExists('workshop_hours'); Schema::dropIfExists('workshop_brand_authorizations'); Schema::dropIfExists('workshop_services'); Schema::dropIfExists('workshop_specialties'); Schema::dropIfExists('workshops'); }
};
