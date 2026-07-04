(function(){
  var s=document.createElement('style');
  s.textContent='body{opacity:0;transition:opacity .28s ease}body.pt-ready{opacity:1}';
  document.head.appendChild(s);

  function ready(){
    requestAnimationFrame(function(){ document.body.classList.add('pt-ready'); });
  }
  if(document.readyState==='loading'){
    document.addEventListener('DOMContentLoaded', ready);
  }else{ ready(); }

  window.pageGoTo=function(url){
    document.body.classList.remove('pt-ready');
    setTimeout(function(){ location.href=url; },260);
  };

  document.addEventListener('click', function(e){
    var a=e.target.closest('a[href]');
    if(!a) return;
    var href=a.getAttribute('href');
    if(!href) return;
    if(href.startsWith('#')||href.startsWith('mailto:')||href.startsWith('http')||a.hasAttribute('download')||a.target==='_blank') return;
    e.preventDefault();
    window.pageGoTo(href);
  });

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
