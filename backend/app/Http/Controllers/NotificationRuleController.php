<?php

namespace App\Http\Controllers;

use App\Models\NotificationRule;
use Illuminate\Http\Request;

class NotificationRuleController extends Controller
{
    public function index()
    {
        return NotificationRule::with('culture')->get();
    }

    public function show($id)
    {
        return NotificationRule::with('culture')->findOrFail($id);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100',
            'description' => 'nullable|string',
            'culture_id' => 'nullable|exists:cultures,id',
            'action' => 'nullable|string',
            'weather_condition' => 'nullable|string',
            'message' => 'required|string',
        ]);
        $rule = NotificationRule::create($validated);
        return response()->json($rule->load('culture'), 201);
    }

    public function update(Request $request, $id)
    {
        $rule = NotificationRule::findOrFail($id);
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:100',
            'description' => 'nullable|string',
            'culture_id' => 'nullable|exists:cultures,id',
            'action' => 'nullable|string',
            'weather_condition' => 'nullable|string',
            'message' => 'required|string',
        ]);
        $rule->update($validated);
        return response()->json($rule->load('culture'));
    }

    public function destroy($id)
    {
        $rule = NotificationRule::findOrFail($id);
        $rule->delete();
        return response()->json(null, 204);
    }
} 