<div align="center">

# V-Stop

**Your V-TOP. Faster. Smarter. Yours.**

V-Stop scrapes your VIT academic data from V-TOP and brings it entirely onto your device — no servers, no accounts, no waiting for a slow portal to load. Everything you need, built the way it should've been.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-teal.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)]()


<img width="284" height="600" alt="image" src="https://github.com/user-attachments/assets/14bfda53-2e6c-4b1e-9579-1e82b2a3c6e0" /> <img width="284" height="600" alt="image" src="https://github.com/user-attachments/assets/8eb87ba7-f344-46a2-8ab5-231637b6c751" />

</div>

---

## Why V-Stop?

Other apps that do this exist — and they get the job done. But they either depend on proxy servers, ask you to sync everything everytime, or show you your data the same way V-TOP does: everything everywhere all at once.

V-Stop takes a different approach:

- **Everything stays on your phone.** Your credentials are used once to scrape data and are stored safely on Android Keychain / iOS Keystore. The scraped data lives in local storage — not a server.
- **It's fast.** Syncing is highly optimized — and if you only need attendance or marks, targeted sync modes get you just that in seconds. No full scrape needed every time.
- **It shows you where you stand in your class** — anonymously. No names, no reg numbers, just aggregated marks averages so you know how you're doing relative to everyone else.

---

## Features

### Attendance Tracking
See your per-course attendance at a glance. Clean, color-coded, and always up to date with your last sync.

### Marks Dashboard
Your CAT1, CAT2, assignments, and finals — all in one place. Each course card shows your score alongside the anonymous class average, so you have context without compromising anyone's privacy.

### Timetable
A clean day-by-day view of your schedule with a live time indicator. See what's now, what's next, and which slots are free — without logging into anything.

### Smart Sync
Three sync modes built for how students actually use the app:

| Mode | What it does |
|---|---|
| **Full sync** | Scrapes everything — attendance, marks, timetable — across all semesters |
| **Attendance only** | Just your attendance data, done fast |
| **Marks only** | Just your marks, done fast |

Attendance-only and marks-only syncs are the most-used modes — so they're treated as first-class, heavily optimized operations, not afterthoughts.

---

## Coming Soon

- FFCS planner with clash detection
- Skip predictor (how many classes you can safely miss)
- Widget support (attendance/next class on home screen)
- Biometric app lock

---

## Privacy

V-Stop is built with privacy as a constraint, not an afterthought.

| What | Where it goes |
|---|---|
| Your VIT credentials | Stored safely on Android Keychain / iOS Keystore with OS level encryption |
| Attendance, timetable data | Stored locally on your device only |
| Your marks | Stored locally. A one-way anonymous hash of your unique identifiers is used as a Firebase identifier |
| Class average data | Aggregated anonymously in Firebase. No reg number, no name — just numbers |

The anonymous hash is generated on-device and is not reversible. No one — including the developer — can link a Firebase entry back to a student.

---

## Installation

V-Stop is a hobby project. There is no planneed Play Store or App Store listing yet.

**Android (sideload APK):**

1. Download the latest APK from [Releases](https://github.com/V-Srivatsan/VStop/releases)
2. Enable "Install from unknown sources" in your Android settings
3. Install and open V-Stop
4. Enter your V-TOP credentials — data syncs once and is cached locally

---

## Tech Stack

| Layer | Tech |
|---|---|
| Framework | Flutter (Dart) |
| Local storage | ObjectBox |
| Anonymous aggregation | Firebase Firestore |
| Scraping | V-TOP session via in-app webview |

---

## Contributing

V-Stop is open source under the MIT license. The codebase is public and you're welcome to read, fork, and learn from it.
The app is still being actively shaped and the architecture is in flux. That said, feedback and bug reports are genuinely appreciated.

---

## Disclaimer

V-Stop is an independent student project and is not affiliated with, endorsed by, or connected to VIT or any official VIT systems. Use it at your own discretion.

---

<div align="center">

Built with way too much caffeine by [Srivatsan](https://srivatsan.netlify.app) · MIT License

</div>
