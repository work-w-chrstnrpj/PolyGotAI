// Runs in Figma's local Plugin API sandbox. No eval, sockets or network access.
figma.showUI(__html__, { width: 520, height: 670, themeColors: true });
let busy = false;
const extra = new Map();
const progress = message => figma.ui.postMessage({ kind: "progress", message });
const frameById = new Map(PROJECT.frames.map(f => [f.id, f.nodeId]));
const TABS = [["Today","TD-01"],["Learn","LR-01"],["Vocabulary","VO-01"],["Speech Lab","SP-01"],["Progress","PG-01"]];
async function context() {
  if (figma.editorType !== "figma") throw new Error("Open the SpeechCoachAI Design file, not FigJam or Slides.");
  const page = await figma.getNodeByIdAsync(PROJECT.pageId);
  const anchor = await figma.getNodeByIdAsync(frameById.get("ON-01"));
  if (!page || page.type !== "PAGE" || !anchor || anchor.parent !== page || !anchor.name.startsWith("ON-01 ·")) {
    throw new Error("This is not the expected SpeechCoachAI expansion. No edits were made.");
  }
  if (typeof figma.fileKey === "string" && figma.fileKey && figma.fileKey !== PROJECT.fileKey) throw new Error("Wrong Figma file.");
  await figma.setCurrentPageAsync(page);
  for (const n of page.children) {
    if (n.type === "FRAME" && n.name.startsWith("Local · ")) extra.set(n.name.slice(8).split(" · ")[0], n.id);
  }
  return page;
}
async function frame(id) {
  const nodeId = extra.get(id) || frameById.get(id);
  const n = nodeId ? await figma.getNodeByIdAsync(nodeId) : null;
  if (!n || n.type !== "FRAME" || n.parent.id !== PROJECT.pageId) throw new Error("Missing frame: " + id);
  return n;
}
async function loadFonts(node) {
  const texts = node.type === "TEXT" ? [node] : node.findAllWithCriteria({ types: ["TEXT"] });
  const fonts = new Map();
  for (const t of texts) for (const s of t.getStyledTextSegments(["fontName"])) fonts.set(JSON.stringify(s.fontName), s.fontName);
  await Promise.all([...fonts.values()].map(f => figma.loadFontAsync(f)));
}
async function link(node, target, sourceRoot, report) {
  if (!target) return;
  const destination = target === "BACK" ? null : await frame(target);
  if (destination && destination.id === sourceRoot.id) return;
  let source = node;
  // Navigation labels get actual 44pt hit regions, preserving their text.
  if (node.type === "TEXT" && node.parent.name === "Navigation") {
    await loadFonts(node);
    const parent = node.parent, index = parent.children.indexOf(node);
    const hit = figma.createFrame();parent.insertChild(index,hit);
    hit.name = "Touch target · " + node.characters;hit.layoutMode = "HORIZONTAL";
    hit.resize(Math.max(44,node.width),44);hit.fills=[];hit.primaryAxisAlignItems="CENTER";hit.counterAxisAlignItems="CENTER";
    hit.appendChild(node);node.layoutSizingHorizontal="HUG";source=hit;
    report.createdNodeIds.push(hit.id);
  }
  const other = (source.reactions || []).filter(r => !r.trigger || r.trigger.type !== "ON_CLICK");
  const action = destination ? {type:"NODE",destinationId:destination.id,navigation:"NAVIGATE",transition:null,resetScrollPosition:true} : {type:"BACK"};
  await source.setReactionsAsync([...other,{trigger:{type:"ON_CLICK"},actions:[action]}]);
  report.mutatedNodeIds.push(source.id);report.linkCount++;
}
async function audit(page) {
  const missing=[],bounds=[],routes=[],unwired=[];
  for (const item of PROJECT.frames) {
    const n=await figma.getNodeByIdAsync(item.nodeId);
    if (!n || n.parent!==page) {missing.push(item.id);continue;}
    const actions=n.findAllWithCriteria({types:["INSTANCE"]}).filter(x=>x.name.startsWith("Action ·"));
    for (const a of actions) {
      if (!a.reactions.some(r=>r.trigger && r.trigger.type==="ON_CLICK")) unwired.push({screen:item.id,nodeId:a.id,label:a.name});
      for(const t of a.findAllWithCriteria({types:["TEXT"]})) if(t.height>28) bounds.push({screen:item.id,nodeId:t.id,issue:"Wrapped action label",height:t.height});
    }
    for (const node of n.findAll(x=>"reactions" in x)) for(const reaction of node.reactions) for(const action of reaction.actions||[]) {
      if(action.type==="NODE"&&action.destinationId) routes.push({source:node.id,destination:action.destinationId});
    }
  }
  const bad=[];
  for(const r of routes){const n=await figma.getNodeByIdAsync(r.destination);if(!n||n.type!=="FRAME"||n.parent!==page)bad.push(r);}
  const preferred=await figma.getNodeByIdAsync("2:37969");
  const art=preferred?preferred.findAll(n=>("fills" in n && Array.isArray(n.fills) && n.fills.some(p=>p.type==="IMAGE")) || /coach|mascot|illustration|hero|scene|artwork/i.test(n.name)).slice(0,40).map(n=>({id:n.id,name:n.name,type:n.type,width:n.width,height:n.height})):[];
  return {operation:"audit",file:figma.root.name,page:page.name,expectedFrames:149,populatedFrames:PROJECT.frames.length-missing.length,missing,unwiredPrimaryActions:unwired,layoutWarnings:bounds,prototypeConnections:routes.length,invalidDestinations:bad,localExtraFrames:[...extra],preferredVisualReference:"Page 1",referenceArtwork:art,verification:"Structural report only. Visual and on-device acceptance remain separate."};
}
async function repair(page) {
  const report={operation:"repair",createdNodeIds:[],mutatedNodeIds:[],linkCount:0,unresolved:[]};
  // Separate capture specimen makes accepting a replacement reachable.
  let take;
  if(extra.has("SP-06-take2")) take=await frame("SP-06-take2");
  else {
    const original=await frame("SP-06");await loadFonts(original);take=original.clone();page.appendChild(take);
    take.name="Local · SP-06-take2 · Recording replacement";take.x=4000;take.y=240;
    extra.set("SP-06-take2",take.id);report.createdNodeIds.push(take.id);
    await link(take.findOne(n=>n.name==="Action · Stop and review"),"SP-07-accept",take,report);
  }
  for (const d of PROJECT.screens) {
    const root=await frame(d.id);
    for(const r of routeDefinitions(d)){
      const n=root.findOne(n=>n.name===r.name);
      if(n) await link(n,r.target,root,report);else report.unresolved.push({screen:d.id,source:r.name,target:r.target});
    }
    const nav=root.findOne(n=>n.name==="Navigation");
    if(nav) {
      const back=nav.findOne(n=>n.type==="TEXT" && (n.characters==="‹ Back" || n.characters==="SpeechCoach"));
      const close=nav.findOne(n=>n.type==="TEXT" && (n.characters==="Close" || n.characters==="Profile"));
      if(back)await link(back,d.tab?"TD-01":"BACK",root,report);
      if(close)await link(close,d.tab?"ST-01":d.id.startsWith("SP-06")?"SP-06-leave":"TD-01",root,report);
    }
    const tab=root.findOne(n=>n.name==="Tab bar");
    if(tab){const row=tab.findOne(n=>n.name==="Tabs");if(row)for(let i=0;i<Math.min(5,row.children.length);i++)await link(row.children[i],TABS[i][1],root,report);}
    for(const a of root.findAllWithCriteria({types:["INSTANCE"]}).filter(n=>n.name.startsWith("Action ·"))){
      await loadFonts(a);
      for(const t of a.findAllWithCriteria({types:["TEXT"]})){t.layoutSizingHorizontal="FILL";t.textAutoResize="HEIGHT";report.mutatedNodeIds.push(t.id);}
    }
  }
  // Keep the sample lesson moving instead of looping every check to Exercise 2.
  const sequence=["EX-02","EX-03","EX-04","EX-05","EX-06","EX-07","EX-08","LR-04"];
  for(let i=0;i<sequence.length-1;i++){
    const n=await frame(sequence[i]);const action=n.findOne(x=>x.name.startsWith("Action · Check"));
    if(action)await link(action,sequence[i+1],n,report);
  }
  figma.commitUndo();
  report.audit=await audit(page);
  return report;
}
const rgb=h=>({r:parseInt(h.slice(1,3),16)/255,g:parseInt(h.slice(3,5),16)/255,b:parseInt(h.slice(5,7),16)/255});
const paint=h=>[{type:"SOLID",color:rgb(h)}];
async function ipad(page) {
  await Promise.all(["Regular","Semibold","Bold"].map(style=>figma.loadFontAsync({family:"SF Pro",style})));
  const report={operation:"ipad",createdNodeIds:[],frames:[],prototypeLinks:[],note:"Editable adaptive composition specimens; actual device and keyboard acceptance NOT_RUN."};
  const preferred=await figma.getNodeByIdAsync("2:37969"), primary=await figma.getNodeByIdAsync("2:40073");
  const bg=preferred && Array.isArray(preferred.fills)?JSON.parse(JSON.stringify(preferred.fills)):paint("#F7F4EC");
  const made=n=>{report.createdNodeIds.push(n.id);return n;};
  function box(parent,name,width,direction="VERTICAL",pad=0,gap=12){
    const n=made(figma.createFrame());parent.appendChild(n);n.name=name;n.layoutMode=direction;n.resize(width,1);
    n.primaryAxisSizingMode="AUTO";n.counterAxisSizingMode="FIXED";n.fills=[];n.itemSpacing=gap;
    n.paddingTop=pad;n.paddingBottom=pad;n.paddingLeft=pad;n.paddingRight=pad;return n;
  }
  function text(parent,str,width,size=17,weight="Regular",color="#213D39"){
    const t=made(figma.createText());parent.appendChild(t);t.fontName={family:"SF Pro",style:weight};t.fontSize=size;
    t.lineHeight={unit:"PERCENT",value:135};t.resize(width,100);t.textAutoResize="HEIGHT";t.characters=str;t.layoutSizingHorizontal="FIXED";t.layoutSizingVertical="HUG";t.fills=paint(color);return t;
  }
  function card(parent,title,body,width){
    const n=box(parent,title,width,"VERTICAL",20,12);n.cornerRadius=18;n.fills=paint("#FFFFFF");
    text(n,title,width-40,22,"Semibold");if(body)text(n,body,width-40);return n;
  }
  async function button(parent,label,width,target,source){
    await loadFonts(primary);const n=made(primary.createInstance());parent.appendChild(n);n.name="Action · "+label;n.resize(width,52);
    n.layoutSizingHorizontal="FIXED";n.layoutSizingVertical="FIXED";n.primaryAxisSizingMode="FIXED";n.counterAxisSizingMode="FIXED";
    for(const t of n.findAllWithCriteria({types:["TEXT"]})){t.characters=label;t.layoutSizingHorizontal="FILL";t.textAutoResize="HEIGHT";t.layoutSizingVertical="HUG";t.textAlignHorizontal="CENTER";}
    if(target)report.prototypeLinks.push({nodeId:n.id,target,source:source.id});return n;
  }
  const specs=[["IPAD-Learn","Learn",1194,834],["IPAD-Speech","Speech Lab",1194,834],["IPAD-Progress","Progress",1194,834],["IPAD-Portrait","Learn",834,1194]];
  for(let i=0;i<specs.length;i++){
    const [key,section,w,h]=specs[i];
    if(extra.has(key)){report.frames.push({id:key,nodeId:extra.get(key),existing:true});continue;}
    const root=box(page,"Local · "+key+" · "+section,w,"HORIZONTAL");root.resize(w,h);root.layoutSizingVertical="FIXED";root.layoutSizingHorizontal="FIXED";root.itemSpacing=0;root.fills=bg;root.x=4500+(i%2)*1354;root.y=240+Math.floor(i/2)*1354;root.clipsContent=true;extra.set(key,root.id);
    const side=box(root,"Sidebar",220,"VERTICAL",20,12);side.layoutSizingVertical="FILL";side.fills=paint("#E1EBE3");
    text(side,"SpeechCoach",180,24,"Bold");text(side,"A little practice.\nA little braver.",180,13,"Regular","#526963");
    for(const [label]of TABS){const row=box(side,"Navigate · "+label,180,"VERTICAL",12);row.cornerRadius=12;if(label===section)row.fills=paint("#FFFFFF");text(row,label,156,17,label===section?"Semibold":"Regular");}
    text(side,"Profile & Settings",180,17,"Semibold");
    const main=box(root,"Main",w-220,"VERTICAL",24,20);main.layoutSizingVertical="FILL";
    const cw=w-268;text(main,section==="Learn"?"Describe your routine":section==="Speech Lab"?"Your story, your voice":"Your learning rhythm",cw,32,"Bold");
    text(main,section==="Learn"?"B1 · Grammar and everyday speaking":section==="Speech Lab"?"Introduction · Capture starts only on tap":"Private · This week",cw,17,"Regular","#526963");
    const body=box(main,"Scrollable learning area",cw,w>1000?"HORIZONTAL":"VERTICAL",0,20);body.layoutSizingVertical="FILL";body.clipsContent=true;body.overflowDirection="VERTICAL";
    const referenceWidth=w>1000?280:cw, workWidth=w>1000?cw-300:cw;
    const work=box(body,"Focused practice",workWidth);
    if(section==="Learn"){
      card(work,"She ___ work at nine.","Choose the verb that fits.",workWidth);
      for(const answer of ["○  start","●  starts","○  starting"]){const a=card(work,answer,"",workWidth);if(answer.startsWith("●"))a.fills=paint("#E1EBE3");}
      await button(work,"Check answer",workWidth,"EX-01-correct",root);
    }else if(section==="Speech Lab"){
      card(work,"Introduce yourself","What do you do, and what do you enjoy about it?",workWidth);
      card(work,"Ready to record","Built-in microphone · No audio is being captured.",workWidth);
      await button(work,"Start recording",workWidth,"SP-06",root);
      await button(work,"Quiet practice",workWidth,"EX-08",root);
    }else{
      card(work,"Four days of practice","A steady rhythm, one session at a time.",workWidth);
      card(work,"Skill evidence","Grammar: 8 activities\nVocabulary: 24 rated reviews\nSpeaking: 3 self-reviewed attempts\nListening: 2 activities\nReading: 4 activities",workWidth);
      await button(work,"View activity history",workWidth,"PG-02",root);
    }
    const ref=box(body,"Reference and context",referenceWidth);
    card(ref,section==="Learn"?"Keep the pattern close":section==="Speech Lab"?"Talking points":"Suggested focus",section==="Learn"?"I start work at nine.\nShe starts work at nine.\n\nWith he, she or it, often add -s.":section==="Speech Lab"?"Your role\nA typical day\nSomething you enjoy\n\nSamples stay hidden until requested.":"Try one concise spoken answer.\n\nXP records participation; it is not an English proficiency score.",referenceWidth);
    card(ref,"Your place is saved","Go back or leave at any time. Resume from Today later.",referenceWidth);
    report.frames.push({id:key,nodeId:root.id,width:w,height:h});
  }
  for(const r of report.prototypeLinks){const n=await figma.getNodeByIdAsync(r.nodeId),dest=await frame(r.target);await n.setReactionsAsync([{trigger:{type:"ON_CLICK"},actions:[{type:"NODE",destinationId:dest.id,navigation:"NAVIGATE",transition:null}]}]);}
  // Navigation between regular-width specimens; unsupported sections keep their existing compact destinations.
  for(const [key]of specs){
    const n=await frame(key);
    for(const [label,id]of TABS){
      const item=n.findOne(x=>x.name==="Navigate · "+label);const target=label==="Learn"?"IPAD-Learn":label==="Speech Lab"?"IPAD-Speech":label==="Progress"?"IPAD-Progress":id;
      const dest=await frame(target);if(dest.id!==n.id)await item.setReactionsAsync([{trigger:{type:"ON_CLICK"},actions:[{type:"NODE",destinationId:dest.id,navigation:"NAVIGATE",transition:null}]}]);
    }
  }
  figma.commitUndo();figma.currentPage.selection=[await frame("IPAD-Learn")];figma.viewport.scrollAndZoomIntoView(figma.currentPage.selection);
  return report;
}
figma.ui.onmessage=async message=>{
  if(busy)return;
  const allowed=["audit","repair","ipad","refine","states","review","focus","screenshot"];
  if(!message || !allowed.includes(message.op))return;
  busy=true;
  try{
    const page=await context();let report;
    if(message.op==="audit")report=await audit(page);
    if(message.op==="review")report=await reviewExport(page);
    if(message.op==="repair"){progress("Connecting documented routes…");report=await repair(page);}
    if(message.op==="ipad"){progress("Building editable iPad specimens…");report=await ipad(page);}
    if(message.op==="refine"){progress("Refining text flow and coach artwork…");report=await refine(page);}
    if(message.op==="states"){progress("Adding keyboard, validation and accessible states…");report=await states(page);}
    if(message.op==="focus"||message.op==="screenshot"){
      if(typeof message.screenId!=="string"||message.screenId.length>80)throw new Error("Enter a known screen ID.");
      const n=await frame(message.screenId);
      figma.currentPage.selection=[n];figma.viewport.scrollAndZoomIntoView([n]);
      report={operation:message.op,nodeId:n.id,name:n.name,width:n.width,height:n.height};
      if(message.op==="screenshot"){const bytes=await n.exportAsync({format:"PNG",constraint:{type:"SCALE",value:1}});figma.ui.postMessage({kind:"png",bytes:Array.from(bytes),name:message.screenId});}
    }
    figma.ui.postMessage({kind:"result",message:message.op+" complete",report});
  }catch(error){
    figma.ui.postMessage({kind:"error",message:error.message,report:{operation:message.op,error:error.message,warning:"An operation may have made partial changes. Inspect the canvas or Undo before retrying."}});
  }finally{busy=false;}
};
