const connectivity = document.querySelector('[data-connectivity]');

if (connectivity) {
    const statusClasses = {
        checking: 'inline-flex items-center gap-2 rounded-full bg-amber-50 px-2.5 py-1 text-xs font-semibold text-amber-700',
        ok: 'inline-flex items-center gap-2 rounded-full bg-emerald-50 px-2.5 py-1 text-xs font-semibold text-emerald-700',
        error: 'inline-flex items-center gap-2 rounded-full bg-rose-50 px-2.5 py-1 text-xs font-semibold text-rose-700',
        unavailable: 'inline-flex items-center gap-2 rounded-full bg-slate-100 px-2.5 py-1 text-xs font-semibold text-slate-600',
    };

    const dotClasses = {
        checking: 'size-1.5 rounded-full bg-amber-500',
        ok: 'size-1.5 rounded-full bg-emerald-500',
        error: 'size-1.5 rounded-full bg-rose-500',
        unavailable: 'size-1.5 rounded-full bg-slate-400',
    };

    const labels = {
        checking: 'Verificando',
        ok: 'Operativo',
        error: 'Sin conexión',
        unavailable: 'No disponible',
    };

    const setStatus = (targetName, state) => {
        const target = connectivity.querySelector(`[data-status-target="${targetName}"]`);

        if (!target) {
            return;
        }

        target.className = statusClasses[state];
        target.replaceChildren();

        const dot = document.createElement('span');
        dot.className = dotClasses[state];
        target.append(dot, document.createTextNode(labels[state]));
    };

    const checkEndpoint = async (url, targetName) => {
        if (!url) {
            setStatus(targetName, 'unavailable');
            return;
        }

        setStatus(targetName, 'checking');

        try {
            const response = await fetch(url, {
                headers: { Accept: 'application/json' },
                cache: 'no-store',
            });
            const payload = await response.json();

            if (!response.ok || payload.status !== 'ok') {
                throw new Error('El servicio respondió con un estado no operativo.');
            }

            if (targetName === 'api' && payload.service) {
                const serviceName = connectivity.querySelector('[data-service-name]');
                if (serviceName) {
                    serviceName.textContent = payload.service;
                }
            }

            setStatus(targetName, 'ok');
        } catch {
            setStatus(targetName, 'error');
        }
    };

    const runChecks = () => {
        void checkEndpoint(connectivity.dataset.healthUrl, 'api');
        void checkEndpoint(connectivity.dataset.databaseUrl, 'database');
    };

    connectivity.querySelector('[data-check-reload]')?.addEventListener('click', runChecks);
    runChecks();
}