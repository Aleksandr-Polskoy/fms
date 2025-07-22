<?php

namespace App\Http\Controllers;

use App\Models\PlanStep;
use Illuminate\Http\Request;

class PlanStepController extends Controller
{
    public function index(Request $request)
    {
        $query = PlanStep::query();
        if ($request->has('plan_id')) {
            $query->where('plan_id', $request->plan_id);
        }
        return $query->orderBy('step_order')->get();
    }

    public function show($id)
    {
        return PlanStep::findOrFail($id);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'plan_id' => 'required|exists:plans,id',
            'action' => 'required|string|max:100',
            'description' => 'nullable|string',
            'photo' => 'nullable|string',
            'preparation_id' => 'nullable|exists:preparations,id',
            'weather_conditions' => 'nullable|string',
            'step_order' => 'nullable|integer',
        ]);
        $step = PlanStep::create($validated);
        return response()->json($step, 201);
    }

    public function update(Request $request, $id)
    {
        $step = PlanStep::findOrFail($id);
        $validated = $request->validate([
            'plan_id' => 'sometimes|required|exists:plans,id',
            'action' => 'sometimes|required|string|max:100',
            'description' => 'nullable|string',
            'photo' => 'nullable|string',
            'preparation_id' => 'nullable|exists:preparations,id',
            'weather_conditions' => 'nullable|string',
            'step_order' => 'nullable|integer',
        ]);
        $step->update($validated);
        return response()->json($step);
    }

    public function destroy($id)
    {
        $step = PlanStep::findOrFail($id);
        $step->delete();
        return response()->json(null, 204);
    }
} 