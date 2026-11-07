USE gorilla_park;

-- 1. Least-privilege application account (no DROP/ALTER/CREATE rights)
DROP USER IF EXISTS 'park_app'@'localhost';
CREATE USER 'park_app'@'localhost' IDENTIFIED BY 'ChangeThisStrongPW!';
GRANT SELECT, INSERT, UPDATE ON gorilla_park.* TO 'park_app'@'localhost';
REVOKE DELETE, DROP, ALTER, CREATE ON gorilla_park.* FROM 'park_app'@'localhost';
FLUSH PRIVILEGES;

-- 2. Stored procedure with typed parameters replaces string-built login query
DELIMITER //
CREATE PROCEDURE sp_guide_login (IN p_username VARCHAR(50), IN p_password VARCHAR(100))
BEGIN
  SELECT guide_id, full_name, role
  FROM guides
  WHERE username = p_username AND password_plain = p_password;
END //
DELIMITER ;
-- App calls this with bound parameters, e.g. (PDO/mysqli/Python):
--   CALL sp_guide_login(?, ?);   -- never string-concatenated

-- 3. Stored procedure for passport lookup (parameterized, no LIKE string-building)
DELIMITER //
CREATE PROCEDURE sp_find_visitor_by_passport (IN p_passport VARCHAR(30))
BEGIN
  SELECT full_name, email FROM visitors WHERE passport_no = p_passport;
END //
DELIMITER ;

-- 4. Passwords should never be plaintext in production:
--    store guides.password_hash VARCHAR(255) using bcrypt/argon2 at the app layer,
--    compare with password_verify()/argon2.verify(), not SQL.

-- 5. Example parameterized query patterns per language (reference, not executable SQL):
--    PHP (PDO):    $stmt = $pdo->prepare("SELECT * FROM guides WHERE username = ?");
--                  $stmt->execute([$username]);
--    Python:       cur.execute("SELECT * FROM guides WHERE username = %s", (username,))
--    Node (mysql2):conn.execute("SELECT * FROM guides WHERE username = ?", [username]);
--    None of these ever concatenate user input into the SQL string.