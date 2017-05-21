mean_centering <- function(data, response=TRUE, one_year=FALSE) {
  
  center_scale <- function(x) {
    scale(x, scale = FALSE)
  }
  
  data.c <- data
  
  if (response) { 
    data.c$won <- NULL # there is a response variable 
  }
  
  m = nrow(data.c)
  n = ncol(data.c)
  
  data.c$team = as.numeric(rep(1, m))
  data.c$opp_team = as.numeric(rep(1,m))
  data.c$seed = as.numeric(rep(1,m))
  data.c$opp_seed = as.numeric(rep(1,m))
  
  
  # more than one season 
  if (! one_year) {
    
    years = unique(matchups$season)
    
    s = data.c[0,] # column names
    
    for (i in 1:length(years)) {
      
      test = data.c[data.c$season==years[i],]
      cs = center_scale(test[,4:n])
      test = cbind(test[,1:3], cs)
      s = rbindlist(list(s, test))
      
    }
    
    data.c = s
  } 
  
  else {
    cs = center_scale(data.c[,4:n])
    data.c = cbind(data.c[,1:3], cs)
  }
  
  data.c$team = data$team
  data.c$opp_team = data$opp_team
  data.c$seed = data$seed
  data.c$opp_seed = data$opp_seed

  
  if (response) {
    r = data$won # response 
    data.c$won = r
    return (data.c)
  } else {
    return (data.c)
  }
  
}