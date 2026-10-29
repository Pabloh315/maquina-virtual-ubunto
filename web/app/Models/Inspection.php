<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
class Inspection extends Model { protected $fillable = ['service_order_id','inspector_id','overall_result','observations','inspected_at']; protected function casts(): array { return ['inspected_at'=>'datetime']; } public function serviceOrder(): BelongsTo { return $this->belongsTo(ServiceOrder::class); } public function results(): HasMany { return $this->hasMany(InspectionResult::class); } }
