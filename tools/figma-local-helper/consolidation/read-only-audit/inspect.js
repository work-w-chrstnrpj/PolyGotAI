// Fixed-purpose read-only SC-T007 inspection. No document mutations, selection changes or networking.
figma.showUI(__html__,{width:560,height:320,themeColors:true});
(async()=>{
 try{
  if(figma.editorType!=='figma'||(figma.fileKey&&figma.fileKey!=='B1A9qEN1B7I3NJKISX39Dx')||figma.currentPage.id!=='0:1')throw Error('Open SpeechCoachAI file B1A9qEN1B7I3NJKISX39Dx, Page 1 (0:1).');
  if(!figma.root.name.includes('SpeechCoachAI'))throw Error('Unexpected document name.');
  figma.ui.postMessage({kind:'progress',text:'Identity verified; reading saved reference.'});
  const page=figma.currentPage,root=await figma.getNodeByIdAsync('41:1074');
  if(!root||root.parent!==page)throw Error('Expected retained reference root missing.');
  const report={operation:'read-only-readiness-audit',date:new Date().toISOString(),fileKey:figma.fileKey||null,expectedFileKey:'B1A9qEN1B7I3NJKISX39Dx',documentName:figma.root.name,page:{id:page.id,name:page.name},rootId:root.id,pages:figma.root.children.map(p=>({id:p.id,name:p.name})),nodes:[],collections:[],variables:[],textStyles:[],images:[],limitations:['API inspection does not establish copyright, cloud persistence, contrast across all states, or native runtime acceptance.']};
  const hashes=new Map();
  function val(v){if(typeof v==='symbol')return 'MIXED';return JSON.parse(JSON.stringify(v));}
  const properties=['visible','opacity','x','y','width','height','layoutMode','layoutSizingHorizontal','layoutSizingVertical','primaryAxisSizingMode','counterAxisSizingMode','paddingTop','paddingBottom','paddingLeft','paddingRight','itemSpacing','cornerRadius','fills','strokes','strokeWeight','effects','boundVariables','explicitVariableModes','resolvedVariableModes','componentProperties','componentPropertyDefinitions','componentPropertyReferences','variantProperties','textStyleId','characters','fontName','fontSize','lineHeight','letterSpacing','textAutoResize','constraints','exportSettings'];
  for(const n of [root,...root.findAll()]){
   const r={id:n.id,parentId:n.parent&&n.parent.id,name:n.name,type:n.type};
   for(const k of properties)if(k in n){try{r[k]=val(n[k]);}catch(e){r[k+'Error']=String(e.message||e);}}
   if(n.type==='INSTANCE'){try{const m=await n.getMainComponentAsync();r.mainComponentId=m&&m.id;}catch(e){r.mainComponentError=String(e.message||e);}}
   if(n.type==='TEXT')r.textSegments=n.getStyledTextSegments(['fontName','fontSize','textStyleId','fills','boundVariables']).map(val);
   for(const kind of ['fills','strokes'])if(Array.isArray(r[kind]))for(const paint of r[kind])if(paint.type==='IMAGE'&&paint.imageHash){if(!hashes.has(paint.imageHash))hashes.set(paint.imageHash,[]);hashes.get(paint.imageHash).push({nodeId:n.id,name:n.name,kind,scaleMode:paint.scaleMode,imageTransform:paint.imageTransform});}
   report.nodes.push(r);
  }
  figma.ui.postMessage({kind:'progress',text:'Read '+report.nodes.length+' nodes; collecting variables.'});
  for(const c of await figma.variables.getLocalVariableCollectionsAsync())report.collections.push({id:c.id,name:c.name,modes:c.modes,defaultModeId:c.defaultModeId,variableIds:c.variableIds});
  for(const v of await figma.variables.getLocalVariablesAsync())report.variables.push({id:v.id,name:v.name,type:v.resolvedType,collectionId:v.variableCollectionId,valuesByMode:val(v.valuesByMode),scopes:v.scopes,description:v.description,codeSyntax:v.codeSyntax});
  for(const s of await figma.getLocalTextStylesAsync())report.textStyles.push({id:s.id,name:s.name,fontName:s.fontName,fontSize:s.fontSize,lineHeight:s.lineHeight,letterSpacing:s.letterSpacing});
  figma.ui.postMessage({kind:'progress',text:'Reading '+hashes.size+' original source images.'});
  for(const [hash,uses] of hashes)report.images.push({hash,uses,availableInLiveDocument:!!figma.getImageByHash(hash)});
  figma.ui.postMessage({kind:'report',report});
 }catch(e){figma.ui.postMessage({kind:'error',error:String(e.message||e)});}
})();
