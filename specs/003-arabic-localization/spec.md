# Feature Specification: Arabic Localization

**Feature Branch**: `003-arabic-localization`

**Created**: 2026-07-28

**Status**: Draft

**Input**: User description: "Add Arabic (Modern Standard Arabic) as a second language to the Lueur Flutter wellness app, manually toggled in the Settings screen (not tied to device locale). English remains the default language. The app must support RTL layout switching when Arabic is selected. This is a lifestyle/wellness app — no clinical/medical language should appear anywhere user-facing. Scope for this phase: dependency setup, string extraction into a localization framework, a language preference cubit that persists the choice, wiring into the app shell, and a Settings toggle. Actual Arabic translation copy is a follow-up phase — placeholders only for now."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Switch app language from Settings (Priority: P1)

A user opens Settings and finds a language option showing "English" and "العربي". They tap "العربي" and the interface immediately re-renders in Arabic with a right-to-left layout — text alignment, navigation icons, and reading order all mirror correctly.

**Why this priority**: This is the entire point of the feature — without a working toggle that flips locale and direction, nothing else matters.

**Independent Test**: From Settings, tap the language toggle and verify the screen's own text direction and any newly rendered screens flip to RTL immediately, with no restart required.

**Acceptance Scenarios**:

1. **Given** the app is running in English (default), **When** the user selects "العربي" in Settings, **Then** the app locale changes to Arabic and the layout direction becomes right-to-left across the app.
2. **Given** the app is running in Arabic, **When** the user selects "English" in Settings, **Then** the app locale changes back to English and the layout direction becomes left-to-right.

---

### User Story 2 - Language choice persists across restarts (Priority: P2)

A user sets the app to Arabic, closes the app fully, and reopens it later. The app launches directly into Arabic without the user having to reselect it.

**Why this priority**: A toggle that resets on every launch is a frustrating, incomplete experience and undermines trust in the setting.

**Independent Test**: Set language to Arabic, force-quit the app, relaunch it, and confirm it opens in Arabic without visiting Settings again.

**Acceptance Scenarios**:

1. **Given** the user previously selected Arabic, **When** the app is relaunched, **Then** the app starts in Arabic.
2. **Given** the user has never changed the language, **When** the app is launched for the first time, **Then** the app starts in English regardless of the device's system language.

---

### User Story 3 - Existing screens remain fully readable in either language (Priority: P3)

As the user navigates through mood check-in, journal, plant/streak, chat, and profile screens, all previously hardcoded text now displays correctly in whichever language is active, with no leftover English text when Arabic is selected and no broken layout in either direction.

**Why this priority**: Partial coverage (some screens translated, some not) would be a visibly broken experience, but this is a scaling concern once the toggle mechanism (US1) and persistence (US2) already work.

**Independent Test**: Switch to Arabic, walk through each primary screen (home/mood capture, response, chat, journal, plant, affirmation, breathing, profile/settings, onboarding, auth), and confirm no hardcoded English strings remain and layout is not visually broken in RTL. (Actual Arabic wording is out of scope for this phase — placeholder text is acceptable as long as the string is routed through the localization system rather than hardcoded.)

**Acceptance Scenarios**:

1. **Given** Arabic is selected, **When** the user visits any primary screen, **Then** every user-facing string on that screen is sourced from the localization system (not a hardcoded literal), even if the displayed Arabic text is currently a placeholder.
2. **Given** Arabic is selected, **When** the user views a screen with mixed content (e.g., icons plus text rows), **Then** the row order and alignment mirror correctly for RTL reading.

### Edge Cases

- What happens if a user switches language while mid-flow (e.g., mid-way through the mood check-in form or an active chat)? The current screen's static labels should reflect the new language immediately; in-progress user-entered text is preserved, not cleared.
- How does the app handle a saved language preference value that is invalid or unrecognized (e.g., corrupted local storage)? The app should fall back to English rather than crashing.
- What happens to screens/components that pull text from the backend (e.g., AI-generated responses, weekly letter)? These are out of scope for locale-based translation in this phase since they originate server-side, not from hardcoded UI strings.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Settings screen MUST present a control that lets the user choose between English and Arabic as the app's display language.
- **FR-002**: The app MUST default to English on first launch, regardless of the device's system locale or region.
- **FR-003**: The app MUST NOT change language based on device locale — language changes only through explicit user action in Settings.
- **FR-004**: The system MUST persist the user's selected language locally so it is remembered across app restarts.
- **FR-005**: When the selected language is Arabic, the app MUST render its layout right-to-left; when English, left-to-right.
- **FR-006**: Selecting a language MUST apply across the app's screens without requiring the user to force-quit or manually restart the app.
- **FR-007**: All user-facing text currently hardcoded in the app's screens and shared widgets MUST be routed through the localization system rather than embedded as string literals, so it can vary by selected language.
- **FR-008**: Arabic display text for this phase MAY be placeholder content; it MUST NOT be machine-translated filler presented as final copy, since real Arabic copy will be authored separately.
- **FR-009**: No user-facing text, in either language, may use clinical or medical terminology, consistent with the app's positioning as a lifestyle/wellness product rather than a therapy product.
- **FR-010**: If a previously saved language preference cannot be read or is invalid, the system MUST fall back to English rather than failing to launch.
- **FR-011**: Switching languages MUST NOT discard or reset any in-progress user input (e.g., partially typed mood notes).
- **FR-012**: Text originating from backend/AI-generated content (e.g., generated responses, weekly letter) is explicitly out of scope for this phase's translation coverage.

### Key Entities

- **Language Preference**: The user's chosen display language (English or Arabic) and its associated text direction. Persists locally per device/user and determines which locale the app renders in on launch and going forward.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can switch the app's display language in under 5 seconds from the Settings screen, with the change visibly applied immediately.
- **SC-002**: 100% of previously hardcoded user-facing strings across the app's screens are sourced from the localization system rather than literal text, verified by a full screen-by-screen audit.
- **SC-003**: A user who selects Arabic and later reopens the app after a full restart sees the app in Arabic without reselecting it, 100% of the time.
- **SC-004**: When Arabic is active, all primary screens render with correct right-to-left reading order and alignment with no visually broken or overlapping layout.
- **SC-005**: A new user who has never touched the language setting always sees English on first launch, independent of device region/locale settings.

## Assumptions

- Only two languages are in scope for this phase: English and Modern Standard Arabic (no regional Arabic dialect variants).
- Real Arabic translation copy will be supplied by the user in a follow-up phase; this phase only needs structurally correct placeholders so nothing user-facing is left hardcoded.
- Backend/AI-generated response text (mood responses, weekly letter) is not translated as part of this phase since it is server-authored content, not app UI strings.
- The app has no existing localization framework in place; this phase introduces one for the first time.
- Persistence of the language choice is local to the device (not synced to a user account/server).
- Django/backend code is out of scope entirely for this feature.
