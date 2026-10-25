// Named local operations. Never changes or removes Page 1 nodes.
async function reflow(root,report,large=false) {
  await loadFonts(root);
  for(const t of root.findAllWithCriteria({types:["TEXT"]})){
    if(t.parent.type==="FRAME" && t.parent.layoutMode!=="NONE"){
      const content=t.characters;
      if(large && !t.parent.name.startsWith("Touch target") && !t.parent.name.startsWith("Status")){
        t.fontSize=Math.max(t.fontSize*1.45,20);t.lineHeight={unit:"PERCENT",value:130};
      }
      t.textAutoResize="HEIGHT";t.layoutSizingVertical="HUG";t.characters=content;
      report.mutatedNodeIds.push(t.id);
    }
  }
  for(const n of root.findAllWithCriteria({types:["INSTANCE"]}).filter(n=>n.name.startsWith("Action ·"))){
    for(const t of n.findAllWithCriteria({types:["TEXT"]})){t.textAlignHorizontal="CENTER";t.layoutSizingHorizontal="FILL";report.mutatedNodeIds.push(t.id);}
    if(large){n.resize(n.width,72);n.layoutSizingVertical="FIXED";report.mutatedNodeIds.push(n.id);}
  }
}
async function refine(page){
  const report={operation:"refine",createdNodeIds:[],mutatedNodeIds:[],artworkSource:"2:37997",reviewFrames:[]};
  for(const [key]of extra){const n=await frame(key);await reflow(n,report);report.reviewFrames.push({id:key,nodeId:n.id});
    for(const row of n.findAll(x=>x.type==="FRAME" && ["Key row","Keyboard actions"].includes(x.name))) {
      row.layoutSizingVertical="HUG";row.counterAxisSizingMode="AUTO";report.mutatedNodeIds.push(row.id);
    }
    for(const keycap of n.findAll(x=>x.type==="FRAME" && (x.name.startsWith("Key · ")||["123","space","Done"].includes(x.name)))) {
      keycap.primaryAxisSizingMode="FIXED";keycap.resize(keycap.width,44);keycap.layoutSizingVertical="FIXED";report.mutatedNodeIds.push(keycap.id);
    }
  }
  const source=await figma.getNodeByIdAsync("2:37997");
  if(!source||source.type!=="RECTANGLE")throw new Error("Expected Page 1 coach illustration is unavailable.");
  const ids=["ON-01","ON-04","TD-01","SP-09","SP-09-no-correction","PG-03","PG-04","AX-01","AX-01-atlas","AX-01-studio","AX-01-dark","AX-01-atlas-dark","AX-01-studio-dark"];
  for(const id of ids){
    const root=await frame(id);
    if(root.findOne(n=>n.name==="Coach artwork · from Page 1"))continue;
    const content=root.findOne(n=>n.name==="Content");
    const hero=content && content.children.find(n=>n.type==="FRAME"&&n.name.startsWith("Card ·"));
    if(!hero)continue;
    await loadFonts(hero);
    const title=hero.children.find(n=>n.type==="TEXT");if(!title)continue;
    const row=figma.createFrame();hero.insertChild(0,row);row.name="Coach greeting";row.layoutMode="HORIZONTAL";row.fills=[];row.itemSpacing=12;row.counterAxisAlignItems="CENTER";
    row.resize(hero.width-32,80);row.layoutSizingHorizontal="FIXED";row.layoutSizingVertical="HUG";
    const art=source.clone();row.appendChild(art);art.name="Coach artwork · from Page 1";art.resize(72,76.32);art.layoutSizingHorizontal="FIXED";art.layoutSizingVertical="FIXED";
    row.appendChild(title);title.resize(hero.width-32-84,title.height);title.textAutoResize="HEIGHT";title.layoutSizingHorizontal="FIXED";title.layoutSizingVertical="HUG";
    report.createdNodeIds.push(row.id,art.id);report.mutatedNodeIds.push(hero.id,title.id);report.reviewFrames.push({id,nodeId:root.id});
  }
  // Distinct quiet, editable decorations stay in theme previews, away from exercises.
  for(const [id,kind]of [["AX-01","academy"],["AX-01-atlas","atlas"],["AX-01-studio","studio"],["AX-01-dark","academy"],["AX-01-atlas-dark","atlas"],["AX-01-studio-dark","studio"]]){
    const root=await frame(id);if(root.findOne(n=>n.name==="Background motif"))continue;
    const header=root.findOne(n=>n.name==="Header");if(!header)continue;
    const svgs={
      academy:'<svg width="345" height="22" xmlns="http://www.w3.org/2000/svg"><path d="M0 11h345" stroke="#B4C9B9"/><path d="M8 5l6 12M14 5L8 17M330 5v12M324 11h12" stroke="#176C60" stroke-width="2"/></svg>',
      atlas:'<svg width="345" height="22" xmlns="http://www.w3.org/2000/svg"><path d="M0 15c48-28 67 18 116 0s70-6 116 0 68-23 113-8" fill="none" stroke="#638FAB" stroke-width="2" stroke-dasharray="4 5"/><circle cx="172" cy="8" r="4" fill="#C96B50"/></svg>',
      studio:'<svg width="345" height="22" xmlns="http://www.w3.org/2000/svg"><rect x="0" y="7" width="110" height="9" rx="2" fill="#ADA5CD"/><path d="M130 17l12-13 10 13M164 8l36 8M208 5l19 10 26-9" fill="none" stroke="#8073A8" stroke-width="2"/><rect x="285" y="4" width="60" height="14" fill="#D9BD8B"/></svg>'
    };
    const motif=figma.createNodeFromSvg(svgs[kind]);header.appendChild(motif);motif.name="Background motif";report.createdNodeIds.push(motif.id,...motif.findAll(()=>true).map(n=>n.id));
  }
  figma.commitUndo();return report;
}
async function states(page){
  const report={operation:"states",createdNodeIds:[],mutatedNodeIds:[],frames:[],note:"Static design states. Keyboard, input and runtime validation are not implemented by the prototype."};
  await Promise.all(["Regular","Semibold","Bold"].map(style=>figma.loadFontAsync({family:"SF Pro",style})));
  function text(parent,str,w,size=17,weight="Regular",color="#213D39"){
    const n=figma.createText();parent.appendChild(n);n.fontName={family:"SF Pro",style:weight};n.fontSize=size;n.lineHeight={unit:"PERCENT",value:130};
    n.resize(w,80);n.textAutoResize="HEIGHT";n.characters=str;n.layoutSizingHorizontal="FIXED";n.layoutSizingVertical="HUG";n.fills=paint(color);report.createdNodeIds.push(n.id);return n;
  }
  function auto(parent,name,w,dir="VERTICAL",pad=0,gap=8){
    const n=figma.createFrame();parent.appendChild(n);n.name=name;n.layoutMode=dir;n.resize(w,1);n.primaryAxisSizingMode="AUTO";n.counterAxisSizingMode="FIXED";
    n.fills=[];n.paddingLeft=pad;n.paddingRight=pad;n.paddingTop=pad;n.paddingBottom=pad;n.itemSpacing=gap;report.createdNodeIds.push(n.id);return n;
  }
  const specs=[
    ["KEYBOARD-Missing","EX-03","keyboard"],["KEYBOARD-Correction","EX-04","keyboard"],["KEYBOARD-Response","EX-08","keyboard"],
    ["LARGE-Today","TD-01","large"],["LARGE-Save","SP-11","large"],["LARGE-Recording","SP-06-ready","large"],
    ["INPUT-Nickname","ON-01","validation"],["WORD-Duplicate","VO-04","duplicate"],["AUDIO-Unavailable","EX-05","audio"],
    ["ASR-Empty","SP-08","asr"],["GEN-Empty","VO-06","generation"],["IPAD-Compact","EX-01","compact"],["FOCUS-Answer","EX-01","focus"]
  ];
  for(let i=0;i<specs.length;i++){
    const [key,base,kind]=specs[i];if(extra.has(key)){report.frames.push({id:key,nodeId:extra.get(key),existing:true});continue;}
    const original=await frame(base);await loadFonts(original);const n=original.clone();page.appendChild(n);n.name="Local · "+key+" · "+base;n.x=4500+(i%3)*520;n.y=3200+Math.floor(i/3)*1120;
    extra.set(key,n.id);report.createdNodeIds.push(n.id,...n.findAll(()=>true).map(n=>n.id));
    if(kind==="large")await reflow(n,report,true);
    if(kind==="compact")n.resize(393,834);
    if(kind==="keyboard"){
      const keys=auto(n,"Keyboard · iOS input specimen",393,"VERTICAL",8,8);keys.fills=paint("#D7DBDD");keys.resize(393,276);keys.layoutSizingVertical="FIXED";
      for(const letters of ["QWERTYUIOP","ASDFGHJKL","ZXCVBNM"]){
        const row=auto(keys,"Key row",377,"HORIZONTAL",0,4);row.primaryAxisAlignItems="CENTER";
        for(const letter of letters){const key=auto(row,"Key · "+letter,32,"VERTICAL",0,0);key.resize(32,44);key.layoutSizingVertical="FIXED";key.primaryAxisAlignItems="CENTER";key.counterAxisAlignItems="CENTER";key.fills=paint("#FFFFFF");key.cornerRadius=5;const label=text(key,letter,32,18);label.textAlignHorizontal="CENTER";}
      }
      const row=auto(keys,"Keyboard actions",377,"HORIZONTAL",0,8);row.primaryAxisAlignItems="CENTER";
      for(const [label,w]of [["123",50],["space",205],["Done",86]]){const key=auto(row,label,w,"VERTICAL",0);key.resize(w,44);key.layoutSizingVertical="FIXED";key.primaryAxisAlignItems="CENTER";key.fills=paint("#FFFFFF");key.cornerRadius=5;const labelNode=text(key,label,w,16);labelNode.textAlignHorizontal="CENTER";}
      const dismiss=keys.findOne(x=>x.name==="Done");await link(dismiss,base,n,{createdNodeIds:report.createdNodeIds,mutatedNodeIds:report.mutatedNodeIds,linkCount:0});
    }
    const info={
      validation:["Choose a name to continue","Enter a nickname, or use a default name and change it later."],
      duplicate:["This word is already saved","Open the existing meaning or save a different sense."],
      audio:["Reference audio is unavailable","Read the text or choose another activity. No audio plays automatically."],
      asr:["No speech was recognized","Replay your take, try a fresh recording, or continue with self-review."],
      generation:["No useful words were returned","Try another topic or add words manually. Nothing was enrolled."],
    }[kind];
    if(info){
      const content=n.findOne(x=>x.name==="Content");const notice=auto(content,"State message",345,"VERTICAL",16,8);content.insertChild(0,notice);notice.cornerRadius=16;notice.fills=paint("#F2E8D9");
      text(notice,info[0],313,20,"Semibold");text(notice,info[1],313);
      const action=n.findOne(x=>x.name.startsWith("Action ·") && x.type==="INSTANCE");
      const target=kind==="duplicate"?"VO-04":kind==="audio"?"EX-06":kind==="asr"?"SP-10":kind==="generation"?"VO-04":"ON-02";
      if(action){await loadFonts(action);const label={validation:"Use default name",duplicate:"Open saved word",audio:"Try quiet reading",asr:"Finish self-review",generation:"Add a word manually"}[kind];
        action.name="Action · "+label;for(const t of action.findAllWithCriteria({types:["TEXT"]}))t.characters=label;
        await link(action,target,n,{createdNodeIds:report.createdNodeIds,mutatedNodeIds:report.mutatedNodeIds,linkCount:0});
      }
    }
    if(kind==="focus"){const button=n.findOne(x=>x.name==="Action · Check answer");button.strokes=paint("#155B97");button.strokeWeight=3;button.strokeAlign="OUTSIDE";report.mutatedNodeIds.push(button.id);}
    report.frames.push({id:key,nodeId:n.id,width:n.width,height:n.height});
  }
  // Reach new states from existing, meaningful controls.
  for(const [base,label,target]of [["EX-03","Card · Your answer","KEYBOARD-Missing"],["EX-04","Card · Your correction","KEYBOARD-Correction"],["EX-08","Card · Your response","KEYBOARD-Response"]]){
    const root=await frame(base);const n=root.findOne(x=>x.name===label);if(n)await link(n,target,root,{createdNodeIds:report.createdNodeIds,mutatedNodeIds:report.mutatedNodeIds,linkCount:0});
  }
  figma.commitUndo();return report;
}

// Read-only review export. The source nodes and Page 1 remain untouched.
async function reviewExport(page){
  const references=[["REF-Today","2:37969"],["REF-Learn","2:38130"],["REF-Recording","2:38407"],["REF-Progress","2:38732"],["REF-Coaches","2:39240"],["REF-Components","2:40070"],["REF-Appearance","2:38893"]];
  const entries=[...references,...PROJECT.frames.map(n=>[n.id,n.nodeId]),...[...extra]];
  const report={operation:"review",page:page.id,frames:[],warnings:[],note:"Read-only rendered screen review; prototype and native runtime acceptance are separate."};
  figma.ui.postMessage({kind:"archive-start"});
  function describe(n,depth=0){
    const o={id:n.id,name:n.name,type:n.type,x:n.x,y:n.y,width:n.width,height:n.height};
    if(n.type==="TEXT"){o.text=n.characters;o.size=n.fontSize;o.font=n.fontName;o.lineHeight=n.lineHeight;}
    if("fills" in n && Array.isArray(n.fills))o.fills=n.fills;
    if("layoutMode" in n){o.layout=n.layoutMode;o.spacing=n.itemSpacing;o.padding=[n.paddingTop,n.paddingRight,n.paddingBottom,n.paddingLeft];o.radius=n.cornerRadius;}
    if("children" in n&&depth<4)o.children=n.children.map(c=>describe(c,depth+1));
    return o;
  }
  for(let i=0;i<entries.length;i++){
    const [id,nodeId]=entries[i],n=await figma.getNodeByIdAsync(nodeId);if(!n)continue;
    progress("Review export "+(i+1)+" / "+entries.length+" · "+id);
    const bytes=await n.exportAsync({format:"PNG",constraint:{type:"SCALE",value:id.startsWith("IPAD-")?.75:1}});
    figma.ui.postMessage({kind:"archive-file",name:id+".png",bytes:Array.from(bytes)});
    report.frames.push({screen:id,...describe(n)});
    if(!id.startsWith("REF-"))for(const t of n.findAllWithCriteria({types:["TEXT"]})){
      if(t.visible && t.parent.type==="FRAME" && t.parent.layoutMode!=="NONE" && t.x+t.width>t.parent.width+1)report.warnings.push({screen:id,node:t.id,issue:"Horizontal text overflow",text:t.characters});
    }
  }
  figma.ui.postMessage({kind:"archive-file",name:"review.json",text:JSON.stringify(report,null,2)});
  figma.ui.postMessage({kind:"archive-end",name:"speechcoach-visual-review.zip"});
  return {operation:"review",exported:report.frames.length,warnings:report.warnings};
}
