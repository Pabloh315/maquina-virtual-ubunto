<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
class VehicleModel extends Model { protected $fillable = ['make_id','name']; public function make(): BelongsTo { return $this->belongsTo(Make::class); } }
