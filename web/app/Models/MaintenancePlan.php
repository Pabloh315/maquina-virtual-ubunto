<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
class MaintenancePlan extends Model { protected $fillable = ['vehicle_id','name','recommendation_source','source_reference','is_active']; protected function casts(): array { return ['is_active'=>'boolean']; } public function vehicle(): BelongsTo { return $this->belongsTo(Vehicle::class); } public function services(): HasMany { return $this->hasMany(MaintenancePlanService::class); } }
