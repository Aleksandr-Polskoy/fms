<?php

namespace App\Http\Controllers;

use App\Models\FieldAction;
use Illuminate\Http\Request;

class FieldActionController extends Controller
{
    public function index(Request $request)
    {
        $query = FieldAction::with(['fieldPlan', 'planStep']);
        if ($request->has('field_plan_id')) {
            $query->where('field_plan_id', $request->field_plan_id);
        }
        return $query->orderBy('id')->get();
    }

    public function show($id)
    {
        return FieldAction::with(['fieldPlan', 'planStep'])->findOrFail($id);
    }

    public function update(Request $request, $id)
    {
        $fieldAction = FieldAction::findOrFail($id);
        $validated = $request->validate([
            'status' => 'sometimes|required|in:pending,done',
            'actual_date' => 'nullable|date',
            'photo_report' => 'nullable|string',
        ]);
        $fieldAction->update($validated);
        return response()->json($fieldAction->load(['fieldPlan', 'planStep']));
    }
} 