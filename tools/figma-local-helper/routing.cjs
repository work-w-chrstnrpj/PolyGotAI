"use strict";
// Pure routing rules; shared by the plugin and local verification.
const RETENTION = {
  "SP-11": { audio: "SP-11-both", text: "SP-11-none" },
  "SP-11-audio": { audio: "SP-11-none", text: "SP-11-both" },
  "SP-11-both": { audio: "SP-11", text: "SP-11-audio" },
  "SP-11-none": { audio: "SP-11-audio", text: "SP-11" }
};
function routedTarget(screenId, label, original) {
  if (screenId === "VO-05" && label === "Preview generated words") return "ST-06-vocabulary";
  if (screenId === "EX-08" && label === "Get AI feedback") return "ST-06-text";
  if (["SP-02", "EX-07", "SP-03", "SP-03-business", "SP-04", "SP-05"].includes(screenId) && original === "SP-06") return "SP-06-ready";
  if (screenId === "SP-07-replace" && label === "Record Take 2") return "SP-06-take2";
  return original;
}
function routeDefinitions(screen) {
  const out = [];
  for (const action of [screen.primary, screen.secondary]) {
    if (action) out.push({ name: "Action · " + action[0], target: routedTarget(screen.id, action[0], action[1]) });
  }
  for (const card of screen.cards || []) {
    if (card[4]) out.push({ name: "Card · " + card[1], target: routedTarget(screen.id, card[1], card[4]) });
  }
  const retention = RETENTION[screen.id];
  if (retention) {
    out.push({ name: "Card · Keep this recording", target: retention.audio });
    out.push({ name: "Card · Keep transcript and feedback", target: retention.text });
  }
  return out;
}
if (typeof module !== "undefined") module.exports = { RETENTION, routedTarget, routeDefinitions };
