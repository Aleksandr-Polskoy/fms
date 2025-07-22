<?php

namespace App\Http\Controllers;

use App\Models\Plan;
use Illuminate\Http\Request;

class PlanController extends Controller
{
    public function index()
    {
        return Plan::with(['culture', 'variety', 'steps'])->get();
    }

    public function show($id)
    {
        return Plan::with(['culture', 'variety', 'steps'])->findOrFail($id);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100',
            'culture_id' => 'required|exists:cultures,id',
            'variety_id' => 'nullable|exists:varieties,id',
            'description' => 'nullable|string',
        ]);
        $plan = Plan::create($validated);
        return response()->json($plan->load(['culture', 'variety', 'steps']), 201);
    }

    public function update(Request $request, $id)
    {
        $plan = Plan::findOrFail($id);
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:100',
            'culture_id' => 'sometimes|required|exists:cultures,id',
            'variety_id' => 'nullable|exists:varieties,id',
            'description' => 'nullable|string',
        ]);
        $plan->update($validated);
        return response()->json($plan->load(['culture', 'variety', 'steps']));
    }

    public function destroy($id)
    {
        $plan = Plan::findOrFail($id);
        $plan->delete();
        return response()->json(null, 204);
    }
} 