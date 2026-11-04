<?php

namespace Tests\Feature\Http\Controllers\Api;

use App\Models\Permission;
use App\Models\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\PersonalAccessToken;
use Tests\TestCase;

class AuthControllerTest extends TestCase
{
    use RefreshDatabase;

    private function userWithPermissions(array $permissions = ['vehicles.view', 'vehicles.create']): User
    {
        $role = Role::create(['name' => 'owner']);
        foreach ($permissions as $permission) {
            $role->permissions()->attach(Permission::create(['name' => $permission]));
        }
        $user = User::factory()->create(['email' => 'owner@example.test', 'password' => 'secret-password']);
        $user->roles()->attach($role);
        return $user;
    }

    public function test_valid_credentials_return_a_token_and_public_user_data(): void
    {
        $user = $this->userWithPermissions();
        $response = $this->postJson('/api/login', ['email' => $user->email, 'password' => 'secret-password', 'device_name' => 'flutter-test']);
        $response->assertOk()
            ->assertJsonPath('user.id', $user->id)->assertJsonPath('user.role', 'owner')
            ->assertJsonPath('user.permissions.0', 'vehicles.view')->assertJsonMissingPath('user.password');
        $this->assertNotEmpty($response->json('token'));
        $this->assertDatabaseCount('personal_access_tokens', 1);
    }

    public function test_invalid_or_unknown_credentials_are_rejected_without_disclosure(): void
    {
        $this->userWithPermissions();
        foreach ([['email' => 'owner@example.test', 'password' => 'incorrecta'], ['email' => 'unknown@example.test', 'password' => 'incorrecta']] as $credentials) {
            $this->postJson('/api/login', $credentials)->assertUnauthorized()
                ->assertExactJson(['message' => 'Las credenciales proporcionadas son incorrectas.']);
        }
    }

    public function test_password_is_hashed_and_not_serialized(): void
    {
        $user = $this->userWithPermissions();
        $this->assertNotSame('secret-password', $user->password);
        $this->assertTrue(password_verify('secret-password', $user->password));
    }

    public function test_protected_endpoint_rejects_missing_or_invalid_token(): void
    {
        $this->getJson('/api/me')->assertUnauthorized();
        $this->withToken('not-a-valid-token')->getJson('/api/me')->assertUnauthorized();
    }

    public function test_user_with_permission_can_access_protected_endpoint(): void
    {
        $user = $this->userWithPermissions(['vehicles.view']);
        $token = $user->createToken('test', ['vehicles.view'])->plainTextToken;
        $this->withToken($token)->getJson('/api/access-check')->assertOk();
    }

    public function test_user_without_permission_receives_forbidden(): void
    {
        $user = $this->userWithPermissions([]);
        $token = $user->createToken('test')->plainTextToken;
        $this->withToken($token)->getJson('/api/access-check')->assertForbidden();
    }

    public function test_logout_revokes_current_token(): void
    {
        $user = $this->userWithPermissions();
        $token = $user->createToken('test')->plainTextToken;
        $this->withToken($token)->postJson('/api/logout')->assertOk();
        $this->app['auth']->forgetGuards();
        $this->withToken($token)->getJson('/api/me')->assertUnauthorized();
        $this->assertDatabaseCount('personal_access_tokens', 0);
    }

    public function test_login_validation_errors_are_json(): void
    {
        $this->postJson('/api/login', ['email' => 'not-an-email'])->assertUnprocessable()
            ->assertJsonValidationErrors(['email', 'password']);
    }

    public function test_login_attempts_are_rate_limited(): void
    {
        $this->userWithPermissions();
        for ($attempt = 0; $attempt < 5; $attempt++) {
            $this->postJson('/api/login', ['email' => 'owner@example.test', 'password' => 'incorrecta'])->assertUnauthorized();
        }
        $this->postJson('/api/login', ['email' => 'owner@example.test', 'password' => 'incorrecta'])->assertStatus(429);
    }
}
