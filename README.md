# Pulse League Manager — Online Edition

This package converts the supplied Excel league manager into a deployable multi-user web app.

## Stack
- Frontend: static HTML/CSS/JavaScript
- Hosting: Vercel (or any static host)
- Authentication + shared database: Supabase
- Source data migration: `migration.json`

## 1. Create Supabase
Create a Supabase project and open **SQL Editor**.
Run `schema.sql`.

Then create the first staff account from the app's **Create account** button.

## 2. Configure the app
Copy `config.example.js` to `config.js`.
Put your Supabase project URL and the browser-safe `anon` key into `config.js`.

Do NOT put a Supabase service-role key in this project.

## 3. Deploy
Upload the project to GitHub, then import the repository into Vercel.
Vercel will serve `index.html` as the public application.

## 4. Migrate the Excel workbook
`migration.json` contains the records extracted from the supplied workbook.
For a production migration, import those records into the matching Supabase tables. The table names are:
- Players -> `players`
- Teams -> `teams`
- Schedule -> `games`
- Payments -> `payments`
- Attendance -> `attendance`
- Bracket -> `bracket_matches`

The current frontend includes the core online CRUD workflow for players, teams, games and payments, plus live standings.

## Important security note
The included RLS policies allow authenticated league users to read/write league data. For a larger organization, add admin/staff-specific policies before opening the system broadly.

## What you get
- Shared cloud database instead of browser-only localStorage
- Email/password authentication
- Multiple staff accounts
- Dashboard
- Players
- Teams
- Schedule
- Standings
- Payments
- Responsive desktop/mobile layout
