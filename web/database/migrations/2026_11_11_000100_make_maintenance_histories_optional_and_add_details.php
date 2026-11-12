<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('maintenance_histories', function (Blueprint $table): void {
            $table->string('service_type', 120)->nullable()->after('service_catalog_id');
            $table->string('provider', 140)->nullable()->after('description');
            $table->decimal('cost', 12, 2)->nullable()->after('provider');
            $table->date('performed_on')->nullable()->change();
            $table->unsignedInteger('mileage')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('maintenance_histories', function (Blueprint $table): void {
            $table->dropColumn(['service_type', 'provider', 'cost']);
            $table->date('performed_on')->nullable(false)->change();
            $table->unsignedInteger('mileage')->nullable(false)->change();
        });
    }
};
