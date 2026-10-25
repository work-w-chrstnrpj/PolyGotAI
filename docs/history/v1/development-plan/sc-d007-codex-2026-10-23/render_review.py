#!/usr/bin/env python3
"""Render the exact candidate for human review; no application writes."""
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent
manifest=json.loads((HERE/'publication-manifest.json').read_text())
bundle=json.loads((HERE/'candidate-bundle/CurriculumCatalog.json').read_text())
lines=['# A1 candidate review pack — SC-D007 proposal 1','',
       'Unpublished original authoring candidate, 2026-10-23. Exact volume and mappings await SC-T073 review. No educator approval, level certification or learning result is claimed.', '',
       'INTRO-01 version 3 is reused byte-for-byte at the decoded lesson level. The other twelve topics propose version 3; their current version 2 remains live. All existing vocabulary item/sense identities and audio bytes are retained.', '',
       'The bundle has 250 activities including reserved tasks. Sixty concept checks and twelve teaching/phonology/editorial records are separate review material, not silently inserted into required lesson completion.', '',
       '## Decision to record','',
       'SC-T073 asks the owner and applicable qualified reviewer to approve or revise the exact thirteen-topic allocation and each proposed core activity list in publication-manifest.json. Five production items per revised topic are a proposal for this pack, not a universal course rule. This volume does not by itself demonstrate complete A1 depth.', '',
       'Reviewer identity, qualifications, date, exact file hashes, changes requested, alternatives, listening accuracy, target opportunities and decision must be supplied by a real reviewer. Record no invented signature. SC-T043/SC-T028 expansion and pilot gates remain applicable to live integration.', '',
       '## References','',
       '- [Council of Europe, CEFR Companion volume (2020)](https://rm.coe.int/cefr-companion-volume-with-new-descriptors-2020/16809ea0d4): candidate scale references, printed pages 48, 54, 62, 78 and 132. Exact task fit remains unreviewed.',
       '- [British Council–EAQUALS Core Inventory](https://www.teachingenglish.org.uk/publications/case-studies-insights-and-research/british-council-eaquals-core-inventory-general): English-specific curriculum planning reference. No protected descriptor or exercise text is reproduced.', '']
for lesson in bundle['lessons']:
    row=next(x for x in manifest['lessons'] if x['lessonID']==lesson['id'])
    lines += [f'## {lesson["title"]} — {row["ticket"]}', '',
              f'Lesson `{lesson["id"]}` · objective `{lesson["objectiveId"]}` · content version `{lesson["contentVersion"]}`.', '']
    if lesson['id']=='intro-01':
        lines += ['Exact reuse. No second introduction lesson, changed task, altered core completion or repeated pilot is proposed. Existing foundation/rubric/editorial gaps remain with SC-T018 and actual learner evidence with SC-T043.', '']
    else:
        record=json.loads((HERE/'topics'/f'{lesson["id"]}.json').read_text())
        lines += [record['teaching'], '', 'Foundation allocation: '+', '.join(f'`{x}`' for x in record['childObjectiveIDs'])+'.', '',
                  '### Concept checks — editorial supplement', '']
        for n,item in enumerate(record['conceptChecks'],1):
            lines += [f'{n}. {item["prompt"]} Answer/example: {item["answer"]}']
        lines += ['', '### Pronunciation self-review', '',record['pronunciationSelfReview'], '',
                  '### Workplace connection', '',record['workplaceApplication'], '',
                  '### Completion and assessment', '',record['coreCompletionProposal']['rule'], '',
                  record['foundationEvidenceLimit'], '',
                  'Baseline, unfamiliar, day-7 and day-28 situations stay separate and hidden from normal practice. They are fresh authored prompts, not calibrated comparable forms. Actual support, modality, delay and target opportunities must be recorded. No new numeric passing threshold is selected.', '']
    lines += ['### Exact candidate activities','']
    for activity in lesson['activities']:
        status='reserved' if activity.get('withheldFromPractice') else ('required alternative' if activity.get('alternativeToActivityID') else 'required' if activity['required'] else 'optional')
        lines += [f'**{activity["id"]}** · {activity["kind"]} · {status}', '',activity.get('prompt',''), '',
                  'Answer/example: '+activity.get('answer',''), '']
        if activity.get('explanation'): lines += ['Teaching after attempt: '+activity['explanation'],'']
        if activity.get('assetId'):
            asset=next(x for x in bundle['assets'] if x['id']==activity['assetId'])
            lines += [f'[Exact existing reference audio](candidate-bundle/{asset["relativePath"]}) · SHA-256 `{asset["sha256"]}`.','']
(HERE/'review-pack.md').write_text('\n'.join(lines)+'\n')
print('Rendered review-pack.md from the exact candidate.')
