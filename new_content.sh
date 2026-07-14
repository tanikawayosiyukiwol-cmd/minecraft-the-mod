#!/bin/bash
# ==========================================================
# new_content.sh
# 番号URLのコンテンツ（記事・ギャラリー・レビュー）を作成するスクリプト
# 使い方: ./new_content.sh   を minecraft-the-mod フォルダの中で実行
# ==========================================================
set -e

SITE_DIR="$HOME/minecraft-the-mod"
cd "$SITE_DIR" || { echo "❌ $SITE_DIR が見つかりません"; exit 1; }

echo "📦 新しいコンテンツを作成します"
echo "----------------------------------------"
echo "1) 記事（運営ブログ）"
echo "2) ギャラリー（建築作品・スクリーンショット）"
echo "3) レビュー・感想"
read -p "番号を選んでください [1-3]: " TYPE_NUM

case "$TYPE_NUM" in
  1) TYPE="article" ;;
  2) TYPE="gallery" ;;
  3) TYPE="review" ;;
  *) echo "❌ 1〜3の番号を入力してください"; exit 1 ;;
esac

echo "----------------------------------------"
read -p "タイトル: " TITLE
read -p "日付 (空欄で今日の日付): " DATE
if [ -z "$DATE" ]; then
  DATE=$(date +%F)
fi

EXCERPT=""
IMAGE=""
AUTHOR=""
RATING=5

if [ "$TYPE" == "article" ]; then
  read -p "一覧に出す短い説明（抜粋）: " EXCERPT
elif [ "$TYPE" == "gallery" ]; then
  read -p "投稿者名: " AUTHOR
  echo "画像ファイル名（先に画像を minecraft-the-mod フォルダ直下にアップロードしておいてください）"
  read -p "例: my-castle.png : " IMAGE
elif [ "$TYPE" == "review" ]; then
  read -p "投稿者名: " AUTHOR
  read -p "評価 (1〜5の数字): " RATING
  read -p "一覧に出す短い説明（抜粋）: " EXCERPT
fi

echo ""
echo "本文を入力してください。空行で段落が分かれます。"
echo "入力が終わったら、Ctrlキーを押しながらDキーを押してください（Ctrl+D）。"
echo "----------------------------------------"
BODY_RAW=$(cat)

# 一意な7桁のIDを生成
while :; do
  NEW_ID=$((1000000 + RANDOM % 9000000))
  if [ ! -d "$SITE_DIR/$NEW_ID" ]; then
    break
  fi
done

mkdir -p "$SITE_DIR/$NEW_ID"

if ! command -v python3 >/dev/null 2>&1; then
  echo "⚠️ python3が見つかりません。sudo apt install python3 -y を実行してから、もう一度お試しください。"
  exit 1
fi

python3 - "$TYPE" "$NEW_ID" "$TITLE" "$DATE" "$EXCERPT" "$BODY_RAW" "$SITE_DIR" "$IMAGE" "$AUTHOR" "$RATING" << 'PYEOF'
import sys, json, html

TYPE, new_id, title, date, excerpt, body_raw, site_dir, image, author, rating = sys.argv[1:11]

paragraphs = [p.strip() for p in body_raw.split("\n\n") if p.strip()]
body_html = "\n  ".join(f"<p>{html.escape(p)}</p>" for p in paragraphs)
title_esc = html.escape(title)
excerpt_esc = html.escape(excerpt)

if TYPE == "gallery":
    extra_head = f'<img src="/minecraft-the-mod/{html.escape(image)}" style="width:100%;border-radius:12px;margin-bottom:1.5rem;border:1px solid rgba(46,230,107,.4)" alt="{title_esc}">'
    meta_line = f'<div class="post-date">投稿者: {html.escape(author)} ・ {date}</div>'
elif TYPE == "review":
    stars = "★"*int(rating or 5) + "☆"*(5-int(rating or 5))
    extra_head = f'<div style="color:#ff5252;font-size:20px;margin-bottom:1rem">{stars}</div>'
    meta_line = f'<div class="post-date">by {html.escape(author)} ・ {date}</div>'
else:
    extra_head = ""
    meta_line = f'<div class="post-date">{date}</div>'

TEMPLATE = f"""<!DOCTYPE html>
<html lang="ja">
<head>
<script>
(function(){{
  try{{
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '/minecraft-the-mod/site-config.json?t=' + Date.now(), false);
    xhr.send(null);
    if(xhr.status === 200){{
      var cfg = JSON.parse(xhr.responseText);
      if(cfg.maintenance === true && location.pathname.indexOf('/maintenance/') === -1){{
        location.replace('/minecraft-the-mod/maintenance/');
      }}
    }}
  }}catch(e){{}}
}})();
</script>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>{title_esc} | マインクラフト.the.Mod</title>
<link rel="icon" type="image/png" sizes="32x32" href="/minecraft-the-mod/favicon-32.png">
<link rel="icon" type="image/png" sizes="16x16" href="/minecraft-the-mod/favicon-16.png">
<link rel="apple-touch-icon" sizes="180x180" href="/minecraft-the-mod/favicon-180.png">
<link rel="icon" type="image/x-icon" href="/minecraft-the-mod/favicon.ico">
<meta name="description" content="{excerpt_esc}">
<link rel="canonical" href="https://tanikawayosiyukiwol-cmd.github.io/minecraft-the-mod/{new_id}/">
<meta property="og:type" content="article">
<meta property="og:title" content="{title_esc} | マインクラフト.the.Mod">
<meta property="og:description" content="{excerpt_esc}">
<meta property="og:url" content="https://tanikawayosiyukiwol-cmd.github.io/minecraft-the-mod/{new_id}/">
<meta property="og:image" content="https://tanikawayosiyukiwol-cmd.github.io/minecraft-the-mod/ogp-image.jpg">
<meta property="og:site_name" content="マインクラフト.the.Mod">
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@400;500;700;900&family=Press+Start+2P&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
<style>
:root{{
  --bg:#f7faf8;--surface:#ffffff;--surface2:#eef6f0;
  --border:rgba(46,230,107,.22);--border2:rgba(46,230,107,.4);
  --cyan:#2ee66b;--gold:#ff5252;--text:#16241b;--muted:#5f7466;--muted2:#93a89b;
  --pixel:"Press Start 2P";--sans:"Noto Sans JP",sans-serif;--mono:"JetBrains Mono",monospace;--r:6px;--r2:12px;
}}
*{{margin:0;padding:0;box-sizing:border-box}}
body{{background:var(--bg);color:var(--text);font-family:var(--sans);overflow-x:hidden}}
.wrap{{max-width:700px;margin:0 auto;padding:0 1.5rem}}
.topbar{{position:sticky;top:0;z-index:100;background:rgba(255,255,255,.9);backdrop-filter:blur(14px);
  border-bottom:1px solid var(--border2);height:56px;display:flex;align-items:center;padding:0 1.5rem}}
.topbar a{{color:var(--muted);text-decoration:none;font-size:13px}}
.topbar a:hover{{color:var(--cyan)}}
.post-date{{font-family:var(--mono);font-size:11.5px;color:var(--muted2);padding-top:2.2rem}}
h1{{font-size:clamp(19px,3.4vw,26px);line-height:1.5;color:var(--text);margin:.5rem 0 2rem;font-weight:900}}
p{{font-size:14px;line-height:1.95;color:#3a4a40;margin-bottom:1.1rem}}
.back-link{{display:inline-block;margin-top:2rem;font-size:12.5px;color:var(--cyan);text-decoration:none}}
.back-link:hover{{text-decoration:underline}}
footer{{padding:2.5rem 0;text-align:center;color:var(--muted2);font-size:11.5px;font-family:var(--mono);
  border-top:1px solid var(--border);margin-top:2rem}}
</style>
</head>
<body>
<div class="topbar"><a href="/minecraft-the-mod/{ {'article':'articles','gallery':'gallery','review':'reviews'}[TYPE] }/">← 一覧へ戻る</a></div>
<div class="wrap">
  {meta_line}
  <h1>{title_esc}</h1>
  {extra_head}

  {body_html}

  <a class="back-link" href="/minecraft-the-mod/{ {'article':'articles','gallery':'gallery','review':'reviews'}[TYPE] }/">← 他も見る</a>

  <footer>© マインクラフト.the.Mod — Not affiliated with Mojang Studios.</footer>
</div>
<script src="/minecraft-the-mod/transition.js"></script>
</body>
</html>
"""

with open(f"{site_dir}/{new_id}/index.html", "w", encoding="utf-8") as f:
    f.write(TEMPLATE)

json_name = {"article": "articles.json", "gallery": "gallery.json", "review": "reviews.json"}[TYPE]
json_path = f"{site_dir}/{json_name}"
try:
    with open(json_path, encoding="utf-8") as f:
        items = json.load(f)
except Exception:
    items = []

entry = {"id": new_id, "title": title, "date": date, "published": True}
if TYPE == "article":
    entry["excerpt"] = excerpt
elif TYPE == "gallery":
    entry["author"] = author
    entry["image"] = image
elif TYPE == "review":
    entry["author"] = author
    entry["rating"] = int(rating or 5)
    entry["excerpt"] = excerpt

items.insert(0, entry)

with open(json_path, "w", encoding="utf-8") as f:
    json.dump(items, f, ensure_ascii=False, indent=2)

print(f"✅ 作成しました: /{new_id}/  （{json_name} に登録済み）")
PYEOF

echo ""
echo "----------------------------------------"
echo "次にこれを実行して公開してください:"
echo ""
echo "  cd ~/minecraft-the-mod"
echo "  git add -A"
echo "  git commit -m \"Add content: $TITLE\""
echo "  git push"
echo ""
