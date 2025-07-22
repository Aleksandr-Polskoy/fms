<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Preparation extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'photo',
        'usage',
    ];
} 