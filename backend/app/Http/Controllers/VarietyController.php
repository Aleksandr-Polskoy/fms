<?php

namespace App\Http\Controllers;

use App\Models\Variety;
use Illuminate\Http\Request;

class VarietyController extends Controller
{
    public function index(Request $request)
    {
        // Фильтрация по culture_id, если передан
        $query = Variety::query();
        if ($request->has('culture_id')) {
            $query->where('culture_id', $request->culture_id);
        }
        return $query->get();
    }

    public function show($id)
    {
        return Variety::findOrFail($id);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'culture_id' => 'required|exists:cultures,id',
            'name' => 'required|string|max:100',
            'description' => 'nullable|string',
            'sowing_period' => 'nullable|string',
            'harvest_period' => 'nullable|string',
            'photo' => 'nullable|string',
        ]);
        $variety = Variety::create($validated);
        return response()->json($variety, 201);
    }

    public function update(Request $request, $id)
    {
        $variety = Variety::findOrFail($id);
        $validated = $request->validate([
            'culture_id' => 'sometimes|required|exists:cultures,id',
            'name' => 'sometimes|required|string|max:100',
            'description' => 'nullable|string',
            'sowing_period' => 'nullable|string',
            'harvest_period' => 'nullable|string',
            'photo' => 'nullable|string',
        ]);
        $variety->update($validated);
        return response()->json($variety);
    }

    public function destroy($id)
    {
        $variety = Variety::findOrFail($id);
        $variety->delete();
        return response()->json(null, 204);
    }
} 