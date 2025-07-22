<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WeatherData extends Model
{
    use HasFactory;

    protected $fillable = [
        'field_id',
        'date',
        'temperature',
        'humidity',
        'precipitation',
        'weather_icon',
    ];

    public function field()
    {
        return $this->belongsTo(Field::class);
    }
} 