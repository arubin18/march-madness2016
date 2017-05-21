import numpy as np
np.set_printoptions(suppress=True)

data = np.genfromtxt("team_stats.csv", dtype=float, delimiter=",")

stats = {}

for i in range(len(data)):

	season = int(data[i,0])
	team = int(data[i,1])

	index = season*team

	stats[index] = data[i,2:].tolist()

games = np.genfromtxt("TourneyDetailedResults.csv", dtype=str, delimiter=",")

new_games = np.ones((1, 38))

for i in range(len(games)):
	season = int(games[i,0])
	daynum = int(games[i,1])
	Wteam = int(games[i,2])

	game = [season, daynum, Wteam]
	game += stats[season*Wteam] # concatenating lists 

	Lteam = int(games[i,4])
	game.append(Lteam)
	game += stats[season*Lteam]

	new_games = np.vstack((new_games, np.array(game)))

new_games = np.delete(new_games, 0, 0) # delete first row of ones

np.savetxt("tourney_games.csv", new_games, delimiter=",", fmt="%s")
