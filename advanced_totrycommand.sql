-- Scenario 1: Average Income
-- The admin want to see the listed data
-- Provider's username as username
-- Provider's name as name
-- Provider's total appointment as total_appointment
-- Provider's average income as average_income_per_appointment
-- which is sorted by the average income from high to low.
-- Therefore, there are some constraints as we must show the provider if and only if he/she has committed at least 1 appointment. Moreover, if any appointment ‘A’ was finished in under 30 minutes or over 12 hours, it is possible that ‘A’ could be an illegal action, and the transaction of ‘A’ won't be shown in the table until the inspection process is finished.

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

-- Scenario 2: Detect Inappropriate Message
-- Since we wish to minimize the toxic behavior of the web-app's community. As a result, the administrator wishes to create a query command to locate persons who use vulgar, racist, or derogatory language with our example keywords in order to punish them in accordance with the company's policies. An investigation will be launched, and the victim who received the communication will be contacted as well.
-- The admin want to see the listed data
-- Sender's user_id as sender_id 
-- Sender's name as sender_name
-- Sender's email as sender_email
-- Every receiver's user_id represented by an array with unique elements as receivers_id
-- The number of text contains profanity from the sender as offensive_text_count
-- The example keywords are defined as the following: {'f**k','n****r','n**a','a***n','s**t'}
-- *Note: We simply use profanity as an example.

SELECT
	user_id AS sender_id,
	name AS sender_name, 
	email AS sender_email,
	receivers AS receivers_id,
	offensive_text_count
	
FROM
	(SELECT 
		sender,
		ARRAY_AGG(DISTINCT CASE
			WHEN sender = provider_id THEN customer_id
			ELSE provider_id END) AS receivers,
		count(text) as offensive_text_count
	FROM message JOIN chat
	ON chat.chatroom_id = message.chatroom_id
	WHERE
		text LIKE '%fuck%' 
		OR text LIKE '%nigger%'
		OR text LIKE '%nigga%'
		OR text LIKE '%asian%'
		OR text LIKE '%shit%'
	GROUP BY sender
	) M
	INNER JOIN users
	ON sender = user_id
	
ORDER BY
	offensive_text_count DESC

-- Scenario 3:

SELECT 
	ROW_NUMBER() OVER() AS position,
	A.name, 
	A.email, 
	A.address

FROM 
	users A

WHERE A.user_id IN (
	SELECT customer_id 
	FROM (
        SELECT customer_id, SUM(price) AS total_payment 
		FROM (
            SELECT * 
			FROM (
				SELECT appointment_id, customer_id 
				FROM make_appointment)
            	NATURAL JOIN
            	appointment
        )
        GROUP BY customer_id
        ORDER BY SUM(price) DESC
        LIMIT 3
    )
)