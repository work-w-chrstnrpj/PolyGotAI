# Frozen Phase 13 inputs

These are the ten app-original track catalogs immediately before Phase 13 (296 lessons). They provide exact archived content and the original teaching/exercises used by `build_topic_lessons.py`; they contain no learner data. Do not edit these files to change current lessons: doing so would alter saved-version definitions. Extend the topic authoring outline/builder for future content versions and retain existing archives.

Run `python3 tools/curriculum/build_topic_lessons.py` from the project root, followed by `python3 tools/curriculum/validate.py`. The builder consumes this snapshot, never the generated current catalogs, so reruns are byte-idempotent. Old stage generators are guarded against overwriting topic catalogs. Editorial and learning validation remain open.
