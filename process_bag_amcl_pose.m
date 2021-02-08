function [bestX, bestY, bestCovXX, bestCovYY, bestTime] = process_bag_amcl_pose(bagName, offsetX, offsetY)
%Summary of this function goes here
% Returns best (in terms of covar) X, Y, their covariance and timestamp
% found in the given .bag file
% https://es.mathworks.com/help/ros/ug/work-with-rosbag-logfiles.html
% Usage: 
% bagName = '2021-01-20-13-14-11.bag';
% [x, y, covX, covY, t] = process_bag_amcl_pose(bagName);
% Human-readable time: datetime(t, 'ConvertFrom','posixtime')
% OFFsets are needed to Transform AMCL coordinates to AoA tool coordinates
    
    %% load 
    bag = rosbag(bagName);

    % show topics recorded
    %bag.AvailableTopics

    % time
    %timeStart = bag.StartTime;  % encoded as a Unix Timestamp or epoch
    %datetime(timeStart, 'ConvertFrom','posixtime')
    %timeSec = bag.EndTime - timeStart;

    % get target topic 
    bagPOSE = select(bag, 'Topic', '/amcl_pose');

    % get all messages published in the topic
    msgs = readMessages(bagPOSE);

    % init best estimations
    bestX = 0;
    bestY = 0;
    bestCovXX = 9999.9;
    bestCovYY = 9999.9;
    bestTime = 0;

    %% for each message
    for msgId = 1:length(msgs)
        %msgId = 1;

        % /amcl_pose publishes PoseWithCovariance messages
        % http://docs.ros.org/en/melodic/api/geometry_msgs/html/msg/PoseWithCovariance.html
        %msgs{id_msg}.showdetails

        % XYZ position
        x = msgs{msgId}.Pose.Pose.Position.X;
        y = msgs{msgId}.Pose.Pose.Position.Y;
        %z = msgs{msgId}.Pose.Pose.Position.Z;

        % Quaternion XYZW orientation:
        %msgs{msgId}.Pose.Pose.Orientation

        % Covariance:
        % 36x1 array Row-major representation of the 6x6 covariance matrix
        % The orientation parameters use a fixed-axis representation.
        % In order, the parameters are:
        % (x, y, z, rotation about X axis, rotation about Y axis, rotation about Z axis)
        cov = msgs{msgId}.Pose.Covariance;   
        cov = reshape(cov,[6, 6]);

        covXX = cov(1, 1);
        %cov_xy = cov(1, 2);
        %cov_yx = cov(2, 1);
        covYY = cov(2, 2);
        %covRotZZ = cov(end);

        % get timestamp of msg
        t = msgs{msgId}.Header.Stamp;
        secondTime = double(t.Sec) + double(t.Nsec) * 10^-9;
        %time = datetime(secondTime, 'ConvertFrom','posixtime');

        if covXX <= bestCovXX && covYY <= bestCovYY
           bestX = x;
           bestY = y;
           bestCovXX = covXX;
           bestCovYY = covYY;
           bestTime = secondTime;
           %msgId
        end
    end
    %% similarly, we can use timeseries objects of matlab
    %ts = timeseries(bag_pose, 'Pose.Pose.Position.X', 'Pose.Pose.Position.Y');
    %ts.Data
    %figure
    %plot(ts, 'LineWidth', 3)
    
    %% Transform AMCL coordinates to AoA tool coordinates
    bestX = bestX + offsetX;
    bestY = bestY + offsetY;

    %% save .csv
    % tagName,x,y,z,t
    formatSpec = '%s,%.3f,%.3f,%.3f,%f\n';
    tagName = 'tagLIDAR';
    bestZ = 0.0;
    
    fid = fopen('tag.txt','w');
    fprintf(fid, formatSpec, tagName, bestX, bestY, bestZ, bestTime);
    fclose(fid);   

end

