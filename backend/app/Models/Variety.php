<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Variety extends Model
{
    use HasFactory;

    protected $fillable = [
        'culture_id',
        'name',
        'description',
        'sowing_period',
        'harvest_period',
        'photo',
    ];

    public function culture()
    {
        return $this->belongsTo(Culture::class);
    }
} 