# Implementation Plan: MVP Menu Bar App

**Track ID:** mvp-menu-bar_20260211
**Spec:** [spec.md](./spec.md)
**Created:** 2026-02-11
**Status:** [~] In Progress

## Overview

Build Let's Stretch as a macOS menu bar app in 6 phases: project foundation, stretch content research & data layer, reminder system with pulsing icon, stretch display UI, auto-play multi-stretch mode, and settings/polish. Each phase builds on the previous, delivering a working increment.

## Phase 1: Project Foundation

Set up the Xcode project, menu bar presence, and basic app lifecycle.

### Tasks

- [x] Task 1.1: Create Xcode project as a macOS app (SwiftUI lifecycle, no main window) targeting macOS 14
- [x] Task 1.2: Configure the app as a menu bar agent (LSUIElement) with NSStatusItem and a placeholder icon
- [x] Task 1.3: Add basic menu bar dropdown with "Quit" and "About" items
- [~] Task 1.4: Set up SwiftLint via Swift Package Manager and add initial configuration
- [ ] Task 1.5: Set up unit test target with XCTest

### Verification

- [ ] App launches in menu bar with icon, dropdown menu shows Quit and About options

## Phase 2: Stretch Content & Data Layer

Research desk-worker stretches, define data models, and bundle content as JSON.

### Tasks

- [ ] Task 2.1: Research and curate 15-20 common desk-worker stretches (sitting/standing and mat categories) with names, descriptions, step-by-step instructions, duration, and animation references
- [ ] Task 2.2: Define Swift data models: `Stretch`, `StretchCategory` (desk-friendly, mat-required), `StretchSession`
- [ ] Task 2.3: Create bundled JSON file(s) with all stretch data
- [ ] Task 2.4: Build `StretchRepository` to load and filter stretches from bundled JSON
- [ ] Task 2.5: Write unit tests for data models and repository (loading, filtering by category)

### Verification

- [ ] All stretch data loads correctly, category filtering works, tests pass

## Phase 3: Reminder System

Implement the timed reminder engine with pulsing icon animation and snooze/skip.

### Tasks

- [ ] Task 3.1: Build `ReminderScheduler` using Timer to trigger reminders at configurable intervals
- [ ] Task 3.2: Implement pulsing animation on the NSStatusItem icon when a reminder fires
- [ ] Task 3.3: Add snooze action (delays reminder by a short interval) and skip action (dismisses until next cycle)
- [ ] Task 3.4: Store reminder interval preference in UserDefaults with a sensible default (e.g., 45 minutes)
- [ ] Task 3.5: Write tests for `ReminderScheduler` (timing, snooze, skip logic)

### Verification

- [ ] Menu bar icon pulses at the configured interval, snooze and skip work correctly

## Phase 4: Stretch Display UI

Build the popup window that shows stretch instructions when the user clicks the pulsing icon.

### Tasks

- [ ] Task 4.1: Create a popover/panel that appears anchored to the menu bar icon on click
- [ ] Task 4.2: Build `StretchDetailView` showing stretch name, description, and step-by-step instructions
- [ ] Task 4.3: Add stretch animations (Lottie/custom SwiftUI animations) with sourced animation data for each stretch
- [ ] Task 4.4: Show a random desk-friendly stretch by default (respecting user's category filter)
- [ ] Task 4.5: Add "Done" and "Skip" buttons to dismiss the stretch view and stop the icon pulse

### Verification

- [ ] Clicking the pulsing icon shows a stretch with instructions and animations, buttons work correctly

## Phase 5: Auto-Play Mode

Build the multi-stretch session player with timed transitions.

### Tasks

- [ ] Task 5.1: Build `SessionPlayer` view model managing a sequence of stretches with timing (stretch duration, rest intervals)
- [ ] Task 5.2: Create `AutoPlayView` with current stretch display, countdown timer, and progress indicator
- [ ] Task 5.3: Implement rest interval screen between stretches (5s default with "Get ready for..." preview)
- [ ] Task 5.4: Add session controls: pause/resume, skip stretch, and end session
- [ ] Task 5.5: Add "Start Session" entry point from the menu bar dropdown and from the single-stretch popup
- [ ] Task 5.6: Write tests for `SessionPlayer` (sequencing, timing, pause/resume, skip)

### Verification

- [ ] Auto-play mode cycles through multiple stretches with rest intervals, controls work, session completes gracefully

## Phase 6: Settings & Polish

Add user preferences UI and final polish.

### Tasks

- [ ] Task 6.1: Build `SettingsView` with: reminder interval picker, stretch category toggles (desk-friendly / mat), launch at login toggle
- [ ] Task 6.2: Implement launch-at-login using `SMAppService` (macOS 13+)
- [ ] Task 6.3: Add auto-play session settings: stretch duration (default 20s), rest interval (default 5s), number of stretches per session
- [ ] Task 6.4: Design and apply a proper menu bar icon (SF Symbol or custom) and app icon
- [ ] Task 6.5: Apply playful copy and tone to all UI text (per product guidelines)
- [ ] Task 6.6: Final pass: edge cases, empty states, smooth animations, and overall polish

### Verification

- [ ] Settings persist across app restarts, launch at login works, all UI text matches the playful tone

## Final Verification

- [ ] All acceptance criteria met
- [ ] Tests passing
- [ ] App runs cleanly from menu bar with no main window
- [ ] Pulsing reminder, single stretch view, and auto-play mode all function end-to-end
- [ ] Stretch categories filter correctly
- [ ] Settings persist and apply immediately
- [ ] Ready for direct distribution (code-signed and notarized)

---

_Generated by Conductor. Tasks will be marked [~] in progress and [x] complete._
