# ADR-0007: Release on merge of development into main

**Status:** accepted (retroactive)
**Date:** 2026-11-08
**Ticket:** #2
**Input:** docs/history-version.md, docs/tdd/tdd.md
**Supersedes:** none

## Context

Releases needed a repeatable, low-effort process for a single developer with AI agents working on the `development` branch.

## Decision

A GitHub Action tags and publishes a release when `development` is merged into `main` with a merge commit. The version comes from `MARKETING_VERSION` first, then Conventional Commit subjects (feat → minor, breaking → major). It then fast-forwards `development` to `main`.

## Alternatives

- Manual tagging: easy to forget and skip notes.
- TestFlight pipeline: no App Store account use yet.

## Consequences

Commit subjects must follow Conventional Commits for good notes. The workflow publishes GitHub releases only; it does not build or sign the app. See .github/workflows/release.yml.
