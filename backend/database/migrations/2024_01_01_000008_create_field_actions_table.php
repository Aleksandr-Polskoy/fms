<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('field_actions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('field_plan_id')->constrained('field_plans')->onDelete('cascade');
            $table->foreignId('plan_step_id')->constrained('plan_steps')->onDelete('cascade');
            $table->enum('status', ['pending', 'done'])->default('pending');
            $table->date('actual_date')->nullable();
            $table->string('photo_report')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('field_actions');
    }
}; 