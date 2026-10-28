// ==UserScript==
// @name         GitHub PR Real Diffstat
// @namespace    http://tampermonkey.net/
// @version      1.1
// @description  Show a PR's +/- for real code next to GitHub's diffstat, splitting out tests, docs, and generated files, and sort changed files by lines changed
// @author       Dan Susman
// @match        https://github.com/*
// @grant        GM_xmlhttpRequest
// @grant        GM_getValue
// @grant        GM_setValue
// @grant        GM_registerMenuCommand
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
    const SORT_TOGGLE_ID = 'gh-real-diffstat-sort';
    const FALLBACK_DELAY_MS = 10000;

    let currentBase = null;
    let observer = null;
    let linesByAnchor = new Map();
    let sortEnabled = GM_getValue('sortFiles', true);

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

    function parseDiff(diff) {
        const files = [];
        let file = null;
        let inHunk = false;
        for (const line of diff.split('\n')) {
            const header = line.match(/^diff --git a\/.* b\/(.*)$/);
            if (header) {
                file = { path: header[1], add: 0, del: 0 };
                files.push(file);
                inHunk = false;
            } else if (line.startsWith('@@')) {
                inHunk = true;
            } else if (inHunk && line[0] === '+') {
                file.add++;
            } else if (inHunk && line[0] === '-') {
                file.del++;
            }
        }
        return files;
    }

    function bucketTotals(files) {
        const totals = {};
        for (const { path, add, del } of files) {
            const bucket = (totals[bucketFor(path)] ??= { add: 0, del: 0 });
            bucket.add += add;
            bucket.del += del;
        }
        return totals;
    }

    async function sha256Hex(text) {
        const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(text));
        return [...new Uint8Array(digest)].map(b => b.toString(16).padStart(2, '0')).join('');
    }

    // GitHub anchors each file's diff at #diff-<sha256 of its path>.
    async function mapLinesByAnchor(files) {
        return new Map(await Promise.all(files.map(async f => [`diff-${await sha256Hex(f.path)}`, f.add + f.del])));
    }

    function fileList() {
        const first = document.querySelector('[class*="diffEntry__"]');
        const list = first?.parentElement;
        if (!list) return null;
        return { list, entries: [...list.children].filter(child => child.matches('[class*="diffEntry__"]')) };
    }

    function anchorOf(entry) {
        return [...entry.querySelectorAll('[id^="diff-"]')].find(el => /^diff-[0-9a-f]{64}$/.test(el.id))?.id;
    }

    // Reorders visually with CSS order so React's own DOM order stays untouched.
    function applyFileOrder() {
        const found = fileList();
        if (!found) return;

        const ranked = found.entries
            .map((entry, index) => ({ entry, index, lines: linesByAnchor.get(anchorOf(entry)) ?? Infinity }))
            .sort((a, b) => a.lines - b.lines || a.index - b.index);
        ranked.forEach(({ entry }, rank) => {
            entry.style.order = rank;
        });

        const entrySet = new Set(found.entries);
        let afterFirstEntry = false;
        for (const child of found.list.children) {
            if (entrySet.has(child)) {
                afterFirstEntry = true;
            } else {
                child.style.order = afterFirstEntry ? ranked.length : -1;
            }
        }
    }

    function clearFileOrder() {
        for (const child of fileList()?.list.children ?? []) child.style.order = '';
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

    function styleSortToggle(button) {
        button.className = sortEnabled ? 'f6 fgColor-accent text-bold' : 'f6 fgColor-muted';
        button.textContent = sortEnabled ? 'sorted by size' : 'sort by size';
        button.setAttribute('aria-pressed', String(sortEnabled));
    }

    function makeSortToggle() {
        const button = document.createElement('button');
        button.id = SORT_TOGGLE_ID;
        button.type = 'button';
        button.title = 'Sort files by lines changed, fewest first';
        button.style.cssText = 'background: none; border: 0; padding: 0; cursor: pointer;';
        button.addEventListener('click', toggleSort);
        styleSortToggle(button);
        return button;
    }

    function makeStats(totals) {
        const stats = document.createElement('span');
        stats.className = 'd-flex flex-column flex-items-end';
        stats.title = DISPLAY_ORDER
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
            stats.append(row);
        }
        return stats;
    }

    function makeBadge(totals, showStats) {
        const badge = document.createElement('span');
        badge.id = BADGE_ID;
        badge.className = 'd-flex flex-items-start gap-2';
        badge.append(makeSortToggle());
        if (showStats) badge.append(makeStats(totals));
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

    function placeBadge(totals, showStats, start) {
        if (document.getElementById(BADGE_ID)) return;

        const row = findDiffstatRow();
        if (row) {
            const badge = makeBadge(totals, showStats);
            badge.style.cssText = 'position: absolute; right: 0; bottom: 100%; margin-bottom: 2px; white-space: nowrap;';
            row.style.position = 'relative';
            row.append(badge);
        } else if (Date.now() - start > FALLBACK_DELAY_MS) {
            console.warn('GitHub PR Real Diffstat: no "Lines changed:" label found, using corner badge');
            placeFallback(makeBadge(totals, showStats));
        }
    }

    function watch(totals, showStats) {
        const start = Date.now();
        let scheduled = false;

        function update() {
            scheduled = false;
            if (sortEnabled) applyFileOrder();
            placeBadge(totals, showStats, start);
        }

        update();
        observer = new MutationObserver(() => {
            if (scheduled) return;
            scheduled = true;
            requestAnimationFrame(update);
        });
        observer.observe(document.body, { childList: true, subtree: true });
        setTimeout(update, FALLBACK_DELAY_MS + 100);
    }

    async function run() {
        const base = prBaseUrl();
        if (base === currentBase) return;

        currentBase = base;
        observer?.disconnect();
        document.getElementById(BADGE_ID)?.remove();
        linesByAnchor = new Map();
        if (!base) return;

        try {
            const files = parseDiff(await fetchDiff(base));
            const totals = bucketTotals(files);
            if (base !== currentBase) return;

            const anchors = await mapLinesByAnchor(files);
            if (base !== currentBase) return;

            linesByAnchor = anchors;
            const hasNonCode = Object.entries(totals).some(([name, t]) => name !== 'code' && (t.add || t.del));
            watch(totals, hasNonCode);
        } catch (error) {
            console.error('GitHub PR Real Diffstat:', error);
        }
    }

    function toggleSort() {
        sortEnabled = !sortEnabled;
        GM_setValue('sortFiles', sortEnabled);
        if (sortEnabled) applyFileOrder();
        else clearFileOrder();

        const button = document.getElementById(SORT_TOGGLE_ID);
        if (button) styleSortToggle(button);
    }

    GM_registerMenuCommand('Toggle sorting files by lines changed', toggleSort);

    run();

    document.addEventListener('turbo:load', run);
    window.addEventListener('popstate', run);

    const _pushState = history.pushState.bind(history);
    history.pushState = function (...args) {
        _pushState(...args);
        run();
    };
})();
