#!/bin/bash
# ==========================================================
# new_subpage.sh
# 既存の番号ページ（例: /1774434/）の中に、
# さらにサブページ（例: /1774434/home/）を追加するスクリプト
# 使い方: ./new_subpage.sh   を minecraft-the-mod フォルダの中で実行
# ==========================================================
set -e

SITE_DIR="$HOME/minecraft-the-mod"
cd "$SITE_DIR" || { echo "❌ $SITE_DIR が見つかりません"; exit 1; }

echo "📄 番号ページの中に、サブページを追加します"
echo "----------------------------------------"
echo "今あるコンテンツの番号一覧:"
find . -maxdepth 1 -regextype posix-extended -regex '\./[0-9]+' | sed 's|^\./||' | sort
echo "----------------------------------------"
read -p "どの番号の中に追加しますか？ (例: 1774434): " PARENT_ID

if [ ! -d "$SITE_DIR/$PARENT_ID" ]; then
  echo "❌ 番号 $PARENT_ID のフォルダが見つかりません。先に記事などを作成してください。"
  exit 1
fi

echo ""
echo "サブページの名前を、半角英数字で入力してください（URLの一部になります）"
read -p "例: home, rules, entries など: " SLUG

if [ -z "$SLUG" ]; then
  echo "❌ 名前を入力してください"
  exit 1
fi
if [ -d "$SITE_DIR/$PARENT_ID/$SLUG" ]; then
  echo "❌ /$PARENT_ID/$SLUG/ はすでに存在します"
  exit 1
fi

read -p "ページタイトル: " TITLE

echo ""
echo "本文を入力してください。空行で段落が分かれます。"
echo "入力が終わったら、Ctrlキーを押しながらDキーを押してください（Ctrl+D）。"
echo "----------------------------------------"
BODY_RAW=$(cat)

mkdir -p "$SITE_DIR/$PARENT_ID/$SLUG"

if ! command -v python3 >/dev/null 2>&1; then
  echo "⚠️ python3が見つかりません。sudo apt install python3 -y を実行してから、もう一度お試しください。"
  exit 1
fi

python3 - "$PARENT_ID" "$SLUG" "$TITLE" "$BODY_RAW" "$SITE_DIR" << 'PYEOF'
import sys, html

def clean(s):
    try:
        return s.encode('utf-8', 'surrogateescape').decode('utf-8', 'replace')
    except Exception:
        return s

parent_id, slug, title, body_raw, site_dir = [clean(x) for x in sys.argv[1:6]]

paragraphs = [p.strip() for p in body_raw.split("\n\n") if p.strip()]
body_html = "\n  ".join(f"<p>{html.escape(p)}</p>" for p in paragraphs)
title_esc = html.escape(title)

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
<meta name="description" content="{title_esc}">
<link rel="canonical" href="https://tanikawayosiyukiwol-cmd.github.io/minecraft-the-mod/{parent_id}/{slug}/">
<meta property="og:type" content="article">
<meta property="og:title" content="{title_esc} | マインクラフト.the.Mod">
<meta property="og:url" content="https://tanikawayosiyukiwol-cmd.github.io/minecraft-the-mod/{parent_id}/{slug}/">
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
  border-bottom:1px solid var(--border2);height:56px;display:flex;align-items:center;padding:0 1.5rem;gap:1rem}}
.topbar a{{color:var(--muted);text-decoration:none;font-size:13px}}
.topbar a:hover{{color:var(--cyan)}}
h1{{font-size:clamp(19px,3.4vw,26px);line-height:1.5;color:var(--text);margin:2.2rem 0 2rem;font-weight:900}}
p{{font-size:14px;line-height:1.95;color:#3a4a40;margin-bottom:1.1rem}}
footer{{padding:2.5rem 0;text-align:center;color:var(--muted2);font-size:11.5px;font-family:var(--mono);
  border-top:1px solid var(--border);margin-top:2rem}}
</style>
</head>
<body>
<div class="topbar">
  <a href="/minecraft-the-mod/{parent_id}/">← 親ページ（/{parent_id}/）へ戻る</a>
  <a href="/minecraft-the-mod/" style="margin-left:auto">トップへ</a>
</div>
<div class="wrap">
  <h1>{title_esc}</h1>

  {body_html}

  <footer>© マインクラフト.the.Mod — Not affiliated with Mojang Studios.</footer>
</div>
<script src="/minecraft-the-mod/transition.js"></script>
</body>
</html>
"""

with open(f"{site_dir}/{parent_id}/{slug}/index.html", "w", encoding="utf-8") as f:
    f.write(TEMPLATE)

print(f"✅ 作成しました: /{parent_id}/{slug}/")
PYEOF

echo ""
echo "----------------------------------------"
echo "次にこれを実行して公開してください:"
echo ""
echo "  cd ~/minecraft-the-mod"
echo "  git add -A"
echo "  git commit -m \"Add subpage: /$PARENT_ID/$SLUG/\""
echo "  git push"
echo ""
