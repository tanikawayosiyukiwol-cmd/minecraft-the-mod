(function(){
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
  // 名前空間はサイト固有のIDにしておく（他サイトと数字が混ざらないように）
  var NS = "mc-the-mod-site-2026";

  // 現在のダウンロード数を「増やさずに」取得する
  window.dlGet = async function(key){
    try{
      const res = await fetch(`https://api.countapi.xyz/get/${NS}/${key}`);
      const data = await res.json();
      return data.value || 0;
    }catch{ return null; }
  };

  // ダウンロードされた瞬間に呼ぶ（1つ増やして、増やした後の数を返す）
  window.dlHit = async function(key){
    try{
      const res = await fetch(`https://api.countapi.xyz/hit/${NS}/${key}`);
      const data = await res.json();
      return data.value || 0;
    }catch{ return null; }
  };
})();
