# Event Hub

A full-stack event management application where users can create events, vote on polls, RSVP, and discuss through nested comments.

Built as a learning project using **Claude** and **Cursor**.

## Tech Stack

| Layer    | Technology                              |
| -------- | --------------------------------------- |
| Backend  | Node.js, Express 5, TypeScript, SQLite  |
| Frontend | Flutter (Dart), BLoC state management   |

## Project Structure

```
event_hub/
├── event_hub_api/   # REST API (Node.js + Express + SQLite)
└── event_hub_app/   # Mobile & Web client (Flutter)
```

## Features

- Create events with categories (cinema, food, games, sports, other)
- Three event types: **Poll**, **Discussion**, **Announcement**
- Poll voting (single-choice & multiple-choice)
- Participation / RSVP (going, maybe, not going)
- Nested comment threads with upvotes
- Event finalization with date, location, and details
- Calendar export (ICS)

---

## Getting Started

### Prerequisites

#### Node.js (v18+)

Download and install from [https://nodejs.org](https://nodejs.org) (LTS recommended). This also installs `npm`.

Verify installation:

```bash
node --version
npm --version
```

#### Flutter SDK (3.9+)

1. Follow the official installation guide for your OS: [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
2. Add Flutter to your system PATH
3. Run Flutter doctor to check everything is set up:

```bash
flutter doctor
```

> **macOS:** You may also need Xcode (for iOS) or Android Studio (for Android emulator).
> **Windows:** You may need Android Studio and the Android SDK.
> **All platforms:** For web development, only Chrome is required.

#### Git

Download and install from [https://git-scm.com](https://git-scm.com).

#### Clone the Repository

```bash
git clone https://github.com/bzkrterdm/event_hub.git
cd event_hub
```

### 1. Backend (API)

```bash
cd event_hub_api

# Install dependencies
npm install

# Seed the database with sample data
npm run seed

# Start the development server (port 8080)
npm run dev
```

The API will be available at `http://localhost:8080`. You can verify with:

```bash
curl http://localhost:8080/health
```

### 2. Frontend (Flutter App)

```bash
cd event_hub_app

# Get dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome

# Or run on a connected device / emulator
flutter run
```

> **Note:** The app connects to the API at `http://localhost:8080/api` by default. Make sure the backend is running before starting the app.

---

## API Endpoints

| Method | Endpoint                          | Description                 |
| ------ | --------------------------------- | --------------------------- |
| GET    | `/health`                         | Health check                |
| GET    | `/api/users`                      | List all users              |
| GET    | `/api/events`                     | List events                 |
| GET    | `/api/events/:id`                 | Event detail                |
| POST   | `/api/events`                     | Create event                |
| POST   | `/api/events/:id/vote`            | Upvote an event             |
| PUT    | `/api/events/:id/finalize`        | Finalize an event           |
| POST   | `/api/events/:eventId/polls`      | Create a poll               |
| POST   | `/api/polls/:id/vote`             | Vote on a poll option       |
| POST   | `/api/events/:eventId/participate`| Set participation status    |
| GET    | `/api/events/:eventId/comments`   | Get comment tree            |
| POST   | `/api/events/:eventId/comments`   | Add a comment               |
| POST   | `/api/comments/:id/vote`          | Upvote a comment            |
| GET    | `/api/events/:id/calendar.ics`    | Export event as ICS         |

---

## Screenshots

_Coming soon_

## License

This project is for educational purposes.
