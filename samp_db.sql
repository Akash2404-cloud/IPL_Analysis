-- Active: 1660496305748@@127.0.0.1@3306@samp_db
select * from `ipl matches 2008-2020`;

select * from `ipl_ball_by_ball`;

-- matches played every season
select distinct(year(date)) as season , count(*) as total_matches from `ipl matches 2008-2020` group by season ;
select distinct(cast(date as year)) as season , count(*) as total_matches from `ipl matches 2008-2020` group by season ;


-- number of teams participated
select year(date) as Season , count(distinct(team1)) as Teams_count from `ipl matches 2008-2020` group by Season; 


--Total matches played by teams
with tb1 as 
(select year(date) as Season , team1 as Home_team , count(*) as Home_matches from `ipl matches 2008-2020`
group by Season , Home_team order by Season , Home_matches desc),
tb2 as 
(select year(date) as Season , team2 as Away_team , count(*) as Away_matches from `ipl matches 2008-2020`
group by Season , Away_team order by Season , Away_matches desc)
select tb1.Season , Home_team as Team , tb1.Home_matches , tb2.Away_matches , 
(tb1.Home_matches + tb2.Away_matches) as Total_matches 
from tb1 join tb2 on tb1.Season = tb2.Season and 
tb1.Home_team = tb2.Away_team order by Season , Total_matches desc;


--most man of the matches
select year(date) as Season , player_of_match , count(*) as total_count from `ipl matches 2008-2020` group by player_of_match order by total_count desc;

--  top 5 venues
select venue as Venue , count(*) as Total_count from `ipl matches 2008-2020` group by venue order by Total_count desc limit 5;

-- top 5 scorer in ipl history
select batsman , sum(batsman_runs) as runs from `ipl_ball_by_ball` group by batsman order by runs desc limit 5;

--Total wins by each of the teams  
select year(date) as season , winner , count(*) as Total_wins from `ipl matches 2008-2020` group by season , winner order by season , Total_wins desc ; 

--Most sixes by the batsman
select batsman , count(*) as Total_6s from 
(select * from `ipl_ball_by_ball` where batsman_runs = 6) 
tb1 group by batsman order by Total_6s desc limit 10;


--Top 10 batsman with most runs
select batsman , sum(batsman_runs) as Total_runs 
from `ipl_ball_by_ball` group by batsman order by `total_runs` DESC limit 10; 


--Top 10 bowlers with most wickets
select bowler , count(*) as Total_wickets from 
(select * from `ipl_ball_by_ball` where is_wicket = 1) tb1 
group by bowler order by Total_wickets desc limit 10;


--Runs of a Player in every season 
delimiter $
drop procedure if exists runs_all_season;
create procedure runs_all_season(player varchar(255))
BEGIN
   declare plyr varchar(255);
   set plyr = player;
   select cast(date as year) as season , sum(`batsman_runs`) as runs_in_season
   from `ipl_ball_by_ball` tb1 join `ipl matches 2008-2020` tb2 on 
   tb1.id = tb2.id where batsman = plyr group by season; 
end $
delimiter ;

call `runs_all_season`('RV Uthappa');


--Percentage of matches won in case of chase 
select (count(*) * 100) / (select count(*) from `ipl matches 2008-2020`)  as Chase_win_percentage
from `ipl matches 2008-2020` where toss_decision = 'field' and winner = team1;


-- Count of matches decided by D/L rule in seasons
select year(date) as season , count(*) from `ipl matches 2008-2020` 
where method = 'D/L' group by season;

--Orange cap per season
with tb1 as 
(select cast(date as year) as season , batsman , sum(batsman_runs) as totalRuns 
from `ipl_ball_by_ball` tb1 join `ipl matches 2008-2020` tb2 on tb1.id = tb2.id
group by season , batsman order by totalRuns desc),
tb2 as
(select * , rank() over(partition by season order by totalRuns desc) as rnk
from tb1)
select season , batsman , totalRuns from tb2 where rnk = 1;

-- Purple cap per season
with tb1 as 
(select cast(date as year) as season , bowler , sum(is_wicket) as total_wickets 
from `ipl_ball_by_ball` tb1 join `ipl matches 2008-2020` tb2 on tb1.id = tb2.id
where not `dismissal_kind` in ('retired hurt' , 'stumped' , 'hit wicket' ,'obstructing the field') 
group by season , bowler order by total_wickets desc),
tb2 as
(select * , rank() over(partition by season order by total_wickets desc) as rnk
from tb1)
select season , bowler , total_wickets from tb2 where rnk = 1;


SELECT * FROM `ipl matches 2008-2020`;

SELECT * FROM `ipl_ball_by_ball`;

