import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from collections import deque
import numpy as np

# Create figure and axis
fig, ax = plt.subplots()
line, = ax.plot([], [], 'b-', label="Real-time Data")

# Set up the data storage with deque
MAX_POINTS = 100  # Keep only the last 100 points
x_data = deque(maxlen=MAX_POINTS)
y_data = deque(maxlen=MAX_POINTS)

# Set initial plot limits
ax.set_xlim(0, MAX_POINTS)
ax.set_ylim(-1.5, 1.5)
ax.set_title("Real-time Data Plot with Dynamic Deletion")
ax.set_xlabel("Time (s)")
ax.set_ylabel("Value")
ax.legend()

# Initialize the plot
def init():
    line.set_data([], [])
    return line,

# Update function
def update(frame):
    # Append new data
    x_data.append(frame * 0.1)
    y_data.append(np.sin(frame * 0.1))
    
    # Dynamically adjust x-axis limits to show only recent data
    ax.set_xlim(max(0, x_data[0]), x_data[-1] + 1)
    
    line.set_data(x_data, y_data)
    return line,

# Animation
ani = FuncAnimation(fig, update, frames=np.arange(0, 10000), init_func=init, blit=True, interval=50)

plt.show()
