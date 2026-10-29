<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class StoreVehicleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'owner_id' => ['required', 'integer', Rule::exists('users', 'id')],
            'vehicle_category_id' => ['required', 'integer', Rule::exists('vehicle_categories', 'id')],
            'vehicle_model_id' => ['required', 'integer', Rule::exists('vehicle_models', 'id')],
            'license_plate' => ['required', 'string', 'max:20', Rule::unique('vehicles', 'license_plate')],
            'vin' => ['nullable', 'string', 'size:17', 'regex:/^[A-HJ-NPR-Z0-9]{17}$/', Rule::unique('vehicles', 'vin')],
            'year' => ['required', 'integer', 'min:1900', 'max:'.(now()->year + 1)],
            'color' => ['nullable', 'string', 'max:50'],
            'fuel_type' => ['nullable', 'string', 'max:30'],
            'current_mileage' => ['sometimes', 'integer', 'min:0'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'owner_id.required' => 'El propietario es obligatorio.',
            'owner_id.exists' => 'El propietario seleccionado no existe.',
            'vehicle_category_id.required' => 'La categoría es obligatoria.',
            'vehicle_category_id.exists' => 'La categoría seleccionada no existe.',
            'vehicle_model_id.required' => 'El modelo es obligatorio.',
            'vehicle_model_id.exists' => 'El modelo seleccionado no existe.',
            'license_plate.required' => 'La placa es obligatoria.',
            'license_plate.unique' => 'La placa ya está registrada.',
            'vin.size' => 'El VIN debe tener exactamente 17 caracteres.',
            'vin.regex' => 'El VIN contiene caracteres no permitidos.',
            'vin.unique' => 'El VIN ya está registrado.',
            'year.required' => 'El año es obligatorio.',
            'year.min' => 'El año no puede ser anterior a 1900.',
            'year.max' => 'El año no puede ser posterior al próximo año.',
            'current_mileage.min' => 'El kilometraje no puede ser negativo.',
        ];
    }

    protected function prepareForValidation(): void
    {
        $normalized = [];

        if ($this->has('license_plate')) {
            $normalized['license_plate'] = Str::upper(trim((string) $this->input('license_plate')));
        }

        if ($this->filled('vin')) {
            $normalized['vin'] = Str::upper(trim((string) $this->input('vin')));
        }

        $this->merge($normalized);
    }
}
