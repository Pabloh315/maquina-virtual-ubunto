<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;
class Appointment extends Model { protected $fillable = ['vehicle_id','workshop_id','scheduled_at','duration_minutes','status','reason','cancelled_at','cancellation_reason','rescheduled_from_id']; protected function casts(): array { return ['scheduled_at'=>'datetime','cancelled_at'=>'datetime','duration_minutes'=>'integer']; } public function vehicle(): BelongsTo { return $this->belongsTo(Vehicle::class); } public function workshop(): BelongsTo { return $this->belongsTo(Workshop::class); } public function rescheduledFrom(): BelongsTo { return $this->belongsTo(self::class, 'rescheduled_from_id'); } public function serviceOrder(): HasOne { return $this->hasOne(ServiceOrder::class); } }
