<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use App\Models\WeatherData;
use App\Models\Field;

class WeatherController extends Controller
{
    // Получить прогноз погоды по координатам поля (на 5 дней)
    public function forecast(Request $request, $fieldId)
    {
        $field = Field::findOrFail($fieldId);
        if (!$field->coordinates) {
            return response()->json(['error' => 'No coordinates for field'], 400);
        }
        [$lat, $lon] = explode(',', $field->coordinates);
        $apiKey = env('OPENWEATHER_API_KEY');
        $url = "https://api.openweathermap.org/data/2.5/forecast?lat={$lat}&lon={$lon}&units=metric&lang=ru&appid={$apiKey}";

        // Проверяем кэш (weather_data)
        $today = date('Y-m-d');
        $cached = WeatherData::where('field_id', $fieldId)
            ->where('date', '>=', $today)
            ->orderBy('date')
            ->get();
        if ($cached->count() >= 5) {
            return $cached;
        }

        // Получаем с OpenWeatherMap
        $response = Http::get($url);
        if (!$response->ok()) {
            return response()->json(['error' => 'Weather API error'], 500);
        }
        $data = $response->json();
        $result = [];
        foreach ($data['list'] as $item) {
            $date = substr($item['dt_txt'], 0, 10);
            // Сохраняем только дневные значения (12:00)
            if (strpos($item['dt_txt'], '12:00:00') !== false) {
                $weather = WeatherData::updateOrCreate(
                    [ 'field_id' => $fieldId, 'date' => $date ],
                    [
                        'temperature' => $item['main']['temp'],
                        'humidity' => $item['main']['humidity'],
                        'precipitation' => $item['pop'] * 100,
                        'weather_icon' => $item['weather'][0]['icon'] ?? null,
                    ]
                );
                $result[] = $weather;
            }
        }
        return $result;
    }
} 