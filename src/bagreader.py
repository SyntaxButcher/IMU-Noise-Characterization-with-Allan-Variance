import bagpy
from bagpy import bagreader 
import rosbag
import pandas as pd

bag = bagreader('/home/shak/catkin_ws/src/lab3/rosbag/fiveHour.bag')

readings = bag.message_by_topic('/IMU_data')
print(readings)
