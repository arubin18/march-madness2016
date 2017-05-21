library(data.table)

get_winners <- function(data) {
  
  winners <- data[0,2:33]
  
  for (i in 1:nrow(data)) {
    response = data$won[i]
    team1 = data[i,2:33]
    team2 = data[i,34:65]
    
    seed1 = data$seed[i] # seed of team 1
    seed2 = data$opp_seed[i] # seed of team 2
    
    if (response == 1) { # higher seeded team won or team with most wins won
      if (seed1 < seed2) {
        # team with seed1 won
        winners = rbindlist(list(winners,team1))
      }
      
      else if (seed1 > seed2) {
        # team with seed2 won
        winners = rbindlist(list(winners,team2))
      } 
      
      else { # seeds are equal
        wins1 = data$wins[i]
        wins2 = data$opp_wins[i]
        
        if (wins1 > wins2) {
          # team with wins1 won
          winners = rbindlist(list(winners,team1))
        }
        
        else if (wins1 < wins2) {
          # team with wins2 won
          winners = rbindlist(list(winners,team2))
        }
        
        else {
          # teams with wins1 won
          winners = rbindlist(list(winners,team1))
        }
        
      }
      
    }
    
    else { # lower seeded team won or team with least wins
      if (seed1 < seed2) { 
        # team with seed2 won
        winners = rbindlist(list(winners,team2))
      }
      
      else if (seed1 > seed2) {
        # team with seed1 won
        winners = rbindlist(list(winners,team1))
      }
      
      else { # teams have equal seeds
        
        if (wins1 > wins2) {
          # team with wins2 won
          winners = rbindlist(list(winners,team2))
        }
        
        else if (wins1 < wins2) {
          # team with wins1 won
          winners = rbindlist(list(winners,team1))
        }
        
        else {
          # team with wins1 won
          winners = rbindlist(list(winners,team1))
        }
        
      }
      
    }
  }
  
  year = data[,1]
  
  return (cbind(year,winners))
  
}