rm(list=ls())

source("~/march_madness/mean_centering.R")
source("~/march_madness/arrange.R")

library(readr)
data <- read_csv("~/march_madness/results.csv")
teams <- read_csv("~/march_madness/teams.csv")

for (i in 1:nrow(data)) {
  
  data$team[i] = teams[teams$Team_Id == toString(data$team[i]),]$Team_Name
  data$opp_team[i] = teams[teams$Team_Id == toString(data$opp_team[i]),]$Team_Name
  
}

data$rpg = data$or + data$dr # rebounds per game
data$opp_rpg = data$opp_or + data$opp_dr

data$fg_percent = 100*data$fgm / data$fga # field goal percentage
data$opp_fg_percent = 100*data$opp_fgm / data$opp_fga

data$ft_percent = 100*data$ftm / data$fta # free throw percentage
data$opp_ft_percent = 100*data$opp_ftm / data$opp_fta 

data$fg3_percent = 100*data$fgm3 / data$fga3 # three point percentage
data$opp_fg3_percent = 100*data$opp_fgm3 / data$opp_fga3

### offensive efficiency 
data$total_possessions = data$games * (data$fga - data$or + data$to + 0.44*data$fta) # total possessions
data$total_points = data$games * data$ppg # total points 
data$ppp = data$total_points / data$total_possessions # points scored by possession

data$opp_total_possessions = data$opp_games * (data$opp_fga - data$opp_or + data$opp_to + 0.44*data$opp_fta)
data$opp_total_points = data$opp_games * data$opp_ppg
data$opp_ppp = data$opp_total_points / data$opp_total_possessions

### defensive efficiency 
data$total_points_allowed = data$games * data$points_allowed # total points allowed
data$dppp = data$total_points_allowed / data$total_possessions # points allowed by possession

data$opp_total_points_allowed = data$games * data$opp_points_allowed
data$opp_dppp = data$opp_total_points_allowed / data$opp_total_possessions

### effective field goal percentage
data$efg = 100*(data$fgm + 0.5*data$fgm3) / data$fga
data$opp_efg = 100*(data$opp_fgm + 0.5*data$opp_fgm3) / data$opp_fga

### true shooting percentage
data$ts = 100*0.5*data$ppg / (data$fga + 0.44*data$fta)
data$opp_ts = 100*0.5*data$opp_ppg / (data$opp_fga + 0.44*data$opp_fta)

### win percentage
data$win_percent = 100*(data$wins / data$games)
data$opp_win_percent = 100*(data$opp_wins / data$opp_games)

### possessions per game
data$possessions_per_game = data$total_possessions / data$games
data$opp_possessions_per_game = data$opp_total_possessions / data$opp_games

attach(data)
### organize the data
data2 <- data.frame(data[,1:3], seed, data[,4:20], rpg, fg_percent, ft_percent, fg3_percent, total_possessions
                    , total_points, ppp, total_points_allowed, dppp, efg, ts, win_percent
                    , possessions_per_game, opp_team, opp_seed, data[,22:38]
                    , opp_rpg, opp_fg_percent, opp_ft_percent, opp_fg3_percent, opp_total_possessions
                    , opp_total_points, opp_ppp, opp_total_points_allowed, opp_dppp, opp_efg
                    , opp_ts, opp_win_percent, opp_possessions_per_game, won)

### exporting data
matchups = data2[data2$season != 2016,] # training data
matchups <- arrange(matchups)

testing = data2[data2$season == 2016,] # what we're going to predict = testing data
write.csv(testing, "~/march_madness/datasets/testing_data.csv", row.names=FALSE)

testing <- arrange(testing)

testing_labels = testing$won
testing$won <- NULL # remove labels

# rounds for the tournament
# round 1 is the only round for testing data
round1 = matchups[matchups$daynum == 136 | matchups$daynum == 137,]
round1$daynum <- NULL
round1.c = mean_centering(round1)
round1_test = testing[testing$daynum == 136 | testing$daynum == 137,]
round1_test$daynum <- NULL
round1_test.c = mean_centering(round1_test, response = FALSE, one_year = TRUE)
write.csv(round1, "~/march_madness/datasets/round1.csv", row.names=FALSE)
write.csv(round1.c, "~/march_madness/datasets/round1_cent.csv", row.names=FALSE)
write.csv(round1_test, "~/march_madness/datasets/round1_test.csv", row.names=FALSE)
write.csv(round1_test.c, "~/march_madness/datasets/round1_test_cent.csv", row.names=FALSE)

round2 = matchups[matchups$daynum == 138 | matchups$daynum == 139,]
round2$daynum <- NULL
round2.c = mean_centering(round2)
write.csv(round2, "~/march_madness/datasets/round2.csv", row.names=FALSE)
write.csv(round2.c, "~/march_madness/datasets/round2_cent.csv", row.names=FALSE)

round3 = matchups[matchups$daynum == 143 | matchups$daynum == 144,]
round3$daynum <- NULL
round3.c = mean_centering(round3)
write.csv(round3, "~/march_madness/datasets/round3.csv", row.names=FALSE)
write.csv(round3.c, "~/march_madness/datasets/round3_cent.csv", row.names=FALSE)

round4 = matchups[matchups$daynum == 145 | matchups$daynum == 146,]
round4$daynum <- NULL
round4.c = mean_centering(round4)
write.csv(round4, "~/march_madness/datasets/round4.csv", row.names=FALSE)
write.csv(round4.c, "~/march_madness/datasets/round4_cent.csv", row.names=FALSE)

round5 = matchups[matchups$daynum == 152,]
round5$daynum <- NULL
round5.c = mean_centering(round5)
write.csv(round5, "~/march_madness/datasets/round5.csv", row.names=FALSE)
write.csv(round5.c, "~/march_madness/datasets/round5_cent.csv", row.names=FALSE)

round6 = matchups[matchups$daynum == 154,]
round6$daynum <- NULL
round6.c = mean_centering(round6)
write.csv(round6, "~/march_madness/datasets/round6.csv", row.names=FALSE)
write.csv(round6.c, "~/march_madness/datasets/round6_cent.csv", row.names=FALSE)

