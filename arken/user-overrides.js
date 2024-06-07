// URL bar search
user_pref("keyword.enabled", true);                   // enabled urlbar search
user_pref("browser.search.suggest.enabled", true);    // live search suggestions
user_pref("browser.download.useDownloadDir", true);   // always download files to the System Download Directory
user_pref("browser.download.dir", "~/Downloads");     // save to System Download Directory
user_pref("browser.urlbar.suggest.searches", true);  // enables search suggestions in the url-bar

// Other
user_pref("signon.rememberSignons", false);           // disable saving passwords
user_pref("network.file.disable_unc_paths", false);   // enable UNC paths

// Personal
user_pref("extensions.pocket.enabled", false);        // disable Pocket

// Enable link prefetching
user_pref("network.prefetch-next", true);             // disable link prefetching
