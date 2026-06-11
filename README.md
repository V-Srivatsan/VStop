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
Per-course attendance at a glance, color-coded by proximity to your configured safety threshold. See exactly how many classes you can skip before dropping below — or how many consecutive classes you need to attend to recover.

### Marks Dashboard
Your CAT1, CAT2, assignments, and finals in one place. Each course card shows your score alongside the anonymous class average, so you know where you stand without compromising anyone's privacy. Supports both standard and ACE grading systems, with grade estimation for ongoing courses.

### Timetable
A day-by-day view of your schedule with a live time indicator. Adaptive — automatically shows no classes on holidays, adjusts for extra instructional days, and reflects your actual exam schedule when applicable.

### Academic Calendar
Instructional days, holidays, and exam dates in one unified calendar. Syncs the current semester automatically and overlays your pending assignments on top — so deadlines and academic events live in the same place.

### Assignments
Manually track your assignments with titles, descriptions, and deadlines. Pending and submitted assignments are separated into tabs, sorted by deadline. Deadlines are integrated into the academic calendar so nothing gets buried.

### Curriculum
Your full course catalogue organised by basket, with credit tracking. Completed courses show their received grade. Supports both standard and ACE grading structures.

### OD Hours
Track your on-duty hours against your semester limit at a glance.

### Smart Sync
Four sync modes built for how students actually use the app:

| Mode | What it does |
|---|---|
| **Full sync** | Scrapes attendance, marks, timetable, calendar and exam schedule |
| **Attendance only** | Just your attendance data for the currently selected semester |
| **Marks only** | Just your marks of the current semester, and your complete grade history |
| **Calendar only** | The academic calendar of the current semester, along with the exam schedules |

Attendance-only and marks-only syncs are the most-used modes — treated as first-class, heavily optimised operations, not afterthoughts.

### Notifications
Timely reminders that respect your schedule:

| Type | When |
|---|---|
| **Classes** | 10 minutes before start |
| **Exams** | 30 minutes before start |
| **Assignments** | 1 hour, 30 minutes, and 10 minutes before deadline |

Each notification type can be individually enabled or disabled from the profile section.

### Theming
Fully custom Material 3 design system with light, dark, and AMOLED themes. The AMOLED theme is true black — built for OLED screens where it matters.

---

## Coming Soon

- FFCS planner with clash detection
- Laundry, Mess and Bus Schedules
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

The anonymous hash is generated and salted on-device and is not reversible. No one — including the developer — can link a Firebase entry back to a student.

---

## Installation

V-Stop is currently in early access, distributed as a sideload APK. 
There is no Play Store listing planned at this time.

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
