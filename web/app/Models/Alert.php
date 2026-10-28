<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
class Alert extends Model { protected $fillable = ['vehicle_id','maintenance_plan_service_id','type','status','title','message','due_at','read_at','resolved_at']; protected function casts(): array { return ['due_at'=>'datetime','read_at'=>'datetime','resolved_at'=>'datetime']; } public function vehicle(): BelongsTo { return $this->belongsTo(Vehicle::class); } }
