import numpy as np

results = np.genfromtxt("results.csv", dtype=str, delimiter=",")

round1 = [137, 137]
round2 = [138, 139]
round3 = [143, 144]
round4 = [145, 146]
round5 = [152]
round6 = [154]

n = results.shape[1]

rnd = np.ones((1, n))

for i in range(len(results)):

	day_num = int(results[i,1])
	
	if day_num in round6:
		rnd = np.vstack((rnd, results[i]))

rnd = np.delete(rnd, 0, 0) # delete first row of ones

print (rnd)

np.savetxt("round6.csv", rnd, delimiter=",", fmt="%s")

