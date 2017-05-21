rm(list=ls())

source("~/march_madness/get_matchups.R")
source("~/march_madness/mean_centering.R")
source("~/march_madness/get_winners.R")

round5_winners <- read_csv("~/march_madness/datasets/round5_winners.csv")
matchups <- read_csv("~/march_madness/datasets/round6.csv") # training data
schedule6 <- read.csv("~/march_madness/datasets/round6_schedule.csv") # round 6 schedule

test_correlations <- matchups
test_correlations$team <- NULL
test_correlations$opp_team <- NULL

cor_relation <- round(cor(test_correlations), digits=3)
cor_relation[abs(cor_relation) < 0.70] <- NA

round6 <- get_matchups(schedule6, round5_winners, matchups)

matchups$seed_dif = matchups$opp_seed - matchups$seed

matchups.c = mean_centering(matchups, TRUE, TRUE)

reg1 = glm(won~opp_ppp, data=matchups.c, family=binomial)
summary(reg1)

roc(matchups$won, fitted(reg1), plot=T, legacy.axes=T)

# opp total possessions

reg2 = update(reg1, ~. + opp_total_possessions)
summary(reg2) # p value for opp ppp lowered 

anova(reg1, reg2, test="Chisq") # additional term is not siginficant

# use reg1

rawresid1 = matchups$won - fitted(reg1)

binnedplot(x=matchups.c$opp_dppp, y=rawresid1) # many of the residuals are outside the bands

### predictions

predictions = predict(reg1, round6, type="response")
labels = round(predictions)

round6P <- round6
round6P$won <- labels

write.csv(round6P, "~/march_madness/datasets/round6_predictions.csv", row.names=FALSE)

winners <- get_winners(round6P)
write.csv(winners, "~/march_madness/datasets/round6_winners.csv", row.names=FALSE)



