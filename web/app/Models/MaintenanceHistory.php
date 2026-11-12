<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
class MaintenanceHistory extends Model { protected $fillable = ['vehicle_id','service_order_id','service_catalog_id','service_job_id','service_type','performed_on','mileage','description','notes','provider','cost']; protected function casts(): array { return ['performed_on'=>'date','mileage'=>'integer','cost'=>'decimal:2']; } public function vehicle(): BelongsTo { return $this->belongsTo(Vehicle::class); } public function serviceOrder(): BelongsTo { return $this->belongsTo(ServiceOrder::class); } public function serviceCatalog(): BelongsTo { return $this->belongsTo(ServiceCatalog::class); } }
