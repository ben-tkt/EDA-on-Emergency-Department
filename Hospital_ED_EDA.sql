USE hospital;

-- Getting an overview of what the data looks like
SELECT * 
FROM hospital_er
LIMIT 10;

-- Checking the datatypes of each column
SELECT 
	COLUMN_NAME AS Column_name,
    DATA_TYPE AS Data_type
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'hospital_er';

-- Dimension of our data
WITH `rows` AS (
    SELECT COUNT(*) AS num_rows 
    FROM hospital_er
),
cols AS (
    SELECT COUNT(*) AS num_cols 
    FROM information_schema.columns 
    WHERE table_name = 'hospital_er'
)
SELECT * FROM `rows`, cols;

-- Number of null values
SELECT 
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS null_date,
	SUM(CASE WHEN patient_id IS NULL THEN 1 ELSE 0 END) AS null_id,
    SUM(CASE WHEN patient_gender IS NULL THEN 1 ELSE 0 END) AS null_gender,
    SUM(CASE WHEN patient_age IS NULL THEN 1 ELSE 0 END) AS null_age,
    SUM(CASE WHEN patient_sat_score IS NULL THEN 1 ELSE 0 END) AS null_SATscore,
    SUM(CASE WHEN patient_first_inital IS NULL THEN 1 ELSE 0 END) AS null_initials,
    SUM(CASE WHEN patient_last_name IS NULL THEN 1 ELSE 0 END) AS null_lastname,
    SUM(CASE WHEN patient_race IS NULL THEN 1 ELSE 0 END) AS null_race,
    SUM(CASE WHEN patient_admin_flag IS NULL THEN 1 ELSE 0 END) AS null_flag,
    SUM(CASE WHEN patient_waittime IS NULL THEN 1 ELSE 0 END) AS null_waittime,
    SUM(CASE WHEN department_referral IS NULL THEN 1 ELSE 0 END) AS null_referral
FROM 
    hospital_er;

-- Number of null values
SELECT 
	SUM(CASE WHEN patient_id = '' THEN 1 ELSE 0 END) AS null_id,
    SUM(CASE WHEN patient_gender = '' THEN 1 ELSE 0 END) AS null_gender,
    SUM(CASE WHEN patient_age = '' THEN 1 ELSE 0 END) AS null_age,
    SUM(CASE WHEN patient_sat_score = '' THEN 1 ELSE 0 END) AS null_SATscore,
    SUM(CASE WHEN patient_first_inital = '' THEN 1 ELSE 0 END) AS null_initials,
    SUM(CASE WHEN patient_last_name = '' THEN 1 ELSE 0 END) AS null_lastname,
    SUM(CASE WHEN patient_race = '' THEN 1 ELSE 0 END) AS null_race,
    SUM(CASE WHEN patient_admin_flag = '' THEN 1 ELSE 0 END) AS null_flag,
    SUM(CASE WHEN patient_waittime = '' THEN 1 ELSE 0 END) AS null_waittime,
    SUM(CASE WHEN department_referral = '' THEN 1 ELSE 0 END) AS null_referral
FROM 
    hospital_er;

-- Percentage Null Value
SELECT 
    ROUND(SUM(CASE WHEN patient_sat_score = '' THEN 1 ELSE 0 END)/(SELECT COUNT(*) FROM hospital_er)*100,2) AS percent_null_SAT
FROM hospital_er;

-- Date range of our data
SELECT 
	MIN(date) AS start_date,
    MAX(date) AS end_date
FROM hospital_er;

-- How satisfied are our patients now?
SELECT ROUND(AVG(patient_sat_score),2) AS Avg_score 
FROM hospital_er
WHERE patient_sat_score <> '';

-- What are the counts of each score?
SELECT 
	patient_sat_score AS Score,
    COUNT(patient_sat_score) AS count
FROM hospital_er
WHERE patient_sat_score <> ''
GROUP BY patient_sat_score
ORDER BY LENGTH(Score), Score;

-- Demographic of Patients

 -- Average age of our patients
 SELECT AVG(patient_age) AS Age FROM hospital_er;

-- Separating the ages into age groups
CREATE OR REPLACE VIEW age_separation AS
	SELECT	
        CASE 
			WHEN patient_age BETWEEN 0 AND 12 THEN 'Child'
			WHEN patient_age BETWEEN 13 AND 19 THEN 'Teenager'
			WHEN patient_age BETWEEN 20 AND 39 THEN 'Adult'
			WHEN patient_age BETWEEN 40 AND 59 THEN 'Middle Age'
			WHEN patient_age >= 60 THEN 'Senior'
			ELSE 'unknown'
		END AS age_group,
		date,
        patient_sat_score AS score,
        patient_waittime
	FROM hospital_er;
    
-- Distribution of patients' age group
SELECT
	age_group,
	COUNT(*) AS count
FROM age_separation
GROUP BY age_group
ORDER BY count DESC;

-- Gender and Age Distribution of our patients
 SELECT 
	patient_gender AS gender,
    COUNT(patient_gender) AS gender_count,
    AVG(patient_age) AS Avg_age
 FROM hospital_er
 GROUP BY patient_gender;

-- Checking the distribution of race amongst our patients
SELECT 
	patient_race,
    count(*) AS Count
FROM hospital_er
GROUP BY patient_race;

-- Percentage of flagged patients
SELECT 
	patient_race,
    COUNT(*) AS flagged_count,
    ROUND(COUNT(*)/(SELECT COUNT(*) FROM hospital_er)*100,2) AS flagged_percentage
FROM hospital_er
WHERE patient_admin_flag = 'TRUE'
GROUP BY patient_race;

-- Agegroup of flagged patients, and percentage of the agegroup flagged.
WITH try AS(
	SELECT	
        CASE 
			WHEN patient_age BETWEEN 0 AND 12 THEN 'Child'
			WHEN patient_age BETWEEN 13 AND 19 THEN 'Teenager'
			WHEN patient_age BETWEEN 20 AND 39 THEN 'Adult'
			WHEN patient_age BETWEEN 40 AND 59 THEN 'Middle Age'
			WHEN patient_age >= 60 THEN 'Senior'
			ELSE 'unknown'
		END AS age_group,
        patient_admin_flag
	FROM hospital_er
)
SELECT 
	age_group,
    SUM(CASE WHEN patient_admin_flag = 'TRUE' THEN 1 ELSE 0 END) AS flagged_count,
    SUM(CASE WHEN patient_admin_flag = 'FALSE' THEN 1 ELSE 0 END) AS unflagged_count,
    ROUND(SUM(CASE WHEN patient_admin_flag = 'TRUE' THEN 1 ELSE 0 END) / (SUM(CASE WHEN patient_admin_flag = 'TRUE' THEN 1 ELSE 0 END) + SUM(CASE WHEN patient_admin_flag = 'FALSE' THEN 1 ELSE 0 END)) * 100,2) AS percentage_count
FROM try
GROUP BY age_group;

-- Count of Referral Types
SELECT 
	department_referral AS 'Referral Types',
    COUNT(*) AS Count
FROM hospital_er
GROUP BY department_referral;

-- Particular group of patients that are less satisfied?
-- Seeing if different agegroups have different average scores
SELECT
	age_group,
    ROUND(AVG(score),2) AS Avg_Score
FROM age_separation
WHERE score <> ''
GROUP BY age_group;

-- Ratings from different gender
 SELECT
	patient_gender AS gender,
	ROUND(AVG(patient_sat_score),2) AS Avg_score,
    COUNT(*) AS Count
FROM hospital_er
WHERE patient_sat_score <> ''
GROUP BY gender;

-- Rating from each race
SELECT
	patient_race,
    ROUND(AVG(patient_sat_score),2) AS avg_score,
    COUNT(*) AS Count
FROM hospital_er
WHERE patient_sat_score <> ''
GROUP BY patient_race;

-- Do flagged patients have higher or lower ratings?
SELECT 
	patient_admin_flag AS 'Flagged Patients',
    ROUND(AVG(patient_sat_score),2) AS 'Average Score'
FROM hospital_er
WHERE patient_sat_score <> ''
GROUP BY patient_admin_flag;

-- Referral type vs avg rating
SELECT
    department_referral,
    ROUND(AVG(patient_sat_score),2) AS Avg_score,
    ROUND(AVG(PATIENT_WAITTIME),2) AS Avg_waittime
FROM hospital_er
WHERE patient_sat_score <> ''
GROUP BY department_referral
ORDER BY avg_score DESC;

-- Min and Max waiting time?
SELECT
	MIN(patient_waittime) AS Min,
    MAX(patient_waittime) AS Max
FROM hospital_er;

-- Pearson correlation between waittime and score
SELECT 
    ROUND(((SUM(patient_waittime * patient_sat_score) - (SUM(patient_waittime) * SUM(patient_sat_score)) / COUNT(*))) / (SQRT(SUM(patient_waittime * patient_waittime) - (SUM(patient_waittime) * SUM(patient_waittime)) / COUNT(*)) * SQRT(SUM(patient_sat_score * patient_sat_score) - (SUM(patient_sat_score) * SUM(patient_sat_score)) / COUNT(*))),4) AS Correlation
FROM
    hospital_er;

-- Rating of patients from different waiting time
CREATE OR REPLACE VIEW time_separation AS
SELECT
	CASE 
		WHEN patient_waittime <= 20 THEN 'Fastest'
        WHEN patient_waittime BETWEEN 20 AND 30 THEN 'Fast'
        WHEN patient_waittime BETWEEN 30 AND 40 THEN 'Normal'
        WHEN patient_waittime BETWEEN 40 AND 50 THEN 'Slow'
        WHEN patient_waittime >= 50 THEN 'Slowest'
	END AS time_group,
    patient_waittime,
    patient_sat_score
FROM hospital_er;

SELECT 
	time_group AS "Waiting Time",
	ROUND(AVG(patient_sat_score),2) AS Avg_score,
    count(*) AS Count
FROM time_separation
WHERE patient_sat_score <> '' AND time_group = 'Fastest'
UNION
SELECT 
	time_group,
	ROUND(AVG(patient_sat_score),2) AS Avg_score,
    count(*)
FROM time_separation
WHERE patient_sat_score <> '' AND time_group = 'Fast'
UNION
SELECT 
	time_group,
	ROUND(AVG(patient_sat_score),2) AS Avg_score,
    count(*)
FROM time_separation
WHERE patient_sat_score <> '' AND time_group = 'Normal'
UNION
SELECT 
	time_group,
	ROUND(AVG(patient_sat_score),2) AS Avg_score,
    count(*)
FROM time_separation
WHERE patient_sat_score <> '' AND time_group = 'Slow'
UNION
SELECT 
	time_group,
	ROUND(AVG(patient_sat_score),2) AS Avg_score,
    count(*)
FROM time_separation
WHERE patient_sat_score <> '' AND time_group = 'Slowest';

-- Preferred timing rating
SELECT
	HOUR(date) AS hours,
	ROUND(AVG(patient_sat_score),2) AS Avg_score
FROM hospital_er
WHERE patient_sat_score <> ''
GROUP BY hours
ORDER BY LENGTH(hours), hours;

-- Peak periods?
-- Number of visits and average waiting time of patients each year
SELECT 
	YEAR(date) AS Year,
    COUNT(*) AS Num_of_visits,
    AVG(patient_waittime) AS Average_Waiting_Time
FROM hospital_er
GROUP BY Year;

-- Number of visits and average waiting time of patients throughout the year?
SELECT 
	monthname(date) AS month,
    COUNT(*) AS Num_of_visits,
    AVG(patient_waittime) AS Average_Waiting_Time
FROM hospital_er
WHERE date < '2020-04-02 00:00:00'
GROUP BY month
ORDER BY Num_of_visits DESC;

--  Number of visits and average waiting time of patients throughout the week?
SELECT 
	DAYNAME(date) AS Day,
    COUNT(*) AS Num_of_visits,
    AVG(patient_waittime) AS Average_Waiting_Time
FROM hospital_er
GROUP BY Day
ORDER BY Num_of_visits DESC;

-- Number of visits and average Waiting time of patients throughout the day?
SELECT 
	HOUR(date) AS Hour,
    COUNT(*) AS Num_of_visits,
    AVG(patient_waittime) AS Average_Waiting_Time
FROM hospital_er
GROUP BY Hour
ORDER BY Hour;

-- Any bottlenecks?
-- See if it takes longer to see different agegroups
SELECT
	age_group,
    ROUND(AVG(patient_waittime),2) AS Avg_waitingtime
FROM age_separation
GROUP BY age_group;

-- See if it takes longer to see different genders
SELECT
	patient_gender AS gender,
    ROUND(AVG(patient_waittime),2) AS Avg_waitingtime
FROM hospital_er
GROUP BY gender;

-- Does it take longer to see flagged patients?
SELECT
	patient_admin_flag AS flagged,
    ROUND(AVG(patient_waittime),2) AS Avg_waitingtime
FROM hospital_er
GROUP BY flagged;

-- Referral Type vs Waiting Time
SELECT
    department_referral,
    ROUND(AVG(PATIENT_WAITTIME),2) AS Avg_waittime
FROM hospital_er
WHERE patient_sat_score <> ''
GROUP BY department_referral
ORDER BY Avg_waittime DESC;

-- Create waittime of patients throughout the hours separated by race
CREATE OR REPLACE VIEW racewait AS 
SELECT
	HOUR(date) AS hours,
    ROUND(AVG(CASE WHEN patient_race = 'White' THEN patient_waittime ELSE NULL END),2) AS WhiteWait,
    ROUND(AVG(CASE WHEN patient_race = 'Native American/Alaska Native' THEN patient_waittime ELSE NULL END),2) AS NA_AlaskaWait,
    ROUND(AVG(CASE WHEN patient_race = 'African American' THEN patient_waittime ELSE NULL END),2) AS AAWait,
    ROUND(AVG(CASE WHEN patient_race = 'Asian' THEN patient_waittime ELSE NULL END),2) AS AWait,
    ROUND(AVG(CASE WHEN patient_race = 'Two or More Races' THEN patient_waittime ELSE NULL END),2) AS BiracialWait,
    ROUND(AVG(CASE WHEN patient_race = 'Pacific Islander' THEN patient_waittime ELSE NULL END),2) AS PIWait,
    ROUND(AVG(CASE WHEN patient_race = 'Declined to Identify' THEN patient_waittime ELSE NULL END),2) AS RestWait
FROM hospital_er
GROUP BY hours
ORDER BY hours;

-- Average waiting time per race
SELECT
	ROUND(AVG(WhiteWait),2) AS 'Average White Waittime',
    ROUND(AVG(NA_AlaskaWait),2) AS 'Average NAA Waittime',
    ROUND(AVG(AAWait),2) AS 'Average AA Waittime',
    ROUND(AVG(AWait),2) AS 'Average Asian Waittime',
    ROUND(AVG(BiracialWait),2) AS 'Average Biracial Waittime',
    ROUND(AVG(PIWait),2) AS 'Average PI Waittime',
    ROUND(AVG(RestWait),2) AS 'Average Others Waittime'
FROM racewait;

-- Can we accomodate the volume of patients?

-- What is the average waiting time?
SELECT AVG(patient_waittime) FROM hospital_er;

-- Finding the hours with the most patients
SELECT
	DATE(date),
    HOUR(date),
    COUNT(*) AS 'Total Cases',
    ROUND(AVG(patient_waittime),2) AS 'Average Waiting Time'    
FROM hospital_er
GROUP BY DATE(date), HOUR(date)
ORDER BY COUNT(*) DESC
LIMIT 10;

-- Creating a table that counts the number of patients per hour
CREATE VIEW day_time AS
SELECT 
	HOUR(date) AS Hour,
    COUNT(*) AS Num_of_visits,
    AVG(patient_waittime) AS Average_Waiting_Time
FROM hospital_er
GROUP BY Hour
ORDER BY Hour;

-- Finding the Hours that has the max and min waiting time and visits
SELECT 
	'Max Waiting Time' AS Type,
    Hour,
    Num_of_visits,
    Average_Waiting_Time
FROM day_time 
WHERE Average_Waiting_Time = (SELECT MAX(Average_Waiting_Time) FROM day_time)
UNION
SELECT 'Min Waiting Time',
    Hour,
    Num_of_visits,
    Average_Waiting_Time
FROM day_time 
WHERE Average_Waiting_Time = (SELECT MIN(Average_Waiting_Time) FROM day_time)
UNION
SELECT 'Max No. of Visits',
    Hour,
    Num_of_visits,
    Average_Waiting_Time
FROM day_time 
WHERE Num_of_visits = (SELECT MAX(Num_of_visits) FROM day_time)
UNION
SELECT 'Min No. of Visits',
    Hour,
    Num_of_visits,
    Average_Waiting_Time
FROM day_time 
WHERE Num_of_visits = (SELECT MIN(Num_of_visits) FROM day_time)
GROUP BY Hour;

-- Seeing what was the longest waiting time
SELECT * 
FROM hospital_er
WHERE patient_waittime IN (
    SELECT patient_waittime 
    FROM (
        SELECT patient_waittime 
        FROM hospital_er 
        ORDER BY patient_waittime DESC 
        LIMIT 1
    ) AS subquery
);

-- Finding out if rating and waiting time is different outside of office hours
SELECT 
	CASE WHEN HOUR(date) >= 9 AND HOUR(date) <= 18 THEN 'Office Hour' ELSE 'Non-Office Hour' END AS Shift,
    ROUND(AVG(patient_sat_score),2) AS Average_Score,
    ROUND(AVG(patient_waittime),2) AS Average_Time
FROM hospital_er
WHERE patient_sat_score <> ''
GROUP BY Shift;
    