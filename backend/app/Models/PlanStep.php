<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PlanStep extends Model
{
    use HasFactory;

    protected $fillable = [
        'plan_id',
        'action',
        'description',
        'photo',
        'preparation_id',
        'weather_conditions',
        'step_order',
    ];

    public function plan()
    {
        return $this->belongsTo(Plan::class);
    }

    public function preparation()
    {
        return $this->belongsTo(Preparation::class);
    }
} 