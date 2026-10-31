#!/usr/bin/env python3
"""Build Phase 13 topic lessons from frozen original app content and an editorial outline.

Idempotent. Never reads learner data or reruns the old stage scripts. Exact source
versions are retained in archivedLessons and never count as current browse lessons.
"""
from __future__ import annotations
import copy
import itertools
import json
import re
from pathlib import Path
from topic_outline import GRAMMAR, TITLES, EXTRAS
import grammar_more
from topic_reading import READING
from track_lib import register_rewards
from validate import fold, giveaway_problems, reading_giveaway

ROOT = Path(__file__).resolve().parents[2]
RES = ROOT / 'application/SpeechCoachAI/Resources'
SOURCES = Path(__file__).parent / 'topic_sources'
VERSION = '2'

APPLICATION = {
'grammarian': 'Work from meaning to form. First decide what the sentence needs to express, then choose the noun, verb or linking pattern that expresses it. Read the complete sentence after editing; a form that works on its own may not fit its subject, time reference or surrounding clause.',
'business': 'Before using these patterns at work, name your listener and the decision or action you need. Keep the useful context, make the request explicit and check that the next step has an owner. The same message may need a warmer opening for a colleague and a shorter summary for a busy decision-maker.',
'copywriter': 'Read the copy from the reader’s point of view. Identify the promise, the evidence for that promise and the action the reader can take. Keep claims proportionate to the proof. A clear benefit and an honest next step are more useful than impressive wording that leaves the offer uncertain.',
'creative-writer': 'Try the technique in a small scene before applying it across a story. Give the character a specific desire and let the chosen details change what the reader notices. During revision, ask what each sentence contributes to action, atmosphere or viewpoint; keep deliberate choices rather than adding decoration everywhere.',
'debater': 'Test the reasoning before polishing the wording. State the claim in a form someone could disagree with, connect the evidence to that claim and identify what the evidence leaves uncertain. When answering another argument, represent its strongest relevant point fairly before explaining your own response.',
'journalist': 'Separate what you observed, what a source claims and what remains unconfirmed. Give the reader enough context to understand the evidence without presenting an inference as an established fact. Attribution identifies who is responsible for a statement; verification asks whether that statement can be supported.',
'negotiator': 'Prepare language that protects the relationship while making your limits clear. Ask what matters to the other person, distinguish a request from a commitment and check the conditions attached to any offer. An agreement is useful only when both sides understand the actions, responsibilities and timing.',
'public-speaker': 'Use these techniques to serve the audience’s understanding, not to perform a fixed speaking style. Decide what listeners should remember, choose one concrete example and rehearse the transitions aloud. Adapt pace, pauses and movement to the room and the message rather than forcing every sentence to sound dramatic.',
'reading-listening': 'Choose a reading or listening purpose before you begin. For an overview, look for the main point and the relationship between ideas; for a detail, locate the relevant evidence and check its context. When you infer a meaning, keep the words that support your inference separate from your own assumptions.',
'storyteller': 'Tell the story to someone, not merely at them. Select the moment of change, keep the details that help a listener follow it and make the ending connect to the beginning. Rehearse aloud, then shorten or expand the telling without changing what the events actually support.',
}

def sentence(text):
    return re.split(r'(?<=[.!?])\s+', text.strip())[0]

def worked_example(source):
    # A worked problem keeps the question and answer together. A negative-choice
    # answer is never presented as an exemplary sentence without its question.
    for activity in source['activities']:
        ex = activity.get('exercise') or {}
        if ex.get('type') == 'choice' and ex.get('accepted') and ex['accepted'][0] not in ['True','False']:
            return {'prompt': activity['prompt'], 'answer': ex['accepted'][0], 'explanation': sentence(source['tip'])}
        if ex.get('type') == 'wordBank' and ex.get('accepted'):
            return {'prompt': activity['prompt'], 'answer': ex['accepted'][0], 'explanation': sentence(source['tip'])}
    raise ValueError('No worked example: '+source['id'])

def make_lesson(coach, stage, unit, title, sources):
    slug = re.sub(r'[^a-z0-9]+','-',title.lower()).strip('-')
    lid = f'{coach}-topic-{slug}'
    written = READING.get(coach, {}).get(title)
    if written:
        # Written topic pages: a heading, a full explanation and labelled example sentences.
        sections = [{'id': f'{lid}-read-{n+1}', 'heading': heading, 'explanation': text,
                     'examples': [{'prompt': label, 'answer': sample, 'explanation': note} for label, sample, note in examples]}
                    for n, (heading, text, examples) in enumerate(written)]
    else:
        sections = []
        for n, source in enumerate(sources):
            teaching = source['tip']
            if source['id'] == 'gram-f-quant':
                teaching = teaching.replace('Words like advice and information are never plural.', 'In their ordinary general meanings, advice and information are uncountable; say a piece of advice or two pieces of information when you need to count them.')
            sections.append({'id': f'{lid}-read-{n+1}', 'heading': source['title'], 'explanation': teaching,
                             'examples': [worked_example(source)]})
    printed = [fold(s['explanation']) + ' ' + ' '.join(fold(e['answer']) for e in s['examples']) for s in sections]
    if not sources:
        # A newly written topic (grammar_more.py): its own checked exercises, kept in authored order.
        chosen = copy.deepcopy(grammar_more.ITEMS[title])
        for item in chosen:
            problems = giveaway_problems({**item,'id':lid}, printed)
            if problems or reading_giveaway(item, sections): raise ValueError(f'{title}: give-away in “{item["prompt"]}” {problems}')
            printed.append(fold(item.get('prompt',''))+' '+fold(item.get('body','')))
        return finish(coach, stage, unit, title, lid, sections, chosen, grammar_more.CREDITS, [])
    pools = [[copy.deepcopy(a) for a in source['activities'] if a.get('exercise',{}).get('type') not in [None,'open']] for source in sources]
    # Round robin gives every source subtopic a place before filling the round.
    chosen, seen = [], set()
    for values in itertools.zip_longest(*pools):
        for original, source in zip(values, sources):
            if original is None: continue
            ex = original['exercise']
            key = (original.get('prompt'), json.dumps(ex,sort_keys=True,ensure_ascii=False))
            if key in seen or giveaway_problems(original, printed) or reading_giveaway(original, sections): continue
            seen.add(key)
            original['explanation'] = sentence(source['tip'])
            chosen.append(original)
            printed.append(fold(original.get('prompt',''))+' '+fold(original.get('body','')))
            if len(chosen) == 18: break
        if len(chosen) == 18: break
    for question, correct, wrong in EXTRAS.get(title, []):
        if len(chosen) == 18: break
        item = {'kind':'grammar','required':True,'prompt':question,'answer':correct,
                'explanation':sentence(sources[0]['tip']),
                'exercise':{'type':'choice','options':[correct]+wrong,'accepted':[correct]}}
        if giveaway_problems({**item,'id':lid},printed): raise ValueError('New task giveaway: '+question)
        chosen.append(item)
    credits = list(dict.fromkeys(c for source in sources for c in source['sources']))
    return finish(coach, stage, unit, title, lid, sections, chosen, credits, [s['id'] for s in sources])

def finish(coach, stage, unit, title, lid, sections, chosen, credits, source_ids):
    if not 15 <= len(chosen) <= 18: raise ValueError(f'{title}: only {len(chosen)} checked items')
    # Preserve recall exemptions when assigning stable new activity identities.
    for n, item in enumerate(chosen):
        recall = '-recall' if 'recall' in item.get('id','') else ''
        item['id'] = f'{lid}-{n+1:02d}{recall}'
    chosen.append({'id':lid+'-your-turn','kind':'grammar','required':True,
                   'prompt':f'Your turn. Use what you learned about {title.lower()} in a short example of your own. Explain one choice you made.',
                   'answer':'A clear example that applies the lesson’s ideas.', 'exercise':{'type':'open'}})
    return {'id':lid,'contentVersion':VERSION,'level':stage['title'],'title':title,
            'objectiveId':'TOPIC-'+lid.upper(),'trackId':coach,'unitId':unit,
            'tip':APPLICATION[coach], 'sources':credits, 'senses':[], 'reading':sections,
            'sourceLessonIDs':source_ids, 'activities':chosen}

def grammar_outline():
    """The Phase 13 grammar outline with the 2026-10-30 topics placed before or after their anchors."""
    outline = list(GRAMMAR)
    for stage_id, unit, title, (where, anchor) in grammar_more.MORE:
        at = next(n for n, entry in enumerate(outline) if entry[2] == anchor)
        outline.insert(at + (where == 'after'), (stage_id, unit, title, []))
    return outline

def build():
    count = 0
    for path in sorted(SOURCES.glob('track-*.json')):
        pack = json.loads(path.read_text()); coach = pack['track']['id']
        old = {l['id']:l for l in pack['lessons']}
        topics = []
        if coach == 'grammarian':
            for stage_id, unit, title, ids in grammar_outline():
                stage = next(s for s in pack['track']['stages'] if s['id']==stage_id)
                topics.append(make_lesson(coach,stage,unit,title,[old[i] for i in ids]))
        else:
            titles = iter(TITLES[coach])
            for stage in pack['track']['stages']:
                for unit in stage['units']:
                    lessons = [l for l in pack['lessons'] if l['unitId']==unit['id']]
                    for index in range(0,len(lessons),2):
                        topics.append(make_lesson(coach,stage,unit['id'],next(titles),lessons[index:index+2]))
        covered = [x for l in topics for x in l['sourceLessonIDs']]
        if set(covered)!=set(old) or len(covered)!=len(set(covered)): raise ValueError('Missing/duplicate source topic '+coach)
        # Retain stage order, dropping units now consolidated into another topic.
        for stage in pack['track']['stages']:
            stage['units'] = [u for u in stage['units'] if any(l['unitId']==u['id'] for l in topics)]
        pack['archivedLessons'] = pack.get('archivedLessons',[]) + pack['lessons']
        pack['lessons'] = topics; pack['contentVersion'] = VERSION
        pack['editorialApprovalReference'] = 'Phase 13 topic consolidation authored 2026-10-26 for personal practice. Qualified editorial review and learning validation remain pending.'
        pack['rightsReference'] += ' Phase 13 reorganizes original app teaching into topic pages with worked examples; original exercise wording is retained where suitable.'
        (RES/'Tracks'/path.name).write_text(json.dumps(pack,ensure_ascii=False,indent=2)+'\n')
        register_rewards([l['id'] for l in topics],VERSION)
        print(coach,len(old),'→',len(topics)); count += len(topics)
    print('Topic lessons:',count)

if __name__=='__main__': build()
