DROP TABLE IF EXISTS games_part;


-- +tbl from loaded data with casted rows
--     don`t include all colums
CREATE TABLE games_part as
    select
        app_id,
        replace(raw.name, '"', '') as game_name,
        strptime(replace(raw.release_date, '"', ''), '%b %d, %Y')::date as releas_date,
        raw.required_age::int as required_age,
        raw.price::double as price,
        raw.windows::bool as on_wind,
        raw.mac::bool as on_mac,
        raw.linux::bool as on_linux,
        raw.recommendations::int as num_recommens,
        raw.developers::varchar[] as developers,                        --nested
        raw.supported_languages::varchar[] as supported_languages,               --nested
        raw.categories::varchar[]  as categories,                        --nested
        raw.genres::varchar[]  as genres,                            --nested
        raw.user_score::double as user_score,
        raw.average_playtime_forever::double as avg_playtime_min
    FROM games;


select *
from games_part
limit 5;


-- top-3 games by user_score per category
-- unnest + window func
select category,
       game_name,
       user_score,
       row_number() over(partition by category order by user_score desc) as rank
from games_part,
     unnest(categories) as t(category)
qualify rank <=3;

-- genres by avg_playtime_min
-- unnest + group by
select genre,
       round(avg(avg_playtime_min), 2) as avg_of_avg_playtime_min
from games_part,
     unnest(genres) as t(genre)
group by genre
order by avg_of_avg_playtime_min desc;

-- diff in price with avg by platform
-- window func
select game_name,
       price,
       case when on_linux and on_wind and on_mac then 'all'
            when on_linux and on_wind then 'Windows + Linux'
            when on_wind and on_mac then 'Windows + Mac'
           when on_wind then 'Windows'
           else 'Other' end as platform_gr,
       round(avg(price) over(partition by platform_gr), 2) as avg_price_platform_gr,
        round(price - avg(price) over(partition by platform_gr), 2) as price_diff_from_avg
from games_part
order by price_diff_from_avg desc;







