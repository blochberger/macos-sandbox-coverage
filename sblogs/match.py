"""
Thin wrapper around matcher component, which is written in C++.
"""
import os
import subprocess
import sys
import tempfile
import json

sys.path.append(os.path.join(os.path.dirname(__file__), "maap"))

from maap.misc.logger import create_logger
from maap.misc.filesystem import project_path

logger = create_logger("sblogs.match")


def perform_matching(processed_logs: list, sandbox_profile: dict) -> dict:
    """
    Invokes the matcher, assuming the directory contains both the profile
    to match against, and processed log entries.
    """
    matcher_path = "matcher"
    assert os.path.exists(matcher_path)

    with tempfile.TemporaryDirectory() as tmpdir:
        # Dump parameters to disk for matching component
        ruleset_at = os.path.join(tmpdir, "patched_profile.json")
        logs_at = os.path.join(tmpdir, "sandbox_logs_processed.json")
        
        with open(ruleset_at, "w") as f:
            json.dump(sandbox_profile, f, ensure_ascii=False, indent=4)
        with open(logs_at, "w") as f:
            json.dump(processed_logs, f, ensure_ascii=False, indent=4)
        
        outfile = os.path.join(tmpdir, "match_results.json")
        
        with open(outfile, "w+b") as outf:
            returncode = subprocess.call([matcher_path, ruleset_at, logs_at], stdout=outf)
            if returncode != 0:
                return
            else:
                outf.flush()
                outf.seek(0, 0)
                return json.load(outf)