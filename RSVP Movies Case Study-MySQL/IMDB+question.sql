USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
/*select table_name, table_rows 
From information_schema.tables
where table_schema='imdb';*/

-- As TABLE_ROWS value in INFORMATION_SCHEMA.TABLES is DIfferent from the actual row counts, 
-- used COUNT(*) to get the actual rows from EACH table, through UNION ALL and produce final 
-- result through CTEs.

WITH CTE_ALLTABLEROWS as
(
select 'director_mapping' as 'TABLE_NAME',  count(*) 'TABLE_ROWS' from director_mapping union all
select 'genre' as 'TABLE_NAME',  count(*) 'TABLE_ROWS' from genre union all
select 'movie' as 'TABLE_NAME',  count(*) 'TABLE_ROWS' from movie union all
select 'names' as 'TABLE_NAME',  count(*) 'TABLE_ROWS' from names union all
select 'ratings' as 'TABLE_NAME',  count(*) 'TABLE_ROWS' from ratings union all
select 'role_mapping' as 'TABLE_NAME',  count(*) 'TABLE_ROWS' from role_mapping
)
SELECT 
		`TABLE_NAME` -- TABLE_NAME is reserved word so enclosed with ``
	,	TABLE_ROWS
FROM 
		CTE_ALLTABLEROWS
ORDER BY `TABLE_NAME`
;	

-- Q2. Which columns in the movie table have null values?
-- Type your code below:

-- Getting the List of NULLABLE COLUMNS from the table : movie
SELECT 
	TABLE_NAME,
    column_Name AS 'movie_columns'
FROM
    information_schema.columns
WHERE
    table_schema = 'imdb'
        AND table_name = 'movie'
        AND is_nullable = 'YES'
ORDER BY ordinal_position
;

WITH movie_null_cols as 
(
select count(*)- count(title) as 'Null_Count','title' as column_name from movie union all
select count(*)- count(Year) as 'Null_Count','Year' as column_name from movie union all
select count(*)- count(date_published) as 'Null_Count','date_published' as column_name from movie union all
select count(*)- count(duration) as 'Null_Count','duration' as column_name from movie union all
select count(*)- count(country) as 'Null_Count','country' as column_name from movie union all
select count(*)- count(worldwide_gross_income) as 'Null_Count','worldwide_gross_income' as column_name from movie union all
select count(*)- count(languages) as 'Null_Count','languages' as column_name from movie union all
select count(*)- count(production_company) as 'Null_Count','production_company' as column_name from movie
)
select 
		 Null_Count
        ,`column_name`
        ,'movie' as `TABLE_NAME`
From 
		movie_null_cols
WHERE 
		null_count>0
ORDER BY 
		null_count DESC
        ;





-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


SELECT 
    YEAR(m.date_published) AS 'Year',
    COUNT(m.id) AS 'number_of_movies'
FROM
    movie m
GROUP BY YEAR(m.date_published)
ORDER BY YEAR(m.date_published);


SELECT 
    MONTH(m.date_published) AS 'month_num',
    COUNT(m.id) AS 'number_of_movies'
FROM
    movie m
GROUP BY MONTH(m.date_published)
ORDER BY MONTH(m.date_published);







/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT 
    YEAR(date_published) AS 'Year',
    COUNT(m.id) AS 'Total_Movies_Produced',
    m.country
FROM
    movie m
WHERE
    country IN ('USA' , 'India')
        AND YEAR(date_published) = 2019
GROUP BY YEAR(date_published) , m.country;
    
SELECT 
    COUNT(m.id) AS '#Movies_Produced(USA,IN)_2019'
FROM
    movie m
WHERE
    country IN ('USA' , 'India')
        AND YEAR(date_published) = 2019;


/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT DISTINCT
    g.genre
FROM
    genre g
ORDER BY g.genre;








/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT 
    COUNT(m.id) as number_of_movies, 
    g.genre
    
FROM
    movie m
        INNER JOIN
    genre g ON m.id = g.movie_id
GROUP BY g.genre
ORDER BY COUNT(m.id) DESC
LIMIT 1;
	
/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:
WITH Movies_With_Only_One_Genre as 
(
SELECT 
		 g.movie_id
        ,count(g.genre) as 'Number_of_Genres'
FROM
		genre g
GROUP BY g.movie_id
HAVING count(g.genre) =1
)
SELECT 
    COUNT(movie_id) as 'One_Genre_Movies'
FROM
    Movies_With_Only_One_Genre;

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT 
    g.genre, AVG(m.duration) AS 'avg_duration'
FROM
    movie m
        INNER JOIN
    genre g ON m.id = g.movie_id
GROUP BY g.genre
ORDER BY AVG(m.duration) DESC;

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
WITH genre_rank as 
(
SELECT 
	 g.genre
	,count(movie_id) AS 'movie_count'
    ,RANK() Over(order by count(movie_id) Desc) AS 'genre_rank'
FROM 
	genre g
GROUP BY g.genre
)
SELECT 
	 genre
    ,movie_count
    ,genre_rank
FROM
	genre_rank
WHERE
	genre='Thriller'
;

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/

-- Segment 2:

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:


SELECT 
    MIN(r.avg_rating) AS 'min_avg_rating',
    MAX(r.avg_rating) AS 'max_avg_rating',
    MIN(r.total_votes) AS 'min_total_votes',
    MAX(r.total_votes) AS 'max_total_votes',
    MIN(r.median_rating) AS 'min_median_rating',
    MIN(r.median_rating) AS 'max_total_votes'
FROM
    ratings r;
   

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

SELECT
	 m.title
	,r.avg_Rating
    ,RANK() OVER(ORDER BY r.avg_rating DESC) 'movie_rank'
FROM
	movie m
    INNER JOIN
    ratings r
    ON m.id=r.movie_id
LIMIT 10 ;


/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT 
    r.median_rating, COUNT(r.movie_id) AS 'movie_count'
FROM
    ratings r
GROUP BY r.median_rating
ORDER BY COUNT(r.movie_id) DESC;

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:
WITH CTE_ProductionHouse_HitMovies as 
(
SELECT
	m.production_company
    ,count(m.id) as 'movie_count'
    ,RANK() OVER(ORder by count(m.id) Desc) 'prod_company_rank'
FROM
	movie m
    INNER JOIN 
    ratings r
    on m.id=r.movie_id
WHERE
	r.avg_rating>8
    AND m.production_company IS NOT NULL
GROUP BY 
	m.production_company
)
select * from CTE_ProductionHouse_HitMovies where prod_company_rank=1;

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
    g.genre, COUNT(g.movie_id) AS 'movie_count'
FROM
    genre g
        INNER JOIN
    movie m ON m.id = g.movie_id
        INNER JOIN
    ratings r ON m.id = r.movie_id
WHERE
    m.country = 'USA'
        AND YEAR(m.date_published) = 2017
        AND MONTH(m.date_published) = 3
        AND r.total_votes > 1000
GROUP BY g.genre
ORDER BY movie_count DESC
;

-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

SELECT 
    m.title, r.avg_rating, g.genre
FROM
    movie m
        INNER JOIN
    ratings r ON m.id = r.movie_id
        INNER JOIN
    genre g ON m.id = g.movie_id
WHERE
    m.title LIKE 'The%' AND r.avg_rating > 8
ORDER BY m.title , g.genre , r.avg_rating;


-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

SELECT 
    COUNT(m.id) AS 'No_Of_Movies', r.median_rating
FROM
    movie m
        INNER JOIN
    ratings r ON m.id = r.movie_id
WHERE
    m.date_published BETWEEN '2018-04-01' AND '2019-04-01'
        AND r.median_rating = 8
GROUP BY r.median_rating
ORDER BY No_Of_Movies DESC;

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

-- Per the data analysis on the languages column: Wild card Search (LIKE '%%') is used in the Languages, as one movie may belong to more than one languages 
With GermanVsItalianMovies as 
(
SELECT 
	 count(m.id) as 'No_Of_Movies'
    ,sum(CASE WHEN m.languages LIKE '%German%' THEN r.total_votes END) 'German_Votes'
    ,sum(CASE WHEN m.languages LIKE '%Italian%' THEN r.total_votes END) 'Italian_Votes'
FROM
	movie m
    INNER JOIN
    ratings r
    ON m.id=r.movie_id
 )   
SELECT 
    CASE
        WHEN German_Votes > Italian_Votes THEN 'Yes'
        ELSE 'No'
    END AS 'German.Votes>Italian.Votes'
FROM
    GermanVsItalianMovies;

-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT 
    (COUNT(*) - COUNT(n.name)) AS 'name_nulls',
    (COUNT(*) - COUNT(n.height)) AS 'height_nulls',
    (COUNT(*) - COUNT(n.date_of_birth)) AS 'date_of_birth_nulls',
    (COUNT(*) - COUNT(n.known_for_movies)) AS 'known_for_movies_nulls'
FROM
    names n;

/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

WITH TOP3GENREMOVIEIDs as
(
WITH TOP3GENRE as 
(
SELECT 
		g.genre
    ,count(g.movie_id) as 'movie_count'
    ,Rank() Over(Order by count(g.movie_id) desc) as 'genre_rank'
FROM
	genre g
GROUP BY 
	g.genre
LIMIT 3
)
SELECT 
    g.movie_id
FROM
    genre g
WHERE
    g.genre IN (SELECT 
            genre
        FROM
            TOP3GENRE)
)
SELECT 
    n.name AS 'director_name',
    COUNT(dm.movie_id) AS 'movie_count'
    
FROM
    director_mapping dm
        INNER JOIN
    names n ON dm.name_id = n.id
WHERE
    dm.movie_id IN (SELECT 
            r.movie_id
        FROM
            ratings r
        WHERE
            r.avg_rating > 8
                AND r.movie_id IN (SELECT 
                    movie_id
                FROM
                    TOP3GENREMOVIEIDs))
GROUP BY n.name
ORDER BY movie_count DESC , director_name
LIMIT 3
;


/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:




SELECT 
    n.name AS 'actor_name', COUNT(rm.movie_id) AS 'movie_Count'
FROM
    names n
        INNER JOIN
    role_mapping rm ON n.id = rm.name_id
        INNER JOIN
    ratings r ON rm.movie_id = r.movie_id
WHERE
    rm.category = 'actor'
        AND r.median_rating >= 8
GROUP BY actor_name
ORDER BY movie_count DESC
LIMIT 2;
	
	



/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT
	m.production_company,
    sum(r.total_votes) as 'vote_count',
    RANK() OVER(ORDER BY sum(r.total_votes) DESC) as 'prod_comp_rank'
FROM
	movie m
    INNER JOIN 
    ratings r
    on m.id=r.movie_id
GROUP BY 
	m.production_company
LIMIT 3;

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH CTE_TOPACTORS AS
(
SELECT
	  n.name as 'actor_name'
	, SUM(r.total_votes) as 'total_votes'
    , COUNT(r.movie_id) as 'movie_count'
    , MAX(r.avg_rating) as 'actor_avg_rating'
    , sum(r.total_votes * r.avg_rating)/SUM(r.total_votes) as 'weighted_avg'
    
FROM
	movie m
    INNER JOIN 
    role_mapping rm
    on m.id=rm.movie_id
    INNER JOIN 
    names n
    on
    rm.name_id=n.id
    INNER JOIN 
    ratings r
    on m.id=r.movie_id
WHERE
		m.country='India'
	AND rm.category='actor'
GROUP BY 
	n.name
HAVING COUNT(m.id)>=5
ORDER BY 'weighted_avg' desc
)
SELECT 
	actor_name,
	total_votes,
    movie_count,
    actor_avg_rating , 
    RANK() OVER(ORDER BY weighted_Avg DESC) as actor_rank
from CTE_TOPACTORS;


-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:


WITH CTE_TOPACTRESSES AS
(
SELECT
	  n.name as 'actor_name'
	, SUM(r.total_votes) as 'total_votes'
    , COUNT(r.movie_id) as 'movie_count'
    -- , MAX(r.avg_rating) as 'actor_avg_rating'
    , Round(sum(r.total_votes * r.avg_rating)/SUM(r.total_votes),2) as 'actor_avg_rating'
    
FROM
	movie m
    INNER JOIN 
    role_mapping rm
    on m.id=rm.movie_id
    INNER JOIN 
    names n
    on
    rm.name_id=n.id
    INNER JOIN 
    ratings r
    on m.id=r.movie_id
WHERE
		m.country='India'
	AND rm.category='actress'
    AND m.languages LIKE '%Hindi%'
GROUP BY 
	n.name
HAVING COUNT(m.id)>=3
ORDER BY 'actor_avg_rating' desc
)
SELECT 
	actor_name,
	total_votes,
    movie_count,
    actor_avg_rating , 
    RANK() OVER(ORDER  BY actor_avg_rating DESC) as actor_rank
from CTE_TOPACTRESSES;





/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:
WITH CTE_THRILLER_MOVIES AS
(
SELECT
	 m.title
    ,g.genre
    ,CASE 
		WHEN r.avg_rating >8 then 'Superhit movies'
        WHEN r.avg_rating between 7 and 8 then 'Hit movies'
        WHEN r.avg_rating between 5 and 7 then 'One-time-watch movies'
		WHEN r.avg_rating <5 then 'Flop movies'
	END as 'Category'
FROM
	movie m
    INNER JOIN 
    genre g
    on m.id=g.movie_id
    INNER JOIN 
    ratings r
    ON
    m.id=r.movie_id
WHERE
	g.genre='Thriller'
)
SELECT 
		
		COUNT(title) as 'Num_Of_Thriller_Movies',
		Category 
FROM CTE_THRILLER_MOVIES
GROUP BY  
	
	Category
ORDER BY 
	Num_Of_Thriller_Movies DESC
;

/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

WITH CTE_GENRE_AVG_DURATION AS
(
SELECT 
		g.genre as 'genre'
    ,	AVG(m.duration) as 'avg_duration'

FROM
	genre g
    INNER JOIN 
    movie m
    ON g.movie_id=m.id
GROUP BY 
	genre
)
SELECT
	genre,
	Round(avg_duration,2) as avg_duration,
    SUM(Round(avg_duration,2)) OVER W1 as running_total_duration,
    AVG(Round(avg_duration,2)) OVER W2 as moving_avg_duration
FROM 
		CTE_GENRE_AVG_DURATION
GROUP BY 
	genre,
    avg_duration
WINDOW W1 AS (ORDER BY avg_duration ROWS UNBOUNDED PRECEDING),
W2 AS (ORDER BY avg_duration ROWS UNBOUNDED PRECEDING)
ORDER BY 
	genre
;






-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies
WITH CTE_GROSS_INCOME_RANK AS
(
WITH CTE_GROSS_INCOME AS
(
WITH CTE_TOP3GENRE AS 
(SELECT 
		g.genre
    ,	count(g.movie_id) as 'movie_count'
    ,	Rank() Over(Order by count(g.movie_id) desc) as 'genre_rank'
FROM
	genre g
GROUP BY 
	g.genre
LIMIT 3
)
SELECT 
		g.genre as Genre
	,	m.Year
    ,   m.title as 'movie_name'
	,	sum(CAST(REPLACE(worldwide_gross_income,'$ ','') as double)) as worldwide_gross_income
--  ,	sum(CAST(REPLACE(worldwide_gross_income,'$ ','') as double))/1000000 as worldwide_gross_income_mn
    ,	concat('$',cast(sum(CAST(REPLACE(worldwide_gross_income,'$ ','') as double)) as CHAR)) as worldwide_gross_income_$
FROM
	genre g
    INNER JOIN movie m
    ON
    g.movie_id=m.id
WHERE 
	m.worldwide_gross_income IS NOT NULL
    AND g.genre in 
    (select genre from CTE_TOP3GENRE)
    
    
GROUP BY
	g.genre,
    m.Year,
    m.title
    )
    SELECT 
			DISTINCT *,
			RANK() OVER W  'movie_rank'
    FROM 
			CTE_GROSS_INCOME 
	WHERE 
			worldwide_gross_income>0
	WINDOW W as (PARTITION BY Genre,Year ORDER BY worldwide_gross_income DESC)
    )
    SELECT 
		Genre,
        Year,
        movie_name,
        worldwide_gross_income_$ as worldwide_gross_income,
        movie_rank
        
    FROM 
    CTE_GROSS_INCOME_RANK where movie_rank between 1 and 5
    ;
	
-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
WITH CTE_Prod_House as
(
SELECT 
		m.production_company
    ,	count(m.id) movie_count
     
FROM
	movie m
    INNER JOIN
    ratings r
    on m.id=r.movie_id
WHERE
		r.median_rating>=8
	AND m.languages IS NOT NULL
	AND POSITION(',' IN m.languages)>0
	AND m.production_company IS NOT NULL
GROUP BY 
	m.production_company
)
SELECT 
	production_company,
    movie_Count,
    RANK() OVER(ORDER BY movie_count desc) as 'prod_comp_rank'
FROM 
	CTE_Prod_House
Limit 2
        ;






-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
WITH CTE_TOP3_ACTRESSES_DRAMA AS
(
select 
		n.name as 'actress_name'
	,	sum(r.total_votes) as total_votes
    , 	count(g.movie_id) as movie_count

    , sum(r.total_votes * r.avg_rating)/SUM(r.total_votes) as 'actress_avg_rating'
    
From 
	movie m
    inner join 
    role_mapping rm 
    on m.id=rm.movie_id
    inner join 
    names n 
    on rm.name_id=n.id
    inner join 
    ratings r 
    on
    m.id=r.movie_id
    inner join 
    genre g
    on m.id=g.movie_id
    
WHERE
	g.genre='Drama'    

AND rm.category='actress'
GROUP BY n.name
)
select 
actress_name,
total_votes,
movie_count,
actress_Avg_rating, 
RANK() OVER(ORDER BY movie_Count DESC,total_votes DESC) 'actress_rank'
 From CTE_TOP3_ACTRESSES_DRAMA
WHERE actress_avg_rating>8 
Limit 3
 ;





/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:
WITH CTE_Director_Final as (
WITH CTE_Director_Rank as (
WITH CTE_Director_DateDiff as 
(
select 
	dm.name_id as director_id,
    n.name as director_name,
    m.date_published,
    LEAD(m.date_published,1) over w as next_date,
    ABS(DATEDIFF(m.date_published,LEAD(m.date_published,1) over w)) as date_diff,
	dm.movie_id,
    r.total_votes,
    r.avg_rating,
    m.duration
    	
From 
	director_mapping dm
    inner join 
    names n
    on
    dm.name_id=n.id
    inner join 
    movie m
    on
    m.id=dm.movie_id
    inner join 
    ratings r
    on 
    m.id=r.movie_id
	WINDOW W as (partition by dm.name_id Order by dm.name_id, m.date_published)   
    ORder by  dm.name_id, m.date_published
)
SELECT 
    director_id,
    director_name,
    COUNT(movie_id) AS number_of_movies,
	Round(AVG(date_diff)) AS avg_inter_movie_days,
    Round(SUM(total_votes * avg_rating) / SUM(total_votes),2) AS 'avg_rating',
    SUM(total_votes) AS total_votes,
    MIN(avg_rating) AS min_rating,
    MAX(avg_rating) AS max_rating,
    SUM(duration) AS total_duration
FROM
    CTE_Director_DateDiff
GROUP BY 
		director_id , 
        director_name
)  
select  
	*,
RANK() OVER(ORDER BY number_of_movies DESC) as 'director_rank'
 from CTE_Director_Rank
 
 )
 SELECT 
	director_id,
    director_name,
    number_of_movies,
    avg_inter_movie_days,
    avg_rating,
    total_votes,
    min_rating,
    max_rating,
    total_duration
FROM 
	CTE_director_Final
LIMIT 9
 ;  
