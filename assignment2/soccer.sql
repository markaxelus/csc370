/*
This part focuses on soccer analytics using SQL.

1. Data Setup
   - Import the provided CSV files:
       england.csv, france.csv, germany.csv, italy.csv
   - Use DataGrip to import the files and automatically create the tables.
   - The resulting tables will be named: England, France, Germany, and Italy.
   - Each table contains over 100 years of soccer game statistics.
   - When importing, carefully assign the correct datatypes for each column.

2. Tasks
   - Write SQL statements to answer the questions provided.
   - For each question, replace the placeholder text 
     ("Your query here") with your SQL query.

3. Submission
   - Submit this SQL file with your completed queries.
   - Submit one PDF file (soccer_viz.pdf) containing your visualizations for Questions 2, 7, 9, and 10.
     * Clearly label each visualization with the corresponding question number (e.g., Q2, Q7, Q9, Q10).
*/



/*Q1 (1 pt)
Find all the games in England between seasons 1920 and 1999 such that the total goals are at least 13.
Order by total goals descending.*/

SELECT *
FROM England
WHERE season BETWEEN 1920 AND 1999 AND totgoal >= 13
ORDER BY totgoal DESC;

/*Sample result
1935-12-26,1935,Tranmere Rovers,Oldham Athletic,13,4,3,17,9,H
1958-10-11,1958,Tottenham Hotspur,Everton,10,4,1,14,6,H
...*/


/*Q2 (2 pt)
For each total goal result, find how many games had that result.
Use the england table and consider only the seasons since 1980.
Order by total goal.*/

SELECT totgoal, COUNT(*) AS num_games
FROM England
WHERE season >= 1980
GROUP BY totgoal
ORDER BY totgoal;

/*Sample result
0,6085
1,14001
...*/

/*Visualize the results using a barchart.*/


/*Q3 (2 pt)
Find for each team in England in tier 1 the total number of games played since 1980.
Report only teams with at least 300 games.

Hint. Find the number of games each team has played as "home".
Find the number of games each team has played as "visitor".
Then union the two and take the sum of the number of games.
*/

SELECT team, SUM(games_played) AS total_games
FROM (
    SELECT home AS team, COUNT(*) AS games_played
    FROM England
    WHERE tier = 1 AND season >= 1980
    GROUP BY home
    UNION ALL
    SELECT visitor AS team, COUNT(*) AS games_played
    FROM England
    WHERE tier = 1 AND season >= 1980
    GROUP BY visitor
) AS all_games
GROUP BY team
HAVING SUM(games_played) >= 300
ORDER BY total_games DESC;

/*Sample result
Everton,1451
Liverpool,1451
...*/


/*Q4 (1 pt)
For each pair team1, team2 in England, in tier 1,
find the number of home-wins since 1980 of team1 versus team2.
Order the results by the number of home-wins in descending order.

Hint. After selecting the tuples needed (... WHERE tier=1 AND ...) do a GROUP BY home, visitor.
*/

SELECT home AS team1, visitor AS team2, COUNT(*) AS home_wins
FROM England
WHERE tier = 1 AND season >= 1980 AND result = 'H'
GROUP BY home, visitor
ORDER BY home_wins DESC;

/*Sample result
Manchester United,Tottenham Hotspur,27
Arsenal,Everton,26
...*/


/*Q5 (1 pt)
For each pair team1, team2 in England in tier 1
find the number of away-wins since 1980 of team1 versus team2.
Order the results by the number of away-wins in descending order.*/

SELECT visitor AS team1, home AS team2, COUNT(*) AS away_wins
FROM England
WHERE tier = 1 AND season >= 1980 AND result = 'A'
GROUP BY visitor, home
ORDER BY away_wins DESC;

/*Sample result
Manchester United,Aston Villa,18
Manchester United,Everton,17
...*/


/*Q6 (2 pt)
For each pair team1, team2 in England in tier 1 report the number of home-wins and away-wins
since 1980 of team1 versus team2.
Order the results by the number of away-wins in descending order.

Hint. Join the results of the two previous queries. To do that you can use those
queries as subqueries. Remove their ORDER BY clause when making them subqueries.
Be careful on the join conditions.
*/

SELECT
    hw.team1,
    hw.team2,
    hw.home_wins,
    aw.away_wins
FROM
    (SELECT home AS team1, visitor AS team2, COUNT(*) AS home_wins
     FROM England
     WHERE tier = 1 AND season >= 1980 AND result = 'H'
     GROUP BY home, visitor) AS hw
JOIN
    (SELECT visitor AS team1, home AS team2, COUNT(*) AS away_wins
     FROM England
     WHERE tier = 1 AND season >= 1980 AND result = 'A'
     GROUP BY visitor, home) AS aw
ON hw.team1 = aw.team1 AND hw.team2 = aw.team2
ORDER BY away_wins DESC;

/*Sample result
Manchester United,Aston Villa,26,18
Arsenal,Aston Villa,20,17
...*/

--Create a view, called Wins, with the query for the previous question.
CREATE VIEW Wins AS
SELECT
    hw.team1,
    hw.team2,
    hw.home_wins,
    aw.away_wins
FROM
    (SELECT home AS team1, visitor AS team2, COUNT(*) AS home_wins
     FROM England
     WHERE tier = 1 AND season >= 1980 AND result = 'H'
     GROUP BY home, visitor) AS hw
JOIN
    (SELECT visitor AS team1, home AS team2, COUNT(*) AS away_wins
     FROM England
     WHERE tier = 1 AND season >= 1980 AND result = 'A'
     GROUP BY visitor, home) AS aw
ON hw.team1 = aw.team1 AND hw.team2 = aw.team2;


/*Q7 (2 pt)
For each pair ('Arsenal', team2), report the number of home-wins and away-wins
of Arsenal versus team2 and the number of home-wins and away-wins of team2 versus Arsenal
(all since 1980).
Order the results by the second number of away-wins in descending order.
Use view W1.*/

-- Using view Wins created above; self-join to get both directions
SELECT
    a.team1 AS team1,
    a.team2 AS team2,
    a.home_wins AS arsenal_home_wins,
    a.away_wins AS arsenal_away_wins,
    b.home_wins AS opponent_home_wins,
    b.away_wins AS opponent_away_wins
FROM Wins a
JOIN Wins b
  ON a.team2 = b.team1 AND a.team1 = b.team2
WHERE a.team1 = 'Arsenal'
ORDER BY b.away_wins DESC;

/*Sample result
Arsenal,Liverpool,14,8,20,11
Arsenal,Manchester United,16,5,19,11
...*/

/*Drop view Wins.*/
DROP VIEW Wins;

/*Build two bar-charts, one visualizing the two home-wins columns, and the other visualizing the two away-wins columns.*/


/*Q8 (2 pt)
Winning at home is easier than winning as visitor.
Nevertheless, some teams have won more games as a visitor than when at home.
Find the team in Germany that has more away-wins than home-wins in total.
Print the team name, number of home-wins, and number of away-wins.*/

/*Your query here*/
SELECT
    team,
    home_wins,
    away_wins
FROM (
    SELECT
        COALESCE(h.team, a.team) AS team,
        COALESCE(h.home_wins, 0) AS home_wins,
        COALESCE(a.away_wins, 0) AS away_wins
    FROM
        (SELECT home AS team, COUNT(*) AS home_wins
         FROM Germany
         WHERE result = 'H'
         GROUP BY home) AS h
    FULL OUTER JOIN
        (SELECT visitor AS team, COUNT(*) AS away_wins
         FROM Germany
         WHERE result = 'A'
         GROUP BY visitor) AS a
    ON h.team = a.team
) AS team_wins
WHERE away_wins > home_wins;
/*Sample result
Wacker Burghausen	...	...*/


/*Q9 (3 pt)
One of the beliefs many people have about Italian soccer teams is that they play much more defense than offense.
Catenaccio or The Chain is a tactical system in football with a strong emphasis on defence.
In Italian, catenaccio means "door-bolt", which implies a highly organised and effective backline defence
focused on nullifying opponents' attacks and preventing goal-scoring opportunities.
In this question we would like to see whether the number of goals in Italy is on average smaller than in England.

Find the average total goals per season in England and Italy since the 1970 season.
The results should be (season, england_avg, italy_avg) triples, ordered by season.

Hint.
Subquery 1: Find the average total goals per season in England.
Subquery 2: Find the average total goals per season in Italy
   (there is no totgoal in table Italy. Take hgoal+vgoal).
Join the two subqueries on season.
*/

SELECT
    e.season,
    e.england_avg,
    i.italy_avg
FROM
    (SELECT season, AVG(totgoal) AS england_avg
     FROM England
     WHERE season >= 1970
     GROUP BY season) AS e
JOIN
    (SELECT season, AVG(hgoal + vgoal) AS italy_avg
     FROM Italy
     WHERE season >= 1970
     GROUP BY season) AS i
ON e.season = i.season
ORDER BY e.season;
--Build a line chart visualizing the results. What do you observe?

-- Observation: Since 1970, England's average total goals per match
-- are generally higher than Italy's. The gap varies by era and tends
-- to narrow in some later seasons, aligning with the defensive
-- reputation (catenaccio) associated with Italian football.

/*Sample result
1970,2.5290927021696252,2.1041666666666667
1971,2.5922090729783037,2.0125
...*/


/*Q10 (3 pt)
Find the number of games in France and England in tier 1 for each goal difference.
Return (goaldif, france_games, eng_games) triples, ordered by the goal difference.
Normalize the number of games returned dividing by the total number of games for the country in tier 1,
e.g. 1.0*COUNT(*)/(select count(*) from france where tier=1)  */

SELECT
    COALESCE(f.goaldif, e.goaldif) AS goaldif,
    COALESCE(f.france_games, 0) AS france_games,
    COALESCE(e.eng_games, 0) AS eng_games
FROM
    (SELECT goaldif, 1.0*COUNT(*)/(SELECT COUNT(*) FROM France WHERE tier=1) AS france_games
     FROM France
     WHERE tier = 1
     GROUP BY goaldif) AS f
FULL OUTER JOIN
    (SELECT goaldif, 1.0*COUNT(*)/(SELECT COUNT(*) FROM England WHERE tier=1) AS eng_games
     FROM England
     WHERE tier = 1
     GROUP BY goaldif) AS e
ON f.goaldif = e.goaldif
ORDER BY goaldif;
/*Sample result
-8,0.00011369234850494562,0.000062637018477920450987
-7,0.00011369234850494562,0.00010439503079653408
...*/

/*Visualize the results using a barchart.*/


/*Q11 (2 pt)
Find all the seasons when England had higher average total goals than France.
Consider only tier 1 for both countries.
Return (season,england_avg,france_avg) triples.
Order by season.*/

WITH e AS (
    SELECT season, AVG(totgoal) AS england_avg
    FROM England
    WHERE tier = 1
    GROUP BY season
), f AS (
    SELECT season, AVG(hgoal + vgoal) AS france_avg
    FROM France
    WHERE tier = 1
    GROUP BY season
)
SELECT e.season, e.england_avg, f.france_avg
FROM e
JOIN f ON e.season = f.season
WHERE e.england_avg > f.france_avg
ORDER BY e.season;

/*Sample result
1936,3.3658008658008658,3.3041666666666667
1952,3.2640692640692641,3.1437908496732026
...*/
