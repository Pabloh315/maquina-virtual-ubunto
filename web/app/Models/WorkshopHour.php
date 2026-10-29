<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
class WorkshopHour extends Model { protected $fillable = ['workshop_id','weekday','opens_at','closes_at','is_closed']; protected function casts(): array { return ['weekday'=>'integer','is_closed'=>'boolean']; } public function workshop(): BelongsTo { return $this->belongsTo(Workshop::class); } }
