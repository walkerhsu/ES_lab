import matplotlib.pyplot as plt
import numpy as np
import ast

def low_pass_filter_moving_average(data, window_size:int):
    if window_size < 1:
        raise ValueError("Window size must be at least 1")
    return np.array([
        np.sum(data[i:i + window_size]) / window_size
        for i in range(len(data) - window_size + 1)
    ])

sample_rate = 10
fig, ax = plt.subplots(6, 1, sharex=True, figsize=(8, 6))

data = []
with open("Angular_velocity_y.txt") as file:
    for xyz in file.readlines():
        d = ast.literal_eval(xyz)
        data.append(d)
        
# print(data)
data = np.array(data)
x, y, z, sample_delay, ing = data[:,0], data[:,1], data[:,2], data[:,3], data[:,4]
# x = low_pass_filter_moving_average(x, window_size=5)
# y = low_pass_filter_moving_average(y, window_size=5)
# z = low_pass_filter_moving_average(z, window_size=5)

# print(x, y, z, sep='\n')

xx = []
count_time = 0
for delay in sample_delay:
    count_time += delay / 1000
    xx.append(count_time)
    
ax[0].plot(xx, x, 'r', label="x")
ax[0].legend()
ax[0].set_title("Shared X-axis Example")

ax[1].plot(xx, y, 'b', label="y")
ax[1].legend()

ax[2].plot(xx, z, 'g', label="z")
ax[2].legend()

ang_speed = np.sign(z) *np.sqrt(y**2 + z**2)
ax[3].plot(xx, ang_speed, 'y', label="w_yz")
ax[3].legend()

sum, ing_raw = data[0, 4], []
for i in range(len(x)):
    sample_rate = 1000 / sample_delay[i]
    sum += np.sign(z[i]) * np.sqrt(max(y[i]**2 + z[i]**2 - x[i]**2 * 0.6, 0)) / sample_rate
    ing_raw.append(sum)

# ing_x = np.arange(len(ing_raw))

ax[4].plot(xx, ing_raw, 'y', label="Angle")
ax[4].legend()

# ing = low_pass_filter_moving_average(ing, window_size=5)

smallcal = 0.9
largecal = 1.1

drink_alert = False
is_drinking = False
finish_drinking = False
drink_alert_counter = 0
is_drinking_counter = 0
finish_counter = 0
water_intake = 0
drink_time_start = []
drink_time_end = []
drinking_results = []

# ing = list()
ing_x = []

# True algorithm
for i in range(len(x)):
    sample_rate = 1000 / sample_delay[i-1] if i>0 else 10
    if i > 0:
        ing_raw[i] = np.sign(z[i]) * np.sqrt(max(y[i]**2 + z[i]**2 - x[i]**2 * 0.6, 0)) / sample_rate + ing_raw[i-1]
    if i < 4:
        cur_ing = low_pass_filter_moving_average(ing_raw[:i+1], window_size=i+1)[0]
    else:
        cur_ing = low_pass_filter_moving_average(ing_raw[i-4:i+1], window_size=5)[0]
        
    # print(cur_ing)
    
    # detect drinking incident
    if np.abs(ang_speed[i]) > 50 and not is_drinking and not finish_drinking:
        drink_alert = True
        drink_alert_counter = 0
    
    # start drinking
    if drink_alert:
        drink_alert_counter += 1
        if np.abs(ing[i]) > 60:
            drink_time_start.append(xx[i])
            drink_alert = False
            is_drinking = True
            drink_alert_counter = 0 
    
    # delete alert
    if drink_alert_counter > 2 * sample_rate and not is_drinking: # didn't drink in 1 sec
        drink_alert = False
        
    # remove drink-too-long incident (written in stm32 already)
        
    # record drinking amount of water
    if is_drinking:
        # map to corresponding drinking rate
        drink_rate = 0 if np.abs(ing[i]) < 65 else \
                    3 * smallcal if np.abs(ing[i]) < 70 else \
                    6 * smallcal if np.abs(ing[i]) < 75 else \
                    8 * smallcal if np.abs(ing[i]) < 80 else \
                    12 * smallcal if np.abs(ing[i]) < 100 else \
                    15 * smallcal if np.abs(ing[i]) < 110 else \
                    18 * largecal if np.abs(ing[i]) < 120 else \
                    23 * largecal if np.abs(ing[i]) < 130 else 30 * largecal
                    # 24 if np.abs(ing[i]) < 130 else 30
        
        water_intake += (1 / sample_rate) * drink_rate
        # print(drink_rate)
        # np.sum([(end - start) * 15 for end, start in zip(drink_time_end, drink_time_start)])
        
        
        # print(is_drinking_counter, sample_rate, ing[i])
        if is_drinking_counter >= 10 * sample_rate:
            print(xx[i])
            is_drinking = False
            is_drinking_counter = 0
            water_intake = 0
        
        is_drinking_counter += 1
        # print(is_drinking_counter)
    
    # detect finishing incident
    if is_drinking and np.abs(ing[i]) < 55:
        # print(xx[i])
        if is_drinking_counter >= 0.8 * sample_rate and water_intake > 5:
            finish_drinking = True
            drinking_results.append(water_intake)
            drink_time_end.append(xx[i])
            water_intake = 0
        else:
            drink_time_start = drink_time_start[:-1]
        
        # print(ing[i])
        is_drinking = False
        is_drinking_counter = 0
    
    # correction for smoothing bottle angle
    if finish_drinking:
        finish_counter += 1
        if finish_counter > 1* sample_rate:
            finish_counter = 0
            finish_drinking = False
    
    # clip abnormal incidents
    if not drink_alert and not is_drinking and not finish_drinking and abs(ing[i]) > 12:
        ing_raw[i] = np.sign(ing_raw[i]) * 0

    # ing.append(cur_ing)

ing = np.array(ing)
# ing_x = np.arange(len(ing))
ax[5].plot(xx, ing, 'y', label="filtered")
ax[5].legend()


print("Drinking time start: ", [round(x, 2) for x in drink_time_start])
print("Drinking time end: ", [round(x, 2) for x in drink_time_end])
print("Drink amount: ", [round(x, 2) for x in drinking_results])
print("Water intake: {:.2f}".format(np.sum(drinking_results)))

plt.tight_layout()
plt.savefig("test.png")
plt.show()