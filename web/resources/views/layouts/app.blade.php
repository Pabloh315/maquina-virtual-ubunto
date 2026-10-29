<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="description" content="Base técnica local del Sistema de Gestión de Mantenimiento de Vehículos">

        <title>@yield('title', config('app.name'))</title>

        @fonts

        @if (file_exists(public_path('build/manifest.json')) || file_exists(public_path('hot')))
            @vite(['resources/css/app.css', 'resources/js/app.js'])
        @endif
    </head>
    <body class="min-h-screen bg-stone-50 font-sans text-slate-900 antialiased">
        <div class="relative isolate min-h-screen overflow-hidden">
            <div class="pointer-events-none absolute inset-x-0 top-0 -z-10 h-[34rem] bg-[radial-gradient(circle_at_12%_0%,rgba(15,118,110,0.18),transparent_34%),radial-gradient(circle_at_88%_6%,rgba(245,158,11,0.16),transparent_28%)]"></div>

            <header class="border-b border-slate-900/8 bg-white/70 backdrop-blur-xl">
                <div class="mx-auto flex max-w-6xl items-center justify-between px-5 py-4 sm:px-8">
                    <a href="{{ route('home') }}" class="flex items-center gap-3" aria-label="Inicio técnico">
                        <span class="grid size-10 place-items-center rounded-xl bg-teal-700 text-sm font-bold tracking-tight text-white shadow-sm">MV</span>
                        <span>
                            <span class="block text-sm font-semibold tracking-tight text-slate-950">Mantenimiento Vehicular</span>
                            <span class="block text-xs text-slate-500">Base técnica integrada</span>
                        </span>
                    </a>
                    <span class="rounded-full border border-teal-700/15 bg-teal-50 px-3 py-1 text-xs font-semibold tracking-wide text-teal-800">EDT 3.3 · LOCAL</span>
                </div>
            </header>

            <main>
                @yield('content')
            </main>

            <footer class="mx-auto flex max-w-6xl flex-col gap-2 border-t border-slate-900/8 px-5 py-8 text-xs text-slate-500 sm:flex-row sm:items-center sm:justify-between sm:px-8">
                <p>{{ config('app.name') }}</p>
                <p>Entorno académico de demostración · Sin despliegue externo</p>
            </footer>
        </div>
    </body>
</html>