"""Publishing overview for the large (batch) projects shown on the home page.

A batch video counts as published when its rendered file was queued in a
social-publishing project and that queue item reached a posted state.  The link
is the item's ``source_path``, which the publishing queue stores when videos are
added from an existing project.
"""

from __future__ import annotations

import os
from typing import Any, Callable, Iterable

from truongngochoa.services import project_store, social_publish

PUBLISHED = "published"
PENDING = "pending"
FAILED = "failed"
UNPUBLISHED = "unpublished"

_PUBLISHED_STATUSES = {"published", "posted"}
_PENDING_STATUSES = {"ready", "uploading", "publishing", "scheduled", "draft"}
_FAILED_STATUSES = {"failed", "missing", "partial"}
# When one render appears in several queues the most advanced state wins.
_PRIORITY = {UNPUBLISHED: 0, FAILED: 1, PENDING: 2, PUBLISHED: 3}


def classify_item_status(status: str) -> str:
    value = str(status or "").casefold()
    if value in _PUBLISHED_STATUSES:
        return PUBLISHED
    if value in _PENDING_STATUSES:
        return PENDING
    if value in _FAILED_STATUSES:
        return FAILED
    return UNPUBLISHED


def _normalize(path: Any) -> str:
    text = str(path or "")
    return os.path.normcase(os.path.abspath(text)) if text else ""


def collect_publish_states() -> dict[str, str]:
    """Map every queued source render path to its best publish state."""
    states: dict[str, str] = {}
    for project in project_store.list_projects():
        if project_store.normalize_project_type(project.get("project_type")) != "publish":
            continue
        try:
            root = project_store.project_root_for_key(str(project.get("key") or ""))
            state = social_publish.load_state(root)
        except (OSError, RuntimeError, ValueError):
            continue
        for item in state.get("items") or []:
            key = _normalize(item.get("source_path"))
            if not key:
                continue
            new_state = classify_item_status(item.get("status"))
            if _PRIORITY[new_state] >= _PRIORITY[states.get(key, UNPUBLISHED)]:
                states[key] = new_state
    return states


def empty_counts() -> dict[str, int]:
    return {"total": 0, PUBLISHED: 0, PENDING: 0, FAILED: 0, UNPUBLISHED: 0}


def count_states(states: Iterable[str]) -> dict[str, int]:
    counts = empty_counts()
    for state in states:
        counts["total"] += 1
        counts[state] += 1
    return counts


def video_publish_state(video: Any, output_path: Callable[[Any], str], states: dict[str, str]) -> str:
    try:
        path = output_path(video)
    except (OSError, KeyError, RuntimeError, ValueError):
        path = ""
    return states.get(_normalize(path), UNPUBLISHED)


def counts_by_project(
    videos: Iterable[Any],
    project_key: Callable[[Any], str],
    output_path: Callable[[Any], str],
    states: dict[str, str],
) -> dict[str, dict[str, int]]:
    result: dict[str, dict[str, int]] = {}
    for video in videos:
        if getattr(video, "project_type", "") != "batch":
            continue
        key = str(project_key(video) or "")
        counts = result.setdefault(key, empty_counts())
        counts["total"] += 1
        counts[video_publish_state(video, output_path, states)] += 1
    return result
