rm(list=ls())

source("~/march_madness/get_matchups.R")
source("~/march_madness/mean_centering.R")
source("~/march_madness/get_winners.R")

round2_winners <- read_csv("~/march_madness/datasets/round2_winners.csv")
matchups <- read_csv("~/march_madness/datasets/round3.csv") # training data
schedule3 <- read.csv("~/march_madness/datasets/round3_schedule.csv") # round 3 schedule 

round3 <- get_matchups(schedule3, round2_winners, matchups)

matchups$seed_dif = matchups$opp_seed - matchups$seed

matchups.c = mean_centering(matchups)

reg1 = glm(won~seed_dif + opp_dppp, data=matchups.c, family=binomial)
summary(reg1) 

reg2 = update(reg1, ~. + win_percent + opp_win_percent)
summary(reg2)

reg3 = update(reg1, ~. + win_percent)
summary(reg3)

rawresid3 = matchups$won - fitted(reg3)

binnedplot(x=matchups.c$win_percent,y=rawresid3)

anova(reg1, reg3, test="Chisq") # not significant 

roc(matchups$won, fitted(reg1), plot=T, legacy.axes=T) # predicting power improved

rawresid1 = matchups$won - fitted(reg1)

binnedplot(x=matchups.c$seed_dif, y=rawresid1) # consider log or quadtratic transformation

binnedplot(x=matchups.c$opp_dppp, y=rawresid1) # residuals look ok

matchups$log_seed_dif = log(matchups$seed_dif)
matchups$seed_dif2 = (matchups$seed_dif)^2

matchups.c = mean_centering(matchups)

reg4 = glm(won~log_seed_dif + opp_dppp, data=matchups.c, family=binomial)
summary(reg4) # lowered p-value for opp dppp

rawresid4 = matchups$won - fitted(reg4)

binnedplot(x=matchups.c$seed_dif, y=rawresid4) # a little better
binnedplot(x=matchups.c$opp_dppp, y=rawresid4) # # consider quadtratic transformation

roc(matchups$won, fitted(reg4), plot=T, legacy.axes=T) # not much predicting power improvement

matchups$opp_dppp2 = (matchups$opp_dppp)^2

matchups.c = mean_centering(matchups)

reg5 = glm(won~log_seed_dif + opp_dppp + opp_dppp2, data=matchups.c, family=binomial)
summary(reg5) # raised p-values

# go back to reg4

### predictions

round3$seed_dif = round3$opp_seed - round3$seed
round3$log_seed_dif = log(round3$seed_dif)

round3.c = mean_centering(round3, FALSE, TRUE)

predictions = predict(reg4, round3.c, type="response")
labels = round(predictions)

round3P <- round3
round3P$won <- labels

write.csv(round3P, "~/march_madness/datasets/round3_predictions.csv", row.names=FALSE)

winners <- get_winners(round3P)
write.csv(winners, "~/march_madness/datasets/round3_winners.csv", row.names=FALSE)

