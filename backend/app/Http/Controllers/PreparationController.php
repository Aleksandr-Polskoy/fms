<?php

namespace App\Http\Controllers;

use App\Models\Preparation;
use Illuminate\Http\Request;

class PreparationController extends Controller
{
    public function index()
    {
        return Preparation::all();
    }

    public function show($id)
    {
        return Preparation::findOrFail($id);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100',
            'description' => 'nullable|string',
            'photo' => 'nullable|string',
            'usage' => 'nullable|string',
        ]);
        $preparation = Preparation::create($validated);
        return response()->json($preparation, 201);
    }

    public function update(Request $request, $id)
    {
        $preparation = Preparation::findOrFail($id);
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:100',
            'description' => 'nullable|string',
            'photo' => 'nullable|string',
            'usage' => 'nullable|string',
        ]);
        $preparation->update($validated);
        return response()->json($preparation);
    }

    public function destroy($id)
    {
        $preparation = Preparation::findOrFail($id);
        $preparation->delete();
        return response()->json(null, 204);
    }
} 