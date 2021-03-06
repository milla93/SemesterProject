function video_processing(video_name, output_name, orient, reply)
%video_processing Summary of this function goes here
%   Detailed explanation goes here

MAX_LAYER = 2;
DECAY_MAX = 5;
INTENSITY_THRES =65;

initialization();
vidObj = VideoReader(video_name);
vidObj2 = VideoWriter(output_name);

open(vidObj2);

% Specify that reading should start at 0.5 seconds from the
% beginning.
eps = 0.032;
vidObj.CurrentTime = 2;
old_dt = vidObj.CurrentTime-eps;

% Create an axes

n = 0;

if(orient == 'hori')
    init_pos =  [vidObj.Width - 10;vidObj.Height/2];
elseif(orient == 'vert')
    init_pos =  [vidObj.Width/2; 10];
end

robot = struct('pos',init_pos,...
               'vel',[0;0],...
               'vel_desired',[0;0],...
               'acc',0,...
               'B',[],...
               'F',zeros(2,2),...
               'b_dot', [],...
               'Error',[],...
               'B_log', [0;0]);

centroid = struct('pos',{zeros(2,2)},...
                  'nbr',0,...
                  'old_nbr',0,...
                  'a_filt',0.3);

layer = struct('pos',NaN(MAX_LAYER,MAX_LAYER,740),...
               'old_pos',zeros(2,2),...
               'nbr',0,...
               'decay',-1*ones(MAX_LAYER,1),...
               'vel',{zeros(2,2)},...
               'alpha_pos',0.3,...
               'alpha_vel',0.3,...
               'v_norm',2,...
               'out_ws',false(MAX_LAYER,1));

time = struct('im_proc',0,...
              'dynamic_out',0,...
              'dynamic_in',0);


iter = 1;
currAxes = axes;
t = datetime('now');
time_str = datestr(t,'yyyymmddTHHMMSS');
cleanupObj = onCleanup(@() cleanMeUp(vidObj2,time_str));

%%
while hasFrame(vidObj)
    
    
    iter = iter + 1;

    dt = vidObj.CurrentTime - old_dt;
    old_dt = vidObj.CurrentTime;
    vidFrame = readFrame(vidObj);

    %Image processing
    time.im_proc = tic;
    centroid.pos = image_processing(vidFrame, INTENSITY_THRES, currAxes);
    time.im_proc = toc(time.im_proc);
    plot(robot.pos(1),robot.pos(2), 'xk', 'LineWidth', 10)
    hold on
    
    centroid.nbr = size(centroid.pos,2);
    if(centroid.nbr)
        time.dynamic_out = tic;
        [centroid,layer,robot, t_inner]= dynamical_processing(centroid,layer,robot,iter,MAX_LAYER,DECAY_MAX,dt,vidObj);
        time.dynamic_in = t_inner;
        time.dynamic_out = toc(time.dynamic_out);
    end

    hold off;
    pause(1/vidObj.FrameRate);
    
    display_data(robot,centroid,layer,iter,time);
    
    currFrame = getframe(figure(1));
    writeVideo(vidObj2,currFrame);
    writeVideo(vidObj2,currFrame);
    writeVideo(vidObj2,currFrame);
    writeVideo(vidObj2,currFrame);
    
    if(reply == 'y' || reply == 'Y')
        save(strcat(time_str,'test.mat'));
    end
    
end
close(vidObj2);


end

function cleanMeUp(vidObj,time_str)
        % saves data to file (or could save to workspace)
        fprintf('saving video to file...\n');
        close(vidObj);
        
end
