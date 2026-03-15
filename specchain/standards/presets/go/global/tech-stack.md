# Tech Stack

| Layer          | Technology       | Notes                    |
|----------------|------------------|--------------------------|
| Language       | Go 1.22+         | Modules required         |
| Framework      | net/http + chi   | Minimal framework        |
| Database       | PostgreSQL       | Via pgx or sqlc          |
| Styling        | —                | Backend service          |
| Testing        | testing + testify | Table-driven tests      |
| Infrastructure | Docker + systemd | Static binary deploy     |
