""" Created a response variable for the data frame and added each team's
seed. """

import numpy as np
import re

data_seeds = np.genfromtxt("TourneySeeds.csv", dtype=str, delimiter=",")

seeds = {}

for i in range(len(data_seeds)):
	year = int(data_seeds[i,0])

	s = data_seeds[i,1]
	seed = int(re.sub("[^0-9]", "", s)) # remove non numeric chars

	team = int(data_seeds[i,2])
	index = year*team
	seeds[index] = seed

results = np.genfromtxt("tourney_games.csv", dtype=float, delimiter=",")

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

	if w_seed < l_seed:
		results[i,n-1] = '1' # winning team has higher seed

	elif w_seed == l_seed:

		if w_wins > l_wins:
			results[i,n-1] = '1'
		else:
			results[i,n-1] = '0'

	else:
		results[i,n-1] = '0' # losing team has largest seed or upset

round1 = np.genfromtxt("tourney_games.csv", dtype=str, delimiter=",")

np.savetxt("results.csv", results, delimiter=",", fmt="%s")
