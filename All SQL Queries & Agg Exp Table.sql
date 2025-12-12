select * from ecom.aggregated_table; /*FINAL TABLE FOR REFFERENCE */

select * from ecom.experiments;
/*These 3 below are the initial Company Data - not with Experimnets - I'm Guessing*/

/* Experiments table columns present: experiment_id, element_tested, start_date, end_date, effects_on_conv */

select * from ecom.orders; /*has user_id column*/

select * from ecom.sessions; /*has user_id(orders, sessions, users), experiment_id column(experiments table)*/

select * from ecom.users; /*has user_id column*/

/*Step 1: Validate Relationship Strength (Are the joins meaningful?)
Before building any aggregated table, you want to confirm:
1. How many sessions belong to each experiment?
→ This tells you if the A/B test was balanced or extremely skewed.

2. How many orders exist per user?
→ Helps you know if purchasing is common or rare.

3. How many sessions actually lead to orders?
→ Gives you a rough sense of conversion.*/

/*1. */
select S.experiment_id, count(S.session_id) as "Total Sessions"
from ecom.sessions as S
join ecom.experiments as E on S.experiment_id = E.experiment_id
group by S.experiment_id
order by S.experiment_id; 
/*We now know the Total Sessions by the Experiment_ID */

/*2. */
select U.user_id, U.customer_name, sum(U.total_orders) as "Total Orders"
from ecom.users as U
join ecom.orders as O on U.user_id = O.user_id
group by U.user_id, U.customer_name
order by U.user_id;


/*3. How many sessions actually lead to orders?
→ Gives you a rough sense of conversion.*/

select* from ecom.sessions;
/*So the Session table has both: 
the session id itself and it also has the completed_purchase column as well 
- so we'll just go with all the values where = True */

select S.session_id, S.completed_purchase
from ecom.sessions as S
where S.completed_purchase = True 
group by S.session_id, S.completed_purchase;
/*So total of 12,408 Sessions where completed purchases is TRUE */

/*ALSO THIS --> Lets try to get the user names for these Sessions (Just Trying)*/

select S.session_id, count(S.completed_purchase) as "total", U.user_id, U.customer_name
from ecom.sessions as S
join ecom.users as U on S.user_id = U.user_id
where S.completed_purchase = True 
group by S.session_id, S.completed_purchase, U.user_id, U.customer_name;


/* Some other up next --> 
What to explore next:
How many sessions per experiment? DONE
How many sessions per user? TO DO 
How many orders per user? DONE
How many sessions lead to at least one order? DONE But can explore again
How many experiment variants exist? To Do 
*/ 


/* How many sessions per user?  TO DO */

select * 
from ecom.sessions 
limit 5;

/* So yup we see that we have user_id column in the Sessions table */ 

select S.user_id, count(S.session_id) as "Total Sessions per User"
from ecom.sessions as S
group by S.user_id;


/* How many experiment variants exist? To Do */

select * 
from ecom.experiments;

/*SO what it means is: what are the element_tested */

select * 
from ecom.sessions;
/*We'll join on experiment_id */


select S.session_id, S.user_id, E.element_tested, count(E.element_tested) as "How many Variants"
from ecom.experiments as E
join ecom.sessions as S on E.experiment_id = S.experiment_id
group by S.session_id, S.user_id, E.element_tested



/* How many experiment variants exist? To Do */
select * 
from ecom.sessions;

select * 
from ecom.experiments;

select E.experiment_id, E.element_tested, S.version_seen, count(S.version_seen) as "How many variants", S.user_id
from ecom.sessions as S
join ecom.experiments as E on E.experiment_id = S.experiment_id
group by E.experiment_id, E.element_tested, S.version_seen, S.user_id
order by E.experiment_id;

/*
1. Variant Breakdown (Basic Sanity Check)
   Question:

How many variants exist for each experiment?

What we’re looking for:
Whether the test is A/B or A/B/C or something else.
Whether something looks wrong (e.g., only 1 variant → no true experiment).
*/


select distinct (version_seen)
from ecom.sessions;

/*AND a more detailed view*/

select E.experiment_id, E.element_tested, version_seen
from ecom.sessions as S
join ecom.experiments as E on S.experiment_id = E.experiment_id
group by E.experiment_id, E.element_tested, version_seen
order by E.experiment_id;


/*2. User Exposure Breakdown (Balance Check)
  Question:
How many users saw each variant?
What we’re looking for:
Whether exposure is balanced (e.g., 50-50 for A/B).
If one variant barely has any users → experiment is invalid.*//

select user_id, version_seen, count(version_seen) as "Count"
from ecom.sessions
where version_seen is not null
group by user_id, version_seen;


select experiment_id, user_id, version_seen, count(version_seen) as "Count"
from ecom.sessions
where version_seen = 'A'
group by experiment_id, user_id, version_seen;
/*Total rows 798 but with count more than 1 were seen*/


select experiment_id,user_id, version_seen, count(version_seen) as "Count"
from ecom.sessions
where version_seen = 'B'
group by experiment_id, user_id, version_seen;
/*Total rows 739 Count COULD BE more than 1 (MAYBE COULD BE)*/



select experiment_id, version_seen, count(distinct user_id)
from ecom.sessions
where version_seen is not null
group by experiment_id, version_seen
order by  version_seen, experiment_id;



/*3. Session Frequency Breakdown (Engagement Check)
  Question:
How many sessions does each user have?
OR
How many sessions belong to each variant?

 What we’re looking for:
Some users may have many sessions → can skew results.
Some variants may have more sessions due to heavy users.*/

select count(version_seen) as "Total"
from ecom.sessions 
where sessions.version_seen in ('A');

select count(session_id)
from ecom.sessions
where version_seen = 'A';


select count(version_seen)
from ecom.sessions
where version_seen = 'B';

select count(session_id)
from ecom.sessions
where version_seen = 'B';


/*How many sessions does each user have?*/

select user_id, count(session_id) as "Total Sessions per User"
from ecom.sessions
group by user_id;


/*ADDED - MINE --> count of A or B per user */


select user_id, count(version_seen)
from ecom.sessions
where version_seen = 'A'
group by user_id


select user_id, count(version_seen)
from ecom.sessions
where version_seen = 'B'
group by user_id


/*4. User Switching Behavior (Exposure Validity Check)
 Question:
Did any user see more than one variant?

What we’re looking for:
Users should only see ONE version.

If users switch variants → test contamination.
*/

/*So now that we know that are 2 versions --> A and B */

select user_id, version_seen
from ecom.sessions
where version_seen in ('A', 'B')

/*SO The having function filters out data even with like an aggregate function eg; where price >= avg(price)
- UNLIKE where function which filters out data based on singe values in a column eg; where price >= 25 */



/*Right so we wanna know if there are any users that have seen both A and B versions*/

select user_id, count(distinct version_seen) as "How many versions"
from ecom.sessions
where version_seen in ('A', 'B')
group by user_id
having count(distinct version_seen) > 1
/*OUTPUT FOR THIS ONE^^^ 
means that this gives us user_id of all of users that saw more than 1 session
---> THIS could mean A|A B|B AND also A|B B|A versions all included and NOT JUST A|B OR B|A */


select user_id, count(version_seen) as "How many Versions"
from ecom.sessions
where version_seen in ('A', 'B')
group by user_id
having count(version_seen) > 1
/* OUTPUT: FOR THIS ONE ^^
This gives us the DISTINCT ones (as in A OR B) --> So out put for this is filtered even more 
so where count more than 1 (A|A, B|B, A|B, B|A) ---> So this filters it to either A|B OR B|A
SO THIS is the right way to do it. 
*/

/* FINAL QUERY FOR NUMBER #4 */

select user_id, count(distinct version_seen) as "How many Versions"
from ecom.sessions 
where version_seen in ('A', 'B')
group by user_id
having count(distinct version_seen) > 1



/* 5. Conversion Funnel Check (Core Metrics)
 Question:
How many sessions led to at least one order?
 What we’re looking for:
Raw conversion health of the dataset.
Ensures orders table is linked properly.
*/

select distinct(session_id), user_id 
from ecom.sessions
where completed_purchase = True
/*Or going purely by orders and order_id*/
select distinct(session_id), user_id
from ecom.sessions
where order_id is not null
/*BOTH ^^^ Give us 12,408*/

/*We can make use of the completed purchase column 
and also we're tryna find the count of the sessions - and not the id's itself*/

select count(distinct session_id)
from ecom.sessions
where completed_purchase = true
/*The count came out to be 12408*/



/*6. Variant-Level Conversion Check (Experiment Health)
 Question:
What is the number of orders per variant?
 What we’re looking for:
High-level: which variant seems to perform better.

Not rigorous stats — just raw counts.*/

select distinct version_seen, count(completed_purchase)
from ecom.sessions
where version_seen in ('A', 'B')
group by distinct version_seen
/*OUTPUT FOR THIS^^^ A: 808, B: 770*/


/*Going by Order_id*/
select distinct version_seen, count(order_id)
from ecom.sessions
where version_seen in ('A', 'B')
group by distinct version_seen
/*OUTPUT FOR THIS^^^ A: 125, B: 157*/


/*FINAL QUERY FOR Number # 6*/
select version_seen, count(*)
from ecom.sessions
where version_seen in ('A', 'B') and completed_purchase = true
group by version_seen
/*OUTPUT FOR THIS^^^ is A: 125, B: 157*/


/*7. Unique User Conversion (Clean Conversion Rate)
 Question:
How many unique users converted per variant?
 What we’re looking for:
Avoid session-count bias.
Checks whether Variant B has fewer users but higher conversion.
*/

select *
from ecom.users


select version_seen, count(distinct S.user_id), count(distinct U.user_id)
from ecom.sessions as S
join ecom.users as U on S.user_id = U.user_id
where version_seen in ('A', 'B') and completed_purchase = true
group by version_seen
/*OUTPUT FOR THIS^^^ ---> A: 125|125 and B: 154|154 */

select version_seen, count(distinct S.user_id), count(distinct U.user_id), U.customer_name
from ecom.sessions as S
join ecom.users as U on S.user_id = U.user_id
where version_seen in ('A', 'B') and completed_purchase = true
group by version_seen, S.user_id, U.user_id, u.customer_name



/*8. Item-Level or Revenue-Level Conversion (Business Impact)
 Question:
How much total order value came from each variant?
 What we’re looking for:
If Variant B increases revenue per user.
Helps determine “which variant wins financially.”*/

select *
from ecom.sessions;

select *
from ecom.orders;

select  S.version_seen, sum(O.order_value) as "Total Order Value", sum(O.profit) as "Total Profit"
from ecom.sessions as S
join ecom.orders as O on S.order_id = O.order_id
where S.version_seen in ('A', 'B') and S.completed_purchase = true
group by S.version_seen 



/*9. Dropout or Zero-Session/Zero-Order Check (Data Quality)
 Question:
Do we have users in the experiment who never created a session or order?
 What we’re looking for:
Data quality issues
Missing events
Users who were assigned but never active
*/

select *
from ecom.sessions

select *
from ecom.orders

select *
from ecom.users


select distinct user_id 
from ecom.sessions as S 
where pages_viewed > 0 and clicked_product = true and added_to_cart = true and completed_purchase = false


select distinct U.user_id, O.category, O.product_id, O.sub_category, O.product_name
from ecom.sessions as S 
join ecom.users as U on S.user_id = U.user_id
join ecom.orders as O on U.user_id = O.user_id
where pages_viewed > 0 and clicked_product = true and added_to_cart = true and completed_purchase = false

/*Where they signed up but did not have any sessions - ONLY WAY TO CHECK*/

select U.user_id
from ecom.sessions as S
join ecom.users as U on S.user_id = U.user_id
where U.signup_date is not null and S.session_date is null
/*SO INITIALLY THIS ^^ WAS WRONG because inner join used - have to use left join*/



select distinct(U.user_id), (S.user_id)
from ecom.users as U
left join ecom.sessions as S on U.user_id = S.user_id
where U.signup_date is not null and S.session_date is null

select distinct (U.user_id), (S.user_id)
from ecom.users as U
left join ecom.sessions as S on S.user_id = U.user_id
where U.signup_date is not null and S.session_id is null



/*10. Experiment Duration Check (Temporal Validity)
 Question:
Which dates does each experiment run across, and are variants active at the same times?
 What we’re looking for:
One variant running longer than others → unfair results
Test not fully rolled out at the same time */

/*date by date (day by day comparison)*/

select version_seen, session_date
from ecom.sessions 
where version_seen in ('A', 'B')
group by version_seen, session_date
order by session_date asc

select version_seen, min(session_date), max(session_date)
from ecom.sessions 
where version_seen in ('A', 'B') 
group by version_seen
order by version_seen asc 


/*Question:
Which dates does each experiment run across, and are variants active at the same times?
 What we’re looking for:
One variant running longer than others → unfair results
Test not fully rolled out at the same time */
*/

/*Using the version_seen */
select session_date, count(distinct version_seen)
from ecom.sessions 
where version_seen in ('A', 'B')
group by session_date
order by session_date asc

/*SIDE BY SIDE VIEW */


select version_seen, session_date, count(distinct session_date)
from ecom.sessions 
where version_seen in ('A', 'B')
group by version_seen, session_date 
order by session_date asc




/*NOW WE CREATE OUR FINAL AGGREGATED TABLE*/

/* STARTS HERE */


select session_id, user_id, experiment_id, version_seen
from ecom.sessions
where experiment_id is not null 
order by session_id, user_id asc


 
select session_id, user_id, experiment_id, version_seen, pages_viewed, clicked_product, added_to_cart, completed_purchase
from ecom.sessions
where experiment_id is not null 
order by session_id, user_id asc


 
select session_id, user_id, experiment_id, version_seen, pages_viewed, 
clicked_product, added_to_cart, completed_purchase, order_id
from ecom.sessions
where experiment_id is not null 
order by session_id, user_id asc



select session_id, user_id, experiment_id, version_seen, pages_viewed, 
clicked_product, added_to_cart, completed_purchase, order_id, count(pages_viewed) as "How many pages viewed",
count(session_id) as "How many sessions"
from ecom.sessions 
where experiment_id is not null 
group by user_id, session_id, experiment_id, version_seen, pages_viewed, 
clicked_product, added_to_cart, completed_purchase, order_id
order by session_id, user_id asc



/*ORIGINAL QUERY BEFORE DEBUGGING AND TWEAKS*/
select session_id, session_date, user_id, experiment_id, version_seen, pages_viewed, 
clicked_product, added_to_cart, completed_purchase, order_id,
sum(pages_viewed) as "How many pages viewed",
count(session_id) as "How many sessions"
from ecom.sessions 
where experiment_id is not null 
group by user_id, session_id, experiment_id, version_seen, pages_viewed, 
clicked_product, added_to_cart, completed_purchase, order_id, session_date
order by session_date, session_id, user_id asc;




/*MY OWN QUERY TWEAKED AND AI QUERY FINAL*/

select session_id, session_date, user_id, experiment_id, version_seen, pages_viewed, 
clicked_product, added_to_cart, completed_purchase, order_id,
count(session_id) over(partition by user_id) as "How many sessions"
from ecom.sessions 
where experiment_id is not null 
group by user_id, session_id, experiment_id, version_seen, pages_viewed, 
clicked_product, added_to_cart, completed_purchase, order_id, session_date
order by session_date, session_id, user_id asc;
	
	/* AND */

SELECT
    session_id,
    session_date,
    user_id,
    experiment_id,
    version_seen,
    pages_viewed,
    clicked_product,
    added_to_cart,
    completed_purchase,
    order_id,

    COUNT(*) OVER (PARTITION BY user_id) AS total_sessions_per_user

FROM ecom.sessions
WHERE experiment_id IS NOT NULL
ORDER BY session_date, session_id, user_id;



				/*FINAL AGGREGATE TABLE - DONE BELOW*/

With 
sessions_clean as (

	
	select session_id, session_date, user_id, experiment_id, version_seen, pages_viewed, 
	clicked_product, added_to_cart, completed_purchase, order_id,
	count(*) over(partition by user_id) as "How many sessions"
	from ecom.sessions 
	where experiment_id is not null 

),


users_clean as (

	select user_id, customer_name, signup_date, country, city, state, postal_code
	from ecom.users
),


orders_clean as (

	select order_id, user_id, order_date_dt, order_value, profit
	from ecom.orders
),


experiments_clean as (

	select experiment_id, element_tested, start_date, end_date, effect_on_conv
	from ecom.experiments 
)


select Ec.experiment_id, Ec.element_tested, Sc.version_seen as "Experiment Version", Uc.user_id, 
Uc.customer_name, Uc.signup_date, Uc.country, Uc.city, Uc.state, Uc.postal_code, 
count(distinct Sc.session_id) as "Total Sessions", /*each session must have a distinct session_id*/
count(*) filter(where clicked_product = true) as "Total clickedProduct", 
/*COUNT(clicked_product) counts non-NULL values, not the number of 1’s. So using sum()*/
count(*) filter(where added_to_cart = true) as "Total added to cart", 
count(*) filter(where completed_purchase = true) as "Total completed Purchases",
sum(Sc.pages_viewed) as "Total Pages Viewed",
count(distinct Oc.order_id) as "Total Orders(Total Order IDs)",
coalesce(sum(order_value), 0) as "Total Order_Value", 
coalesce(sum(profit), 0) as "Total Profit", 
Ec.start_date, Ec.end_date, Ec.effect_on_conv

from sessions_clean as Sc 
left join users_clean as Uc on Sc.user_id = Uc.user_id
left join orders_clean as Oc on Sc.order_id = Oc.order_id
left join experiments_clean as Ec on Sc.experiment_id = Ec.experiment_id

group by Ec.experiment_id, Ec.element_tested, Sc.version_seen, Uc.user_id, Uc.customer_name, Uc.signup_date, Uc.country, Uc.city, Uc.state, Uc.postal_code, 
Ec.start_date, Ec.end_date, Ec.effect_on_conv

order by Ec.experiment_id, Sc.version_seen, Uc.user_id asc;

/*-------------------------------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------------------------------*/


			/* CREATING THE AGGREGATED TABLE */

create table ecom.Agg_ExpDetailsTable  as 

		
With 
sessions_clean as (

	
	select session_id, session_date, user_id, experiment_id, version_seen, pages_viewed, 
	clicked_product, added_to_cart, completed_purchase, order_id,
	count(*) over(partition by user_id) as "How many sessions"
	from ecom.sessions 
	where experiment_id is not null 

),


users_clean as (

	select user_id, customer_name, signup_date, country, city, state, postal_code
	from ecom.users
),


orders_clean as (

	select order_id, user_id, order_date_dt, order_value, profit
	from ecom.orders
),


experiments_clean as (

	select experiment_id, element_tested, start_date, end_date, effect_on_conv
	from ecom.experiments 
)


	select Ec.experiment_id, Ec.element_tested, Sc.version_seen as "Experiment Version", Uc.user_id, 
	Uc.customer_name, Uc.signup_date, Uc.country, Uc.city, Uc.state, Uc.postal_code, 
	count(distinct Sc.session_id) as "Total Sessions", /*each session must have a distinct session_id*/
	count(*) filter(where clicked_product = true) as "Total clickedProduct", 
	/*COUNT(clicked_product) counts non-NULL values, not the number of 1’s. So using sum()*/
	count(*) filter(where added_to_cart = true) as "Total added to cart", 
	count(*) filter(where completed_purchase = true) as "Total completed Purchases",
	sum(Sc.pages_viewed) as "Total Pages Viewed",
	count(distinct Oc.order_id) as "Total Orders(Total Order IDs)",
	coalesce(sum(order_value), 0) as "Total Order_Value", 
	coalesce(sum(profit), 0) as "Total Profit", 
	Ec.start_date, Ec.end_date, Ec.effect_on_conv
	
	from sessions_clean as Sc 
	left join users_clean as Uc on Sc.user_id = Uc.user_id
	left join orders_clean as Oc on Sc.order_id = Oc.order_id
	left join experiments_clean as Ec on Sc.experiment_id = Ec.experiment_id
	
	group by Ec.experiment_id, Ec.element_tested, Sc.version_seen, Uc.user_id, Uc.customer_name, Uc.signup_date, Uc.country, Uc.city, Uc.state, Uc.postal_code, 
	Ec.start_date, Ec.end_date, Ec.effect_on_conv
	
	order by Ec.experiment_id, Sc.version_seen, Uc.user_id asc;

		/* DONE WE HAVE STORED IT IN THIS - CURRENT SCHEMA */



		/* NAME WAS TOO LONG SO CHANGED TO */
alter table ecom.agg_expdetailstable
rename to Agg_Etable



		/* QUICK CHECK */
select *
from ecom.agg_etable;
