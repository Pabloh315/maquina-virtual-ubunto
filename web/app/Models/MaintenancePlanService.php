<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
class MaintenancePlanService extends Model { protected $fillable = ['maintenance_plan_id','service_catalog_id','interval_km','interval_months','last_service_mileage','last_service_date','next_service_mileage','next_service_date']; protected function casts(): array { return ['last_service_date'=>'date','next_service_date'=>'date']; } public function maintenancePlan(): BelongsTo { return $this->belongsTo(MaintenancePlan::class); } public function serviceCatalog(): BelongsTo { return $this->belongsTo(ServiceCatalog::class); } }
