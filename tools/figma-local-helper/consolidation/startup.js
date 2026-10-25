// Fixed build on launch avoids unreliable iframe button automation.
// Never removes Page 2 automatically; inspect exported evidence first.
async function startPreparedKit(){
 if(busy)return;busy=true;
 try{
  const p=await original();
  const existing=p.children.find(n=>n.name===KIT);
  const result=existing?await auditKit():await build();
  figma.ui.postMessage(result);
  if(!existing){await repairKitLayout();await refineKitExamples();}
  const verified=await auditKit();
  console.log('SPEECHCOACH_KIT_REPORT '+JSON.stringify(verified));
  const root=await figma.getNodeByIdAsync(verified.rootNodeId);
  figma.currentPage.selection=[root.children[0]];
  figma.viewport.scrollAndZoomIntoView([root.children[0]]);
  const message='Page 1 kit built · '+verified.originalsRetained+' originals · '+verified.sections.length+' sections · '+verified.horizontalOverflow.length+' horizontal layout warnings · root '+verified.rootNodeId+' · '+verified.pages.length+' page(s)';
  figma.notify(message,{timeout:600000});
  figma.ui.postMessage(verified);
 }catch(e){console.error('SPEECHCOACH_KIT_ERROR '+String(e.message||e));figma.ui.postMessage({error:String(e.message||e)});figma.closePlugin('Kit stopped: '+String(e.message||e));}
 finally{busy=false;}
}
startPreparedKit();
