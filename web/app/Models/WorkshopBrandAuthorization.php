<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
class WorkshopBrandAuthorization extends Model { protected $fillable = ['workshop_id','make_id','is_officially_authorized','authorization_reference','valid_until']; protected function casts(): array { return ['is_officially_authorized'=>'boolean','valid_until'=>'date']; } public function workshop(): BelongsTo { return $this->belongsTo(Workshop::class); } public function make(): BelongsTo { return $this->belongsTo(Make::class); } }
