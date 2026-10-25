#!/usr/bin/env python3
"""Apply the bounded personal-use INTRO-01 v4 correction, preserving exact v3 history."""
import copy
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CATALOG = ROOT / 'application/SpeechCoachAI/Resources/Curriculum/CurriculumCatalog.json'


def complete_intro(catalog):
    lesson = next(row for row in catalog['lessons'] if row['id'] == 'intro-01')
    if lesson['contentVersion'] == '4':
        return catalog
    if lesson['contentVersion'] != '3':
        raise ValueError('Expected exact INTRO-01 v3; do not replace another content version')
    archives = catalog.setdefault('archivedLessons', [])
    previous = next((row for row in archives if row['id'] == 'intro-01' and row['contentVersion'] == '3'), None)
    if previous is not None and previous != lesson:
        raise ValueError('Conflicting historical INTRO-01 v3; preserve it for explicit review')
    if previous is None:
        archives.append(copy.deepcopy(lesson))
    for activity in lesson['activities']:
        if activity['id'] == 'quiet-intro':
            activity['prompt'] = 'Without speaking, write three facts: your chosen name, your work, study or daily role, and one interest. Then answer: What do you like to do in your free time? Invented details are welcome. This stays text practice.'
            activity['answer'] = 'A name, a role and an interest, plus an answer about your free time. For example: My name is Noor. I study art. I like walking. In my free time, I walk in the park. Other meaningful wording and fictional details are valid.'
        if activity['id'] == 'listen-alex-name':
            activity['answer'] = "The speaker's name is Alex."
        if activity['id'] == 'listen-alex-like':
            activity['prompt'] = 'Play the recording. It is a different person from the reading. What does the speaker like?'
            activity['answer'] = 'Alex likes music.'
    lesson['contentVersion'] = '4'
    return catalog


if __name__ == '__main__':
    before = CATALOG.read_text()
    data = complete_intro(json.loads(before))
    guide = CATALOG.with_name('IntroductionReviewGuide.json')
    if guide.exists():
        payload = guide.read_bytes()
        asset = dict(id='intro-01-review-guide', relativePath=guide.name,
                     byteCount=len(payload), sha256=hashlib.sha256(payload).hexdigest(), mediaType='application/json')
        data['assets'] = [a for a in data['assets'] if a['id'] != asset['id']] + [asset]
    after = json.dumps(data, indent=2, ensure_ascii=False) + '\n'
    if json.loads(before) != data:
        CATALOG.write_text(after)
        print('INTRO-01 v4 applied; exact v3 archived')
    else:
        print('INTRO-01 v4 unchanged')
