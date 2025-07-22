<?php

namespace App\Http\Controllers;

use App\Models\FieldPlan;
use App\Models\PlanStep;
use App\Models\FieldAction;
use Illuminate\Http\Request;

class FieldPlanController extends Controller
{
    public function index(Request $request)
    {
        $query = FieldPlan::with(['field', 'plan']);
        if ($request->has('field_id')) {
            $query->where('field_id', $request->field_id);
        }
        return $query->get();
    }

    public function show($id)
    {
        return FieldPlan::with(['field', 'plan'])->findOrFail($id);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'field_id' => 'required|exists:fields,id',
            'plan_id' => 'required|exists:plans,id',
            'start_date' => 'nullable|date',
        ]);
        $fieldPlan = FieldPlan::create($validated);

        // Генерируем field_actions по шагам плана
        $planSteps = PlanStep::where('plan_id', $validated['plan_id'])->orderBy('step_order')->get();
        foreach ($planSteps as $step) {
            FieldAction::create([
                'field_plan_id' => $fieldPlan->id,
                'plan_step_id' => $step->id,
                'status' => 'pending',
                'actual_date' => null,
                'photo_report' => null,
            ]);
        }

        return response()->json($fieldPlan->load(['field', 'plan']), 201);
    }

    public function update(Request $request, $id)
    {
        $fieldPlan = FieldPlan::findOrFail($id);
        $validated = $request->validate([
            'field_id' => 'sometimes|required|exists:fields,id',
            'plan_id' => 'sometimes|required|exists:plans,id',
            'start_date' => 'nullable|date',
        ]);
        $fieldPlan->update($validated);
        return response()->json($fieldPlan->load(['field', 'plan']));
    }

    public function destroy($id)
    {
        $fieldPlan = FieldPlan::findOrFail($id);
        $fieldPlan->delete();
        return response()->json(null, 204);
    }
} 