<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Plan extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'culture_id',
        'variety_id',
        'description',
    ];

    public function culture()
    {
        return $this->belongsTo(Culture::class);
    }

    public function variety()
    {
        return $this->belongsTo(Variety::class);
    }

    public function steps()
    {
        return $this->hasMany(PlanStep::class);
    }
} 