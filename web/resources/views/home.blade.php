@extends('layouts.app')

@section('title', config('app.name').' · Estado técnico')

@section('content')
    <div
        class="mx-auto max-w-6xl px-5 py-12 sm:px-8 sm:py-16"
        data-connectivity
        data-health-url="{{ $healthUrl }}"
        data-database-url="{{ $databaseUrl }}"
    >
        <section class="grid items-end gap-10 lg:grid-cols-[1.35fr_0.65fr]">
            <div class="max-w-3xl">
                <p class="mb-5 inline-flex items-center gap-2 rounded-full border border-slate-900/10 bg-white/80 px-3 py-1 text-xs font-semibold uppercase tracking-[0.16em] text-slate-600 shadow-sm">
                    <span class="size-1.5 rounded-full bg-amber-500"></span>
                    Hito M02 · Demostración local
                </p>
                <h1 class="text-balance text-4xl font-semibold tracking-[-0.04em] text-slate-950 sm:text-6xl">
                    Sistema de Gestión de Mantenimiento de Vehículos
                </h1>
                <p class="mt-6 max-w-2xl text-pretty text-base leading-7 text-slate-600 sm:text-lg">
                    Base web y API REST conectadas a PostgreSQL, preparadas para la integración técnica con Flutter en la EDT 3.4.
                </p>
            </div>

            <aside class="rounded-3xl border border-slate-900/10 bg-slate-950 p-6 text-white shadow-2xl shadow-slate-950/15">
                <p class="text-xs font-semibold uppercase tracking-[0.18em] text-teal-300">Alcance actual</p>
                <ul class="mt-5 grid gap-3 text-sm text-slate-300">
                    <li class="flex gap-3"><span class="mt-1 size-2 shrink-0 rounded-full bg-teal-400"></span>API técnica versionada en JSON</li>
                    <li class="flex gap-3"><span class="mt-1 size-2 shrink-0 rounded-full bg-teal-400"></span>Persistencia Eloquent en PostgreSQL</li>
                    <li class="flex gap-3"><span class="mt-1 size-2 shrink-0 rounded-full bg-teal-400"></span>Validaciones y pruebas automatizadas</li>
                </ul>
                <p class="mt-6 border-t border-white/10 pt-5 text-xs leading-5 text-slate-400">No incluye aún autenticación avanzada ni módulos de negocio de hitos posteriores.</p>
            </aside>
        </section>

        <section class="mt-14" aria-labelledby="estado-heading">
            <div class="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
                <div>
                    <p class="text-xs font-semibold uppercase tracking-[0.16em] text-teal-700">Comprobación en vivo</p>
                    <h2 id="estado-heading" class="mt-2 text-2xl font-semibold tracking-tight text-slate-950">Estado de la integración</h2>
                </div>
                <button type="button" data-check-reload class="w-fit rounded-xl border border-slate-300 bg-white px-4 py-2 text-sm font-semibold text-slate-700 shadow-sm transition hover:border-slate-400 hover:bg-slate-50 focus:outline-none focus:ring-2 focus:ring-teal-600 focus:ring-offset-2">
                    Volver a comprobar
                </button>
            </div>

            <div class="mt-6 grid gap-4 md:grid-cols-3">
                <article class="rounded-2xl border border-slate-900/10 bg-white p-5 shadow-sm">
                    <div class="flex items-center justify-between gap-4">
                        <span class="text-sm font-semibold text-slate-950">Laravel Web</span>
                        <span class="inline-flex items-center gap-2 rounded-full bg-emerald-50 px-2.5 py-1 text-xs font-semibold text-emerald-700">
                            <span class="size-1.5 rounded-full bg-emerald-500"></span>Operativo
                        </span>
                    </div>
                    <p class="mt-6 text-sm leading-6 text-slate-500">Esta vista Blade fue renderizada correctamente por el backend.</p>
                </article>

                <article class="rounded-2xl border border-slate-900/10 bg-white p-5 shadow-sm">
                    <div class="flex items-center justify-between gap-4">
                        <span class="text-sm font-semibold text-slate-950">API REST</span>
                        <span data-status-target="api" class="inline-flex items-center gap-2 rounded-full bg-amber-50 px-2.5 py-1 text-xs font-semibold text-amber-700">
                            <span class="size-1.5 rounded-full bg-amber-500"></span>Verificando
                        </span>
                    </div>
                    <p class="mt-6 text-sm leading-6 text-slate-500">Servicio: <strong data-service-name class="font-semibold text-slate-700">mantenimiento-vehiculos-api</strong></p>
                </article>

                <article class="rounded-2xl border border-slate-900/10 bg-white p-5 shadow-sm">
                    <div class="flex items-center justify-between gap-4">
                        <span class="text-sm font-semibold text-slate-950">PostgreSQL</span>
                        <span data-status-target="database" class="inline-flex items-center gap-2 rounded-full bg-amber-50 px-2.5 py-1 text-xs font-semibold text-amber-700">
                            <span class="size-1.5 rounded-full bg-amber-500"></span>Verificando
                        </span>
                    </div>
                    <p class="mt-6 text-sm leading-6 text-slate-500">Consulta técnica de solo lectura, disponible únicamente en entorno local.</p>
                </article>
            </div>
        </section>

        <section class="mt-14 grid gap-6 lg:grid-cols-[1.2fr_0.8fr]" aria-labelledby="endpoints-heading">
            <article class="overflow-hidden rounded-3xl border border-slate-900/10 bg-white shadow-sm">
                <div class="border-b border-slate-900/8 px-6 py-5">
                    <p class="text-xs font-semibold uppercase tracking-[0.16em] text-teal-700">Contrato técnico provisional</p>
                    <h2 id="endpoints-heading" class="mt-2 text-xl font-semibold text-slate-950">Endpoints disponibles</h2>
                </div>
                <div class="divide-y divide-slate-900/8">
                    <a href="{{ $healthUrl }}" target="_blank" rel="noreferrer" class="group flex items-center gap-4 px-6 py-5 transition hover:bg-slate-50">
                        <span class="rounded-lg bg-emerald-100 px-2 py-1 text-[0.7rem] font-bold text-emerald-800">GET</span>
                        <code class="min-w-0 flex-1 truncate text-sm text-slate-700">/api/health</code>
                        <span class="text-sm text-slate-400 transition group-hover:translate-x-0.5 group-hover:text-slate-700">Abrir →</span>
                    </a>
                    @if ($databaseUrl)
                        <a href="{{ $databaseUrl }}" target="_blank" rel="noreferrer" class="group flex items-center gap-4 px-6 py-5 transition hover:bg-slate-50">
                            <span class="rounded-lg bg-emerald-100 px-2 py-1 text-[0.7rem] font-bold text-emerald-800">GET</span>
                            <code class="min-w-0 flex-1 truncate text-sm text-slate-700">/api/database</code>
                            <span class="text-sm text-slate-400 transition group-hover:translate-x-0.5 group-hover:text-slate-700">Abrir →</span>
                        </a>
                    @endif
                    <a href="{{ $vehiclesUrl }}" target="_blank" rel="noreferrer" class="group flex items-center gap-4 px-6 py-5 transition hover:bg-slate-50">
                        <span class="rounded-lg bg-emerald-100 px-2 py-1 text-[0.7rem] font-bold text-emerald-800">GET</span>
                        <code class="min-w-0 flex-1 truncate text-sm text-slate-700">/api/v1/vehicles</code>
                        <span class="text-sm text-slate-400 transition group-hover:translate-x-0.5 group-hover:text-slate-700">Abrir →</span>
                    </a>
                </div>
            </article>

            <article class="rounded-3xl border border-amber-900/10 bg-amber-50 p-6">
                <p class="text-xs font-semibold uppercase tracking-[0.16em] text-amber-800">Siguiente integración</p>
                <h2 class="mt-2 text-xl font-semibold text-slate-950">Preparado para Flutter</h2>
                <p class="mt-4 text-sm leading-6 text-slate-600">La aplicación móvil podrá consumir las mismas respuestas JSON usando la dirección adecuada para cada entorno.</p>
                <dl class="mt-6 grid gap-4 text-sm">
                    <div>
                        <dt class="font-semibold text-slate-900">Emulador Android</dt>
                        <dd class="mt-1 font-mono text-xs text-slate-600">http://10.0.2.2:8000/api</dd>
                    </div>
                    <div>
                        <dt class="font-semibold text-slate-900">Equipo local</dt>
                        <dd class="mt-1 font-mono text-xs text-slate-600">http://127.0.0.1:8000/api</dd>
                    </div>
                </dl>
            </article>
        </section>
    </div>
@endsection