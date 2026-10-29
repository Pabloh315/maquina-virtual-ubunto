<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
class ServiceOrder extends Model { protected $fillable = ['vehicle_id','workshop_id','appointment_id','technician_id','status','received_at','closed_at','mileage_at_entry','customer_notes','internal_notes']; protected function casts(): array { return ['received_at'=>'datetime','closed_at'=>'datetime','mileage_at_entry'=>'integer']; } public function vehicle(): BelongsTo { return $this->belongsTo(Vehicle::class); } public function workshop(): BelongsTo { return $this->belongsTo(Workshop::class); } public function appointment(): BelongsTo { return $this->belongsTo(Appointment::class); } public function technician(): BelongsTo { return $this->belongsTo(User::class, 'technician_id'); } public function inspection(): HasOne { return $this->hasOne(Inspection::class); } public function jobs(): HasMany { return $this->hasMany(ServiceJob::class); } }
