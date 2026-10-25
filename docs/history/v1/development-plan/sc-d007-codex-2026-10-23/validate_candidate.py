#!/usr/bin/env python3
"""Non-mutating structural checks. No review approval, publication or learner data."""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
LIVE = ROOT / 'application/SpeechCoachAI/Resources/Curriculum'
EXPECTED = {'a1-greetings','intro-01','a1-alphabet','a1-numbers','a1-dates','family-01',
            'a1-home','routine-01','food-01','a1-shopping','a1-places','a1-hobbies','a1-weather'}
BASELINE = HERE / 'integration/baseline-catalog.json'
KINDS = {'reading','listening','grammar','recall','guidedSpeaking','quietText','selfReview'}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def unique(values, label):
    require(len(values) == len(set(values)), f'duplicate {label}')


def validate(bundle, manifest, live, directory):
    require(not bundle['editorialApprovalReference'].strip(), 'candidate must remain unpublished')
    require(manifest['publicationApproved'] is False and manifest['ownerApproval'] is None
            and manifest['qualifiedReviewer'] is None, 'unrecorded approval')
    lessons = bundle['lessons']
    unique([x['id'] for x in lessons], 'lesson identity')
    require({x['id'] for x in lessons} == EXPECTED, 'A1 topic coverage')
    unique([x['id'] for x in bundle['assets']], 'asset identity')
    assets = {x['id']:x for x in bundle['assets']}
    for asset in assets.values():
        relative = Path(asset['relativePath'])
        require(not relative.is_absolute() and '..' not in relative.parts, 'unsafe asset path')
        raw = (directory/relative).read_bytes()
        require(len(raw)==asset['byteCount'] and hashlib.sha256(raw).hexdigest()==asset['sha256'], 'asset integrity')
    originals = {x['id']:x for x in live['lessons']}
    for lesson in lessons:
        lid = lesson['id']; source = originals[lid]
        require(lesson['level']=='A1' and lesson['objectiveId']==source['objectiveId'], 'objective history changed')
        require(lesson['senses']==source['senses'], 'shared sense identity/meaning changed')
        if lid=='intro-01':
            require(lesson==source, 'INTRO-01 must be reused exactly')
            continue
        require(lesson['contentVersion']=='3' and source['contentVersion']=='2', 'revision version')
        activities = lesson['activities']; unique([x['id'] for x in activities], 'activity identity')
        require(all(x['kind'] in KINDS for x in activities), 'unsupported activity')
        practice = [x for x in activities if not x.get('withheldFromPractice')]
        require({'reading','listening','grammar','recall','guidedSpeaking','quietText','selfReview'} <= {x['kind'] for x in practice}, 'five-skill/quiet structure')
        for activity in activities:
            require(bool(activity.get('prompt','').strip()), 'empty prompt')
            require(bool(activity.get('answer','').strip()), 'empty example/answer')
            if activity.get('assetId'):
                require(activity['assetId'] in assets, 'missing required asset')
        guided = [x for x in practice if x['kind']=='guidedSpeaking']
        quiet = [x for x in practice if x['kind']=='quietText']
        require(len(guided)==len(quiet)==1 and quiet[0]['alternativeToActivityID']==guided[0]['id'], 'quiet substitution')
        for purpose in ['baseline','day7','day28']:
            activity = next((a for a in activities if a['id']==f'{lid}-{purpose}-v3'), None)
            require(activity is not None and activity['withheldFromPractice'] is True and not activity['required'], 'reserved task leaked')
        reserved = [x for x in activities if x.get('withheldFromPractice')]
        require(len(reserved)==4, 'baseline/transfer/delay separation')
        unique([x['prompt'] for x in reserved], 'independent task wording')
        productions = [x for x in activities if x['kind']=='grammar']
        require(len(productions)==5 and all(x.get('explanation') and x.get('childObjectiveIds') for x in productions), 'production explanations/objectives')
    unique([x['lessonID'] for x in manifest['lessons']], 'allocation')
    require({x['lessonID'] for x in manifest['lessons']}==EXPECTED, 'allocation mismatch')
    require(len(manifest['grammarCoverage'])==10, 'grammar allocation incomplete')
    return {'topics':len(lessons),'assets':len(assets),'activities':sum(len(x['activities']) for x in lessons),
            'newProductionItems':60,'newConceptItems':60,'newTeachingSidecars':12,
            'candidateMatchesApprovedBaseline':True,'publicationApproved':False}


def main():
    raw=(BASELINE if BASELINE.exists() else LIVE/'CurriculumCatalog.json').read_bytes()
    manifest=json.loads((HERE/'publication-manifest.json').read_text())
    require(hashlib.sha256(raw).hexdigest()==manifest['sourceCatalogSHA256'], 'live source drift: rebase candidate before integration')
    result=validate(json.loads((HERE/'candidate-bundle/CurriculumCatalog.json').read_text()),manifest,json.loads(raw),HERE/'candidate-bundle')
    for row in manifest['lessons']:
        if row['mode']=='exact_reuse': continue
        topic=json.loads((HERE/'topics'/f'{row["lessonID"]}.json').read_text())
        require(topic['editorialState']=='ready_for_review' and topic['qualifiedReviewer'] is None, 'unrecorded topic review')
        require(len(topic['conceptChecks'])==5, 'concept coverage')
        unique([x['id'] for x in topic['conceptChecks']], 'concept identity')
        require(all(x['prompt'].strip() and x['answer'].strip() for x in topic['conceptChecks']), 'empty concept check')
        require(set(topic['childObjectiveIDs'])==set(row['childObjectiveIDs']), 'foundation allocation mismatch')
    result['liveCatalogIntegrated'] = (LIVE/'CurriculumCatalog.json').read_bytes() != raw
    print(json.dumps(result,indent=2))

if __name__=='__main__':
    main()
