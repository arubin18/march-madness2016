""" Created a outcome variable for the data frame and added each team's
seed. Exports new matchup array into a txt file. Run with Python 3. """

import numpy as np
import re
np.set_printoptions(suppress=True)

data_seeds = np.genfromtxt("TourneySeeds.csv", dtype=str, delimiter=",") # seed of tournament teams for every season

seeds = {}

for i in range(len(data_seeds)):

	season = int(data_seeds[i,0])

	s = data_seeds[i,1]
	seed = int(re.sub("[^0-9]", "", s)) # remove non numeric chars

	team = int(data_seeds[i,2]) # team identifier 
	index = season*team # special identifier 
	seeds[index] = seed # seed of that team for that season 

results = np.genfromtxt("tourney_games.csv", dtype=float, delimiter=",") # tournament matchups 

n = results.shape[1]

results = np.append(results, np.zeros([len(results),3]),1)

n = results.shape[1]

for i in range(len(results)):
	year = int(results[i,0])
	w_team = int(results[i,2])
	l_team = int(results[i,20])

	w_wins = int(results[i,18])
	l_wins = int(results[i,37])

	w_index = year*w_team
	l_index = year*l_team

	w_seed = seeds[w_index]
	l_seed = seeds[l_index]

	results[i,n-3] = w_seed
	results[i,n-2] = l_seed

	# winning team has higher seed
	if w_seed < l_seed:
		results[i,n-1] = '1'

	# seeds are equal 
	elif w_seed == l_seed:

		# winning team has more season wins 
		if w_wins > l_wins:
			results[i,n-1] = '1'

		# losing team has more than or equal to the number of wins as the winning team 
		else:
			results[i,n-1] = '0'

	# losing team has largest seed and the winning team has smaller seed (upset)
	else:
		results[i,n-1] = '0'

print (results[0])

np.savetxt("results.csv", results, delimiter=",", fmt="%s") # export matchups with seeds and outcome variable 
