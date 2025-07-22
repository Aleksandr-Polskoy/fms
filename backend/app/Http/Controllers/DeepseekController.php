<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use App\Models\Field;
use App\Models\FieldPlan;
use App\Models\Plan;
use App\Models\Variety;
use App\Models\Culture;
use App\Models\FieldAction;
use App\Models\PlanStep;
use App\Models\Preparation;

class DeepseekController extends Controller
{
    public function recommend(Request $request, $fieldId)
    {
        $field = Field::findOrFail($fieldId);
        $fieldPlan = FieldPlan::where('field_id', $fieldId)->latest()->first();
        if (!$fieldPlan) {
            return response()->json(['error' => 'Нет применённого плана для поля'], 400);
        }
        $plan = Plan::find($fieldPlan->plan_id);
        $variety = $plan && $plan->variety_id ? Variety::find($plan->variety_id) : null;
        $culture = $plan ? Culture::find($plan->culture_id) : null;
        $actions = FieldAction::where('field_plan_id', $fieldPlan->id)->with(['planStep'])->orderBy('id')->get();
        $preparations = [];
        foreach ($actions as $a) {
            if ($a->planStep && $a->planStep->preparation_id) {
                $prep = Preparation::find($a->planStep->preparation_id);
                if ($prep) $preparations[] = $prep->toArray();
            }
        }
        // Геолокация: страна, область, населённый пункт (заглушка, можно доработать через обратное геокодирование)
        $location = [
            'country' => $request->input('country', 'Россия'),
            'region' => $request->input('region', 'Московская область'),
            'locality' => $request->input('locality', 'Москва'),
            'coordinates' => $field->coordinates,
        ];
        $payload = [
            'field' => $field->toArray(),
            'location' => $location,
            'culture' => $culture ? $culture->toArray() : null,
            'variety' => $variety ? $variety->toArray() : null,
            'actions' => $actions->map(function($a) {
                return [
                    'id' => $a->id,
                    'plan_step' => $a->planStep ? $a->planStep->toArray() : null,
                    'status' => $a->status,
                    'actual_date' => $a->actual_date,
                    'photo_report' => $a->photo_report,
                ];
            }),
            'preparations' => $preparations,
        ];
        $apiKey = env('DEEPSEEK_API_KEY');
        $url = env('DEEPSEEK_API_URL', 'https://api.deepseek.com/recommend');
        $response = Http::withToken($apiKey)->post($url, $payload);
        if (!$response->ok()) {
            return response()->json(['error' => 'Deepseek API error'], 500);
        }
        return $response->json();
    }
} 