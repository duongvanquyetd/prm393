Setup and run the auth server (connects to SQL Server)

1. Install dependencies:

```bash
cd server
npm install
```

2. Create database and table (example):

```sql
CREATE DATABASE DuaThuyen;
USE DuaThuyen;
CREATE TABLE Users (
  Id INT IDENTITY PRIMARY KEY,
  Name NVARCHAR(200),
  Email NVARCHAR(250) UNIQUE,
  PasswordHash NVARCHAR(500)
);
```

3. Configure environment variables (create a `.env` file in `server/`):

```
DB_USER=sa
DB_PASSWORD=YourStrong!Passw0rd
DB_SERVER=localhost
DB_NAME=DuaThuyen
PORT=3000
```

4. Start server:

```bash
npm start
```

Access endpoints at `http://localhost:3000/register` and `/login`.
