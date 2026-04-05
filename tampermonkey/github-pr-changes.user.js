// ==UserScript==
// @name         GitHub PR → /changes + Overview Panel
// @namespace    http://tampermonkey.net/
// @version      1.1
// @description  Redirect GitHub PR URLs to /changes view and auto-open the overview panel (once per session, skips Submission PRs)
// @author       Dan Susman
// @match        https://github.com/*/*/pull/*
// @grant        none
// @run-at       document-end
// ==/UserScript==

(function () {
    'use strict';

    const PR_BASE_RE = /^https:\/\/github\.com\/[^/]+\/[^/]+\/pull\/(\d+)\/?$/;

    function prBaseUrl() {
        const m = location.href.match(/^(https:\/\/github\.com\/[^/]+\/[^/]+\/pull\/\d+)/);
        return m ? m[1] : null;
    }

    function alreadyHandled(base) {
        return sessionStorage.getItem('gh-pr-changes:' + base) === '1';
    }

    function markHandled(base) {
        sessionStorage.setItem('gh-pr-changes:' + base, '1');
    }

    function isSubmissionPR() {
        // document.title on a PR page: "Fix something · Pull Request #123 · org/repo"
        return document.title.toLowerCase().includes('submission');
    }

    function openOverviewPanel() {
        const tooltip = [...document.querySelectorAll('span[popover]')]
            .find(el => el.textContent.trim() === 'Open overview panel');
        if (!tooltip) return false;

        const btn = document.querySelector(`[aria-labelledby="${tooltip.id}"]`);
        if (btn && btn.getAttribute('aria-expanded') !== 'true') {
            btn.click();
        }
        return true;
    }

    function onChangesPage() {
        return /\/pull\/\d+\/changes/.test(location.href);
    }

    function tryOpenPanel(base) {
        if (!onChangesPage()) return;
        if (openOverviewPanel()) return;

        let attempts = 0;
        const interval = setInterval(() => {
            if (openOverviewPanel() || ++attempts >= 30) clearInterval(interval);
        }, 200);
    }

    function run() {
        const base = prBaseUrl();
        if (!base) return;
        if (alreadyHandled(base) || isSubmissionPR()) return;

        // On the base PR URL — redirect to /changes
        if (PR_BASE_RE.test(location.href)) {
            markHandled(base);
            location.replace(base + '/changes');
            return;
        }

        // Already on /changes (e.g. hard load of that URL) — just open the panel
        if (onChangesPage()) {
            markHandled(base);
            tryOpenPanel(base);
        }
    }

    run();

    document.addEventListener('turbo:load', run);

    const _pushState = history.pushState.bind(history);
    history.pushState = function (...args) {
        _pushState(...args);
        run();
    };
})();
