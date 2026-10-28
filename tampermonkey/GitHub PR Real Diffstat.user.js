// ==UserScript==
// @name         GitHub PR Real Diffstat
// @namespace    http://tampermonkey.net/
// @version      1.0
// @description  Show a PR's +/- for real code next to GitHub's diffstat, splitting out tests, docs, and generated files
// @author       Dan Susman
// @match        https://github.com/*
// @grant        GM_xmlhttpRequest
// @connect      github.com
// @connect      patch-diff.githubusercontent.com
// @run-at       document-end
// ==/UserScript==

(function () {
    'use strict';

    const BUCKETS = [
        {
            name: 'generated',
            patterns: [
                /\.xcstrings$/,
                /(^|\/)Generated\//,
                /\/res\/values[^/]*\/strings\.xml$/,
                /(^|\/)(package-lock\.json|yarn\.lock|pnpm-lock\.yaml|Podfile\.lock|Package\.resolved)$/,
                /(^|\/)__Snapshots__\//,
                /\.snap$/,
            ],
        },
        {
            name: 'tests',
            patterns: [
                /(^|\/)(UnitTests|UITests|__tests__|tests?|androidTest)\//,
                /Tests?\.(swift|kt|m)$/,
                /\.(test|spec)\.[jt]sx?$/,
            ],
        },
        { name: 'docs', patterns: [/^docs\//] },
    ];
    const DISPLAY_ORDER = ['code', 'tests', 'docs', 'generated'];
    const SQUARE_CLASSES = { addition: 'addition__3w3cWj', deletion: 'deletion__wmC-SA', neutral: 'neutral__T4nd7Z' };
    const BADGE_ID = 'gh-real-diffstat';
    const FALLBACK_DELAY_MS = 10000;

    let currentBase = null;
    let observer = null;

    function prBaseUrl() {
        const m = location.href.match(/^(https:\/\/github\.com\/[^/]+\/[^/]+\/pull\/\d+)/);
        return m ? m[1] : null;
    }

    function bucketFor(path) {
        const bucket = BUCKETS.find(b => b.patterns.some(re => re.test(path)));
        return bucket ? bucket.name : 'code';
    }

    function fetchDiff(base) {
        return new Promise((resolve, reject) => {
            GM_xmlhttpRequest({
                method: 'GET',
                url: base + '.diff',
                timeout: 15000,
                onload: r => (r.status === 200 ? resolve(r.responseText) : reject(new Error(`HTTP ${r.status} from ${r.finalUrl}`))),
                onerror: r => reject(new Error(`request failed: ${r.error ?? r.statusText}`)),
                ontimeout: () => reject(new Error('request timed out')),
            });
        });
    }

    function countLines(diff) {
        const totals = {};
        let bucket = null;
        let inHunk = false;
        for (const line of diff.split('\n')) {
            const header = line.match(/^diff --git a\/.* b\/(.*)$/);
            if (header) {
                bucket = bucketFor(header[1]);
                totals[bucket] ??= { add: 0, del: 0 };
                inHunk = false;
            } else if (line.startsWith('@@')) {
                inHunk = true;
            } else if (inHunk && line[0] === '+') {
                totals[bucket].add++;
            } else if (inHunk && line[0] === '-') {
                totals[bucket].del++;
            }
        }
        return totals;
    }

    function fmt(n) {
        return n.toLocaleString('en-US');
    }

    function span(className, text) {
        const el = document.createElement('span');
        el.className = className;
        el.textContent = text;
        return el;
    }

    function squareClass(kind) {
        return document.querySelector(`[data-testid="${kind} diffstat"]`)?.className ?? `diffSquare__kZ1s3g ${SQUARE_CLASSES[kind]}`;
    }

    function squares({ add, del }) {
        const total = add + del;
        const addCount = total ? Math.floor((add / total) * 5) : 0;
        const delCount = total ? Math.floor((del / total) * 5) : 0;
        const kinds = [
            ...Array(addCount).fill('addition'),
            ...Array(delCount).fill('deletion'),
            ...Array(5 - addCount - delCount).fill('neutral'),
        ];

        const row = document.createElement('div');
        row.className = 'd-flex';
        for (const kind of kinds) {
            const square = document.createElement('div');
            square.className = squareClass(kind);
            row.append(square);
        }
        return row;
    }

    function makeBadge(totals) {
        const badge = document.createElement('span');
        badge.id = BADGE_ID;
        badge.className = 'd-flex flex-column flex-items-end';
        badge.title = DISPLAY_ORDER
            .filter(name => totals[name])
            .map(name => `${name}: +${fmt(totals[name].add)} -${fmt(totals[name].del)}`)
            .join('\n');

        for (const name of ['code', 'tests']) {
            const { add, del } = totals[name] ?? { add: 0, del: 0 };
            if (name !== 'code' && !add && !del) continue;
            const row = document.createElement('div');
            row.className = 'd-flex flex-items-center gap-1';
            row.append(
                span('f6 fgColor-muted', name),
                span('f6 fgColor-success text-bold', `+${fmt(add)}`),
                span('f6 fgColor-danger text-bold', `-${fmt(del)}`),
                squares({ add, del }),
            );
            badge.append(row);
        }
        return badge;
    }

    function findDiffstatRow() {
        const label = [...document.querySelectorAll('.sr-only')].find(el => el.textContent.startsWith('Lines changed:'));
        return label?.parentElement ?? null;
    }

    function placeFallback(badge) {
        badge.style.cssText += `
            position: fixed; right: 16px; bottom: 16px; z-index: 100; margin: 0; padding: 4px 8px;
            border: 1px solid var(--borderColor-default, #3d444d); border-radius: 6px;
            background: var(--bgColor-default, #0d1117);
        `;
        document.body.append(badge);
    }

    function show(totals) {
        const start = Date.now();
        let scheduled = false;

        function place() {
            scheduled = false;
            if (document.getElementById(BADGE_ID)) return;

            const row = findDiffstatRow();
            if (row) {
                const badge = makeBadge(totals);
                badge.style.cssText = 'position: absolute; right: 0; bottom: 100%; margin-bottom: 2px; white-space: nowrap;';
                row.style.position = 'relative';
                row.append(badge);
            } else if (Date.now() - start > FALLBACK_DELAY_MS) {
                console.warn('GitHub PR Real Diffstat: no "Lines changed:" label found, using corner badge');
                placeFallback(makeBadge(totals));
            }
        }

        place();
        observer = new MutationObserver(() => {
            if (scheduled) return;
            scheduled = true;
            requestAnimationFrame(place);
        });
        observer.observe(document.body, { childList: true, subtree: true });
        setTimeout(place, FALLBACK_DELAY_MS + 100);
    }

    async function run() {
        const base = prBaseUrl();
        if (base === currentBase) return;

        currentBase = base;
        observer?.disconnect();
        document.getElementById(BADGE_ID)?.remove();
        if (!base) return;

        console.info('GitHub PR Real Diffstat: fetching', base + '.diff');
        try {
            const totals = countLines(await fetchDiff(base));
            console.info('GitHub PR Real Diffstat:', base, totals);
            const hasNonCode = Object.entries(totals).some(([name, t]) => name !== 'code' && (t.add || t.del));
            if (base === currentBase && hasNonCode) show(totals);
        } catch (error) {
            console.error('GitHub PR Real Diffstat:', error);
        }
    }

    run();

    document.addEventListener('turbo:load', run);
    window.addEventListener('popstate', run);

    const _pushState = history.pushState.bind(history);
    history.pushState = function (...args) {
        _pushState(...args);
        run();
    };
})();
