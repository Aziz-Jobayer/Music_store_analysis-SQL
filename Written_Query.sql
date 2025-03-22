-- all the artists list in alphabetical order. 

--SELECT * FROM artist
SELECT name 
FROM artist 
ORDER BY name asc;

-- each artist total album numbers.
-- analyzed the schema and approached join operation 

--SELECT * FROM album 
--SELECT * FROM artist
SELECT artist.Name, COUNT(album_id) AS NumberOfAlbums
FROM artist
JOIN album ON artist.artist_id = album.artist_id
GROUP BY artist.artist_id, artist.name      -- artist_id add for elimanting same name case 
ORDER BY NumberOfAlbums DESC;

--Names of all employees who report to someone. 

--SELECT * FROM employee 
SELECT first_name, last_name ,reports_to
FROM employee
WHERE reports_to IS NOT NULL;

--Senior most employee based on job title.

--SELECT * FROM employee
SELECT first_name, last_name, title , levels
FROM employee 
ORDER BY levels desc 
LIMIT 1;

--List all the unique countries of customers. 
SELECT DISTINCT country 
FROM customer 
ORDER BY country;

--The customer who has the longest name.

SELECT customer_id, first_name, last_name, LENGTH (first_name||last_name) AS Largest_Length
FROM Customer
ORDER BY Largest_Length DESC
LIMIT 1;

--total number of tracks in the database.
--SELECT * FROM track
SELECT COUNT (track_id) as Total_track 
FROM track;

--The country with the highest number of invoices
--SELECT * FROM invoice
SELECT billing_country , COUNT(invoice_id) AS InvoiceCount
FROM invoice
GROUP BY billing_country 
ORDER BY InvoiceCount DESC
LIMIT 1;

--Top 3 values of total invoice
--SELECT * FROM invoice
SELECT total FROM invoice 
ORDER BY total DESC 
LIMIT 3;

--Best city of customers. That has the highest sum of invoice totals (For throwing a promotional music festival)

--SELECT * FROM invoice
SELECT billing_city as City_Name,SUM(total) as Highest_total
FROM invoice
GROUP BY billing_city 
ORDER BY Highest_total DESC 
LIMIT 1;

/*The best customer who has spent the most money .
Analyzed the invoice & schema table and approached to join method.*/

--SELECT * FROM invoice
--SELECT * FROM customer
SELECT  customer.first_name,customer.last_name,customer.customer_id, SUM(invoice.total) as Total_spent
FROM customer 
JOIN invoice ON customer.customer_id=invoice.customer_id
GROUP BY customer.customer_id
ORDER BY Total_spent DESC 
LIMIT 1;

--Average track length(in milliseconds) for each genre.

SELECT g.name AS GenreName,g.genre_id, AVG(t.milliseconds) as average_length 
FROM genre g
JOIN track t ON g.genre_id=t.genre_id
GROUP BY g.name,g.genre_id
ORDER BY average_length desc ;

--List of the top 5 most popular genres(based on the number of tracks).
SELECT genre.name as genre_name, COUNT(track.track_id) as total_track
FROM track 
JOIN genre ON track.genre_id=genre.genre_id
GROUP BY genre.genre_id
ORDER BY total_track DESC 
LIMIT 5;


/*query to return the email, first name, last name, & Genre of all Rock Music listeners.
 Return the list ordered alphabetically by email starting with A.
 Observed the schema & use multiple join operation.*/

SELECT DISTINCT email, first_name, last_name, genre.name
FROM customer
JOIN invoice ON customer.customer_id=invoice.customer_id
JOIN invoice_line ON invoice.invoice_id= invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email

-- Name of the artists have tracks in the "Rock" genre.

SELECT artist.artist_id,artist.name,
        MIN(track.name) as track_name, 						/*extract (alphabetically first) track name for each artist.
		                                                         you can also use Max aggregate functions to to get the maximum (alphabetically last). */	
		genre.name as genre_name												   
FROM artist
JOIN album ON artist.artist_id=album.artist_id
JOIN track ON album.album_id=track.album_id
JOIN genre ON track.genre_id=genre.genre_id 
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id,genre.name,artist.name
ORDER BY artist.name 

/*Let's invite the artists who have written the most rock music in our dataset.
Write a query that returns the Artist name and total track count of the top 10 rock bands.
Analyzed the schema and went for multiple join operation */

SELECT artist.artist_id,artist.name,COUNT (track.track_id) as TotalMusic
FROM track                                         --use track as primary table because it is in the center among the for table.
JOIN album ON track.album_id=album.album_id
JOIN artist ON album.artist_id=artist.artist_id
JOIN genre ON track.genre_id=genre.genre_id
WHERE genre.name LIKE 'Rock'                       -- Filter for Rock genre
GROUP BY artist.artist_id, artist.name
ORDER BY TotalMusic DESC  
LIMIT 10;

/*Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. 
Order by the song length with the longest songs listed first.*/

SELECT name,milliseconds
FROM track
WHERE milliseconds>(
       SELECT AVG(milliseconds) AS avg_song_length            --Filter out songs that are shorter than the average song length.
	   FROM track
)
ORDER BY milliseconds DESC

--Total sell of 3,4 & 5th no. employees.

SELECT e.employee_id,SUM(invoice.total)as Total_sell                            
FROM employee e 
JOIN customer ON CAST(e.employee_id AS integer)= customer.support_rep_id 				-- changed the employee_id data type since it is in character varying
JOIN invoice ON customer.customer_id=invoice.customer_id 								-- point to be noted, this query will show only 3,4 & 5 no. employees sell total because in support_rep_id column has only those employee id. so if you want to get full result you need to change(input all the employee id)in support_rep_id column. 
GROUP BY e.employee_id
ORDER BY Total_sell DESC;

-- Query to find the customer who has purchased the most tracks from a specific genre (e.g., "Jazz")
--Decide to use CTE method for probable multiple highest purchased number

WITH genre_purchases AS (
    SELECT 
        c.customer_id, 
        c.first_name, 
        c.last_name, 
		g.name AS genre_name,
        COUNT(il.track_id) AS total_tracks_purchased
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    WHERE g.name = 'Jazz'  -- Filtering for the specific genre
    GROUP BY c.customer_id, c.first_name, c.last_name,g.name
)
SELECT * 
FROM genre_purchases
WHERE total_tracks_purchased = (SELECT MAX(total_tracks_purchased) FROM genre_purchases); --This ensures that if multiple customers have the highest purchase count, all of them are included in the final result. 

--How much amount spent by each customer on artists? 
--This query will return customer name, artist name and total spent

SELECT
    c.customer_id,c.first_name || ' ' || c.last_name AS customer_name,        -- Concatenate first & last name
    a.name AS artist_name,
    SUM(il.unit_price * il.quantity) AS total_spent			 -- Calculate total amount spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_Line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist a ON al.artist_id = a.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, a.artist_id, a.name
ORDER BY total_spent DESC;


--List of customer spending on the top-selling artist.

-- Step 1: First Find the highest-selling artist based on total sales
WITH best_selling_artist AS (
    SELECT 
        artist.artist_id,  
        artist.name AS artist_name,  
        SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales  
    FROM invoice_line
    JOIN track ON track.track_id = invoice_line.track_id  
    JOIN album ON album.album_id = track.album_id  
    JOIN artist ON artist.artist_id = album.artist_id  
    GROUP BY 1               -- Here 1 is the select column serial.
    ORDER BY 3 DESC  
    LIMIT 1             -- Select the highest-selling artist
)

-- Step 2: Now Find the customers who spent on this artist
SELECT 
    c.customer_id,  
    c.first_name,   
    c.last_name,    
    bsa.artist_name,  
    SUM(il.unit_price * il.quantity) AS amount_spent  
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id  
JOIN invoice_line il ON il.invoice_id = i.invoice_id  
JOIN track t ON t.track_id = il.track_id  
JOIN album alb ON alb.album_id = t.album_id  

-- Filters purchases to only include those from the best-selling artist
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id  
GROUP BY 1,2,3,4 
ORDER BY 5 DESC

/* The most popular music Genre for each country. 
   Determined the most popular genre as the genre with the highest amount of purchases.
   This query returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres.
   */


WITH RECURSIVE
	sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
		FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2
	),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY 2
		ORDER BY 2)

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;


/* Query that determines the customer that has spent the most on music for each country. 
This query will return the country along with the top customer and how much they spent. 
N.B.For countries where the top amount spent is shared, provide all customers information who spent this amount. */

WITH RECURSIVE 
		customer_by_country AS (
					SELECT 
						c.customer_id,
						c.first_name|| ' ' || c.last_name AS customer_name,
						i.billing_country AS country_name,
						SUM(total) AS total_spending
					FROM customer c
					JOIN invoice i ON c.customer_id=i.customer_id
					GROUP BY 1,2,3
					ORDER BY 4),
		country_max_spending AS(
                   SELECT country_name,MAX(total_spending)AS max_spending 
				    FROM customer_by_country
					GROUP BY country_name)

SELECT 
	cc.customer_id,
	cc.customer_name,
	cc.country_name,
	cc.total_spending
FROM customer_by_country cc
JOIN country_max_spending cs ON cc.country_name=cs.country_name   -- Match customers with their country's spending record
WHERE cc.total_spending=cs.max_spending                           -- Filter to keep only top spenders per country
ORDER BY 3;


-- The percentage of sales for each employee compared to the total sales

SELECT 
    e.employee_id, 
    e.first_name, 
    e.last_name, 
    SUM(i.total) AS total_sales,
    ROUND(
        (SUM(i.total)::numeric * 100) / (SELECT SUM(total)::numeric FROM invoice),   --Calculates each employee's sales percentage of the total. Uncorrelated subquery gets the company's total sales.
        2
    ) AS sales_percentage
FROM employee e
JOIN customer c ON CAST(e.employee_id AS integer) = c.support_rep_id 	
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY sales_percentage DESC;

-- The artist whose albums have the highest average number of tracks.

SELECT a.artist_id,a.name,COUNT(t.track_id)AS total_track,
 ROUND(
        COUNT(t.track_id) * 1.0 / COUNT(DISTINCT al.album_id),2 
    ) AS track_average_per_album
FROM artist a 
JOIN album al ON a.artist_id=al.artist_id
JOIN track t ON al.album_id=t.album_id
GROUP BY a.artist_id,a.name
ORDER BY track_average_per_album DESC
LIMIT 1;


--Alternative approach using sub-query
SELECT 
    ar.artist_id, 
    ar.name AS artist_name, 
    AVG(track_count) AS avg_tracks_per_album
FROM (
    -- Subquery to calculate the number of tracks per album
SELECT 
        al.album_id, 
        al.artist_id, 
        COUNT(t.track_id) AS track_count
    FROM album al
    JOIN track t ON al.album_id = t.album_id
    GROUP BY al.album_id, al.artist_id
) album_tracks
JOIN artist ar ON album_tracks.artist_id = ar.artist_id
GROUP BY ar.artist_id, ar.name
ORDER BY avg_tracks_per_album DESC
LIMIT 10;  -- Selects the artist with the highest average

--A report that shows the customer name, their total spending, and the number of invoices they have. 

SELECT
	c.customer_id,
	c.first_name || ' ' || c.last_name AS customer_name,
	SUM(i.total) AS Total_spending,
	COUNT (i.invoice_id) AS number_of_invoices
from customer c
JOIN invoice i ON i.customer_id=c.customer_id
GROUP BY 1,2
ORDER BY 3 DESC 

--A report of top 3 Best-Selling Tracks per genre.

WITH TrackSales AS (
    -- Calculate the sales for each track
    SELECT
        t.track_id,
        t.name AS track_name,
        g.name AS genre_name,
        g.genre_id,
        SUM(il.quantity) AS sales_count
    FROM
        track t
    JOIN
        genre g ON t.genre_id = g.genre_id
    JOIN
        invoice_line il ON t.track_id = il.track_id
    GROUP BY
        t.track_id, t.name, g.name, g.genre_id
),
RankedTracks AS (
    -- Rank tracks within each genre based on sales,  used DENSE_RANK since it will handling ties correctly
    SELECT
        track_id,
        track_name,
        genre_name,
        genre_id,
        sales_count,
        DENSE_RANK() OVER (PARTITION BY genre_id ORDER BY sales_count DESC) AS rank_within_genre
    FROM
        TrackSales
)
-- Select the top 3 tracks from each genre, including ties
SELECT
    track_name,
    genre_name,
    sales_count
FROM
    RankedTracks
WHERE
    rank_within_genre <= 3
ORDER BY
    genre_name,
    sales_count DESC;