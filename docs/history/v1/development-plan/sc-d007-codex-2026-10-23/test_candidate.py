import copy
import json
import unittest
from pathlib import Path
from validate_candidate import validate, HERE, LIVE, BASELINE

class CandidateBoundaryTests(unittest.TestCase):
    def setUp(self):
        self.bundle=json.loads((HERE/'candidate-bundle/CurriculumCatalog.json').read_text())
        self.manifest=json.loads((HERE/'publication-manifest.json').read_text())
        self.live=json.loads((BASELINE if BASELINE.exists() else LIVE/'CurriculumCatalog.json').read_text())

    def check_candidate(self):
        return validate(self.bundle,self.manifest,self.live,HERE/'candidate-bundle')

    def test_complete_candidate(self):
        self.assertEqual(self.check_candidate()['topics'],13)

    def test_review_cannot_be_invented(self):
        self.bundle['editorialApprovalReference']='invented'
        with self.assertRaisesRegex(ValueError,'unpublished'): self.check_candidate()

    def test_intro_cannot_be_silently_rewritten(self):
        next(x for x in self.bundle['lessons'] if x['id']=='intro-01')['activities'][0]['answer']='changed'
        with self.assertRaisesRegex(ValueError,'INTRO-01'): self.check_candidate()

    def test_reused_sense_cannot_be_changed(self):
        self.bundle['lessons'][0]['senses'][0]['senseId']='different'
        with self.assertRaisesRegex(ValueError,'sense'): self.check_candidate()

    def test_reserved_task_cannot_become_core(self):
        next(x for x in self.bundle['lessons'][0]['activities'] if 'baseline-v3' in x['id'])['required']=True
        with self.assertRaisesRegex(ValueError,'reserved'): self.check_candidate()

    def test_quiet_must_replace_actual_speaking_task(self):
        next(x for x in self.bundle['lessons'][0]['activities'] if x['kind']=='quietText')['alternativeToActivityID']='missing'
        with self.assertRaisesRegex(ValueError,'quiet'): self.check_candidate()

    def test_corrupt_audio_does_not_pass(self):
        self.bundle['assets'][0]['sha256']='0'*64
        with self.assertRaisesRegex(ValueError,'integrity'): self.check_candidate()

    def test_duplicate_topics_do_not_pass(self):
        self.bundle['lessons'].append(copy.deepcopy(self.bundle['lessons'][0]))
        with self.assertRaisesRegex(ValueError,'duplicate lesson'): self.check_candidate()

    def test_missing_topic_does_not_pass(self):
        self.bundle['lessons'].pop()
        with self.assertRaisesRegex(ValueError,'coverage'): self.check_candidate()

    def test_asset_cannot_escape_candidate(self):
        self.bundle['assets'][0]['relativePath']='../private.wav'
        with self.assertRaisesRegex(ValueError,'unsafe'): self.check_candidate()

if __name__=='__main__': unittest.main(verbosity=2)
