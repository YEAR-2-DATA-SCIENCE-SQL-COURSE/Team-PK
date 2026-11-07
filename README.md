# Volcanoes National Park Gorilla Trekking: SQL Injection Study

Database for **permits, guides, trekking groups and visitor bookings**, used to demonstrate
**SQL / data injection**: how it happens, how it is exploited, and how to prevent it.

## Structure

```
assignment presentation/
├─ README.md
├─ sql/
│  ├─ 01_schema.sql                tables, keys, constraints
│  ├─ 02_sample_data.sql           demo rows
│  ├─ 03_queries.sql               normal business queries
│  ├─ 04_injection_attacks.sql     vulnerable queries + attack payloads
│  └─ 05_prevention.sql            prepared statements, procedures, least privilege
├─ diagrams/
│  ├─ erd.mmd                      entity relationship diagram (Mermaid)
│  └─ injection-flow.mmd           attack vs defence flow (Mermaid)
└─ sample-data/                    CSV versions of the demo data
```


## Entities

- **visitors** — tourists who book treks
- **guides** — park guides who lead groups
- **gorilla_families** — habituated families (Susa, Sabyinyo, Agashya, Kwitonda, Amahoro, Hirwa)
- **trek_groups** — one daily group (max 8 visitors) = 1 guide + 1 family + 1 date
- **permits** — one permit per visitor per trek
- **bookings** — links visitor, permit and group, with payment status

## Entity Relationship Diagram

See `diagrams/erd.mmd` (Mermaid source). Render it at https://mermaid.live or with the
Mermaid extension in VS Code. It shows how `visitors`, `guides`, `gorilla_families`,
`trek_groups`, `permits`, and `bookings` relate to one another.

## How to run (MySQL)

```bash
mysql -u root -p < sql/01_schema.sql
mysql -u root -p gorilla_park < sql/02_sample_data.sql
mysql -u root -p gorilla_park < sql/03_queries.sql
```

`sql/04_injection_attacks.sql` is for **demonstration on this sample database only** —
never run equivalent raw queries against a real, internet-facing system.

`sql/05_prevention.sql` creates a least-privilege application account and stored
procedures that fix the vulnerable patterns shown in `04_injection_attacks.sql`.

## SQL injection in this system

| Entry point | Vulnerable pattern | Attacker payload | Impact |
|---|---|---|---|
| Guide login | string concatenation | `admin' --` or `' OR '1'='1` | authentication bypass |
| Visitor lookup by passport | string concatenation | `' OR 1=1 --` | dumps all visitor PII |
| Permit search by family/name | UNION SELECT | `x%' UNION SELECT username,password_plain FROM guides --` | leaks guide credentials |
| Booking status update | stacked query | `1; DROP TABLE bookings; --` | tampers or destroys data |
| Permit validity check | blind boolean injection | `RDB-0001' AND SUBSTRING(...)='A' --` | extracts data one character at a time |

Full working examples, with the exact vulnerable query the application builds and the
exact payload used, are in `sql/04_injection_attacks.sql`.

## Prevention

1. **Parameterized queries / prepared statements** — never concatenate user input into SQL text; bind values separately from the query template.
2. **Stored procedures with typed parameters** — `sp_guide_login`, `sp_find_visitor_by_passport` in `sql/05_prevention.sql`.
3. **Least-privilege DB accounts** — the application user (`park_app`) cannot `DROP`, `ALTER`, or `CREATE`.
4. **Hashed passwords** — bcrypt/argon2 at the application layer; never store plaintext (the demo schema uses plaintext only to make the login-bypass attack visible).
5. **Input validation / allow-lists** — restrict dates, permit numbers, and family names to expected formats before they ever reach SQL.
6. **Hide raw DB errors** — show a generic message to users; log full errors server-side only.
7. **Monitoring** — watch for unusual query patterns (e.g. `UNION`, `--`, `;` in form fields) as an additional layer, not a replacement for the fixes above.

## Diagrams

- `diagrams/erd.mmd` — entity relationship diagram of the six tables.
- `diagrams/injection-flow.mmd` — flowchart contrasting the vulnerable (string-concatenation) path with the safe (prepared-statement) path for the same input.

## Sample Data

CSV versions of the demo rows used in `sql/02_sample_data.sql` live in `sample-data/`
(`visitors.csv`, `guides.csv`, `gorilla_families.csv`, `trek_groups.csv`, `permits.csv`,
`bookings.csv`) for anyone who wants to load the data outside MySQL (e.g. into Excel,
pandas, or another DBMS).

## Presentation

The slide deck (`Gorilla_Trekking_SQL_Injection.pptx`) is intentionally excluded from
this GitHub repository and is submitted through the course's Google Form link instead.

## Team

Group assignment — ULK (Kigali Independent University), Year 2 Data Science, SQL course.
Repository: `YEAR-2-DATA-SCIENCE-SQL-COURSE/Team-PK`.
