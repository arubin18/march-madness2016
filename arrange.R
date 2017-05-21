### arranging data so that the higher seed is first

arrange <- function(data) {
  
  new_data <- data[0,]
  
  for (i in 1:nrow(data)) {
    seed1 = as.numeric(data$seed[i])
    seed2 = as.numeric(data$opp_seed[i])
    team1 = data[i,3:34]
    team2 = data[i,35:66]
    
    m = data[i,1:2] # matchup
    w = data$won[i] # won response 
    
    if (seed1 == seed2) {
      new_data <- rbindlist(list(new_data, data[i,]))
      next
    }
    
    else if (seed1 < seed2) {
      teams = cbind(team1, team2)
      m = cbind(m, teams)
      m = cbind(m, w)
    }
    
    else {
      teams = cbind(team2, team1)
      m = cbind(m, teams)
      m = cbind(m, w)
    }
    
    new_data <- rbindlist(list(new_data, m))
    
  }
  
  return (new_data)
  
}