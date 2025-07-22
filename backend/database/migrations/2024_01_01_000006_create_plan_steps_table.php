<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('plan_steps', function (Blueprint $table) {
            $table->id();
            $table->foreignId('plan_id')->constrained('plans')->onDelete('cascade');
            $table->string('action');
            $table->text('description')->nullable();
            $table->string('photo')->nullable();
            $table->foreignId('preparation_id')->nullable()->constrained('preparations')->onDelete('set null');
            $table->text('weather_conditions')->nullable();
            $table->integer('step_order')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('plan_steps');
    }
}; 