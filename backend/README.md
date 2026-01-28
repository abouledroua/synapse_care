# Backend (Node + Express + PostgreSQL)

## Setup

```bash
cd backend
npm install
copy .env.example .env
```

Edit `.env` with your database credentials, then:

```bash
npm run dev
```

## Endpoints

- `GET /health` - API + DB health check
- `POST /auth/signup` - doctor signup (creates user with `type=1`)
- `GET /patients` - list patients
