// ==UserScript==
// @name         GitHub PR Branch Names
// @namespace    http://tampermonkey.net/
// @version      1.1
// @description  Display branch names on GitHub PR list pages
// @author       You
// @match        https://github.com/*/*/pulls*
// @match        https://github.com/*/*/issues*
// @grant        none
// @run-at       document-end
// ==/UserScript==

(function() {
    'use strict';

    console.log('GitHub PR Branch Names script loaded');

    // Function to fetch branch name for a PR
    async function getBranchName(prUrl) {
        try {
            const response = await fetch(prUrl);
            const html = await response.text();
            const parser = new DOMParser();
            const doc = parser.parseFromString(html, 'text/html');

            // Find the branch name element
            const branchElement = doc.querySelector('.head-ref');
            return branchElement ? branchElement.textContent.trim() : null;
        } catch (error) {
            console.error('Error fetching branch name:', error);
            return null;
        }
    }

    // Function to add branch name to a PR row
    async function addBranchToRow(row) {
        // Skip if already processed
        if (row.dataset.branchAdded) return;
        row.dataset.branchAdded = 'true';

        // Find the PR link
        const prLink = row.querySelector('.js-navigation-open');
        if (!prLink) return;

        const prUrl = prLink.href;
        const branchName = await getBranchName(prUrl);

        if (branchName) {
            // Find the title element to add branch after
            const titleElement = row.querySelector('.markdown-title');
            if (titleElement) {
                // Create branch badge
                const branchBadge = document.createElement('span');
                branchBadge.className = 'IssueLabel ml-1';
                branchBadge.style.cssText = `
                    background-color: #0969da;
                    color: white;
                    padding: 2px 7px;
                    border-radius: 12px;
                    font-size: 12px;
                    font-weight: 500;
                    display: inline-block;
                    vertical-align: middle;
                `;
                branchBadge.textContent = `🌿 ${branchName}`;
                branchBadge.title = `Branch: ${branchName}`;

                // Insert after the title link
                titleElement.parentNode.insertBefore(branchBadge, titleElement.nextSibling);
            }
        }
    }

    // Function to check if we're on a PR list page
    function isPRListPage() {
        return window.location.pathname.includes('/pulls');
    }

    // Function to process all PR rows
    function processAllPRs() {
        if (!isPRListPage()) {
            console.log('Not on PR list page, skipping');
            return;
        }

        console.log('Processing PR rows...');
        const prRows = document.querySelectorAll('.js-issue-row');
        console.log(`Found ${prRows.length} PR rows`);
        prRows.forEach(row => addBranchToRow(row));
    }

    // Initialize with a delay to ensure DOM is ready
    function initialize() {
        console.log('Initializing...');
        setTimeout(() => {
            processAllPRs();
            setupObservers();
        }, 500);
    }

    // Setup all observers
    function setupObservers() {
        // Watch for dynamic content changes
        const targetNode = document.body;
        const observer = new MutationObserver((mutations) => {
            // Check if new PR rows were added
            const hasNewRows = mutations.some(mutation => {
                return Array.from(mutation.addedNodes).some(node => {
                    return node.nodeType === 1 && (
                        node.classList?.contains('js-issue-row') ||
                        node.querySelector?.('.js-issue-row')
                    );
                });
            });

            if (hasNewRows) {
                console.log('New PR rows detected');
                processAllPRs();
            }
        });

        observer.observe(targetNode, {
            childList: true,
            subtree: true
        });

        console.log('Observer set up');
    }

    // Initial load
    initialize();

    // Listen for Turbo navigation
    document.addEventListener('turbo:load', () => {
        console.log('Turbo load event');
        initialize();
    });

    document.addEventListener('turbo:render', () => {
        console.log('Turbo render event');
        initialize();
    });

    // Listen for PJAX navigation
    document.addEventListener('pjax:end', () => {
        console.log('PJAX end event');
        initialize();
    });

    // Watch for URL changes
    let lastUrl = location.href;
    const urlObserver = new MutationObserver(() => {
        const url = location.href;
        if (url !== lastUrl) {
            console.log(`URL changed from ${lastUrl} to ${url}`);
            lastUrl = url;
            initialize();
        }
    });

    urlObserver.observe(document.querySelector('title'), {
        subtree: true,
        characterData: true,
        childList: true
    });
})();