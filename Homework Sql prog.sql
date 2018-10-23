use  Sakila;

/*1a. Display the first and last names of all actors from the table actor.*/
select first_name,last_name from actor;

/*
1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.*/

select  ucase(concat(first_name," ",Last_name)) as `Actor Name` from actor;

/*2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?*/
select actor_id,first_name,Last_name from actor
where first_name='Joe';

/*
2b. Find all actors whose last name contain the letters GEN:*/
select actor_id,first_name,Last_name from actor
where last_name like '%GEN%';

/*2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:*/
select Last_name,first_name from actor
where last_name like '%LI%'
order by last_name,first_name;


/*2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:*/
select country_id,country from country
where country in ('Afghanistan','Bangladesh','China');

/*3a. You want to keep a description of each actor. 
You don't think you will be performing queries on a description, 
so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB,
 as the difference between it and VARCHAR are significant).*/
 alter table actor
 add description blob;
 
 /*
3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.*/
 alter table actor
 drop description;

/*
4a. List the last names of actors, as well as how many actors have that last name.*/
select distinct(last_name),count(actor_id) as `No of Actors With Lastname` from actor
group by last_name;
/*
4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors*/
select distinct(last_name),count(actor_id) as `No of Actors With Lastname` from actor
group by last_name
having `No of Actors With Lastname` >=2
order by `No of Actors With Lastname` desc;

/*
4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.*/
update actor
set first_name="HARPO"
where first_name='GROUCHO'  and last_name='WILLIAMS';
/*
4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.*/
update actor
set first_name="GROUCHO"
where first_name="HARPO" and last_name='WILLIAMS';
/*
5a. You cannot locate the schema of the address table. Which query would you use to re-create it?*/
SHOW CREATE TABLE address;
/*select * from address;*/
/*

Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html

6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:*/
select a.first_name,a.last_name,b.address,c.city,d.Country, b.district,b.postal_code
from staff as a left join 
address as b 
on a.address_id=b.address_id
left join city as c
on b.city_id=c.city_id
left join country as d 
on c.country_id=d.country_id ;






/*

6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.*/

select a.first_name,a.last_name,sum(b.amount) as `Total Runged`
from staff as a left join 
payment as b 
on a.staff_id=b.staff_id
where month(payment_date)=8 and year(payment_date)=2005
group by a.first_name;


/*


6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.*/

select a.title,count(b.actor_id) as `Actors Listed`
from film as a inner join 
film_actor as b 
on a.film_id=b.film_id
group by a.title
order by `Actors Listed` desc;

/*

6d. How many copies of the film Hunchback Impossible exist in the inventory system?*/

select a.title,count(b.film_id) as `No of Hunchback`
from film as a left join 
inventory as b 
on a.film_id=b.film_id
where a.title='Hunchback Impossible';



/*
6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:*/
select a.last_name,a.first_name,sum(b.amount) as `Total Paid`
from customer as a left join 
payment as b 
on a.customer_id=b.customer_id
group by a.customer_id
order by  a.last_name;
/*

    ![Total amount paid](Images/total_payment.png)

7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
films starting with the letters K and Q have also soared in popularity. Use subqueries to 
display the titles of movies starting with the letters K and Q whose language is English.*/

select title from film
where title like 'K%' or title like 'Q%' and language_id=(select language_id from language where name='English')
;



/*
7b. Use subqueries to display all actors who appear in the film Alone Trip.*/

select first_name,last_name from actor 
where  actor_id in ( select actor_id from film where title='Alone Trip')
;


select a.first_name,a.Last_name,b.actor_id,c.title
from actor as a inner join 
film_actor as b 
on a.actor_id=b.actor_id
left join film as c

on b.film_id =c.film_id
where c.film_id = (select film_id from film where title='Alone Trip')
;



/*7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.*/
select a.first_name,a.last_name,a.email,b.country
from customer as a left join country as b
on b.country='Canada';


/*
7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.*/

select a.title,b.category_id,c.name
from film as a left join film_category as b
on a.film_id=b.film_id
left join category as c 
on b.category_id=c.category_id
where c.name='Family';


/*
7e. Display the most frequently rented movies in descending order.*/
drop  view if exists `rent`;
create view rent as
select a.inventory_id,b.film_id,c.title
from rental as a left join inventory as b
on a.inventory_id=b.inventory_id
left join film  as c on
b.film_id=c.film_id;

select title, count(film_id) as `No of times rented`
from rent
group by title
order by `No of times rented` desc;
/*
7f. Write a query to display how much business, in dollars, each store brought in.
customer_id
store-id
amount*/
drop  view if exists `payed`;
create view payed as
select a.customer_id,a.amount,b.store_id
from payment as a 
left join customer as b
on a.customer_id=b.customer_id;

select store_id, sum(amount) as `Sum of Payment`
from payed
group by store_id
order by `Sum of Payment` desc;

/*
7g. Write a query to display for each store its store ID, city, and country.

*/
drop view if exists city_country;
create view city_country as
select a.store_id,b.city_id,c.city,c.country_id,d.country
from store as a
left join address as b on
a.address_id=b.address_id
left join city as c
on b.city_id=c.city_id 
left join country as d
on c.country_id=d.country_id ;

select store_id,city,country
from city_country;



/*
7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)*/
drop view if exists gross_rev;
create view gross_rev as
select a.rental_id,a.amount,b.inventory_id,c.film_id,d.category_id,e.name
from payment as a
left join rental as b on
a.rental_id=b.rental_id
left join inventory as c
on b.inventory_id=c.inventory_id 
left join film_category as d
on c.film_id=d.film_id 
left join category as e
on d.category_id=e.category_id;

select name,sum(amount) as `Payment by Category`
from gross_rev
group by name 
order by `Payment by Category` desc;


/*
8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.*/
/*YES running a limit of 5 querry on the gross_rev view created above*/
drop view if exists Top_5;
create view Top_5 as
select name,sum(amount) as `Payment by Category`
from gross_rev
group by name 
order by `Payment by Category` desc
limit 5;
/*
8b. How would you display the view that you created in 8a?*/
select * from Top_5;
/*

8c. You find that you no longer need the view top_five_genres. Write a query to delete it.*/
drop view if exists Top_5;
