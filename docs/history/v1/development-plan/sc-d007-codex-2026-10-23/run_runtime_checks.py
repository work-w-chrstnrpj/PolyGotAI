#!/usr/bin/env python3
"""Run production content/loader/journey logic on macOS with synthetic responses.

Two dependency declarations are extracted byte-for-byte from their production
files, avoiding compilation of unrelated preferences/audio/provider code.
No replacement logic or mock decoder/loader/session is used.
"""
import json
import hashlib
import subprocess
import tempfile
from pathlib import Path

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
APP=ROOT/'application/SpeechCoachAI'
sources=[APP/'Domain/CurriculumCatalog.swift',APP/'Infrastructure/Curriculum/CurriculumCatalogLoader.swift',APP/'Domain/LessonJourney.swift']
with tempfile.TemporaryDirectory(prefix='sc-d007-check-') as scratch:
    scratch=Path(scratch)
    vocab=(APP/'Domain/VocabularyLink.swift').read_text()
    # Preserve the exact declarations needed by CurriculumManifest.
    sense=vocab[:vocab.index('/// Optional collection membership.')]
    error=vocab[vocab.index('enum VocabularyLinkError:'):vocab.index('struct VocabularyCollection:')]
    context=(APP/'Domain/PracticeSessionContext.swift').read_text()
    checks=context[context.index('enum IntroCheckKind:'):]
    dependency=scratch/'ProductionDependencies.swift'
    dependency.write_text(sense+'\n'+error+'\n'+checks)
    binary=scratch/'check-a1'
    subprocess.run(['xcrun','swiftc','-o',str(binary),*[str(x) for x in sources],str(dependency),str(HERE/'RuntimeChecks.swift')],check=True)
    subprocess.run([str(binary),str(HERE/'candidate-bundle'),str(APP/'Resources/Curriculum')],check=True)
    print('Production source SHA-256:')
    for path in sources+[APP/'Domain/VocabularyLink.swift',APP/'Domain/PracticeSessionContext.swift']:
        print(hashlib.sha256(path.read_bytes()).hexdigest(),path.relative_to(ROOT))
