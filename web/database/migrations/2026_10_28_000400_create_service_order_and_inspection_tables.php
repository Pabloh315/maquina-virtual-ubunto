<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('service_orders', function (Blueprint $table) {
            $table->id(); $table->foreignId('vehicle_id')->constrained()->restrictOnDelete(); $table->foreignId('workshop_id')->constrained()->restrictOnDelete(); $table->foreignId('appointment_id')->nullable()->unique()->constrained()->nullOnDelete(); $table->foreignId('technician_id')->nullable()->constrained('users')->nullOnDelete(); $table->string('status', 30)->default('open'); $table->timestamp('received_at'); $table->timestamp('closed_at')->nullable(); $table->unsignedInteger('mileage_at_entry'); $table->text('customer_notes')->nullable(); $table->text('internal_notes')->nullable(); $table->timestamps(); $table->index(['workshop_id', 'status']); $table->index(['vehicle_id', 'received_at']);
        });
        Schema::create('inspections', function (Blueprint $table) {
            $table->id(); $table->foreignId('service_order_id')->unique()->constrained()->cascadeOnDelete(); $table->foreignId('inspector_id')->nullable()->constrained('users')->nullOnDelete(); $table->string('overall_result', 30)->default('pending'); $table->text('observations')->nullable(); $table->timestamp('inspected_at')->nullable(); $table->timestamps();
        });
        Schema::create('inspection_items', function (Blueprint $table) {
            $table->id(); $table->string('name', 120)->unique(); $table->string('category', 80)->nullable(); $table->boolean('is_active')->default(true); $table->timestamps();
        });
        Schema::create('inspection_results', function (Blueprint $table) {
            $table->id(); $table->foreignId('inspection_id')->constrained()->cascadeOnDelete(); $table->foreignId('inspection_item_id')->constrained()->restrictOnDelete(); $table->string('result', 30); $table->text('observation')->nullable(); $table->timestamps(); $table->unique(['inspection_id', 'inspection_item_id']);
        });
        Schema::create('service_jobs', function (Blueprint $table) {
            $table->id(); $table->foreignId('service_order_id')->constrained()->cascadeOnDelete(); $table->foreignId('service_catalog_id')->nullable()->constrained()->nullOnDelete(); $table->foreignId('technician_id')->nullable()->constrained('users')->nullOnDelete(); $table->string('name', 140); $table->string('status', 30)->default('pending'); $table->text('description')->nullable(); $table->decimal('labor_cost', 12, 2)->nullable(); $table->decimal('parts_cost', 12, 2)->nullable(); $table->timestamp('started_at')->nullable(); $table->timestamp('completed_at')->nullable(); $table->timestamps(); $table->index(['service_order_id', 'status']);
        });
        Schema::create('maintenance_histories', function (Blueprint $table) {
            $table->id(); $table->foreignId('vehicle_id')->constrained()->restrictOnDelete(); $table->foreignId('service_order_id')->nullable()->constrained()->nullOnDelete(); $table->foreignId('service_catalog_id')->nullable()->constrained()->nullOnDelete(); $table->foreignId('service_job_id')->nullable()->unique()->constrained()->nullOnDelete(); $table->date('performed_on'); $table->unsignedInteger('mileage'); $table->string('description', 255); $table->text('notes')->nullable(); $table->timestamps(); $table->index(['vehicle_id', 'performed_on']);
        });
    }
    public function down(): void { Schema::dropIfExists('maintenance_histories'); Schema::dropIfExists('service_jobs'); Schema::dropIfExists('inspection_results'); Schema::dropIfExists('inspection_items'); Schema::dropIfExists('inspections'); Schema::dropIfExists('service_orders'); }
};
