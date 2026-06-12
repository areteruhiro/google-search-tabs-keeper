# Google Search Tabs Keeper

Google検索で「ショッピング」へ移動した際などに、検索カテゴリのタブ列が
消えた場合だけ補助ナビゲーションを表示するChrome拡張機能です。

## 対応環境

- Google Chrome
- Chrome Extensions Manifest V3
- `www.google.com` / `www.google.co.jp`

## インストール

1. Chromeで `chrome://extensions/` を開く
2. 右上の「デベロッパー モード」を有効にする
3. 「パッケージ化されていない拡張機能を読み込む」を押す
4. この `google-search-tabs-keeper` フォルダを選択する
5. Google検索ページを再読み込みする

## 動作

- Google標準のタブ列が見えている間は、補助バーを表示しません。
- 標準のタブ列が消えると、検索結果の直前に補助バーを表示します。
- 現在の検索語を維持したまま、AIモード、すべて、ショッピング、画像、
  ショート動画、ウェブ、フライトへ移動できます。
- 「もっと見る」には動画、ニュース、地図、書籍を用意しています。
- 「ツール」では検索期間を指定できます。

## ライセンス

GNU General Public License v3.0（GPL-3.0）で公開しています。
