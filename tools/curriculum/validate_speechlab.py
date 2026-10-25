#!/usr/bin/env python3
"""Validate only Speech Lab original content; independent of the course/coach validator."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2] / 'application/SpeechCoachAI/Resources/SpeechLab'

def validate(root=ROOT):
    errors, seen = [], set()
    for path in sorted(root.glob('speechlab-*.json')):
        try:
            data = json.loads(path.read_text())
            assert data['version'] == 1 and data['credits'].strip()
            for item in data['items']:
                assert item['id'] not in seen and item['id'].strip()
                seen.add(item['id'])
                assert item['title'].strip()
                if 'phonetics' in path.name:
                    assert item['ipa'].strip() and len(item['examples']) == 3
                    assert all(w.strip() for w in item['examples']) and item['tip'].strip()
                    assert item['group'] in ['Vowels','Diphthongs','R-colored vowels','Consonants']
                    assert len(set(item['choices'])) >= 2 and item['cue'] in item['choices'] and item['cueIPA'].strip()
                if 'prosody' in path.name:
                    assert item['kind'] in ['stress','intonation'] and item['ipa'].strip() and item['text'].strip()
                    assert item['answer'] in item['options'] and len(set(item['options'])) == len(item['options'])
                if 'articulation' in path.name:
                    assert item['text'].strip() and item['tip'].strip() and item['question'].strip()
                    assert item['answer'] in item['options'] and len(set(item['options'])) >= 2
                    assert item['grade'] in ['Short','Medium','Long']
                if path.name == 'speechlab-voice.json':
                    assert item['level'] in ['A1','A2','B1','B2','C1','C2'] and len(item['text'].split()) >= 50
                if 'warmups' in path.name:
                    assert item['text'].strip() and 5 <= item['seconds'] <= 60
                if 'dictation' in path.name:
                    assert item['text'].strip() and item['spoken'].strip()
                    assert item['category'] in ['Sentences','Numbers','Dates','Names','Spelling']
                    assert item['level'] in ['A1','A2','B1','B2','C1','C2']
            if path.name == 'speechlab-voice.json':
                assert len(data['items']) >= 8
                assert set(x['level'] for x in data['items']) == {'A1','A2','B1','B2','C1','C2'}
            if 'warmups' in path.name:
                assert len(data['items']) >= 3
            if 'phonetics' in path.name:
                assert len(data['items']) >= 40
            if 'articulation' in path.name:
                assert sum(x['category']=='Minimal pairs' for x in data['items']) >= 20
                assert sum(x['category']=='Tongue twisters' for x in data['items']) >= 12
                assert all(any(x['category']=='Tongue twisters' and x['grade']==g for x in data['items']) for g in ['Short','Medium','Long'])
            if 'dictation' in path.name:
                for level in ['A1','A2','B1','B2','C1','C2']:
                    assert sum(x['level']==level and x['category']=='Sentences' for x in data['items']) >= 6
                assert all(any(x['category']==c for x in data['items']) for c in ['Numbers','Dates','Names','Spelling'])
        except (ValueError, KeyError, AssertionError, TypeError) as error:
            errors.append(f'{path.name}: invalid content {error}')
    if not seen: errors.append('No Speech Lab items')
    return errors

if __name__ == '__main__':
    import sys
    errors = validate(Path(sys.argv[1]) if len(sys.argv)>1 else ROOT)
    print('\n'.join(errors) if errors else 'Speech Lab content valid')
    sys.exit(bool(errors))
