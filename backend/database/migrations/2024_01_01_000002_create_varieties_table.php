<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('varieties', function (Blueprint $table) {
            $table->id();
            $table->foreignId('culture_id')->constrained('cultures')->onDelete('cascade');
            $table->string('name');
            $table->text('description')->nullable();
            $table->string('sowing_period')->nullable();
            $table->string('harvest_period')->nullable();
            $table->string('photo')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('varieties');
    }
}; 