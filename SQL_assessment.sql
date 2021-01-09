-- SQL Assessment

-- explore the data

SELECT *
FROM poem;

SELECT *
FROM author;

SELECT *
FROM gender;

-- Q.1
--The poetry in this database is the work of children in grades 1 through 5.
-- a. How many poets are represented in the data? 1=623, 2=1437, 3=2344, 4=3288, 5=3464

SELECT grade_id, COUNT(*) AS grade_count
FROM author
GROUP by grade_id
ORDER by grade_id;

-- b. How many poets are either male or female?

SELECT grade_id, gender.name, COUNT(*) AS grade_count
FROM author INNER JOIN gender ON author.gender_id = gender.id
WHERE gender.name IN ('Male', 'Female')
GROUP BY grade_id, gender.name
ORDER BY grade_id, gender.name;

-- There's a gradual increase in poets as we go up in grades.

-- Q.2
-- Return the total number of poems,and average character count in a single query. -Poem CT:4531, Avg_Char_CT: 228

SELECT COUNT(poem.id) as poem_count,
		ROUND(AVG(char_count), 0) as avg_char_count
FROM poem 
WHERE text ILIKE '%death%' OR text ILIKE '%love%'
ORDER BY poem_count;

-- Q.3

Select *
from emotion;

WITH emo as (SELECT name as emotion, ROUND(AVG(intensity_percent),2) as avg_intensity, ROUND(AVG(char_count),2) as avg_char_count, COUNT(poem.id)
				FROM poem_emotion
				JOIN poem on poem_emotion.poem_id = poem.id
				JOIN emotion on poem_emotion.emotion_id = emotion.id
				GROUP BY name),
 emotions as (SELECT poem_id, intensity_percent, char_count, title, text, name
				FROM poem_emotion
				JOIN poem on poem_emotion.poem_id = poem.id
				JOIN emotion on poem_emotion.emotion_id = emotion.id)
SELECT poem_id, intensity_percent, char_count, title, text, (e.char_count - emo.avg_char_count) AS diff_fromavg_char_count
FROM emotions as e
FULL JOIN emo on e.name = emo.emotion
WHERE name LIKE 'Joy'
ORDER BY intensity_percent DESC
LIMIT 7;


-- Q.4 

WITH grade_one_anger AS (SELECT *
						 FROM poem INNER JOIN poem_emotion ON poem.id = poem_emotion.poem_id
						 		   INNER JOIN emotion ON emotion.id = poem_emotion.emotion_id
						 		   INNER JOIN author ON author.id = poem.author_id
						  		   INNER JOIN gender on gender.id = author.gender_id
						 WHERE grade_id = 1
						 	   AND emotion.name = 'Anger'
						 ORDER BY intensity_percent DESC
						 LIMIT 5),
	 grade_five_anger AS (SELECT *
						  FROM poem INNER JOIN poem_emotion ON poem.id = poem_emotion.poem_id
						  		    INNER JOIN emotion ON emotion.id = poem_emotion.emotion_id
						  		    INNER JOIN author ON author.id = poem.author_id
						  			INNER JOIN gender on gender.id = author.gender_id
						  WHERE grade_id = 5
						  	    AND emotion.name = 'Anger'
						  ORDER BY intensity_percent DESC
						  LIMIT 5)
SELECT *
FROM grade_one_anger
UNION ALL
SELECT *
FROM grade_five_anger;

-- Q.5 --export and create a visualization of the table

SELECT  grade.name, COUNT(author.name) as total_count,
		COUNT (CASE WHEN emotion.name ILIKE 'Joy' then 'Joy' END) as Joy,
		COUNT (CASE WHEN emotion.name ILIKE 'Anger' then 'Anger' END) as Anger,
		COUNT (CASE WHEN emotion.name ILIKE 'Fear' then 'Fear' END) as Fear,
		COUNT (CASE WHEN emotion.name ILIKE 'Sadness' then 'Sadness' END) as Sadness
FROM poem_emotion
JOIN poem on poem_emotion.id = poem.id
JOIN emotion on poem_emotion.emotion_id = emotion.id
JOIN author on author.id = poem.author_id
JOIN grade on author.grade_id = grade.id
WHERE author.name ILIKE 'Emily'
GROUP BY grade.name;
