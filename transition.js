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
})();
