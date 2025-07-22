<?php

namespace App\Http\Controllers;

use App\Models\Field;
use Illuminate\Http\Request;

class FieldController extends Controller
{
    public function index()
    {
        return Field::all();
    }

    public function show($id)
    {
        return Field::findOrFail($id);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100',
            'description' => 'nullable|string',
            'area' => 'nullable|numeric',
            'coordinates' => 'nullable|string',
            'photo' => 'nullable|string',
        ]);
        $field = Field::create($validated);
        return response()->json($field, 201);
    }

    public function update(Request $request, $id)
    {
        $field = Field::findOrFail($id);
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:100',
            'description' => 'nullable|string',
            'area' => 'nullable|numeric',
            'coordinates' => 'nullable|string',
            'photo' => 'nullable|string',
        ]);
        $field->update($validated);
        return response()->json($field);
    }

    public function destroy($id)
    {
        $field = Field::findOrFail($id);
        $field->delete();
        return response()->json(null, 204);
    }
} 