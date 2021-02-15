# ros-texas

This repo contains the ROS packages and files need to run automatic localization with a LIDAR + RPi set.

# Packages in catkin/src/
* my_carto
  * Custom Cartographer configuration and launch file examples for A1 lidar + RPI
* my_pure_loc
  * Custom package runing Map Server, Laser Scan Matcher and AMCL + some configuration and examples
* save_poses
  * Example of a package that subscribes to a current topic
* scan_tools
  * Package needed to run AMCL
    
# Matlab

* process_bag_amcl_pose.m
  * This script processes the ROS .bag files saved containing the /amcl_pose topic. Will return the best (in terms of covar) X, Y and timestamp found within the .bag. Also, outputs a tag.txt file compatible with AoA TI tool.

# Other

* chrony_commands
  * Containes chrony coomands to force time sync. between machines. A time offset between the node and the master will result in localization failure or errors.
* magick
  * ImageMagick is a free and open-source cross-platform software suite for displaying, creating, converting, modifying, and editing raster images. Useful for converting .png (etc.) map images to .pgm format used by ROS and the Map Server package.
