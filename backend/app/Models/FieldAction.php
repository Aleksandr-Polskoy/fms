<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FieldAction extends Model
{
    use HasFactory;

    protected $fillable = [
        'field_plan_id',
        'plan_step_id',
        'status',
        'actual_date',
        'photo_report',
    ];

    public function fieldPlan()
    {
        return $this->belongsTo(FieldPlan::class);
    }

    public function planStep()
    {
        return $this->belongsTo(PlanStep::class);
    }
} 