<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FieldPlan extends Model
{
    use HasFactory;

    protected $fillable = [
        'field_id',
        'plan_id',
        'start_date',
    ];

    public function field()
    {
        return $this->belongsTo(Field::class);
    }

    public function plan()
    {
        return $this->belongsTo(Plan::class);
    }

    public function actions()
    {
        return $this->hasMany(FieldAction::class);
    }
} 