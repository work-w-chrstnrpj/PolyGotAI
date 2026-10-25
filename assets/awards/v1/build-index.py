"""Read-only PNG analysis and HTML/manifest packaging; never edits artwork pixels."""
from pathlib import Path
import hashlib, html, json
from PIL import Image

ROOT = Path(__file__).resolve().parent
plan = json.loads((ROOT / 'generation-plan.json').read_text())
assets = []
for intent in plan['assets']:
    item = {k: v for k, v in intent.items() if k != 'prompt'}
    asset_path = ROOT / 'masters' / intent['filename']
    record_path = ROOT / 'records' / (intent['id'].lower() + '.json')
    record = json.loads(record_path.read_text()) if record_path.exists() else {}
    item['prompt_file'] = 'prompts/' + intent['id'].lower() + '.txt'
    item['file'] = 'masters/' + intent['filename']
    item['record_file'] = 'records/' + intent['id'].lower() + '.json'
    item['generation_status'] = 'saved' if asset_path.exists() else 'pending'
    item['visual_review'] = record.get('visual_review', 'pending')
    item['visual_notes'] = record.get('visual_notes', '')
    if asset_path.exists():
        item['sha256'] = hashlib.sha256(asset_path.read_bytes()).hexdigest()
        item['bytes'] = asset_path.stat().st_size
        with Image.open(asset_path) as artwork:
            artwork.verify()
        with Image.open(asset_path) as artwork:
            item['width'], item['height'] = artwork.size
            item['mode'] = artwork.mode
            if 'A' in artwork.getbands():
                alpha = artwork.getchannel('A')
                histogram = alpha.histogram()
                item['alpha_extrema'] = list(alpha.getextrema())
                item['fully_transparent_fraction'] = histogram[0] / (artwork.width * artwork.height)
                item['alpha_bounds'] = list(alpha.getbbox()) if alpha.getbbox() else None
                item['corner_alpha'] = [alpha.getpixel(p) for p in [(0,0),(artwork.width-1,0),(0,artwork.height-1),(artwork.width-1,artwork.height-1)]]
                item['structural_check'] = 'pass' if histogram[0] > 0 and histogram[255] > 0 and alpha.getbbox() else 'fail'
            else:
                item['structural_check'] = 'fail'
    assets.append(item)
manifest = {'version':1, 'format':'individually generated transparent PNG raster masters', 'tool':'built-in ImageGen', 'family_count':len(assets), 'saved':sum(a['generation_status']=='saved' for a in assets), 'reviewed':sum(a['visual_review']=='pass' for a in assets), 'native_accessibility':'NOT_RUN', 'vectors_and_state_overlays':'not part of this raster delivery', 'assets':assets}
(ROOT / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
data = json.dumps(assets).replace('<','\\u003c')
page = '''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>SpeechCoachAI · Award masters v1</title><style>
*{box-sizing:border-box}body{margin:0;background:#f7f4ec;color:#213d39;font:15px system-ui,sans-serif}header{padding:22px 28px;background:#fffdf8;border-bottom:1px solid #dce3dc}h1{font-size:25px;margin:0 0 6px}p{margin:6px 0;line-height:1.45}.controls{display:flex;gap:12px;align-items:center;flex-wrap:wrap;padding:14px 28px}button,select,a{font:inherit}button,select{padding:9px 14px;border:1px solid #75938b;border-radius:10px;background:white;color:#213d39}button{cursor:pointer}button:disabled{opacity:.4}a{color:#176c60}.grid{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:14px;padding:0 28px 28px}.card{background:#fffefa;border:1px solid #dce3dc;border-radius:16px;padding:12px;min-width:0}.art{height:185px;display:grid;place-items:center;background:#fff;border-radius:10px;overflow:hidden}.art img{max-width:100%;max-height:100%;object-fit:contain}.dark .art{background:#142925}.small .art img{width:64px;height:64px}.card h2{font-size:15px;margin:8px 0 4px;line-height:1.25}.meta{font-size:12px;line-height:1.35;color:#536b65}.id{font-weight:700;letter-spacing:.04em}.pending{height:185px;display:grid;place-items:center;color:#788d86}footer{padding:0 28px 24px;color:#536b65}@media(max-width:760px){.grid{grid-template-columns:repeat(2,minmax(0,1fr))}}
</style><header><h1>SpeechCoachAI · Award artwork masters</h1><p>One individually generated raster master per adopted family. Artwork review only: no earned-user state, vector or native accessibility claim.</p><p id="summary"></p></header><div class="controls"><button id="previous">Previous</button><span id="page"></span><button id="next">Next</button><label>Shell <select id="filter"><option value="all">All</option><option value="circle">Practice circles</option><option value="shield">Completion shields</option><option value="hexagon">Evidence hexagons</option><option value="checkpoint">Milestone icons</option></select></label><button id="theme">Dark art surface</button><button id="size">Small-size review</button><a href="manifest.json">Manifest</a></div><main class="grid" id="grid"></main><footer>Labels and status/tier overlays remain separate from art. Native/device verification is NOT_RUN. Prompt and source records accompany each master.</footer><script>
const assets=DATA;const params=new URLSearchParams(location.search);let page=Math.max(0,Number(params.get('page')||0));const perPage=12;const grid=document.getElementById('grid');const filter=document.getElementById('filter');
function esc(s){return String(s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]))}
function draw(){const list=assets.filter(a=>filter.value==='all'||a.shell.toLowerCase().includes(filter.value));const pages=Math.max(1,Math.ceil(list.length/perPage));page=Math.min(page,pages-1);document.getElementById('page').textContent=`${page+1} / ${pages}`;document.getElementById('previous').disabled=page===0;document.getElementById('next').disabled=page===pages-1;document.getElementById('summary').textContent=`${assets.filter(a=>a.generation_status==='saved').length} / ${assets.length} masters saved · ${assets.filter(a=>a.visual_review==='pass').length} statically reviewed`;grid.innerHTML=list.slice(page*perPage,(page+1)*perPage).map(a=>`<article class="card"><div class="id">${esc(a.id)}</div>${a.generation_status==='saved'?`<div class="art"><img src="${esc(a.file)}" alt="${esc(a.name)} artwork"></div>`:'<div class="pending">Generation pending</div>'}<h2>${esc(a.name)}</h2><div class="meta">${esc(a.shell)}<br>${esc(a.subject)}<br>${a.width?`${a.width} × ${a.height} · ${esc(a.mode)} · ${esc(a.visual_review)}`:'Not yet saved'}</div></article>`).join('');history.replaceState(null,'',`?page=${page}`)}
document.getElementById('previous').onclick=()=>{page--;draw()};document.getElementById('next').onclick=()=>{page++;draw()};filter.onchange=()=>{page=0;draw()};document.getElementById('theme').onclick=()=>document.body.classList.toggle('dark');document.getElementById('size').onclick=()=>document.body.classList.toggle('small');draw();
</script></html>'''.replace('DATA',data)
(ROOT / 'gallery.html').write_text(page)
print(json.dumps({'families':len(assets),'saved':manifest['saved'],'reviewed':manifest['reviewed'],'structural_failures':[a['id'] for a in assets if a.get('structural_check')=='fail']}))
