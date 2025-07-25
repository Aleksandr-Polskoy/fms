<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Culture extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'photo',
    ];

    public function varieties()
    {
        return $this->hasMany(Variety::class);
    }
} 