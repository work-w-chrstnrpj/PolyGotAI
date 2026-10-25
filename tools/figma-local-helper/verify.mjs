import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import vm from "node:vm";
import { createRequire } from "node:module";
import { fileURLToPath } from "node:url";
const dir=path.dirname(fileURLToPath(import.meta.url));
const require=createRequire(import.meta.url);
const {RETENTION,routedTarget,routeDefinitions}=require("./routing.cjs");
const screens=JSON.parse(fs.readFileSync(path.join(dir,"screens.json"),"utf8"));
const ids=new Set(screens.map(s=>s.id));ids.add("SP-06-take2");
assert.equal(screens.length,149);
for(const d of screens)for(const r of routeDefinitions(d))assert.ok(ids.has(r.target),"Unresolved destination: "+d.id+" → "+r.target);
assert.equal(routedTarget("VO-05","Preview generated words","ST-06"),"ST-06-vocabulary");
assert.equal(routedTarget("EX-08","Get AI feedback","ST-06"),"ST-06-text");
assert.equal(routedTarget("SP-06-paused","Resume recording","SP-06"),"SP-06");
assert.equal(routedTarget("SP-02","Ready to record","SP-06"),"SP-06-ready");
const states={"SP-11":[false,true],"SP-11-audio":[true,false],"SP-11-both":[true,true],"SP-11-none":[false,false]};
for(const [id,flags]of Object.entries(states))for(const [axis,index]of [["audio",0],["text",1]]){
 const result=[...flags];result[index]=!result[index];
 assert.deepEqual(states[RETENTION[id][axis]],result,"Retention toggles must change only their own choice.");
}
const manifest=JSON.parse(fs.readFileSync(path.join(dir,"manifest.json"),"utf8"));
assert.deepEqual(manifest.networkAccess.allowedDomains,["none"]);
const code=fs.readFileSync(path.join(dir,"code.js"),"utf8");
new vm.Script(code); // Parse the exact distributable, not only the source fragments.
assert.ok(!/\beval\s*\(|new Function\s*\(|\bfetch\s*\(|WebSocket/.test(code),"No arbitrary execution or external networking");
assert.ok(!/\.remove\s*\(/.test(code),"No destructive node-removal operation");
const fake={editorType:"figma",fileKey:"unrelated",root:{name:"Another file"},getNodeByIdAsync:async()=>null,showUI(){},ui:{postMessage(){}},setCurrentPageAsync(){throw new Error("Must reject before switching");}};
const runtime=vm.createContext({figma:fake,__html__:"",Map,Set,JSON,Promise,Array,Math,Error});
new vm.Script(code).runInContext(runtime);
await assert.rejects(vm.runInContext("context()",runtime),/not the expected SpeechCoachAI/);
console.log("PASS: 149 definitions; destination integrity; disclosure separation; four retention combinations; explicit recording start; network/destructive-operation guards; wrong-file rejection; distributable syntax.");
