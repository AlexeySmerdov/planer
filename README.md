# Task Planner PWA

A Progressive Web Application (PWA) for task management with offline support, built with Next.js, TypeScript, and Tailwind CSS.

## Features

- ✅ Create, update, and delete tasks
- 📅 View tasks in a calendar
- 📷 Attach images to tasks
- 💬 Add comments to tasks
- 🔄 Works offline (data stored in localStorage)
- 📱 Installable as a PWA

## Tech Stack

- Next.js 13+ (App Router)
- TypeScript
- Tailwind CSS
- FullCalendar
- next-pwa
- Local Storage

## Getting Started

1. Clone the repository
2. Install dependencies:
   ```bash
   npm install
   ```
3. Run the development server:
   ```bash
   npm run dev
   ```
4. Open [http://localhost:3000](http://localhost:3000) in your browser

## Build for Production

```bash
npm run build
npm start
```

## PWA Features

- Offline support
- Installable on desktop and mobile devices
- Local data persistence
- Push notifications (coming soon)

## Project Structure

```
src/
  app/                    # Next.js App Router pages
    page.tsx             # Home page
    calendar/            # Calendar view
    new-task/           # Create task form
    task/[id]/          # Task details page
  types/                # TypeScript type definitions
  utils/                # Utility functions
public/                 # Static assets
  manifest.json         # PWA manifest
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request 