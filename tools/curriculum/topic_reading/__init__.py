"""Phase 13 reading pages, written per coach. Each topic title maps to its sections:
(heading, explanation, [(label, example sentence, note), ...]) with one to four examples.
A topic without written pages falls back to the frozen tip and a worked exercise."""
from importlib import import_module

COACHES = ['grammarian', 'business', 'copywriter', 'creative_writer', 'debater', 'journalist',
           'negotiator', 'public_speaker', 'reading_listening', 'storyteller']
READING: dict[str, dict] = {}
for _name in COACHES:
    try:
        _module = import_module(f'topic_reading.{_name}')
    except ModuleNotFoundError:
        continue
    READING[_name.replace('_', '-')] = _module.READING
