(function(){
  // ===== ダークモード =====
  // 保存された設定 → 無ければ端末の設定(ダーク優先か)に合わせる
  var savedTheme = localStorage.getItem('mc_theme');
  var theme = savedTheme || ((window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) ? 'dark' : 'light');
  document.documentElement.setAttribute('data-theme', theme);

  // ダークモード用の色の上書き（元の :root 変数を data-theme="dark" の時だけ上書きする）
  var darkStyle = document.createElement('style');
  darkStyle.textContent = `
html[data-theme="dark"]{
  --bg:#07101f;--surface:#0e1d33;--surface2:#132340;
  --border:rgba(46,230,107,.14);--border2:rgba(46,230,107,.26);
  --text:#e8f1ff;--muted:#5a7a9a;--muted2:#3a5570;
}
html[data-theme="dark"] body::before{
  background-image:linear-gradient(rgba(46,230,107,.03) 1px,transparent 1px),
    linear-gradient(90deg,rgba(46,230,107,.03) 1px,transparent 1px);
}
html[data-theme="dark"] .topbar{background:rgba(7,16,31,.9)}
html[data-theme="dark"] .footer{background:rgba(7,16,31,.94)}
html[data-theme="dark"] .card-thumb{background:linear-gradient(135deg,#0c1c30,#0f2040)}
html[data-theme="dark"] .feat-thumb{background:linear-gradient(135deg,#0c1c30,#0f2040)}
html[data-theme="dark"] .dl-icon{background:linear-gradient(135deg,#0c1c30,#0f2040)}
html[data-theme="dark"] .footer-logo{filter:brightness(1) invert(0)}
html[data-theme="dark"] .top-search input::placeholder{color:#4a6070}
html[data-theme="dark"] .empty,html[data-theme="dark"] .coming-soon{color:#5a7a9a}
`;
  document.head.appendChild(darkStyle);

  // 切り替えボタンをページ右下に自動で設置する
  var btn = document.createElement('button');
  btn.id = 'theme-toggle-btn';
  btn.type = 'button';
  btn.style.cssText = 'position:fixed;bottom:20px;right:20px;z-index:9999;width:44px;height:44px;'
    + 'border-radius:50%;border:1px solid rgba(46,230,107,.4);background:var(--surface,#fff);'
    + 'color:var(--text,#16241b);font-size:19px;cursor:pointer;box-shadow:0 4px 16px rgba(0,0,0,.18);'
    + 'display:flex;align-items:center;justify-content:center;transition:transform .2s;';
  btn.onmouseenter = function(){ btn.style.transform = 'scale(1.08)'; };
  btn.onmouseleave = function(){ btn.style.transform = 'scale(1)'; };

  function updateIcon(){
    var t = document.documentElement.getAttribute('data-theme');
    btn.textContent = t === 'dark' ? '☀️' : '🌙';
    btn.title = t === 'dark' ? 'ライトモードに切り替え' : 'ダークモードに切り替え';
  }

  window.toggleTheme = function(){
    var cur = document.documentElement.getAttribute('data-theme');
    var next = cur === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', next);
    localStorage.setItem('mc_theme', next);
    updateIcon();
  };
  btn.onclick = window.toggleTheme;

  function mountButton(){
    document.body.appendChild(btn);
    updateIcon();
  }
  if(document.readyState==='loading'){
    document.addEventListener('DOMContentLoaded', mountButton);
  }else{ mountButton(); }

  // フェードイン/フェードアウト用のCSSを自動で挿入
  var s=document.createElement('style');
  s.textContent='body{opacity:0;transition:opacity .28s ease}body.pt-ready{opacity:1}';
  document.head.appendChild(s);

  // ページ読み込み時にフェードイン
  function ready(){
    requestAnimationFrame(function(){ document.body.classList.add('pt-ready'); });
  }
  if(document.readyState==='loading'){
    document.addEventListener('DOMContentLoaded', ready);
  }else{ ready(); }

  // 他ページへ移動する際にフェードアウトしてから遷移する関数
  // JSのonclickから呼び出す場合: onclick="pageGoTo('terms.html')"
  window.pageGoTo=function(url){
    document.body.classList.remove('pt-ready');
    setTimeout(function(){ location.href=url; },260);
  };

  // 通常の<a>リンクも自動でフェードアウトしてから遷移させる
  // （外部リンク・mailto・ダウンロード・target=_blank・#リンクは対象外）
  document.addEventListener('click', function(e){
    var a=e.target.closest('a[href]');
    if(!a) return;
    var href=a.getAttribute('href');
    if(!href) return;
    if(href.startsWith('#')||href.startsWith('mailto:')||href.startsWith('http')||a.hasAttribute('download')||a.target==='_blank') return;
    e.preventDefault();
    window.pageGoTo(href);
  });

  // ===== ダウンロード数カウンター（CountAPI: 無料・全員共通で見える） =====
  var NS = "mc-the-mod-site-2026";

  window.dlGet = async function(key){
    try{
      const res = await fetch(`https://api.countapi.xyz/get/${NS}/${key}`);
      const data = await res.json();
      return data.value || 0;
    }catch{ return null; }
  };

  window.dlHit = async function(key){
    try{
      const res = await fetch(`https://api.countapi.xyz/hit/${NS}/${key}`);
      const data = await res.json();
      return data.value || 0;
    }catch{ return null; }
  };
})();
