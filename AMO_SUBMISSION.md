# Mozilla Add-ons Submission Information

## Upload files

- Add-on package:
  `dist/amo/google-search-tabs-keeper-firefox-v1.1.0-amo.zip`
- Optional source package:
  `dist/amo/google-search-tabs-keeper-v1.1.0-source.zip`

The add-on package contains `manifest.json` at the root of the ZIP archive.

## Source code question

Select **No** for "Does this add-on require source code submission?"

The distributed JavaScript and CSS files are the original human-readable source
files. This project does not use minification, obfuscation, transpilation,
bundling, code generation, or third-party JavaScript libraries.

The optional source package is provided for reviewer convenience. It contains
the same source files and the PowerShell packaging script.

## Build instructions

Requirements:

- Windows PowerShell 5.1 or PowerShell 7

Run:

```powershell
.\scripts\build-packages.ps1
```

The AMO package is generated at:

```text
dist/amo/google-search-tabs-keeper-firefox-v1.1.0-amo.zip
```

No network access, package installation, compiler, or dependency download is
required to build the package.

## Suggested listing

### Name

Google Search Tabs Keeper

### Summary

Keeps Google search category navigation available when it disappears on
Shopping and other result pages.

### Description

Google Search Tabs Keeper restores a lightweight category navigation bar when
Google hides its standard search tabs.

It preserves the current search query and provides quick links to AI Mode, All,
Shopping, Images, Short videos, Web, Flights, Videos, News, Maps, Books, and
date filters. The extension does nothing while Google's native category tabs
are visible.

No account is required. No browsing history, search query, personal data, or
analytics data is collected or transmitted.

### Categories

- Search Tools
- Other

### Support website

https://github.com/areteruhiro/google-search-tabs-keeper

### License

GNU General Public License v3.0

## Notes for reviewers

This extension only runs on Google Search result pages at `www.google.com` and
`www.google.co.jp`.

Testing:

1. Install the extension.
2. Open a Google search result.
3. Select Shopping or another result type where Google's native category tabs
   are hidden.
4. Confirm that the extension displays a replacement category navigation bar.
5. Return to a page where Google's native tabs are visible and confirm that the
   replacement bar is hidden.

The extension has no background script, no remote code, no external library,
no network request of its own, and no storage permission.
