use sakila;
select * from actor;
-- 1a. Display the first and last names of all actors from the table `actor`.
select first_name, last_name from actor limit 10;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select concat_ws(' ', first_name, last_name) as 'Actor Name' from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters `GEN`:
select actor_id, first_name, last_name from actor where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select last_name, first_name from actor where last_name like '%LI%';

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country
where country in ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
alter table actor
add column description BLOB;

-- * 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
alter table actor
drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(actor_id) from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(actor_id) from actor
group by last_name
having count(actor_id)>=2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
select * from actor where first_name = "GROUCHO" and last_name = "WILLIAMS";
select * from actor where first_name = "HARPO" and last_name = "WILLIAMS";

update actor 
set first_name = "HARPO", last_name = "WILLIAMS"
where first_name = "GROUCHO" and last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
update actor 
set first_name = "GROUCHO", last_name = "WILLIAMS"
where first_name = "HARPO" and last_name = "WILLIAMS";

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
select * from address;
show create table address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
select * from address;
select * from staff;

select first_name, last_name, address from staff
inner join address where address.address_id = staff.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
select * from payment;
select * from payment where payment_date like '2005-08%';

select staff.first_name, staff.last_name, A.sum_payment_200508 from(
select staff_id, sum(amount) as sum_payment_200508 from payment
where payment_date like '2005-08%'
group by staff_id)A
inner join staff where staff.staff_id = A.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select * from film_actor;
select * from film;

select film.title, actor_count from (
select film_id, count(actor_id) as actor_count from film_actor
group by film_id)A
inner join film where film.film_id = A.film_id;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select count(inventory_id) from inventory where film_id = (
select film_id from film where title = 'Hunchback Impossible');

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
select customer.first_name, customer.last_name, total_payment as "Total amount paid" from (
select customer_id, sum(amount) as total_payment from payment
group by customer_id) A
inner join customer where customer.customer_id = A.customer_id
order by customer.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select title from film
where language_id = (
select language_id from language where name = "English")
having title like 'K%' 
or title like 'Q%';

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select first_name, last_name from actor where actor_id in (
select actor_id from film_actor where film_id = (
select film_id from film where title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select first_name, last_name, email from customer where address_id in (
select address_id from address where city_id in (
select city_id from city where country_id = (
select country_id from country where country.country = 'Canada'
)));

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
select title from film where film_id in (
select film_id from film_category where category_id = (
select category_id from category where name = 'Family'
));

-- 7e. Display the most frequently rented movies in descending order.
select film.title, B.rental_count from (
select A.film_id, count(A.rental_id) as rental_count from (
select rental_id, rental.inventory_id, inventory.film_id from inventory
inner join rental where rental.inventory_id = inventory.inventory_id
) A
group by A.film_id)B
inner join film where film.film_id = B.film_id
order by B.rental_count desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select store_id, concat('$', format(total_amount,2)) as 'Total amount'
from (
select staff_id, sum(amount) as total_amount from payment
group by staff_id) A
inner join staff where staff.staff_id = A.staff_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select C.store_id, C.city, country.country from (
select B.store_id, city.city, city.country_id from (
select store.store_id, A.city_id from (
select address_id, city_id from address where address_id in (
select address_id from store
)
)A
inner join store where store.address_id = A.address_id
)B
inner join city where city.city_id = B.city_id
)C
inner join country where country.country_id = C.country_id;

--  7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select category.name as 'Film Genre', sum(C.amount) as 'Gross Revenue' from (
select film_category.category_id, B.amount from(
select inventory.film_id, A.amount from (
select rental.rental_id, rental.inventory_id, payment.amount from payment
inner join rental where rental.rental_id = payment.rental_id
)A
inner join inventory where inventory.inventory_id = A.inventory_id
)B
inner join film_category where film_category.film_id = B.film_id
)C
inner join category where category.category_id = C.category_id
group by category.name
order by sum(C.amount) desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW view_top_5 AS
SELECT category.name as 'Film Genre', sum(C.amount) as 'Gross Revenue'
FROM (
select film_category.category_id, B.amount from(
select inventory.film_id, A.amount from (
select rental.rental_id, rental.inventory_id, payment.amount from payment
inner join rental where rental.rental_id = payment.rental_id
)A
inner join inventory where inventory.inventory_id = A.inventory_id
)B
inner join film_category where film_category.film_id = B.film_id
)C
inner join category where category.category_id = C.category_id
group by category.name
order by sum(C.amount) desc
limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from view_top_5;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW view_top_5;