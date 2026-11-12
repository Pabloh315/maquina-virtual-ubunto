<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreMaintenanceHistoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /** @return array<string, ValidationRule|array<mixed>|string> */
    public function rules(): array
    {
        return [
            'service_catalog_id' => ['nullable', 'integer', Rule::exists('service_catalogs', 'id')],
            'service_type' => ['required', 'string', 'max:120'],
            'description' => ['required', 'string', 'max:255'],
            'performed_on' => ['nullable', 'date'],
            'mileage' => ['nullable', 'integer', 'min:0'],
            'notes' => ['nullable', 'string'],
            'provider' => ['nullable', 'string', 'max:140'],
            'cost' => ['nullable', 'numeric', 'min:0'],
        ];
    }

    /** @return array<string, string> */
    public function messages(): array
    {
        return [
            'service_type.required' => 'El tipo de mantenimiento es obligatorio.',
            'description.required' => 'La descripciÃ³n del antecedente es obligatoria.',
            'mileage.min' => 'El kilometraje no puede ser negativo.',
            'cost.min' => 'El costo no puede ser negativo.',
            'service_catalog_id.exists' => 'El servicio seleccionado no existe.',
        ];
    }
}
