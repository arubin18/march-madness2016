""" Replaces each team's local stats with their season stats for every matchup. 
Exports new matchup array into a txt file. Run with Python 3. """

import numpy as np
np.set_printoptions(suppress=True)

data = np.genfromtxt("team_stats.csv", dtype=float, delimiter=",") # regular season results for every team 

stats = {} # holds team stats for each season 

for i in range(len(data)):

	season = int(data[i,0])
	team = int(data[i,1])

	index = season*team # special identifier for a team 

	stats[index] = data[i,2:].tolist() # season stats for regression

games = np.genfromtxt("TourneyDetailedResults.csv", dtype=str, delimiter=",") # tournament matchups with stats from that game 

new_games = np.ones((1, 38)) 

# iterate through tournament games 
for i in range(len(games)):

	# append winning team's info 
	season = int(games[i,0])
	daynum = int(games[i,1])
	Wteam = int(games[i,2])

	game = [season, daynum, Wteam]
	game += stats[season*Wteam] # concatenating lists with season stats

	# append losing team's info 
	Lteam = int(games[i,4])
	game.append(Lteam)
	game += stats[season*Lteam]

	new_games = np.vstack((new_games, np.array(game))) # append tournament matchup with info from both teams

new_games = np.delete(new_games, 0, 0) # delete first row of ones

np.savetxt("tourney_games.csv", new_games, delimiter=",", fmt="%s") # export tournament matchups 
