## <p align="center"> Questions


---

### 1. My partner and I want to come by each of the stores in person and meet the managers. Please send over the managers’ names at each store, with the full address of each property (street address, district, city, and country please).

```sql
-- Select the manager's full name and the complete store address

SELECT 
    CONCAT(s1.first_name, ' ', s1.last_name) AS manager_name, -- Combine the first and last name of the manager
    CONCAT(a.address,
            ', ',
            a.district,
            ', ',
            c.city,
            ', ',
            c1.country) AS address -- Create a concatenated address including address, district, city, and country
FROM
    movies_db.store AS s
        JOIN
    movies_db.staff AS s1 ON s.store_id = s1.store_id -- Join the 'store' and 'staff' tables on the 'store_id' column
        JOIN
    movies_db.address AS a ON a.address_id = s.address_id -- Join the 'address' table using the 'address_id' from 'store'
        JOIN
    movies_db.city AS c ON a.city_id = c.city_id -- Join the 'city' table using the 'city_id' from 'address'
        JOIN
    movies_db.country AS c1 ON c.country_id = c1.country_id; -- Join the 'country' table using the 'country_id' from 'city'
```

### 2. I would like to get a better understanding of all of the inventory that would come along with the business. Please pull together a list of each inventory item you have stocked, including the store_id number, the inventory_id, the name of the film, the film’s rating, its rental rate and replacement cost.

```sql
-- Select specific columns from the database to retrieve store and film information

SELECT 
    st.store_id, -- Select the unique store identifier
    inv.inventory_id, -- Select the unique inventory identifier
    f.title AS film_name, -- Select the film title and alias it as 'film_name'
    f.rating, -- Select the film rating
    f.rental_rate, -- Select the rental rate for the film
    f.replacement_cost -- Select the replacement cost of the film
FROM
    movies_db.store AS st -- Alias the 'store' table as 'st' for brevity
        JOIN
    movies_db.inventory AS inv ON st.store_id = inv.store_id -- Join 'store' and 'inventory' tables on 'store_id'
        JOIN
    movies_db.film AS f ON inv.film_id = f.film_id; -- Join 'inventory' and 'film' tables on 'film_id'
```

### 3. From the same list of films you just pulled, please roll that data up and provide a summary level overview of your inventory. We would like to know how many inventory items you have with each rating at each store.

```sql
-- Select the store ID, film rating, and count of film inventory for each store and rating combination

SELECT 
    st.store_id, -- Select the unique store identifier
    f.rating, -- Select the film rating
    COUNT(*) AS inventory_count -- Count the number of records for each combination
FROM
    movies_db.store AS st -- Alias the 'store' table as 'st' for brevity
        JOIN
    movies_db.inventory AS inv ON st.store_id = inv.store_id -- Join 'store' and 'inventory' tables on 'store_id'
        JOIN
    movies_db.film AS f ON inv.film_id = f.film_id -- Join 'inventory' and 'film' tables on 'film_id'
GROUP BY st.store_id, f.rating -- Group the results by store ID and film rating
ORDER BY st.store_id, f.rating; -- Order the results by store ID and film rating
```

### 4. Similarly, we want to understand how diversified the inventory is in terms of replacement cost. We want to see how big of a hit it would be if a certain category of film became unpopular at a certain store. We would like to see the number of films, as well as the average replacement cost, and total replacement cost, sliced by store and film category.

```sql
-- Retrieve store-specific film category statistics including film count, average replacement cost, and total replacement cost

SELECT 
    s.store_id AS stores, -- Select and alias the store ID as 'stores'
    c.name AS category_name, -- Select the category name
    COUNT(*) AS number_of_films, -- Count the number of films in each category for each store
    CAST(AVG(f.replacement_cost) AS DECIMAL(10, 2)) AS average_replacement_cost, -- Calculate the average replacement cost of films in each category
    CAST(SUM(f.replacement_cost) AS DECIMAL(10, 2)) AS total_replacement_cost -- Calculate the total replacement cost of films in each category
FROM
    movies_db.store AS s -- Alias the 'store' table as 's' for brevity
        JOIN
    movies_db.inventory AS i ON s.store_id = i.store_id -- Join 'store' and 'inventory' tables on 'store_id'
        JOIN
    movies_db.film_category AS fc ON i.film_id = fc.film_id -- Join 'inventory' and 'film_category' tables on 'film_id'
        JOIN
    movies_db.category AS c ON c.category_id = fc.category_id -- Join 'film_category' and 'category' tables on 'category_id'
        JOIN
    movies_db.film AS f ON f.film_id = fc.film_id -- Join 'film_category' and 'film' tables on 'film_id'
GROUP BY s.store_id, c.name -- Group the results by store ID and category name
ORDER BY s.store_id, c.name; -- Order the results by store ID and category name
```

### 5. We want to make sure you folks have a good handle on who your customers are. Please provide a list of all customer names, which store they go to, whether or not they are currently active, and their full addresses —street address, city, and country.

```sql
-- Retrieve customer information including customer name, store ID, active status, and full address

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name, -- Combine the first and last name to get the customer's full name
    s.store_id AS stores, -- Select the store ID associated with each customer
    CASE
        WHEN c.active = 1 THEN 'Yes' -- Check if the customer is active and display 'Yes' if true, 'No' otherwise
        ELSE 'No'
    END AS 'Are_customers_active?', -- Alias the active status column
    CONCAT(a.address,
            ', ',
            c1.city,
            ', ',
            c2.country) AS full_address -- Create a concatenated full address including address, city, and country
FROM
    movies_db.customer AS c -- Alias the 'customer' table as 'c' for brevity
        JOIN
    movies_db.store AS s ON c.store_id = s.store_id -- Join 'customer' and 'store' tables on 'store_id'
        JOIN
    movies_db.address AS a ON c.address_id = a.address_id -- Join 'customer' and 'address' tables on 'address_id'
        JOIN
    movies_db.city AS c1 ON a.city_id = c1.city_id -- Join 'address' and 'city' tables on 'city_id'
        JOIN
    movies_db.country AS c2 ON c1.country_id = c2.country_id -- Join 'city' and 'country' tables on 'country_id'
ORDER BY customer_name; -- Order the results by customer name
```

### 6. We would like to understand how much your customers are spending with you, and also to know who your most valuable customers are. Please pull together a list of customer names, their total lifetime rentals, and the sum of all payments you have collected from them. It would be great to see this ordered on total lifetime value, with the most valuable customers at the top of the list.

```sql
-- Retrieve customer information including customer name, total lifetime rentals, and total payments

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name, -- Combine the first and last name to get the customer's full name
    COUNT(r.rental_id) AS total_lifetime_rentals, -- Count the total number of rentals for each customer
    CAST(SUM(p.amount) AS DECIMAL(10, 2)) AS total_payments -- Calculate the total payments made by each customer
FROM
    movies_db.customer AS c -- Alias the 'customer' table as 'c' for brevity
        JOIN
    movies_db.payment AS p ON c.customer_id = p.customer_id -- Join 'customer' and 'payment' tables on 'customer_id'
        JOIN
    movies_db.rental AS r ON p.rental_id = r.rental_id -- Join 'payment' and 'rental' tables on 'rental_id'
GROUP BY customer_name -- Group the results by customer name
ORDER BY total_payments DESC; -- Order the results by total payments in descending order
```

### 7. My partner and |would like to get to know your board of advisors and any current investors. Could you please provide a list of advisor and investor names in one table? Could you please note whether they are an investor or an advisor, and for the investors, it would be good to include which company they work with.

```sql
-- Combine information from two different tables: investors and advisors

-- Select investor information
SELECT 
    CONCAT(i.first_name, ' ', i.last_name) AS full_name, -- Combine the first and last name to get the full name of the investor
    'Investor' AS 'role', -- Assign 'Investor' as the role
    i.company_name AS name_of_company -- Select the name of the company for investors
FROM
    movies_db.investor AS i -- Specify the 'investor' table as the data source

UNION -- Combine the results with information from advisors

-- Select advisor information
SELECT 
    CONCAT(a.first_name, ' ', a.last_name), -- Combine the first and last name to get the full name of the advisor
    'Advisor' AS 'role', -- Assign 'Advisor' as the role
    NULL AS name_of_company -- Advisors don't have a company, so use NULL for the company name
FROM
    movies_db.advisor AS a; -- Specify the 'advisor' table as the data source
```

### 8. We're interested in how well you have covered the most-awarded actors. Of all the actors with three types of awards, for what % of them do we carry a film? And how about for actors with two types of awards? Same questions. Finally, how about actors with just one award?    

```sql
-- Calculate statistics for movies and their actors' awards

-- Select movie title, number of awards for actors, and calculate the percentage of award winners for each movie
SELECT 
    movie_title, -- Select the movie title
    number_of_awards, -- Select the number of awards for actors
    COUNT(*) AS number_of_actors, -- Count the number of actors for each movie and award category
    (COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY movie_title)) * 100 AS perc_award_winners -- Calculate the percentage of award-winning actors for each movie
FROM
    (SELECT 
        f.title AS movie_title, -- Select the movie title
            CONCAT(a.first_name, ' ', a.last_name) AS full_name, -- Combine the first and last name to get the full name of the actor
            a.awards, -- Select the awards column for actors
            CASE
                WHEN awards LIKE '%/%/%' THEN 3 -- Assign a value of 3 if the awards format is 'x/y/z'
                WHEN awards LIKE '%/%' THEN 2 -- Assign a value of 2 if the awards format is 'x/y'
                ELSE 1 -- Assign a value of 1 for all other cases
            END AS number_of_awards -- Calculate the number of awards based on the awards format
    FROM
        movies_db.film AS f -- Specify the 'film' table as the source of movie information
    JOIN movies_db.film_actor AS fa ON f.film_id = fa.film_id -- Join 'film' and 'film_actor' tables on 'film_id'
    JOIN movies_db.actor_award AS a ON fa.actor_id = a.actor_id -- Join 'film_actor' and 'actor_award' tables on 'actor_id'
    ) m -- Alias the subquery as 'm'

GROUP BY movie_title, number_of_awards -- Group the results by movie title and number of awards
ORDER BY movie_title, number_of_awards; -- Order the results by movie title and number of awards
```
