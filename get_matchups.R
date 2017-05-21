library(data.table)

get_matchups <- function(schedule, winners, training) {
  
  testing <- training[0,][1:ncol(training)-1] # get the column names
  
  for (i in 1:nrow(schedule)) {
    name1 <- toString(schedule[i,1])
    name2 <- toString(schedule[i,2])
    
    team1 = winners[winners$team == name1,]
    
    if (nrow(team1) == 0) {
      print (name1)
    }
    
    team2 = winners[winners$team == name2,][2:ncol(winners)]
    
    if (nrow(team2) == 0) {
      print (name2)
    }
    
    m = cbind(team1, team2) # matchup
    testing = rbindlist(list(testing, m))
    
  }
  
  return (data.frame(testing))
  
}