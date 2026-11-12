<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('maintenance_plans', function (Blueprint $table): void {
            $table->text('source_reference')->nullable()->after('recommendation_source');
        });
    }

    public function down(): void
    {
        Schema::table('maintenance_plans', function (Blueprint $table): void {
            $table->dropColumn('source_reference');
        });
    }
};