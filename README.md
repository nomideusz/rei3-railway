# Deploy and Host REI3 on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/rei3?referralCode=sLjDXb&utm_medium=integration&utm_source=button&utm_campaign=rei3)

[REI3](https://rei3.de) is an open-source low-code platform for business applications. You install ready-made apps from its free repository (time tracking, absences, projects and tasks, tickets, IT assets, a password safe, contracts, CRM-style contact lists and more), or build your own in the browser with forms, lists, calendars, Gantt charts, roles and workflows, then adjust them to fit. It is MIT licensed, written in Go, and developed in Germany since 2019.

## About Hosting REI3

This template runs REI3 3.13 against Railway Postgres:

| Service | What it does |
|---|---|
| **REI3** | The REI3 server (web app, API, scheduler), built from the official release package. Its volume holds uploaded files, the config file and integrated backups. |
| **Postgres** | PostgreSQL 17 on a volume. |

REI3 has no official container image, and its example Docker setup is marked "development and testing only" because it keeps the default login and hard-codes database credentials. This template fixes both:

- **No `admin` / `admin`.** REI3 creates an `admin` account with password `admin` on first start, so anyone who finds a fresh instance can take it over. Here the start script replaces that password with the generated `R3_ADMIN_PASSWORD` as soon as the account exists, and only while it still has the default.
- **Database settings from Railway variables.** The config file is rewritten from the `PG*` variables on every boot, so credentials are never baked into the image.
- **Behind Railway's HTTPS.** REI3 serves plain HTTP inside the container and Railway terminates TLS, so there are no self-signed certificate warnings.
- **Thumbnails and backups work.** ImageMagick and Ghostscript are installed for image and PDF previews, and `pg_dump` 17 for REI3's integrated backups.
- **Links point to your domain.** REI3's public host name, used in emails, calendar feeds and client downloads, is set to the Railway domain on first boot.

## Common Use Cases

- Ready-made internal apps for a small or mid-sized company: time tracking, absence requests, projects, tickets, IT asset lists
- Replacing spreadsheets and Access databases with multi-user web apps that have roles, audit logs and workflows
- Building custom business apps (inventory, contracts, approvals) without writing a backend

## Dependencies for REI3 Hosting

- PostgreSQL 17 (included)
- SMTP or IMAP credentials (optional) for notifications and mail-driven workflows

### Deployment Dependencies

- [REI3 admin documentation](https://rei3.de/en/docs/admin)
- [REI3 on GitHub](https://github.com/r3-team/r3)
- [Template source on GitHub](https://github.com/two-workspaces/rei3)

### Implementation Details

**Sign in.** Open the REI3 service's Railway domain and sign in as `admin`, with the `R3_ADMIN_PASSWORD` value from the service's Variables tab. The variable is only used to replace the default password, so change it afterwards under your user settings (top right).

**Install apps.** A fresh instance has no apps. The setup screen offers **Install Core Company** (absences, time tracking, projects and tasks, requests, a password safe and IT assets, in one click) or single apps from the repository, which you can also find later under Admin → Applications. Then open Admin → Users, edit your user and give it roles in the apps. Without roles you'll see "No access to applications".

**Maintenance mode.** A new instance starts in maintenance mode, where only admins can sign in. Turn on **Production mode** under Admin → System once your apps are installed, so your users can sign in.

**Add users.** Admin → Users → **New**. Set a password there, or connect LDAP or OAuth (those are Professional features that need a license, but local users are free and unlimited).

**Backups.** Under Admin → Backups, set the target directory to `/opt/r3/data/backups` (already created) and turn on daily, weekly or monthly sets. They are written to the REI3 service's volume, so download or copy them off Railway regularly. Railway's own volume backups are another option.

**Email (optional).** Add SMTP and IMAP accounts under Admin → Email accounts. No variables are needed.

**Custom domain.** Add it to the REI3 service, then update the public host name under Admin → System.

**Upgrade.** Set `R3_VERSION` on the REI3 service to a newer release (for example `3.13.1`, see [releases](https://github.com/r3-team/r3/releases)) and deploy. The image is rebuilt with that version and REI3 upgrades the database on start. Upgrades can't be undone, so take a backup first.

**Things to know.**

- Keep **brute-force protection** (Admin → System) off. Behind Railway's proxy REI3 sees the proxy's address instead of each visitor's, so blocking one attacker would block everyone.
- `R3_ADMIN_PASSWORD` and `R3_PUBLIC_HOST` only apply on first boot. Changing them later does nothing; use the REI3 admin UI instead.
- Clustering (several REI3 nodes on one database) is supported by REI3 but not set up here.

**Memory.** Measured on Railway with the Core Company apps installed: REI3 idles at about 115 MB (peaking near 230 MB while installing apps) and Postgres at about 160 MB, so under 300 MB in total.

## Why Deploy REI3 on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying REI3 on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
