<?php

namespace App\Models;

use Database\Factories\MakeFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Make extends Model
{
    /** @use HasFactory<MakeFactory> */
    use HasFactory;

    protected $fillable = ['name'];

    public function vehicleModels(): HasMany
    {
        return $this->hasMany(VehicleModel::class);
    }

    public function workshopBrandAuthorizations(): HasMany
    {
        return $this->hasMany(WorkshopBrandAuthorization::class);
    }
}
