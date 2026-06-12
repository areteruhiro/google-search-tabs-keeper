(() => {
  "use strict";

  const ROOT_ID = "gstk-root";
  const NATIVE_TAB_TEXTS = new Set([
    "AI モード",
    "AI Mode",
    "すべて",
    "All",
    "ショッピング",
    "Shopping",
    "画像",
    "Images",
    "ショート動画",
    "Short videos",
    "ウェブ",
    "Web"
  ]);

  let updateTimer;
  let lastUrl = location.href;

  function currentSearch() {
    return new URL(location.href).searchParams.get("q") || "";
  }

  function searchUrl(parameters = {}) {
    const url = new URL("/search", location.origin);
    const current = new URL(location.href);
    const query = currentSearch();

    if (query) {
      url.searchParams.set("q", query);
    }

    for (const name of ["hl", "gl", "safe"]) {
      const value = current.searchParams.get(name);
      if (value) {
        url.searchParams.set(name, value);
      }
    }

    for (const [name, value] of Object.entries(parameters)) {
      if (value !== null && value !== undefined && value !== "") {
        url.searchParams.set(name, value);
      }
    }

    return url.href;
  }

  function flightUrl() {
    const url = new URL("/travel/flights", location.origin);
    const query = currentSearch();
    if (query) {
      url.searchParams.set("q", query);
    }
    url.searchParams.set("output", "search");
    return url.href;
  }

  function mapsUrl() {
    const url = new URL("https://www.google.com/maps/search/");
    url.searchParams.set("api", "1");
    url.searchParams.set("query", currentSearch());
    return url.href;
  }

  function activeType() {
    const url = new URL(location.href);
    const udm = url.searchParams.get("udm");
    const tbm = url.searchParams.get("tbm");

    if (udm === "50") return "ai";
    if (udm === "28" || tbm === "shop") return "shopping";
    if (udm === "2" || tbm === "isch") return "images";
    if (udm === "39") return "shorts";
    if (udm === "web") return "web";
    return "all";
  }

  function createLink(label, href, type) {
    const link = document.createElement("a");
    link.className = "gstk-link";
    link.textContent = label;
    link.href = href;

    if (activeType() === type) {
      link.classList.add("gstk-active");
      link.setAttribute("aria-current", "page");
    }

    return link;
  }

  function createMenu(label, items) {
    const details = document.createElement("details");
    details.className = "gstk-menu";

    const summary = document.createElement("summary");
    summary.className = "gstk-link";
    summary.textContent = label;
    details.append(summary);

    const panel = document.createElement("div");
    panel.className = "gstk-menu-panel";

    for (const item of items) {
      panel.append(createLink(item.label, item.href, ""));
    }

    details.append(panel);
    return details;
  }

  function buildRoot() {
    const root = document.createElement("nav");
    root.id = ROOT_ID;
    root.setAttribute("aria-label", "検索カテゴリ");

    const items = document.createElement("div");
    items.className = "gstk-items";
    items.append(
      createLink("AI モード", searchUrl({ udm: "50" }), "ai"),
      createLink("すべて", searchUrl(), "all"),
      createLink("ショッピング", searchUrl({ udm: "28" }), "shopping"),
      createLink("画像", searchUrl({ udm: "2" }), "images"),
      createLink("ショート動画", searchUrl({ udm: "39" }), "shorts"),
      createLink("ウェブ", searchUrl({ udm: "web" }), "web"),
      createLink("フライト", flightUrl(), "flights"),
      createMenu("もっと見る", [
        { label: "動画", href: searchUrl({ udm: "7" }) },
        { label: "ニュース", href: searchUrl({ tbm: "nws" }) },
        { label: "地図", href: mapsUrl() },
        { label: "書籍", href: searchUrl({ tbm: "bks" }) }
      ]),
      createMenu("ツール", [
        { label: "期間指定なし", href: searchUrl() },
        { label: "1時間以内", href: searchUrl({ tbs: "qdr:h" }) },
        { label: "24時間以内", href: searchUrl({ tbs: "qdr:d" }) },
        { label: "1週間以内", href: searchUrl({ tbs: "qdr:w" }) },
        { label: "1か月以内", href: searchUrl({ tbs: "qdr:m" }) },
        { label: "1年以内", href: searchUrl({ tbs: "qdr:y" }) }
      ])
    );

    root.append(items);
    return root;
  }

  function isVisible(element) {
    if (!(element instanceof HTMLElement)) return false;
    const style = getComputedStyle(element);
    const rect = element.getBoundingClientRect();
    return style.display !== "none"
      && style.visibility !== "hidden"
      && rect.width > 0
      && rect.height > 0;
  }

  function nativeTabsAreVisible() {
    const candidates = document.querySelectorAll(
      "#hdtb a, #hdtb button, #hdtb-sc a, #hdtb-sc button, " +
      "[role='navigation'] a, [role='navigation'] button"
    );
    let matches = 0;

    for (const element of candidates) {
      if (element.closest(`#${ROOT_ID}`) || !isVisible(element)) continue;
      if (NATIVE_TAB_TEXTS.has(element.textContent.trim())) {
        matches += 1;
      }
      if (matches >= 3) return true;
    }

    return false;
  }

  function findMountPoint() {
    return document.querySelector("#search")
      || document.querySelector("#rso")
      || document.querySelector("main")
      || document.body.firstElementChild;
  }

  function update() {
    if (!currentSearch()) return;

    const existing = document.getElementById(ROOT_ID);
    const urlChanged = lastUrl !== location.href;
    lastUrl = location.href;

    if (!existing || urlChanged) {
      existing?.remove();
      const mountPoint = findMountPoint();
      if (!mountPoint?.parentNode) return;
      mountPoint.parentNode.insertBefore(buildRoot(), mountPoint);
    }

    const root = document.getElementById(ROOT_ID);
    if (root) {
      root.hidden = nativeTabsAreVisible();
    }
  }

  function scheduleUpdate() {
    clearTimeout(updateTimer);
    updateTimer = setTimeout(update, 100);
  }

  const observer = new MutationObserver(scheduleUpdate);
  observer.observe(document.documentElement, {
    childList: true,
    subtree: true
  });

  addEventListener("popstate", scheduleUpdate);
  addEventListener("pageshow", scheduleUpdate);
  document.addEventListener("click", (event) => {
    if (event.target instanceof Element && event.target.closest("a")) {
      setTimeout(scheduleUpdate, 150);
    }
  });

  update();
})();
