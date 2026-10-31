#!/usr/bin/env python3
"""Check every Lab video link (Phase 15) against YouTube's public oEmbed endpoint.

Reads the IDs and channels from Domain/LabVideos.swift and confirms each video exists and belongs to
the expected channel. Titles in the app are shortened for display, so they are not compared. Run before adding or changing a video:

    python3 tools/curriculum/check_lab_videos.py
"""
import json
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path

SOURCE = Path(__file__).resolve().parents[2] / "application/SpeechCoachAI/Domain/LabVideos.swift"


def normalize(text: str) -> str:
    return re.sub(r"[^a-z0-9]+", " ", text.replace("’", "'").lower()).strip()


def main() -> int:
    entries = re.findall(r'\.init\(id: "([\w-]{11})", title: "((?:[^"\\]|\\.)*)", channel: "((?:[^"\\]|\\.)*)"', SOURCE.read_text())
    if not entries:
        print("No videos found in", SOURCE)
        return 1
    failures = 0
    for video_id, _title, channel in entries:
        channel = channel.replace('\\"', '"')
        url = f"https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v={video_id}&format=json"
        try:
            with urllib.request.urlopen(url, timeout=15) as response:
                data = json.load(response)
        except (urllib.error.URLError, TimeoutError) as error:
            print(f"FAIL {video_id}: {error}")
            failures += 1
            continue
        problems = []
        if data.get("author_name") != channel:
            problems.append(f"channel is {data.get('author_name')!r}")
        print(("FAIL " if problems else "ok   ") + video_id + (": " + "; ".join(problems) if problems else ""))
        failures += bool(problems)
    print(f"{len(entries) - failures} of {len(entries)} videos checked")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
