#!/usr/bin/env python3
"""Build the Pronunciation coach (Phase 12): Resources/Tracks/track-pronunciation.json.

Reading pages come from topic_reading/pronunciation.py. Each lesson then has "Say it" items (answered by voice and
checked on the phone), "Listen" items (the phone voice says one word of a minimal pair) and a few sound questions,
followed by Your turn. Pairs reuse the Speech Lab minimal-pair list. Original wording, written 2026-10-26.
Run from the project root: python3 tools/curriculum/build_pronunciation.py
"""
from __future__ import annotations

import json
import re

from topic_reading.pronunciation import READING
from track_lib import RES, register_rewards
from validate import giveaway_problems, reading_giveaway

VERSION = '1'
SOURCES = [
    'International Phonetic Alphabet symbols (common learner-dictionary conventions), used for notation only',
    'Lexical-set names (FLEECE, KIT…) after J. C. Wells, used as labels only',
    'SpeechCoachAI Speech Lab minimal pairs and tips, 2026-10-25',
]


def say(word, contrast=None, tip='Hear it first, then say it clearly.'):
    prompt = f'Say “{word}”.' if contrast is None else f'Say “{word}” — not “{contrast}”.'
    return {'kind': 'grammar', 'prompt': prompt, 'answer': word, 'explanation': tip,
            'exercise': {'type': 'speak', 'accepted': [word], 'audioText': word}}


def hear(word, contrast, tip):
    return {'kind': 'grammar', 'prompt': 'Listen. Which word do you hear?', 'answer': word, 'explanation': tip,
            'exercise': {'type': 'choice', 'options': [word, contrast], 'accepted': [word], 'audioText': word}}


def ask(prompt, correct, wrong, tip, audio=None):
    item = {'kind': 'grammar', 'prompt': prompt, 'answer': correct, 'explanation': tip,
            'exercise': {'type': 'choice', 'options': [correct, *wrong], 'accepted': [correct]}}
    if audio: item['exercise']['audioText'] = audio
    return item


IY, UW = 'Long /iː/: smile a little and hold it; short /ɪ/ is relaxed.', 'Long /uː/: round and push the lips; short /ʊ/ is relaxed.'
OPEN, STRUT = 'Drop the jaw further for /æ/ than for /e/.', '/ʌ/ is short and central; the open back vowel needs the jaw down.'
SCHWA = 'Unstressed syllables and small words relax into the schwa /ə/.'
DIPH, ROUND = 'Glide: the tongue moves during the vowel.', 'For /aʊ/ and /əʊ/, the lips round at the end.'
NURSE, LONGR = '/ɜː/ is long and central, lips neutral.', 'Keep /ɑː/ and /ɔː/ long; round the lips for /ɔː/.'
VOICE, PUFF = 'Voiced sounds buzz in the throat; voiceless ones do not.', 'Start /p/, /t/, /k/ with a small puff of air.'
TH = 'Tongue tip lightly between the teeth; /ð/ buzzes, /θ/ does not.'
SH, CH, JY = '/s/ is a sharp hiss; /ʃ/ is softer with rounded lips.', '/tʃ/ starts with a stop; /ʃ/ does not.', '/dʒ/ has a full stop; /j/ is a glide.'
LR, WV, HNG = 'For /l/ the tongue touches the ridge; for /r/ it does not.', 'Rounded lips for /w/; top teeth on the lip for /v/.', '/h/ is gentle breath; /ŋ/ uses the back of the tongue.'
STRESS = 'The stressed syllable is louder, longer and higher.'
RHYTHM = 'Content words are stressed; function words are weak.'
TUNE = 'Statements and wh- questions fall; yes/no questions rise.'

LESSONS = [
 ('foundation', 'vowels', 'Long and short vowels', 'Write three more words with the long /iː/ sound and three with the short /ɪ/ sound, then say them aloud.', [
    say('sheep', 'ship', IY), say('ship', 'sheep', IY), say('leave', 'live', IY), say('sit', 'seat', IY),
    say('pool', 'pull', UW), say('full', 'fool', UW), say('feel', 'fill', IY),
    hear('beat', 'bit', IY), hear('live', 'leave', IY), hear('seat', 'sit', IY), hear('fool', 'full', UW),
    hear('look', 'Luke', UW), hear('heel', 'hill', IY), hear('green', 'grin', IY),
    ask('Which word has the same vowel as “sheep”?', 'team', ['tip', 'top', 'tape'], IY),
    ask('Which word has the long /uː/ sound?', 'moon', ['book', 'good', 'foot'], UW),
    ask('Which word has the short /ɪ/ sound?', 'gym', ['seen', 'team', 'meal'], IY)]),
 ('foundation', 'vowels', 'Open vowels', 'Write a sentence that uses bed, bad and bud, then say it slowly and watch your jaw.', [
    say('bad', 'bed', OPEN), say('bed', 'bad', OPEN), say('man', 'men', OPEN), say('cup', 'cop', STRUT),
    say('lock', 'luck', STRUT), say('cat', 'cut', OPEN), say('pan', 'pen', OPEN),
    hear('pen', 'pan', OPEN), hear('men', 'man', OPEN), hear('cut', 'cat', STRUT), hear('cop', 'cup', STRUT),
    hear('luck', 'lock', STRUT), hear('hat', 'hut', OPEN), hear('said', 'sad', OPEN),
    ask('Which word has the same vowel as “cat”?', 'map', ['cup', 'met', 'cot'], OPEN),
    ask('Which word has the same vowel as “cup”?', 'sun', ['sand', 'send', 'soon'], STRUT),
    ask('Which word needs the widest open mouth?', 'bad', ['bed', 'bid', 'bead'], OPEN)]),
 ('foundation', 'vowels', 'Schwa and weak syllables', 'Write one sentence with “to”, “of” and “and”, mark the weak words, then say it with weak forms.', [
    say('about', tip=SCHWA), say('today', tip=SCHWA), say('banana', tip=SCHWA), say('teacher', tip=SCHWA),
    say('a cup of tea', tip=SCHWA), say('fish and chips', tip=SCHWA), say('I want to go', tip=SCHWA),
    ask('Which part of “about” has the weak schwa sound?', 'a', ['bout'], SCHWA, audio='about'),
    ask('Which part of “today” is weak?', 'to', ['day'], SCHWA, audio='today'),
    ask('Which syllable of “banana” is stressed?', 'second', ['first', 'third'], SCHWA, audio='banana'),
    ask('How many schwa sounds are in “banana”?', 'two', ['one', 'three'], SCHWA),
    ask('Which word is usually weak in “a cup of tea”?', 'of', ['cup', 'tea'], SCHWA),
    ask('Which word is usually weak in “fish and chips”?', 'and', ['fish', 'chips'], SCHWA),
    ask('Which word ends in a weak schwa sound?', 'sofa', ['see', 'saw', 'sigh'], SCHWA),
    ask('Which part of “problem” has the schwa?', 'lem', ['prob'], SCHWA, audio='problem'),
    ask('Where does “at” keep its strong form?', 'What are you looking at?', ['Look at this.', 'I’m at home.'], SCHWA)]),
 ('foundation', 'diphthongs', 'Diphthongs', 'Write five words with the /aɪ/ sound in different spellings (time, my, light…), then say them aloud.', [
    say('late', 'let', DIPH), say('time', 'tame', DIPH), say('boy', 'buy', DIPH), say('now', 'no', ROUND),
    say('boat', 'bought', ROUND), say('pain', 'pen', DIPH), say('toy', 'tie', DIPH),
    hear('let', 'late', DIPH), hear('tame', 'time', DIPH), hear('may', 'my', DIPH), hear('no', 'now', ROUND),
    hear('tone', 'town', ROUND), hear('coat', 'caught', ROUND), hear('buy', 'boy', DIPH),
    ask('Which word has the same vowel sound as “day”?', 'rain', ['red', 'ran', 'rice'], DIPH),
    ask('In which word is “ow” said /aʊ/?', 'town', ['show', 'snow', 'grow'], ROUND),
    ask('Which word has the /ɔɪ/ sound?', 'coin', ['cone', 'con', 'cane'], DIPH)]),
 ('foundation', 'diphthongs', 'R-coloured vowels', 'Choose British or American r. Write three words with /ɜː/ and say them in your chosen accent.', [
    say('hurt', 'hut', NURSE), say('bird', 'bud', NURSE), say('heart', 'hot', LONGR), say('short', 'shot', LONGR),
    say('card', 'cod', LONGR), say('port', 'pot', LONGR), say('work', 'walk', NURSE),
    hear('hut', 'hurt', NURSE), hear('bud', 'bird', NURSE), hear('hot', 'heart', LONGR), hear('shot', 'short', LONGR),
    hear('cod', 'card', LONGR), hear('walk', 'work', NURSE), hear('firm', 'farm', NURSE),
    ask('Which word has the same vowel as “bird”?', 'learn', ['lean', 'lane', 'lawn'], NURSE),
    ask('In most British accents, do you hear the r in “car”?', 'No', ['Yes'], LONGR),
    ask('Which word has the same vowel as “door”?', 'four', ['far', 'fur', 'foe'], LONGR)]),
 ('intermediate', 'consonant-pairs', 'Voiced and voiceless pairs', 'Write three pairs like pig / big and say each pair with your fingers on your throat.', [
    say('pig', 'big', VOICE), say('big', 'pig', VOICE), say('fan', 'van', VOICE), say('van', 'fan', VOICE),
    say('zip', 'sip', VOICE), say('coat', 'goat', PUFF), say('bag', 'back', VOICE),
    hear('pen', 'Ben', PUFF), hear('two', 'do', PUFF), hear('tie', 'die', PUFF), hear('time', 'dime', PUFF),
    hear('fine', 'vine', VOICE), hear('very', 'berry', VOICE), hear('zoo', 'Sue', VOICE),
    ask('Which sound buzzes in your throat?', '/z/', ['/s/'], VOICE),
    ask('Which word starts with a puff of air?', 'pen', ['Ben', 'men'], PUFF),
    ask('In which word is the vowel a little longer?', 'bed', ['bet'], VOICE)]),
 ('intermediate', 'consonant-pairs', 'TH sounds', 'Write a sentence with at least four TH words, then say it slowly with your tongue forward.', [
    say('think', 'sink', TH), say('three', 'tree', TH), say('thin', 'tin', TH), say('they', 'day', TH),
    say('then', 'den', TH), say('those', 'doze', TH), say('bath', 'bass', TH),
    hear('sink', 'think', TH), hear('tree', 'three', TH), hear('tin', 'thin', TH), hear('day', 'they', TH),
    hear('den', 'then', TH), hear('mouth', 'mouse', TH), hear('thank', 'tank', TH),
    ask('Where does your tongue go for TH?', 'lightly between the teeth', ['behind the bottom teeth', 'on the lower lip'], TH),
    ask('Which word starts with the voiced TH /ð/?', 'this', ['think', 'thank', 'three'], TH),
    ask('Which word has the voiceless TH /θ/?', 'month', ['mother', 'this', 'they'], TH)]),
 ('intermediate', 'tricky-consonants', 'S, SH, CH and J', 'Write three words each with /ʃ/ and /tʃ/, then say them in pairs (ship – chip).', [
    say('she', 'see', SH), say('see', 'she', SH), say('ship', 'chip', CH), say('chip', 'ship', CH),
    say('choose', 'shoes', CH), say('jet', 'yet', JY), say('yam', 'jam', JY),
    hear('shoes', 'choose', CH), hear('chair', 'share', CH), hear('share', 'chair', CH), hear('joke', 'choke', JY),
    hear('yet', 'jet', JY), hear('sip', 'ship', SH), hear('sock', 'shock', SH),
    ask('Which word starts with a stop, then a hiss?', 'chip', ['ship'], CH),
    ask('Which word has the /ʒ/ sound?', 'measure', ['mesh', 'match', 'mass'], SH),
    ask('Which word has a hidden /j/ sound?', 'music', ['moon', 'mood', 'move'], JY)]),
 ('intermediate', 'tricky-consonants', 'L, R, W, V, H and NG', 'Write a sentence that mixes l, r, w and v words, then say it slowly.', [
    say('light', 'right', LR), say('right', 'light', LR), say('west', 'vest', WV), say('vest', 'west', WV),
    say('hat', 'at', HNG), say('sing', 'sin', HNG), say('wine', 'vine', WV),
    hear('long', 'wrong', LR), hear('lead', 'read', LR), hear('rice', 'lice', LR), hear('wet', 'vet', WV),
    hear('hair', 'air', HNG), hear('thing', 'thin', HNG), hear('ran', 'rang', HNG),
    ask('For which sound does your tongue touch the ridge behind your top teeth?', '/l/', ['/r/'], LR),
    ask('For /v/, what touches your lower lip?', 'teeth', ['tongue', 'nothing'], WV),
    ask('Do you add a /ɡ/ sound at the end of “sing”?', 'No', ['Yes'], HNG)]),
 ('advanced', 'stress-rhythm', 'Word stress', 'Write five new words you learned this week, mark the stressed syllable in capitals, and say them aloud.', [
    ask('Which syllable is stressed in “photograph”?', 'first', ['second', 'third'], STRESS, audio='photograph'),
    ask('Which syllable is stressed in “photography”?', 'second', ['first', 'third', 'fourth'], STRESS, audio='photography'),
    ask('Which syllable is stressed in “photographic”?', 'third', ['first', 'second', 'fourth'], STRESS),
    ask('Which syllable is stressed in “computer”?', 'second', ['first', 'third'], STRESS, audio='computer'),
    ask('Which syllable is stressed in “hotel”?', 'second', ['first'], STRESS),
    ask('Which syllable is stressed in “comfortable”?', 'first', ['second', 'third'], STRESS, audio='comfortable'),
    ask('Which syllable is stressed in “interesting”?', 'first', ['second', 'third'], STRESS),
    ask('Which syllable is stressed in “understand”?', 'third', ['first', 'second'], STRESS, audio='understand'),
    ask('Which syllable is stressed in “engineer”?', 'third', ['first', 'second'], STRESS),
    ask('Which syllable is stressed in “Japanese”?', 'third', ['first', 'second'], STRESS, audio='Japanese'),
    ask('Which syllable is stressed in “education”?', 'third', ['first', 'second', 'fourth'], STRESS),
    ask('Which syllable is stressed in “decide”?', 'second', ['first'], STRESS, audio='decide'),
    ask('Which syllable is stressed in “window”?', 'first', ['second'], STRESS),
    ask('Which syllable is stressed in “economy”?', 'second', ['first', 'third', 'fourth'], STRESS, audio='economy'),
    ask('Which syllable is stressed in “economic”?', 'third', ['first', 'second', 'fourth'], STRESS),
    ask('“I have a present for you.” Which syllable of “present” is stressed?', 'first', ['second'], STRESS),
    ask('“Let me present the plan.” Which syllable of “present” is stressed?', 'second', ['first'], STRESS),
    ask('Which syllable is stressed in “development”?', 'second', ['first', 'third', 'fourth'], STRESS)]),
 ('advanced', 'stress-rhythm', 'Sentence stress and rhythm', 'Write a sentence of eight to ten words, underline the content words, then say it with strong beats on them.', [
    say('a cup of tea', tip=RHYTHM), say('fish and chips', tip=RHYTHM), say('I want to go home', tip=RHYTHM),
    say('What do you want', tip=RHYTHM), say('next week', tip=RHYTHM), say('pick it up', tip=RHYTHM),
    say('turn it off', tip=RHYTHM),
    ask('Which word is usually stressed in “I want to go home”?', 'home', ['to', 'I'], RHYTHM),
    ask('Which word is usually weak in “She’s been to Paris twice”?', 'to', ['Paris', 'twice'], RHYTHM),
    ask('Which word is stressed in “I can’t come tonight”?', 'can’t', ['I'], RHYTHM),
    ask('Which kind of word is usually stressed?', 'nouns', ['articles', 'prepositions'], RHYTHM),
    ask('Which kind of word is usually weak?', 'prepositions', ['adjectives', 'nouns'], RHYTHM),
    ask('“I wanted TEA, not coffee.” Why is “tea” stressed?', 'contrast', ['rhythm', 'habit'], RHYTHM),
    ask('“SHE called.” What does the stress on “she” tell you?', 'not him', ['it was late', 'a question'], RHYTHM),
    ask('Which sound often disappears in “next week”?', 't', ['k', 'w'], RHYTHM),
    ask('How many strong beats are in “The CATS will have EATen the FISH”?', 'three', ['seven', 'nine'], RHYTHM),
    ask('How does “an apple” usually sound?', 'a-napple', ['an … apple, with a pause'], RHYTHM)]),
 ('advanced', 'intonation', 'Intonation', 'Write a yes/no question, a wh- question and a list. Mark ↗ or ↘ at the end of each, then say them aloud.', [
    say('Are you ready', tip=TUNE), say('Where do you live', tip=TUNE), say('Tea or coffee', tip=TUNE),
    say('That’s great', tip=TUNE), say('It’s cold, isn’t it', tip=TUNE),
    ask('At the end of “Are you ready?”, does the voice usually go up or down?', 'up', ['down'], TUNE),
    ask('At the end of “Where do you live?”, does the voice usually go up or down?', 'down', ['up'], TUNE),
    ask('At the end of “I live in Paris.”, does the voice usually go up or down?', 'down', ['up'], TUNE),
    ask('At the end of “Close the door.”, does the voice usually go up or down?', 'down', ['up'], TUNE),
    ask('At the end of “Is it far?”, does the voice usually go up or down?', 'up', ['down'], TUNE),
    ask('At the end of “What time is it?”, does the voice usually go up or down?', 'down', ['up'], TUNE),
    ask('In “apples, bread and milk”, where does the voice fall?', 'on milk', ['on apples', 'on bread'], 'In a list, rise on each item and fall on the last.'),
    ask('In “Tea or coffee?”, where does the voice fall?', 'on coffee', ['on tea'], 'In a choice, rise on the first option and fall on the last.'),
    ask('“It’s cold, isn’t it ↘?” A falling tag means…', 'you expect agreement', ['you really don’t know'], 'A falling tag asks for agreement; a rising tag is a real question.'),
    ask('“You’re coming, aren’t you ↗?” A rising tag means…', 'it is a real question', ['you are sure'], 'A falling tag asks for agreement; a rising tag is a real question.'),
    ask('Which kind of tune can sound bored or rude?', 'flat', ['wide', 'rising'], 'A wide range sounds interested; a flat one can sound bored.'),
    ask('Which tune shows surprise in “Really?”', 'high rise', ['low fall'], 'A high rise shows surprise.')]),
]
STAGES = [('foundation', 'Foundation', [('vowels', 'Vowels'), ('diphthongs', 'Diphthongs and r-vowels')]),
          ('intermediate', 'Intermediate', [('consonant-pairs', 'Consonant pairs'), ('tricky-consonants', 'Tricky consonants')]),
          ('advanced', 'Advanced', [('stress-rhythm', 'Stress and rhythm'), ('intonation', 'Intonation')])]
TIPS = {'foundation': 'Hear the pair, feel the mouth shape, then say it. Shape matters more than length.',
        'intermediate': 'Check the tongue, lips and voice: one small change separates each pair.',
        'advanced': 'Stress, rhythm and tune carry meaning; practise whole phrases, not single words.'}


def build():
    stage_titles = {s: title for s, title, _ in STAGES}
    lessons = []
    for stage, unit, title, your_turn, items in LESSONS:
        slug = re.sub(r'[^a-z0-9]+', '-', title.lower()).strip('-')
        lid = f'pronunciation-{slug}'
        sections = [{'id': f'{lid}-read-{n+1}', 'heading': h, 'explanation': x,
                     'examples': [{'prompt': a, 'answer': b, 'explanation': c} for a, b, c in ex]}
                    for n, (h, x, ex) in enumerate(READING[title])]
        printed = [s['explanation'] for s in sections]
        activities = []
        for n, item in enumerate(items):
            item = dict(item, id=f'{lid}-{n+1:02d}', required=True)
            problems = giveaway_problems(item, printed) + (['answer printed on a reading page'] if reading_giveaway(item, sections) else [])
            if problems: raise ValueError(f'{item["id"]}: {problems}')
            activities.append(item)
        if not 15 <= len(activities) <= 18: raise ValueError(f'{title}: {len(activities)} checked items')
        activities.append({'id': f'{lid}-your-turn', 'kind': 'grammar', 'required': True,
                           'prompt': f'Your turn. {your_turn}', 'answer': 'Your own words, said aloud.', 'exercise': {'type': 'open'}})
        lessons.append({'id': lid, 'contentVersion': VERSION, 'level': stage_titles[stage], 'title': title,
                        'objectiveId': 'PRON-' + slug.upper(), 'trackId': 'pronunciation', 'unitId': unit,
                        'tip': TIPS[stage], 'sources': SOURCES, 'senses': [], 'reading': sections, 'activities': activities})
    pack = {'schemaVersion': 1, 'packId': 'speechcoach.track.pronunciation', 'contentVersion': VERSION, 'locale': 'en-US',
            'minimumSchemaVersion': 1,
            'editorialApprovalReference': 'Phase 12 Pronunciation coach authored 2026-10-26 for personal practice. Qualified phonetics review pending.',
            'rightsReference': 'Original SpeechCoachAI wording written 2026-10-26. IPA and lexical-set names are used as notation only; no text is copied.',
            'assets': [],
            'track': {'id': 'pronunciation', 'coach': 'pronunciation',
                      'stages': [{'id': s, 'title': t, 'units': [{'id': u, 'title': ut} for u, ut in units]} for s, t, units in STAGES]},
            'lessons': lessons, 'archivedLessons': []}
    (RES / 'Tracks/track-pronunciation.json').write_text(json.dumps(pack, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    register_rewards([l['id'] for l in lessons], VERSION)
    print('pronunciation lessons:', len(lessons), 'checked items:', sum(len(l['activities']) - 1 for l in lessons))


if __name__ == '__main__':
    build()
