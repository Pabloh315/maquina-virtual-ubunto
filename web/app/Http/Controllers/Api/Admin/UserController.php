<?php
namespace App\Http\Controllers\Api\Admin;
use App\Http\Controllers\Controller; use App\Models\Role; use App\Models\User; use Illuminate\Http\Request; use Illuminate\Support\Facades\DB;
class UserController extends Controller {
 private function data(User $u): array { return ['id'=>$u->id,'name'=>$u->name,'email'=>$u->email,'phone'=>$u->phone,'roles'=>$u->roles()->pluck('name')->values()]; }
 public function index(Request $r) { $q=User::query()->with('roles')->orderBy('id'); if($r->filled('search')) $q->where(fn($x)=>$x->where('name','ilike','%'.$r->search.'%')->orWhere('email','ilike','%'.$r->search.'%')); return response()->json($q->paginate(15)->through(fn($u)=>$this->data($u))); }
 public function show(User $user) { return response()->json(['user'=>$this->data($user)]); }
 public function store(Request $r) { $d=$r->validate(['name'=>['required','string','max:255'],'email'=>['required','email','max:255','unique:users,email'],'password'=>['required','string','min:12','confirmed'],'role_id'=>['required','integer','exists:roles,id'],'phone'=>['nullable','string','max:30']]); $user=DB::transaction(function()use($d){$u=User::create(collect($d)->except('role_id')->all());$u->roles()->sync([$d['role_id']]);return $u;}); return response()->json(['user'=>$this->data($user)],201); }
 public function update(Request $r,User $user) { $d=$r->validate(['name'=>['sometimes','required','string','max:255'],'email'=>['sometimes','required','email','max:255','unique:users,email,'.$user->id],'phone'=>['nullable','string','max:30']]); $user->update($d); return response()->json(['user'=>$this->data($user)]); }
 public function updateRole(Request $r,User $user) { $d=$r->validate(['role_id'=>['required','integer','exists:roles,id']]); $user->roles()->sync([$d['role_id']]); return response()->json(['user'=>$this->data($user)]); }
}