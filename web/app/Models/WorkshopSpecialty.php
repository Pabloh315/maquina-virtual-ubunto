<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
class WorkshopSpecialty extends Model { protected $fillable = ['workshop_id','name']; public function workshop(): BelongsTo { return $this->belongsTo(Workshop::class); } }
