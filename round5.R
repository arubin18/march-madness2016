rm(list=ls())

source("~/march_madness/get_matchups.R")
source("~/march_madness/mean_centering.R")
source("~/march_madness/get_winners.R")

round4_winners <- read_csv("~/march_madness/datasets/round4_winners.csv")
matchups <- read_csv("~/march_madness/datasets/round5.csv") # training data
schedule5 <- read.csv("~/march_madness/datasets/round5_schedule.csv") # round 5 schedule 

round5 <- get_matchups(schedule5, round4_winners, matchups)

matchups.c = mean_centering(matchups)

reg1 = glm(won~opp_points_allowed + ft_percent + or, data=matchups.c, family=binomial)
summary(reg1) # only or has a significant p-value

reg2 = glm(won~or,data=matchups.c, family=binomial)
summary(reg2)

roc(matchups$won, fitted(reg2), plot=T, legacy.axes=T)

anova(reg1, reg2, test="Chisq") # two other predictors are not significant 

reg3 = update(reg2, ~. + opp_pf)
summary(reg3)

anova(reg3, reg2, test="Chisq") # term is nearly singificant 

roc(matchups$won, fitted(reg3), plot=T, legacy.axes=T) # predicting power improved a lot

rawresid3 = matchups$won - fitted(reg3)

binnedplot(x=matchups.c$or, y=rawresid3) # residuals look periodical
# consider transformation or note serial correlation 

binnedplot(x=matchups.c$opp_pf, y=rawresid3) # residuals look ok

matchups$or2 = (matchups$or)^2
matchups$log_opp_pf = log(matchups$opp_pf)
matchups$opp_pf2 = (matchups$opp_pf)^2

matchups.c = mean_centering(matchups)

reg4 = glm(won ~ or + or2 + opp_pf, data=matchups.c, family=binomial)
summary(reg4) # p values for other predictors inflated

rawresid4 = matchups$won - fitted(reg4)

binnedplot(x=matchups.c$or, y=rawresid4) # residuals look the same
binnedplot(x=matchups.c$opp_pf, y=rawresid4) # residuals look the same

roc(matchups$won, fitted(reg3), plot=T, legacy.axes=T) # predictive power has not increased

# stay with reg 3 - no transformations were sucessful

vif(reg3) # looks good

### predictions

round5.c = mean_centering(round5, FALSE, TRUE)

predictions = predict(reg3, round5.c, type="response")
labels = round(predictions)

round5P <- round5
round5P$won <- labels

write.csv(round5P, "~/march_madness/datasets/round5_predictions.csv", row.names=FALSE)

winners <- get_winners(round5P)
write.csv(winners, "~/march_madness/datasets/round5_winners.csv", row.names=FALSE)

