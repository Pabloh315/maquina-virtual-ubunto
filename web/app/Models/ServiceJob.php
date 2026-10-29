<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
class ServiceJob extends Model { protected $fillable = ['service_order_id','service_catalog_id','technician_id','name','status','description','labor_cost','parts_cost','started_at','completed_at']; protected function casts(): array { return ['labor_cost'=>'decimal:2','parts_cost'=>'decimal:2','started_at'=>'datetime','completed_at'=>'datetime']; } public function serviceOrder(): BelongsTo { return $this->belongsTo(ServiceOrder::class); } }
