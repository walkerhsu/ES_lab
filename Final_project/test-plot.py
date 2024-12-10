import matplotlib.pyplot as plt
import numpy as np
import ast

fig, ax = plt.subplots(5, 1, sharex=True, figsize=(8, 6))

data = []
with open("Angular_velocity_y.txt") as file:
    for xyz in file.readlines():
        d = ast.literal_eval(xyz)
        data.append(d)
        
print(data)
data = np.array(data)
x, y, z = data[:,0], data[:,1], data[:,2]
print(x, y, z, sep='\n')

xx = range(len(data))
ax[0].plot(xx, x, 'r', label="x")
ax[0].legend()
ax[0].set_title("Shared X-axis Example")

ax[1].plot(xx, y, 'b', label="y")
ax[1].legend()

ax[2].plot(xx, z, 'g', label="z")
ax[2].legend()

ax[3].plot(xx, y/np.abs(y)*np.sqrt(y**2 + z**2), 'y', label="yz")
ax[3].legend()

sum, ing = 0, []
for i in xx:
    sum += y[i]/np.abs(y[i])*np.sqrt(y[i]**2 + z[i]**2)
    ing.append(sum)

ax[4].plot(xx, ing, 'y', label="yz")
ax[4].legend()

plt.tight_layout()
plt.savefig("test.png")
plt.show()