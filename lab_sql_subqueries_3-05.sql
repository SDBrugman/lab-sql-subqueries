USE sakila;

-- 1 --
-- How many copies of the film Hunchback Impossible exist in the inventory system? --
# Using joins
SELECT * from inventory where film_id = 439;
SELECT * from film where title='Hunchback Impossible'; 

select f.title AS film_title, count(i.inventory_id) AS nr_of_copies 
from inventory i
	join film f
		on i.film_id = f.film_id 
where f.film_id = 439;

# Using subqueries
select title, count(i.inventory_id) AS nr_of_copies 
from inventory i
	join film f on i.film_id = f.film_id 
where i.film_id in (
	select film_id 
    from film
    where title='Hunchback Impossible'
    );

-- 2 --
-- List all films whose length is longer than the average of all the films. --
SELECT avg(length) as average_length from film;

SELECT title, length 
from film
where length > (SELECT avg(length) from film)
order by length ASC;

-- 3 --
-- Use subqueries to display all actors who appear in the film Alone Trip --
# Using joins
select f.title, concat(a.first_name, ' ', a.last_name)  AS actor
from film_actor fa
	join film f
		on fa.film_id = f.film_id
	join actor a
		on fa.actor_id = a.actor_id
where f.title = 'Alone Trip';

# Using subqueries
Select title, concat(a.first_name, ' ', a.last_name)  AS actor
from film_actor fa 
	join film f on fa.film_id = f.film_id
    join actor a on fa.actor_id = a.actor_id
where fa.film_id in (
	select film_id
    from film
    where title = 'Alone Trip'
    );

-- 4 --
-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films. --
SELECT name from category where name = 'Family';

# Using joins
SELECT f.title AS film_title, c.name AS category 
FROM film_category fc
	join film f on fc.film_id = f.film_id
    join category c on fc.category_id = c.category_id
where c.name = 'Family'
order by f.title;

# Using subqueries
select title, c.name AS category 
from film_category fc
	join category c on fc.category_id = c.category_id
    join film f on fc.film_id = f.film_id
where fc.category_id in (
	select category_id 
    from category
    where c.name = 'Family'
    );

-- 5 --
SELECT concat(first_name, ' ', last_name) AS name, email
FROM customer;

SELECT country from country where country = 'Canada';

# How to use subqueries with multiple tables (4): customer, address, city and country
select email, first_name, last_name 
from customer 
where address_id in (
		select address_id 
		from address 
		where city_id in (
			select city_id 
			from city 
			where country_id in (
				select country_id 
				from country 
				where country 
				like 'Canada'
				)
		)
);

# Using joins
select c.first_name, c.last_name, c.email, co.country
from customer c 
	join address a on c.address_id = a.address_id
	join city ci on a.city_id = ci.city_id
	join country co on ci.country_id = co.country_id
where co.country = 'Canada';

-- 6 --
# Actor who acted in the most number of films
SELECT actor_id, count(film_id) AS nr_of_films
from film_actor
group by actor_id
order by nr_of_films DESC;

# Check name of most prolific actor with actor_id 107
SELECT actor_id, first_name, last_name from actor where actor_id = 107;

# Get film titles of most prolific actor
select f.title, concat(a.first_name, ' ', a.last_name)  AS actor
from film_actor fa
	join film f
		on fa.film_id = f.film_id
	join actor a
		on fa.actor_id = a.actor_id
where a.actor_id = 107
order by f.title;

# Using subqueries
select title from film
	where film_id in (
		select film_id 
        from film_actor
		where actor_id = (
			select actor_id 
            from film_actor
			group by actor_id
			order by count(film_id) desc
			limit 1)
	);

-- 7 --
-- Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer
-- ie the customer that has made the largest sum of payments --

# Get the most profitable customer
SELECT c.customer_id, concat(c.first_name, ' ', c.last_name)  AS customer, sum(p.amount) as total_payment
FROM customer c
	join payment p on c.customer_id = p.customer_id
group by customer
order by total_payment DESC;

# Get rented films by most profitable customer
SELECT f.title as film_title, c.customer_id, concat(c.first_name, ' ', c.last_name)  AS customer_name
FROM customer c
    join rental r on c.customer_id = r.customer_id
    join inventory i on r.inventory_id = i.inventory_id
    join film f on i.film_id = f.film_id
where c.customer_id = 526
order by film_title;

-- 8 --
# Get average payments of customers
SELECT round(avg(amount),2) as average_amount FROM payment where amount not in ('',' ');

SELECT p.customer_id, concat(c.first_name, ' ', c.last_name)  AS customer_name, p.amount 
from payment p 
	join customer c on p.customer_id = c.customer_id
where p.amount > (SELECT round(avg(amount),2) from payment where amount not in ('',' '))
group by customer_name 
order by p.amount ASC;


