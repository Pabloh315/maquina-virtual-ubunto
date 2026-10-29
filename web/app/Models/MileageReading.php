<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
class MileageReading extends Model { protected $fillable = ['vehicle_id','mileage','recorded_at','source']; protected function casts(): array { return ['mileage'=>'integer','recorded_at'=>'datetime']; } public function vehicle(): BelongsTo { return $this->belongsTo(Vehicle::class); } }
