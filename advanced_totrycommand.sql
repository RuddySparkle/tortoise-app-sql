-- Scenario:
-- The admin want to see the listed data
-- 1. Provider's name
-- 2. Provider's username
-- 3. Provider's total appointment
-- 4. Provider's average income recieved per appointment
-- which is sorted by the average income.
-- Show the provider if and only if he/she has committed at least 1 appointment.
-- If an appointment A finished in under 30 minutes or over 12 hours, It is possible that A could be an illegal action,
-- and the transaction of A won't be shown in the table until the inspection process is finished.

SELECT
 	users.username,
	users.name,
	COUNT(A.transaction_id) AS total_appointment,
	SUM(amount)/COUNT(A.transaction_id) AS average_income_per_appointment
	
FROM 
	(SELECT provider_id, end_time - start_time AS appointment_duration, transaction_id 
	FROM make_appointment
	JOIN appointment
	ON make_appointment.appointment_id = appointment.appointment_id
	WHERE end_time - start_time > '00:30:00' AND end_time - start_time < '12:00:00') A
	JOIN appointment_transaction
	ON appointment_transaction.transaction_id = A.transaction_id
	JOIN users 
	ON A.provider_id = users.user_id
	
GROUP BY
	users.username, users.name
	
ORDER BY
	average_income_per_appointment DESC

-- Scenario:
-- As we want the community of the app to be as less toxic as possible. 
-- The admin therefore wants to write a query command to find people who use vulgar words, racism words, or offensive words 
-- with the keywords as in the example in order to punish those people according to the company's measures. An investigation 
-- will be conducted by contacting the person who received the message as well.
-- The admin want to see the listed data
-- 1. Sender's user_id as sender_id 
-- 2. Sender's name as sender_name
-- 3. Sender's email as sender_email
-- 4. Every reciever's user_id represented by a set (or array with no repeated element) as recievers_id
-- 5. Total number of text contains vulgar, racism, or offensive words sent by the sender as offensive_text_count
-- The example keyword is defined as the following: {'fuck','nigger','nigga','asian','shit'}
-- Note that this is just an example, We definitely do not promote insults on the community.

SELECT
	user_id AS sender_id,
	name AS sender_name, 
	email AS sender_email,
	recievers AS recievers_id,
	offensive_text_count
	
FROM
	(
	SELECT 
		sender,
		ARRAY_AGG(DISTINCT CASE 	
			WHEN sender = provider_id THEN customer_id
			ELSE provider_id END) AS recievers,
		count(text) as offensive_text_count
	FROM 
		message JOIN chat
		ON chat.chatroom_id = message.chatroom_id
	WHERE
		text LIKE '%fuck%' 
		OR text LIKE '%nigger%'
		OR text LIKE '%nigga%'
		OR text LIKE '%asian%'
		OR text LIKE '%shit%'
	GROUP BY
		sender
	) M
	INNER JOIN users
	ON sender = user_id
	
ORDER BY
	offensive_text_count DESC