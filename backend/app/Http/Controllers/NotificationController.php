<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use App\Models\NotificationRule;
use App\Models\WeatherData;
use App\Models\Field;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $query = Notification::with(['field', 'rule']);
        if ($request->has('field_id')) {
            $query->where('field_id', $request->field_id);
        }
        if ($request->has('date')) {
            $query->where('date', $request->date);
        }
        return $query->orderBy('date', 'desc')->get();
    }

    // Генерация уведомлений для поля на основе погодных данных и правил
    public function generate(Request $request, $fieldId)
    {
        $field = Field::findOrFail($fieldId);
        $weather = WeatherData::where('field_id', $fieldId)->get();
        $rules = NotificationRule::all();
        $notifications = [];
        foreach ($weather as $w) {
            foreach ($rules as $rule) {
                // Пример: weather_condition = "temp>25&humidity>80"
                $ok = true;
                if ($rule->weather_condition) {
                    $conds = explode('&', $rule->weather_condition);
                    foreach ($conds as $cond) {
                        if (preg_match('/temp([<>]=?)([\d.]+)/', $cond, $m)) {
                            if (!eval('return $w->temperature '.$m[1].$m[2].';')) $ok = false;
                        }
                        if (preg_match('/humidity([<>]=?)([\d.]+)/', $cond, $m)) {
                            if (!eval('return $w->humidity '.$m[1].$m[2].';')) $ok = false;
                        }
                        if (preg_match('/precip([<>]=?)([\d.]+)/', $cond, $m)) {
                            if (!eval('return $w->precipitation '.$m[1].$m[2].';')) $ok = false;
                        }
                    }
                }
                if ($ok) {
                    $notif = Notification::updateOrCreate(
                        [ 'field_id' => $fieldId, 'date' => $w->date, 'rule_id' => $rule->id ],
                        [ 'status' => 'active', 'message' => $rule->message ]
                    );
                    $notifications[] = $notif;
                }
            }
        }
        return $notifications;
    }
} 