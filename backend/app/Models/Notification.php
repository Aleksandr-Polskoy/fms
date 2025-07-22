<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Notification extends Model
{
    use HasFactory;

    protected $fillable = [
        'field_id',
        'date',
        'rule_id',
        'status',
        'message',
    ];

    public function field()
    {
        return $this->belongsTo(Field::class);
    }

    public function rule()
    {
        return $this->belongsTo(NotificationRule::class, 'rule_id');
    }
} 