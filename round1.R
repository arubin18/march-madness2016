library(arm)
library(pROC)

rm(list=ls())

source("~/march_madness/get_winners.R")
source("~/march_madness/mean_centering.R")

library(readr)
matchups <- read_csv("~/march_madness/datasets/round1.csv") # training data
round1 <- read_csv("~/march_madness/datasets/round1_test.csv") # testing data

### correlation matrix c

test_correlations <- matchups
test_correlations$team <- NULL
test_correlations$opp_team <- NULL

cor_relation <- round(cor(test_correlations), digits=3)
cor_relation[abs(cor_relation) < 0.70] <- NA
write.csv(cor_relation, "~/march_madness/datasets/correlations.csv")

### notable correlations:
# efg and ts are very correlated 
# efg is correlated with fg percent, fg3 percent, ppp
# ts is correlated with fg percent, fg3 percent, ppp
# win percent is very correlated with wins 
# ppg is correlated with possessions per game, total points, fga, fgm
# opp points allowed is correlated with opp ppg

matchups$seed_dif = matchups$opp_seed - matchups$seed

matchups.c <- mean_centering(matchups)

reg = glm(won~dppp + opp_dppp + ppp + opp_ppp + win_percent + opp_win_percent
          + ts + opp_ts + seed_dif + points_allowed + opp_points_allowed
          , data=matchups.c, family=binomial)
summary(reg)

### too much multicolinearity and need a more simplistic model 
reg1 = stepAIC(reg,direction="both",k=log(dim(matchups.c)[1]))

roc(matchups$won, fitted(reg1), plot=T, legacy.axes=T)

summary(reg1)

reg2 = update(reg1, ~. + opp_ppp + dppp)
summary(reg2)

anova(reg1, reg2, test="Chisq") # addition of both terms are not significant 

reg3 = update(reg1, ~. + total_possessions)
summary(reg3)

anova(reg1, reg3, test="Chisq") # variable is very significant

rawresid3 = matchups$won - fitted(reg3)

# use reg3

roc(matchups$won, fitted(reg3), plot=T, legacy.axes=T) # predictive power increased

# none of the interaction terms have significant p-values
reg4 = glm(won~seed_dif * (opp_dppp + ppp + ts + total_possessions), data=matchups.c, family=binomial)
summary(reg4)

anova(reg3, reg4, test="Chisq") # interaction terms as a whole are not significant 

binnedplot(x=matchups.c$seed_dif, y=rawresid3) # consider quadtratic transformation or cubic 
binnedplot(x=matchups.c$opp_dppp, y=rawresid3) # consider cubic transformation
binnedplot(x=matchups.c$ppp, y=rawresid3)
binnedplot(x=matchups.c$ts, y=rawresid3)
binnedplot(x=matchups.c$total_possessions, y=rawresid3)

matchups$seed_dif2 = (matchups$seed_dif)^2

matchups.c = mean_centering(matchups)

reg5 = glm(won~seed_dif + seed_dif2 + opp_dppp + ppp + ts + total_possessions
           , data=matchups.c, family=binomial)
summary(reg5) # lowered p-values for other terms 

rawresid5 = matchups$won - fitted(reg5)

roc(matchups$won, fitted(reg5), plot=T, legacy.axes=T) # slightly increased predictive power

binnedplot(x=matchups.c$seed_dif2, y=rawresid5) # residuals look much better
binnedplot(x=matchups.c$opp_dppp, y=rawresid5) # consider cubic transformation

# use reg5

matchups$opp_dppp3 = (matchups$opp_dppp)^3

matchups.c = mean_centering(matchups)

reg6 = glm(won~seed_dif + seed_dif2 + opp_dppp + opp_dppp3 + ppp + ts + total_possessions
           , data=matchups.c, family=binomial)
summary(reg6) 

roc(matchups$won, fitted(reg6), plot=T, legacy.axes=T) # increased predictive power

rawresid6 = matchups$won - fitted(reg6)

binnedplot(x=matchups.c$seed_dif, y=rawresid5)
binnedplot(x=matchups.c$opp_dppp, y=rawresid6) # residuals look better

library("car")

vif(reg6) # a lot of variance inflation of opp dpp 3

vif(reg3)

threshold = 0.5
table(matchups$won, reg6$fitted > threshold) # many false positives

round1$seed_dif = round1$opp_seed - round1$seed
round1$seed_dif2 = (round1$seed_dif)^2
round1$opp_dppp3 = (round1$opp_dppp)^3

round1.c = mean_centering(round1, FALSE, TRUE)

### predictions

predictions = predict(reg6, round1.c, type="response")
labels = round(predictions)

round1P <- round1
round1P$won <- labels

write.csv(round1P, "~/march_madness/datasets/round1_predictions.csv", row.names=FALSE)

winners <- get_winners(round1P)
write.csv(winners, "~/march_madness/datasets/round1_winners.csv", row.names=FALSE)
