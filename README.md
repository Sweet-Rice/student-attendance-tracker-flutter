# Student Attendance Tracker

A clean, responsive Material 3 Flutter app for recording student and subject attendance.

## Features

- Add students and remove students with confirmation.
- Add subjects to each student; empty student and subject names are rejected with validation messages.
- Mark each class Present or Absent, with percentages updated immediately.
- Mark the whole class present in one tap with the **Mark all present** (✓✓) action in the app bar.
- Correct Present and Total class counts for existing records.
- View each student's subject-wise and overall attendance, plus a dashboard-wide overall rate.
- Show a shortage warning when recorded attendance falls below 75%.
- Save student, subject, and attendance data locally between launches.
- Responsive dashboard layout for narrow and wide screens.

## SDG 4 connection

This app supports **UN Sustainable Development Goal 4: Quality Education** by helping educators monitor attendance and identify students who may need follow-up support. Clear attendance records can help schools respond early to participation barriers and encourage consistent access to learning.

## Screenshots

Add 3–4 screenshots of the running app to `screenshots/` before submitting. Suggested views:

1. Dashboard with overall attendance and student list.
2. Add-student form and validation.
3. A student's subject attendance with present/absent actions.
4. Attendance shortage or corrected attendance view.

## Technologies

- Flutter and Dart
- Material 3
- Provider (`ChangeNotifierProvider`, `ChangeNotifier`, `Consumer`)
- `shared_preferences` for local JSON persistence

## How Provider is used

`AttendanceProvider` owns the student list and attendance operations. Screens read state through `Consumer` and invoke changes through `context.read`. Each mutation saves the updated data and notifies listeners, so attendance totals and percentages refresh live.

## Run locally

1. Install a working Flutter SDK and an Android, iOS, web, or desktop target.
2. From this directory, run `flutter create --platforms=android,ios,web,windows .` to generate the native target folders if they are not present.
3. Run `flutter pub get`.
4. Run `flutter run` (or choose a target with `flutter run -d <device>`).

## Publish on GitHub Pages

The workflow in `.github/workflows/deploy.yml` builds the web version and deploys it to GitHub Pages on every push to `main`. Push this project as the root of a GitHub repository, then set **Settings → Pages → Build and deployment → Source** to **GitHub Actions**. After the workflow succeeds, the site URL will be `https://<your-github-username>.github.io/<repository-name>/`.

## Attendance calculation formula

`Attendance Percentage = Present Classes / Total Classes × 100`

When no classes have been recorded, the app displays 0.0%.
