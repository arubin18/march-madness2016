rm(list=ls())

source("~/march_madness/get_matchups.R")
source("~/march_madness/mean_centering.R")
source("~/march_madness/get_winners.R")

round3_winners <- read_csv("~/march_madness/datasets/round3_winners.csv")
matchups <- read_csv("~/march_madness/datasets/round4.csv") # training data
schedule4 <- read.csv("~/march_madness/datasets/round4_schedule.csv") # round 4 schedule 

round4 <- get_matchups(schedule4, round3_winners, matchups)

matchups$seed_dif = matchups$opp_seed - matchups$seed

matchups.c = mean_centering(matchups)

reg = glm(won~dppp + opp_dppp + ppp + opp_ppp + win_percent + opp_win_percent
          + ts + opp_ts + seed_dif + points_allowed + opp_points_allowed
          , data=matchups.c, family=binomial)
summary(reg)

reg1 = stepAIC(reg,direction="both",k=log(dim(matchups.c)[1]))
summary(reg1)

roc(matchups$won, fitted(reg1), plot=T, legacy.axes=T) 

reg2 = update(reg1, ~. + opp_ast + ft_percent + or)
summary(reg2)

anova(reg1, reg2, test="Chisq") # group of variables are significant 

roc(matchups$won, fitted(reg2), plot=T, legacy.axes=T) # predicting power improved a lot

rawresid2 = matchups$won - fitted(reg2)

binnedplot(x=matchups.c$opp_points_allowed,y=rawresid2) # consider quadtratic or cubic transformation 
binnedplot(x=matchups.c$opp_ast,y=rawresid2) # consider quadtratic transformation
binnedplot(x=matchups.c$ft_percent,y=rawresid2) # consider quadtratic or cubic transformation 
binnedplot(x=matchups.c$or,y=rawresid2) # consider quadtratic or cubic transformation

matchups$opp_points_allowed2 = (matchups$opp_points_allowed)^2
matchups$opp_points_allowed3 = (matchups$opp_points_allowed)^3
matchups$opp_ast2 = (matchups$opp_ast)^2
matchups$ft_percent2 = (matchups$ft_percent)^2
matchups$ft_percent3 = (matchups$ft_percent)^3
matchups$or2 = (matchups$or)^2
matchups$or3 = (matchups$or)^3

matchups.c = mean_centering(matchups)

reg3 = update(reg2, ~. + or3)
summary(reg3)

# transformations increased p-values for most predictors

summary(reg2)

reg4 = update(reg2, ~. - opp_ast)
summary(reg4) # made other p-values more significant 

anova(reg2, reg4, test="Chisq") # opp ast is not significant to the model

# use reg4
roc(matchups$won, fitted(reg4), plot=T, legacy.axes=T) # lowered predictive power a little
# may have been overfitting before

vif(reg4) # looks good

### predictions

round4.c = mean_centering(round4, FALSE, TRUE)

### predictions

predictions = predict(reg4, round4.c, type="response")
labels = round(predictions)

round4P <- round4
round4P$won <- labels

write.csv(round4P, "~/march_madness/datasets/round4_predictions.csv", row.names=FALSE)

winners <- get_winners(round4P)
write.csv(winners, "~/march_madness/datasets/round4_winners.csv", row.names=FALSE)


