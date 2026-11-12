<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreMaintenancePlanRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:120'],
            'recommendation_source' => ['required', 'string', 'max:100'],
            'source_reference' => ['nullable', 'string'],
            'is_active' => ['sometimes', 'boolean'],
            'services' => ['required', 'array', 'min:1'],
            'services.*.service_catalog_id' => ['required', 'integer', Rule::exists('service_catalogs', 'id')],
            'services.*.interval_km' => ['nullable', 'integer', 'min:1'],
            'services.*.interval_months' => ['nullable', 'integer', 'min:1', 'max:1200'],
            'services.*.last_service_mileage' => ['nullable', 'integer', 'min:0'],
            'services.*.last_service_date' => ['nullable', 'date'],
        ];
    }

    public function after(): array
    {
        return [function (Validator $validator): void {
            foreach ($this->input('services', []) as $index => $service) {
                if (empty($service['interval_km']) && empty($service['interval_months'])) {
                    $validator->errors()->add("services.$index", 'Cada servicio debe tener al menos un intervalo por kilometraje o tiempo.');
                }
            }
        }];
    }
}