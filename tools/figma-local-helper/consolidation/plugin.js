// Local, fixed-purpose design consolidation. No network or generic code execution.
figma.showUI(__html__, {width:560,height:620,themeColors:true});
const FILE='B1A9qEN1B7I3NJKISX39Dx';
async function original(){
 if(figma.editorType!=='figma'||(figma.fileKey&&figma.fileKey!==FILE))throw Error('Wrong design file.');
 const p=figma.root.children.find(p=>p.name==='Page 1');
 if(!p)throw Error('Original Page 1 missing.');
 await figma.setCurrentPageAsync(p);return p;
}
async function inspect(){
 const p=await original();
 return {operation:'inspect',pageId:p.id,pages:figma.root.children.map(p=>({id:p.id,name:p.name})),nodes:p.children.map(n=>({id:n.id,name:n.name,type:n.type,x:n.x,y:n.y,w:n.width,h:n.height})),components:p.findAllWithCriteria({types:['COMPONENT','COMPONENT_SET']}).map(n=>({id:n.id,name:n.name,w:n.width,h:n.height})),fonts:[...new Set(p.findAllWithCriteria({types:['TEXT']}).flatMap(t=>t.getStyledTextSegments(['fontName']).map(s=>JSON.stringify(s.fontName))))],collections:(await figma.variables.getLocalVariableCollectionsAsync()).map(c=>({id:c.id,name:c.name,count:c.variableIds.length,modes:c.modes})),styles:(await figma.getLocalTextStylesAsync()).map(s=>({id:s.id,name:s.name}))};
}
let busy=false;
figma.ui.onmessage=async m=>{if(busy)return;busy=true;try{
 let result;
 if(m.op==='inspect')result=await inspect();
 else if(m.op==='build')result=await build();
 else if(m.op==='finish')result=await finish();
 else if(m.op==='review')result=await review();
 else if(m.op==='focus'){result=await auditKit();const root=await figma.getNodeByIdAsync(result.rootNodeId);figma.currentPage.selection=[root.children[0]];figma.viewport.scrollAndZoomIntoView([root.children[0]]);}
 else throw Error('Unknown fixed operation.');
 figma.ui.postMessage(result);
 }catch(e){figma.ui.postMessage({error:String(e.message||e)})}finally{busy=false}};
