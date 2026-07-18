#!/bin/bash
# ==========================================================
# new_quiz.sh
# 新しいクイズゲームを作成するスクリプト（番号URLで公開されます）
# 使い方: ./new_quiz.sh   を minecraft-the-mod フォルダの中で実行
# ==========================================================
set -e

SITE_DIR="$HOME/minecraft-the-mod"
cd "$SITE_DIR" || { echo "❌ $SITE_DIR が見つかりません"; exit 1; }

echo "🧠 新しいクイズゲームを作成します"
echo "----------------------------------------"
read -p "クイズのタイトル（例: マイクラ道具クイズ）: " QUIZ_TITLE
read -p "アイコン絵文字（空欄で🧠）: " ICON
if [ -z "$ICON" ]; then ICON="🧠"; fi
read -p "問題数（1〜15の数字）: " Q_COUNT

if ! [[ "$Q_COUNT" =~ ^[0-9]+$ ]] || [ "$Q_COUNT" -lt 1 ] || [ "$Q_COUNT" -gt 15 ]; then
  echo "❌ 1〜15の数字を入力してください"
  exit 1
fi

QUESTIONS_JSON="["
for ((i=1; i<=Q_COUNT; i++)); do
  echo ""
  echo "---- 問題 $i / $Q_COUNT ----"
  read -p "問題文: " Q_TEXT
  read -p "選択肢1: " C1
  read -p "選択肢2: " C2
  read -p "選択肢3: " C3
  read -p "選択肢4: " C4
  read -p "正解の番号（1〜4）: " ANS
  read -p "解説文（正解発表時に表示）: " EXPLAIN

  if [ "$i" -gt 1 ]; then QUESTIONS_JSON="$QUESTIONS_JSON,"; fi
  QUESTIONS_JSON="$QUESTIONS_JSON{\"q_b64\":\"$(printf '%s' "$Q_TEXT" | base64 -w0)\",\"c_b64\":[\"$(printf '%s' "$C1" | base64 -w0)\",\"$(printf '%s' "$C2" | base64 -w0)\",\"$(printf '%s' "$C3" | base64 -w0)\",\"$(printf '%s' "$C4" | base64 -w0)\"],\"answer\":$((ANS-1)),\"explain_b64\":\"$(printf '%s' "$EXPLAIN" | base64 -w0)\"}"
done
QUESTIONS_JSON="$QUESTIONS_JSON]"

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

python3 - "$NEW_ID" "$QUIZ_TITLE" "$ICON" "$QUESTIONS_JSON" "$SITE_DIR" << 'PYEOF'
import sys, json, base64, html

def clean(s):
    try:
        return s.encode('utf-8', 'surrogateescape').decode('utf-8', 'replace')
    except Exception:
        return s

new_id, title, icon, questions_raw, site_dir = [clean(x) for x in sys.argv[1:6]]
title_esc = html.escape(title)

raw_qs = json.loads(questions_raw)
questions = []
for item in raw_qs:
    q = base64.b64decode(item["q_b64"]).decode("utf-8")
    choices = [base64.b64decode(c).decode("utf-8") for c in item["c_b64"]]
    explain = base64.b64decode(item["explain_b64"]).decode("utf-8")
    questions.append({"q": q, "choices": choices, "answer": item["answer"], "explain": explain})

questions_js = json.dumps(questions, ensure_ascii=False)

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
<meta name="description" content="{title_esc}に挑戦しよう！">
<link rel="canonical" href="https://tanikawayosiyukiwol-cmd.github.io/minecraft-the-mod/{new_id}/">
<meta property="og:type" content="website">
<meta property="og:title" content="{title_esc} | マインクラフト.the.Mod">
<meta property="og:description" content="{title_esc}に挑戦しよう！">
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
.wrap{{max-width:560px;margin:0 auto;padding:0 1.5rem}}
.topbar{{position:sticky;top:0;z-index:100;background:rgba(255,255,255,.9);backdrop-filter:blur(14px);
  border-bottom:1px solid var(--border2);height:56px;display:flex;align-items:center;padding:0 1.5rem}}
.topbar a{{color:var(--muted);text-decoration:none;font-size:13px}}
.topbar a:hover{{color:var(--cyan)}}
h1{{font-family:var(--pixel);font-size:clamp(13px,3vw,17px);line-height:1.9;color:var(--text);
  padding:2.2rem 0 .4rem;text-align:center}}
.sub{{color:var(--muted);font-size:12.5px;margin-bottom:1.6rem;line-height:1.8;text-align:center}}
.progress{{display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;font-size:12px;
  color:var(--muted);font-family:var(--mono)}}
.bar{{height:6px;background:var(--surface2);border-radius:3px;overflow:hidden;margin-bottom:1.5rem}}
.bar-fill{{height:100%;background:linear-gradient(90deg,var(--cyan),#17c765);transition:width .3s}}
.q-card{{background:var(--surface);border:1px solid var(--border2);border-radius:var(--r2);padding:1.6rem}}
.q-text{{font-size:15px;font-weight:700;margin-bottom:1.2rem;line-height:1.7}}
.choice{{display:block;width:100%;text-align:left;background:var(--surface2);border:1px solid var(--border2);
  border-radius:var(--r);padding:.8rem 1.1rem;font-size:13px;color:var(--text);margin-bottom:.7rem;
  cursor:pointer;transition:border-color .15s}}
.choice:hover{{border-color:var(--cyan)}}
.choice.correct{{background:rgba(46,230,107,.15);border-color:var(--cyan);font-weight:700}}
.choice.wrong{{background:rgba(255,82,82,.12);border-color:var(--gold)}}
.choice:disabled{{cursor:default}}
.explain{{font-size:12px;color:var(--muted);line-height:1.8;margin-top:1rem;padding-top:1rem;border-top:1px solid var(--border);display:none}}
.next-btn{{display:none;margin-top:1.2rem;width:100%;background:linear-gradient(135deg,var(--cyan),#17c765);
  color:#04170c;border:none;border-radius:var(--r);padding:.8rem;font-weight:700;font-size:13.5px;cursor:pointer}}
.result{{text-align:center;padding:2rem 0}}
.result .score{{font-family:var(--pixel);font-size:28px;color:var(--cyan);margin:1rem 0}}
.result p{{font-size:13px;color:var(--muted);line-height:1.8;margin-bottom:1.5rem}}
.retry-btn{{background:var(--surface2);border:1px solid var(--border2);border-radius:var(--r);
  padding:.7rem 1.6rem;font-size:13px;font-weight:700;color:var(--text);cursor:pointer}}
footer{{padding:2.5rem 0;text-align:center;color:var(--muted2);font-size:11.5px;font-family:var(--mono);
  border-top:1px solid var(--border);margin-top:2rem}}
</style>
</head>
<body>
<div class="topbar"><a href="/minecraft-the-mod/games/">← ミニゲーム一覧へ戻る</a></div>
<div class="wrap">
  <h1>{icon} {title_esc}</h1>
  <p class="sub">全{len(questions)}問！あなたは何問正解できるでしょうか？</p>

  <div class="progress"><span id="q-num">問題 1 / {len(questions)}</span><span id="q-score">正解 0</span></div>
  <div class="bar"><div class="bar-fill" id="bar-fill" style="width:0%"></div></div>

  <div id="game-area"></div>

  <footer>© マインクラフト.the.Mod — Not affiliated with Mojang Studios.</footer>
</div>

<script src="/minecraft-the-mod/transition.js"></script>
<script>
const QUESTIONS = {questions_js};

let current = 0;
let score = 0;

function renderQuestion(){{
  const area = document.getElementById("game-area");
  const item = QUESTIONS[current];

  document.getElementById("q-num").textContent = `問題 ${{current+1}} / ${{QUESTIONS.length}}`;
  document.getElementById("q-score").textContent = `正解 ${{score}}`;
  document.getElementById("bar-fill").style.width = `${{(current/QUESTIONS.length)*100}}%`;

  area.innerHTML = `
    <div class="q-card">
      <div class="q-text">Q${{current+1}}. ${{item.q}}</div>
      ${{item.choices.map((c,i)=>`<button class="choice" data-i="${{i}}" onclick="selectChoice(${{i}})">${{c}}</button>`).join("")}}
      <div class="explain" id="explain">${{item.explain}}</div>
      <button class="next-btn" id="next-btn" onclick="nextQuestion()">${{current<QUESTIONS.length-1 ? "次の問題へ →" : "結果を見る →"}}</button>
    </div>
  `;
}}

function selectChoice(i){{
  const item = QUESTIONS[current];
  const buttons = document.querySelectorAll(".choice");
  buttons.forEach(b => b.disabled = true);
  buttons[item.answer].classList.add("correct");
  if(i !== item.answer){{ buttons[i].classList.add("wrong"); }}
  else{{ score++; }}
  document.getElementById("explain").style.display = "block";
  document.getElementById("next-btn").style.display = "block";
  document.getElementById("q-score").textContent = `正解 ${{score}}`;
}}

function nextQuestion(){{
  current++;
  if(current >= QUESTIONS.length){{ showResult(); }} else {{ renderQuestion(); }}
}}

function showResult(){{
  document.getElementById("bar-fill").style.width = "100%";
  document.getElementById("q-num").textContent = "終了";
  let comment = "";
  const total = QUESTIONS.length;
  if(score === total) comment = "満点！すごいです🎉";
  else if(score >= total*0.7) comment = "かなり詳しいですね！";
  else if(score >= total*0.4) comment = "まずまずの成績です。";
  else comment = "これを機に、もっとMinecraftを遊び込んでみましょう！";

  document.getElementById("game-area").innerHTML = `
    <div class="q-card result">
      <div>あなたの正解数</div>
      <div class="score">${{score}} / ${{total}}</div>
      <p>${{comment}}</p>
      <button class="retry-btn" onclick="restart()">🔄 もう一度挑戦する</button>
    </div>
  `;
}}

function restart(){{ current = 0; score = 0; renderQuestion(); }}
renderQuestion();
</script>
</body>
</html>
"""

with open(f"{site_dir}/{new_id}/index.html", "w", encoding="utf-8") as f:
    f.write(TEMPLATE)

# games.json に登録
json_path = f"{site_dir}/games.json"
try:
    with open(json_path, encoding="utf-8") as f:
        games = json.load(f)
except Exception:
    games = []

games.insert(0, {
    "id": new_id,
    "title": title,
    "icon": icon,
    "desc": f"全{len(questions)}問のクイズに挑戦！",
    "published": True
})

with open(json_path, "w", encoding="utf-8") as f:
    json.dump(games, f, ensure_ascii=False, indent=2)

print(f"✅ クイズを作成しました: /{new_id}/  （games.json に登録済み）")
PYEOF

echo ""
echo "----------------------------------------"
echo "次にこれを実行して公開してください:"
echo ""
echo "  cd ~/minecraft-the-mod"
echo "  git add -A"
echo "  git commit -m \"Add quiz: $QUIZ_TITLE\""
echo "  git push"
echo ""
