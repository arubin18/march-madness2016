rm(list=ls())

source("~/march_madness/get_matchups.R")
source("~/march_madness/mean_centering.R")
source("~/march_madness/get_winners.R")

library(data.table)

round1_winners <- read.csv("~/march_madness/datasets/round1_winners.csv")
matchups <- read.csv("~/march_madness/datasets/round2.csv") # training data
schedule2 <- read.csv("~/march_madness/datasets/round2_schedule.csv") # round 2 schedule 

round2 <- get_matchups(schedule2, round1_winners, matchups)
round2.c = mean_centering(round2, response = FALSE, one_year = TRUE)

matchups$seed_dif = matchups$opp_seed - matchups$seed
matchups$seed_dif2 = (matchups$seed_dif)^2
matchups$opp_dppp3 = (matchups$opp_dppp)^3

matchups.c <- mean_centering(matchups)

reg1 = glm(won~seed_dif + opp_dppp + ppp + ts + total_possessions, data=matchups.c, family=binomial)
summary(reg1) 

reg2 = update(reg1, ~. - ppp - ts - total_possessions)

summary(reg2)

rawresid2 = matchups$won - fitted(reg2)

anova(reg1, reg2, test="Chisq") # those three predictors are not significant 

reg3 = update(reg2, ~. + opp_ppp)
summary(reg3)

binnedplot(x=matchups.c$opp_dppp,y=rawresid2) # consider quadtratic or cubic transformation

binnedplot(x=matchups.c$seed_dif,y=rawresid2) # consider quadtratic or cubic transformation

matchups$log_seed_dif = log(matchups$seed_dif)
matchups$seed_dif3 = (matchups$seed_dif)^3
matchups$opp_dppp2 = (matchups$opp_dppp)^2

matchups.c = mean_centering(matchups)

reg4 = update(reg2, ~. + opp_dppp2 + seed_dif3)
summary(reg4)

rawresid4 = matchups$won - fitted(reg4)

binnedplot(x=matchups.c$opp_dppp,y=rawresid4) # better
binnedplot(x=matchups.c$seed_dif,y=rawresid4) # looks good

roc(matchups$won, fitted(reg4), plot=T, legacy.axes=T)

reg5 = update(reg4, ~. + opp_ppp)
summary(reg5) # other p-values also decreased

anova(reg4, reg5, test="Chisq") # term is significant

roc(matchups$won, fitted(reg5), plot=T, legacy.axes=T) # predicting power improved

rawresid5 = matchups$won - fitted(reg5)

binnedplot(x=matchups.c$opp_ppp,y=rawresid5) # residuals look good

round2$seed_dif = round2$opp_seed - round2$seed
round2$seed_dif2 = (round2$seed_dif)^2
round2$seed_dif3 = (round2$seed_dif)^3
round2$opp_dppp2 = (round2$opp_dppp)^2

round2.c = mean_centering(round2, FALSE, TRUE)

### predictions

predictions = predict(reg5, round2.c, type="response")
labels = round(predictions)

round2P <- round2
round2P$won <- labels

write.csv(round2P, "~/march_madness/datasets/round2_predictions.csv", row.names=FALSE)

winners <- get_winners(round2P)
write.csv(winners, "~/march_madness/datasets/round2_winners.csv", row.names=FALSE)
