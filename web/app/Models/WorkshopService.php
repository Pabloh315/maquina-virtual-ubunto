<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
class WorkshopService extends Model { protected $fillable = ['workshop_id','service_catalog_id','base_price','is_active']; protected function casts(): array { return ['base_price'=>'decimal:2','is_active'=>'boolean']; } public function workshop(): BelongsTo { return $this->belongsTo(Workshop::class); } public function serviceCatalog(): BelongsTo { return $this->belongsTo(ServiceCatalog::class); } }
