<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(Request $request): JsonResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'email:rfc', 'max:255'],
            'password' => ['required', 'string'],
            'device_name' => ['nullable', 'string', 'max:100'],
        ]);
        $user = User::query()->where('email', $credentials['email'])->first();
        if (! $user || ! Hash::check($credentials['password'], $user->password)) {
            return response()->json(['message' => 'Las credenciales proporcionadas son incorrectas.'], 401);
        }
        $permissions = $user->permissionNames();
        $token = $user->createToken($credentials['device_name'] ?? 'api-client', $permissions);
        return response()->json([
            'message' => 'Inicio de sesión exitoso.',
            'user' => $this->publicUser($user, $permissions),
            'token' => $token->plainTextToken,
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->user();
        return response()->json(['user' => $this->publicUser($user, $user->permissionNames())]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()?->delete();
        return response()->json(['message' => 'Sesión cerrada correctamente.']);
    }

    /** @param array<int, string> $permissions */
    private function publicUser(User $user, array $permissions): array
    {
        $roles = $user->roles()->pluck('name')->values()->all();
        return ['id' => $user->id, 'name' => $user->name, 'email' => $user->email,
            'role' => $roles[0] ?? null, 'roles' => $roles, 'permissions' => $permissions];
    }
}

