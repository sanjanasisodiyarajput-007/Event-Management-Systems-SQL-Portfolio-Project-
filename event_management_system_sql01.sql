create database Event_Management_System

create table users(
user_id int primary key,
name varchar(50),
city varchar(50),
age int
);

create table events(
event_id int primary key,
event_name varchar(100),
category varchar(50),
ticket_price decimal(10,2)
);

create table registrations(
registration_id int primary key,
user_id int,
event_id int,
feedback_rating int,
attended int,
foreign key (user_id) references users(user_id),
foreign key(event_id) references events(event_id)
);

insert into users values
(1,'sanna','delhi',20),
(2,'disha','UP',32),
(3,'naha','delhi',25),
(4,'deepanshi','noida',28),
(5,'raghav','karela',29),
(6,'jadega','haryana',31);

insert into events values
(101,'birthday','entertainment',500),
(102,'marriage','function',500),
(103,'enagement','function',300),
(104,'music concert','entertainment',500),
(105,'yoga training','health',500);

insert into registrations values
(1,1,101,9,1),
(2,2,101,6,1),
(3,3,102,6,1),
(4,4,103,7,1),
(5,5,104,7,1),
(6,6,105,9,1),
(7,1,102,4,1),
(8,2,103,8,1),
(9,3,104,9,1),
(10,4,105,null,0);

--Q1.analyze event popularity(total registrations)--
 SELECT e.event_name, COUNT(r.registration_id) AS total_registrations
FROM Events e
LEFT JOIN Registrations r ON e.event_id = r.event_id
GROUP BY e.event_name
ORDER BY total_registrations DESC


--Q2. calculate total registrations and average feedback for each event--
SELECT e.event_name, AVG(r.feedback_rating) AS avg_rating
FROM Events e
JOIN Registrations r ON e.event_id = r.event_id
WHERE r.feedback_rating IS NOT NULL
GROUP BY e.event_name;


--Q3. find events with an average rating greater than 8--
SELECT e.event_name
FROM Events e
JOIN Registrations r ON e.event_id = r.event_id
GROUP BY e.event_name
HAVING AVG(r.feedback_rating) > 8;


--Q4. determine total revenue genrated by each event--
SELECT e.event_name,
       e.ticket_price * COUNT(r.registration_id) AS total_revenue
FROM Events e
JOIN Registrations r ON e.event_id = r.event_id
GROUP BY e.event_name, e.ticket_price;


--Q5. identify top performing events in each category--
SELECT category, event_name, avg_rating
FROM (
    SELECT e.category, e.event_name,
           AVG(r.feedback_rating) AS avg_rating,
           RANK() OVER (PARTITION BY e.category ORDER BY AVG(r.feedback_rating) DESC) AS rnk
    FROM Events e
    JOIN Registrations r ON e.event_id = r.event_id
    GROUP BY e.category, e.event_name
) t
WHERE rnk = 1;


--Q6. DISPLAY USERS WHO ATTENDED MORE THAN ONE EVENT--
SELECT u.name, COUNT(r.event_id) AS attended_events
FROM Users u
JOIN Registrations r ON u.user_id = r.user_id
WHERE r.attended = 1
GROUP BY u.name
HAVING COUNT(r.event_id) > 1;


--Q7. shows users who have not attended any event--
SELECT u.name
FROM Users u
LEFT JOIN Registrations r ON u.user_id = r.user_id AND r.attended = 1
GROUP BY u.user_id, u.name
HAVING COUNT(r.registration_id) = 0;


--Q8. retrieve users who attended the most expensive event--
SELECT u.name, e.event_name, e.ticket_price
FROM Users u
JOIN Registrations r ON u.user_id = r.user_id
JOIN Events e ON r.event_id = e.event_id
WHERE e.ticket_price = (SELECT MAX(ticket_price) FROM Events)
  AND r.attended = 1;


--Q8.generate a leaderboard showing each users total attendeed events anmd average rating--
  SELECT 
    u.name,
    COUNT(r.event_id) AS total_events_attended,
    AVG(r.feedback_rating) AS avg_rating
FROM Users u
JOIN Registrations r ON u.user_id = r.user_id
WHERE r.attended = 1
GROUP BY u.name
ORDER BY total_events_attended DESC, avg_rating DESC;