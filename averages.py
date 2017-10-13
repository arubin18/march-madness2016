""" Calculates the season averages for every team and then exports an array
with these calculations into a txt file. Run with Python 3. """

import numpy as np
np.set_printoptions(suppress=True)

# matchups and results from regular season games from all seasons 
data = np.genfromtxt("RegularSeasonDetailedResults.csv", dtype=str, delimiter=",")

teams = {} # holds every team’s season stats for a particular season 


season = data[0,0] # starting season
length = 19

team_stats = np.ones((1, length))

def update_stats(season, teams, team, info):
	""" Adds matchup results to the season totals.
	Returns the updated dictionary. """

	if team not in teams:
		teams[team] = np.zeros(length)
		teams[team][0] = int(season)
		teams[team][1] = int(team)
		teams[team] += info

	else:
		teams[team] += info # array addition 

	return teams

for i in range(0,len(data)):


	# if there is a new season 
	# Gets season averages for all the teams of the previous season 
	if season != data[i,0]:

		season = data[i,0] # update the season 

		for i in teams:
			for j in range(3,len(teams[i])-2): # get averages
				teams[i][j] = teams[i][j] / float(teams[i][2])
			teams[i][len(teams[i])-1] = teams[i][len(teams[i])-1] / float(teams[i][2])

			team_stats = np.vstack((team_stats, np.array(teams[i])))

		teams = {} # erases everything inside of the dictionary 

		continue 

	team1 = data[i,2]
	score1 = int(data[i,3])
	fgm1 = int(data[i,8])
	fga1 = int(data[i,9])
	fgm31 = int(data[i,10])
	fga31 = int(data[i,11])
	ftm1 = int(data[i,12])
	fta1 = int(data[i,13])
	or1 = int(data[i,14])
	dr1 = int(data[i,15])
	ast1 = int(data[i,16])
	to1 = int(data[i,17])
	stl1 = int(data[i,18])
	blk1 = int(data[i,19])
	pf1 = int(data[i,20])
	points_allowed1 = int(data[i,5])

	info = [0, 0, 1, score1, fgm1, fga1, fgm31, fga31, ftm1, fta1, or1, dr1, ast1, to1, stl1, blk1, pf1,1, points_allowed1]

	# gets the matchup results from one game and updates the teams dictionary 
	teams = update_stats(season, teams, team1, np.array(info))

	team2 = data[i,4]
	score2 = int(data[i,5])
	fgm2 = int(data[i,21])
	fga2 = int(data[i,22])
	fgm32 = int(data[i,23])
	fga32 = int(data[i,24])
	ftm2 = int(data[i,25])
	fta2 = int(data[i,26])
	or2 = int(data[i,27])
	dr2 = int(data[i,28])
	ast2 = int(data[i,29])
	to2 = int(data[i,30])
	stl2 = int(data[i,31])
	blk2 = int(data[i,32])
	pf2 = int(data[i,33])
	points_allowed2 = int(data[i,3])

	info = [0, 0, 1, score2, fgm2, fga2, fgm32, fga32, ftm2, fta2, or2, dr2, ast2, to2, stl2, blk2, pf2,0, points_allowed2]

	teams = update_stats(season, teams, team2, np.array(info))

# dividing stat totals by games to get averages and append the arrays together 
for i in teams:
	for j in range(3,len(teams[i])-2): # get averages
		teams[i][j] = teams[i][j] / float(teams[i][2])
	teams[i][len(teams[i])-1] = teams[i][len(teams[i])-1] / float(teams[i][2])

	team_stats = np.vstack((team_stats, np.array(teams[i])))

team_stats = np.delete(team_stats, 0, 0) # delete first row of ones

np.savetxt("team_stats.csv", team_stats, delimiter=",", fmt="%s") # export regular season team info
