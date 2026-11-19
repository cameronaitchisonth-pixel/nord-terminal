// Load chrome/userChrome.css and chrome/userContent.css (Nord light/dark)
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Vertical tabs in the sidebar (delete these two lines to go back to horizontal tabs)
user_pref("sidebar.revamp", true);
user_pref("sidebar.verticalTabs", true);

// Nord start page as the home page (Home button / Alt+Home)
user_pref("browser.startup.homepage", "file://@HOME@/.local/share/nord-startpage/index.html");

// Ghostty's font (Maple Mono NF) for all web page text. Pages may not pick their own fonts;
// icon fonts on Firefox's built-in allowlist still load. Delete this block to undo.
user_pref("font.name.serif.x-western", "Maple Mono NF");
user_pref("font.name.sans-serif.x-western", "Maple Mono NF");
user_pref("font.name.monospace.x-western", "Maple Mono NF");
user_pref("font.name.serif.x-unicode", "Maple Mono NF");
user_pref("font.name.sans-serif.x-unicode", "Maple Mono NF");
user_pref("font.name.monospace.x-unicode", "Maple Mono NF");
user_pref("font.default.x-western", "sans-serif");
user_pref("font.default.x-unicode", "sans-serif");
user_pref("browser.display.use_document_fonts", 0);
