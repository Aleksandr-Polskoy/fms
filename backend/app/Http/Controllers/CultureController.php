<?php

namespace App\Http\Controllers;

use App\Models\Culture;
use Illuminate\Http\Request;

class CultureController extends Controller
{
    public function index()
    {
        return Culture::all();
    }

    public function show($id)
    {
        return Culture::findOrFail($id);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100',
            'description' => 'nullable|string',
            'photo' => 'nullable|string',
        ]);
        $culture = Culture::create($validated);
        return response()->json($culture, 201);
    }

    public function update(Request $request, $id)
    {
        $culture = Culture::findOrFail($id);
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:100',
            'description' => 'nullable|string',
            'photo' => 'nullable|string',
        ]);
        $culture->update($validated);
        return response()->json($culture);
    }

    public function destroy($id)
    {
        $culture = Culture::findOrFail($id);
        $culture->delete();
        return response()->json(null, 204);
    }
} 