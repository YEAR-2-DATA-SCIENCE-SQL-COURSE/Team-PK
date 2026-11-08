SELECT DATABASE(), CURRENT_USER(), NOW();

-- ============================================================
-- Soldier Management SQL   |  Student: Uwase Ishimwe Viella  (202511196)
-- Personal values: P=6  U=1  M=2
-- Needs soldiers_seed.sql (teacher) in the same folder as this file.
-- Run from this folder:  mysql -u root -p -t -e "source sms_202511196.sql"
-- Replace every <N> with the real row count after running.
-- ============================================================

-- ===================== PART A: CREATE THE TABLES =====================

-- A0
-- Does: creates my own database so all 5 tables live in one place.
CREATE DATABASE IF NOT EXISTS sms_202511196;

-- A0b
-- Does: selects my database so every following statement works inside it.
USE sms_202511196;

-- A0c
-- Does: removes the view if an old copy exists, so this file can be re-run safely.
DROP VIEW IF EXISTS v_soldier_profile;

-- A0d
-- Does: drops old tables (children first) so this file can be re-run from zero.
DROP TABLE IF EXISTS soldier_missions, soldiers, missions, units, ranks;

-- A1
-- Does: creates ranks. PK rank_id; name required+unique; level only 1 to 6.
CREATE TABLE ranks (
  rank_id    INT         NOT NULL,
  rank_name  VARCHAR(50) NOT NULL,
  rank_level TINYINT     NOT NULL,
  CONSTRAINT pk_ranks       PRIMARY KEY (rank_id),
  CONSTRAINT uq_ranks_name  UNIQUE (rank_name),
  CONSTRAINT ck_ranks_level CHECK (rank_level BETWEEN 1 AND 6)
) ENGINE=InnoDB;

-- A2
-- Does: creates units. PK unit_id; name required+unique; location required.
CREATE TABLE units (
  unit_id   INT          NOT NULL,
  unit_name VARCHAR(80)  NOT NULL,
  location  VARCHAR(80)  NOT NULL,
  CONSTRAINT pk_units      PRIMARY KEY (unit_id),
  CONSTRAINT uq_units_name UNIQUE (unit_name)
) ENGINE=InnoDB;

-- A3
-- Does: creates missions. end_date may be NULL (ongoing) but never before start_date.
CREATE TABLE missions (
  mission_id   INT          NOT NULL,
  mission_name VARCHAR(100) NOT NULL,
  start_date   DATE         NOT NULL,
  end_date     DATE         NULL,
  CONSTRAINT pk_missions       PRIMARY KEY (mission_id),
  CONSTRAINT uq_missions_name  UNIQUE (mission_name),
  CONSTRAINT ck_missions_dates CHECK (end_date IS NULL OR end_date >= start_date)
) ENGINE=InnoDB;

-- A4
-- Does: creates soldiers. Auto-numbered PK, unique service number, all columns required,
--       status limited to 3 values (default Active), enlistment after birth, FKs to ranks and units.
CREATE TABLE soldiers (
  soldier_id      INT         NOT NULL AUTO_INCREMENT,
  service_number  VARCHAR(30) NOT NULL,
  first_name      VARCHAR(50) NOT NULL,
  last_name       VARCHAR(50) NOT NULL,
  date_of_birth   DATE        NOT NULL,
  enlistment_date DATE        NOT NULL,
  status          VARCHAR(10) NOT NULL DEFAULT 'Active',
  rank_id         INT         NOT NULL,
  unit_id         INT         NOT NULL,
  CONSTRAINT pk_soldiers        PRIMARY KEY (soldier_id),
  CONSTRAINT uq_soldiers_svc    UNIQUE (service_number),
  CONSTRAINT ck_soldiers_status CHECK (status IN ('Active','On Leave','Retired')),
  CONSTRAINT ck_soldiers_dates  CHECK (enlistment_date > date_of_birth),
  CONSTRAINT fk_soldiers_rank   FOREIGN KEY (rank_id) REFERENCES ranks(rank_id),
  CONSTRAINT fk_soldiers_unit   FOREIGN KEY (unit_id) REFERENCES units(unit_id)
) ENGINE=InnoDB;

-- A5
-- Does: creates soldier_missions (many-to-many link). Composite PK stops a soldier being
--       listed twice on one mission; FKs force soldier and mission to exist; role required.
CREATE TABLE soldier_missions (
  soldier_id   INT         NOT NULL,
  mission_id   INT         NOT NULL,
  mission_role VARCHAR(60) NOT NULL,
  CONSTRAINT pk_soldier_missions PRIMARY KEY (soldier_id, mission_id),
  CONSTRAINT fk_sm_soldier FOREIGN KEY (soldier_id) REFERENCES soldiers(soldier_id),
  CONSTRAINT fk_sm_mission FOREIGN KEY (mission_id) REFERENCES missions(mission_id)
) ENGINE=InnoDB;

-- ===================== PART B: INSERT THE DATA =====================

-- B1a
-- Does: inserts the 6 ranks given in the exam.
INSERT INTO ranks (rank_id, rank_name, rank_level) VALUES
(1,'Private',1),(2,'Corporal',2),(3,'Sergeant',3),
(4,'Lieutenant',4),(5,'Captain',5),(6,'Major',6);

-- B1b
-- Does: inserts the 6 units given in the exam.
INSERT INTO units (unit_id, unit_name, location) VALUES
(1,'Alpha Company','North Camp'),(2,'Bravo Company','South Camp'),
(3,'Charlie Company','East Camp'),(4,'Delta Company','West Camp'),
(5,'Signals Unit','Central Camp'),(6,'Medical Unit','Central Camp');

-- B1c
-- Does: inserts the 5 missions; "none" end dates are stored as NULL (ongoing mission).
INSERT INTO missions (mission_id, mission_name, start_date, end_date) VALUES
(1,'Exercise Falcon','2025-02-03','2025-02-28'),
(2,'Flood Relief','2025-04-14','2025-05-30'),
(3,'Border Patrol','2025-07-01',NULL),
(4,'Peace Support','2025-09-15',NULL),
(5,'Field Medical Camp','2026-01-12','2026-01-23');

-- B2
-- Does: runs the teacher's file that adds 30 soldiers and their mission assignments.
SOURCE soldiers_seed.sql;

-- B3a
-- Does: adds soldiers 31-33. 31 = me (rank 1, unit U=1); 32 = invented (rank (6 mod 6)+1 = 1, unit 1);
--       33 = invented (rank 2, unit (1 mod 6)+1 = 2). Dates are invented; status stays Active (default).
INSERT INTO soldiers (soldier_id, service_number, first_name, last_name, date_of_birth, enlistment_date, status, rank_id, unit_id) VALUES
(31,'ST-202511196',  'Ishimwe Viella',  'Uwase',  '2003-03-12',   '2024-02-05',   'Active',1,1),
(32,'ST-202511196-2','Eric','Habimana','1999-08-21','2021-03-15','Active',1,1),
(33,'ST-202511196-3','Aline','Mukamana','2001-11-02','2022-06-01','Active',2,2);

-- B3b
-- Does: puts soldiers 31 and 32 on mission M=2 with a role each. Soldier 33 gets no mission on purpose.
INSERT INTO soldier_missions (soldier_id, mission_id, mission_role) VALUES
(31,2,'Radio Operator'),
(32,2,'Driver');

-- ===================== PART C: RETRIEVE THE DATA =====================

-- C1
-- Does: shows the last 10 soldiers added by sorting ID high to low and keeping 10.
-- Rows returned: <N>
SELECT * FROM soldiers ORDER BY soldier_id DESC LIMIT 10;

-- C2
-- Does: takes the same last 10 soldiers, then re-sorts them from lowest ID to highest.
-- Rows returned: <N>
SELECT * FROM (SELECT * FROM soldiers ORDER BY soldier_id DESC LIMIT 10) AS last_ten ORDER BY soldier_id ASC;

-- C3
-- Does: finds soldiers whose ID is 10, 15 or 20 using IN.
-- Rows returned: <N>
SELECT * FROM soldiers WHERE soldier_id IN (10,15,20);

-- C4
-- Does: same as C3 but shifted by P=6, so IDs 16, 21, 26.
-- Rows returned: <N>
SELECT * FROM soldiers WHERE soldier_id IN (16,21,26);

-- C5
-- Does: lists Active soldiers with ID from 10 to 20 (both included) using BETWEEN.
-- Rows returned: <N>
SELECT * FROM soldiers WHERE status = 'Active' AND soldier_id BETWEEN 10 AND 20;

-- C6
-- Does: shows ID, name and rank name; highest rank level first, then last name A-Z.
-- Rows returned: <N>
SELECT s.soldier_id, s.first_name, s.last_name, r.rank_name
FROM soldiers s JOIN ranks r ON r.rank_id = s.rank_id
ORDER BY r.rank_level DESC, s.last_name;

-- C7
-- Does: shows Active soldiers of unit U=1 with rank name, unit name and location.
-- Rows returned: <N>
SELECT s.first_name, s.last_name, r.rank_name, u.unit_name, u.location
FROM soldiers s
JOIN ranks r ON r.rank_id = s.rank_id
JOIN units u ON u.unit_id = s.unit_id
WHERE s.status = 'Active' AND s.unit_id = 1;

-- C8
-- Does: shows everyone on mission M=2 with mission name, soldier name, role and unit name.
-- Rows returned: <N>
SELECT m.mission_name, s.first_name, s.last_name, sm.mission_role, u.unit_name
FROM soldier_missions sm
JOIN missions m ON m.mission_id = sm.mission_id
JOIN soldiers s ON s.soldier_id = sm.soldier_id
JOIN units    u ON u.unit_id    = s.unit_id
WHERE sm.mission_id = 2;

-- C9
-- Does: finds soldiers with no row in soldier_missions (LEFT JOIN, keep the NULL matches).
-- Rows returned: <N>
SELECT s.soldier_id, s.first_name, s.last_name
FROM soldiers s LEFT JOIN soldier_missions sm ON sm.soldier_id = s.soldier_id
WHERE sm.soldier_id IS NULL;

-- C10
-- Does: counts soldiers per unit (units with 0 still show), biggest unit first.
-- Rows returned: <N>
SELECT u.unit_name, COUNT(s.soldier_id) AS soldier_count
FROM units u LEFT JOIN soldiers s ON s.unit_id = u.unit_id
GROUP BY u.unit_id, u.unit_name
ORDER BY soldier_count DESC;

-- ===================== PART D: INDEX AND VIEW =====================

-- D1a
-- Does: EXPLAIN BEFORE the index, to see how MySQL searches last_name.
-- Rows returned: <N>
EXPLAIN SELECT * FROM soldiers WHERE last_name = 'Mugisha';

-- D1b
-- Does: creates the index idx_soldiers_last_name on last_name.
CREATE INDEX idx_soldiers_last_name ON soldiers (last_name);

-- D1c
-- Does: the same EXPLAIN AFTER the index.
-- Rows returned: <N>
-- What changed: type changed from <ALL> to <ref>, key changed from <NULL> to <idx_soldiers_last_name>
--               (write what YOUR output showed; MySQL now jumps straight to matching rows instead of reading the whole table).
EXPLAIN SELECT * FROM soldiers WHERE last_name = 'Mugisha';

-- D2
-- Does: creates view v_soldier_profile: one row per soldier with full name, rank, unit, location, status.
CREATE VIEW v_soldier_profile AS
SELECT s.soldier_id, CONCAT(s.first_name,' ',s.last_name) AS full_name,
       r.rank_name, u.unit_name, u.location, s.status
FROM soldiers s
JOIN ranks r ON r.rank_id = s.rank_id
JOIN units u ON u.unit_id = s.unit_id;

-- D3
-- Does: uses the view to show every soldier in unit U=1, ordered by full name.
-- Rows returned: <N>
SELECT * FROM v_soldier_profile
WHERE unit_name = (SELECT unit_name FROM units WHERE unit_id = 1)
ORDER BY full_name;

-- ===================== CHANGE ORDER =====================
-- Does: <Change Order text was not in the document - paste its task here, then its SQL below, with a comment>