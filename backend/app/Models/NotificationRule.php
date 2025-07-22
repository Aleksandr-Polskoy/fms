<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class NotificationRule extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'culture_id',
        'action',
        'weather_condition',
        'message',
    ];

    public function culture()
    {
        return $this->belongsTo(Culture::class);
    }
} 