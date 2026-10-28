<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
class Workshop extends Model { protected $fillable = ['name','tax_id','phone','email','address','appointment_capacity','is_active']; protected function casts(): array { return ['appointment_capacity'=>'integer','is_active'=>'boolean']; } public function appointments(): HasMany { return $this->hasMany(Appointment::class); } public function serviceOrders(): HasMany { return $this->hasMany(ServiceOrder::class); } }
