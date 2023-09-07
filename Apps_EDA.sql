-- Creating Tabels and loading the data 

CREATE TABLE appstore (
    id INT PRIMARY KEY,
    track_name VARCHAR(255),
    size_bytes BIGINT,
    currency VARCHAR(10),
    price DECIMAL(10, 2),
    rating_count_tot INT,
    rating_count_ver INT,
    user_rating DECIMAL(3, 1),
    user_rating_ver DECIMAL(3, 1),
    ver VARCHAR(20),
    cont_rating VARCHAR(5),
    prime_genre VARCHAR(50),
    sup_devices_num INT,
    ipadSc_urls_num INT,
    lang_num INT,
    vpp_lic BOOLEAN
);

select * from appstore;

create table app_desc(
    id SERIAL,
    track_name VARCHAR(255),
    size_bytes BIGINT,
    app_desc TEXT
);

select * from app_desc;


-- **EXPLORATORY DATA ANALYSIS** 

-- Checking Unique apps in both tables 

select count(distinct id) from appstore;

select count(distinct id) from app_desc;

-- Checking Null values in the columns 


select count(*) as missing_count
from app_desc
where  app_desc  is null;


-- Find out the number of apps per genre
select 
prime_genre,
count(id) as count 
from appstore
group by prime_genre
order by count desc;

-- Get an overview of apps user rating
select 
    min(user_rating) as min_rating ,
    round(avg(user_rating),2) as avg_rating,
    max(user_rating) as max_rating
from appstore;

-- Overview of Content Rating
select 
cont_rating,
count(cont_rating) as num
from appstore
group by cont_rating
order by num desc;


----DATA ANALYSIS----

-- Does paid apps have higher ratings than free apps ?

select case 
when price > '0' then 'Paid'
else 'Free'
end as App_type,
round(avg(user_rating),2) as avg_ratings
from appstore
group by App_type;


--- Does Apps with more supported languages have higher ratings?

select case
when lang_num < '10' then '< 10 Languages'
when lang_num between '10' and '30' then 'Between 10 - 30'
when lang_num > '30' then '>30 Languages'
end as bracket_of_lang,
round(avg(user_rating),2) as avg_rating
from appstore
group by bracket_of_lang;

-- Which Genre has the lowest ratings?
select 
prime_genre,
round(avg(user_rating),2) as avg_ratings 
from appstore
group by prime_genre
order by avg_ratings asc
limit 10;


--- Is there a correlation between the length of app description and user ratings?

select avg(length(app_desc)) from app_desc;



with cte as (
select
user_rating,
app_desc
from appstore as s
left join app_desc as d
on s.id = d.id
)
select case
when length(app_desc) <500 then 'Short Desc'
when length(app_desc) between 500 and 1000 then 'Medium Desc'
else 'Long Desc'
end as desc_words_count,
round(avg(user_rating),1) as avg_ratings
from cte
group by desc_words_count;


-- what are the top rated apps for each genre?

select prime_genre,
user_rating,
track_name,
rating_count_tot

from 

(
select prime_genre,
user_rating,
track_name,
rating_count_tot,
dense_rank() over (partition by prime_genre order by user_rating desc,  rating_count_tot desc) as best_apps
from appstore
)

where best_apps = 1;




--- Final Recommendation

-- 1) Paid apps have slightly higher avg user ratings than the free apps.

-- 2) Apps supporting between 10 - 30 Languages have higher rating than apps with more than 30 Languages . 
--    This indicates that number of language support isn't a factor for an app to be more used . Focusing on the 
--    right set of language support will do.

-- 3) Finance Book Navigation Lifestyle News Sports Social Networking Food & Drink Entertainment These categories
--    of apps has very low avg ratings . This means that the user needs are not fully met . Developers of these apps 
--    should work in improving the quality of the app to work their way back into the market.

-- 4) People tend to be more happy with the apps that offers long description as this allows the users to know more
--    about the app before downloading and using it.

-- 5) The Games genre has the most number of applications . So entering into this space could be more challenging 
--    also indicating a very high demand in this sector.

-- 6) Developer should aim for more than the avg rating of 3.5  to get success . 
