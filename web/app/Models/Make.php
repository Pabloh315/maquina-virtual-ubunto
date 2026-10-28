<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
class Make extends Model { protected $fillable = ['name']; public function vehicleModels(): HasMany { return $this->hasMany(VehicleModel::class); } public function workshopBrandAuthorizations(): HasMany { return $this->hasMany(WorkshopBrandAuthorization::class); } }
