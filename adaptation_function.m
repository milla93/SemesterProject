function [robot,layer] = adaptation_function(robot,layer,epsilon,dt,iter)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
DS_task = @(x)  0.1*[-10 0; 0 -10] * x;
DS_robot = @(x) 0.1*[-10 0; 0 -10] * x;

F_ident = zeros(2,layer.nbr);
b_dot_tilde = zeros(1,layer.nbr);
robot.B = ones(1,layer.nbr)/layer.nbr;

for i = 1:layer.nbr
    F_ident(:,i) = DS_robot(layer.pos(:,i,iter)-robot.pos);
    
%     b_dot_tilde(i) =  epsilon*(layer.vel(:,i)'*F_ident(:,i));
    b_dot_tilde(i) =  -epsilon*norm(F_ident(:,i)-layer.vel(:,i) );

end

b_dot = winner_takes_all(b_dot_tilde, robot, layer.nbr);
robot.b_dot(:,end+1) = b_dot;

robot.B = robot.B + dt*b_dot;

robot.B_log(:,end+1) = robot.B;


for i = 1:layer.nbr
    if (robot.B(i) > 1), robot.B(i) = 1;
    elseif (robot.B(i) < 0), robot.B(i) = 0;
    end 
end
    

robot.F = DS_task(robot.pos - layer.pos(:,1,iter));

robot.F = robot.F + layer.vel;

robot.vel_desired = sum(robot.B.*robot.F , 2);

% p1 = robot.vel'*layer.vel(:,1);
%     p2 = robot.vel'*layer.vel(:,2);
%     
%     p1_plus = max(0,p1);
%     p1_minus = min(0,p1);
%     
%     p2_plus = max(0,p2);
%     p2_minus = min(0,p2);
%     
%     adapt_error_1 = p1_minus;
%     adapt_error_2 = p2_minus;
%     adapt_error_3 = max(-robot.B(1)*p1_plus, -robot.B(2)*p2_plus);
%     adapt_error = robot.B(1).*adapt_error_1 + robot.B(2).*adapt_error_2 + ...
%                   robot.B(3).*adapt_error_3;
%     pos_err_1 = norm(robot.pos - layer.pos(:,1,iter));
%     pos_err_2 = norm(robot.pos - layer.pos(:,2,iter));
%     adapt_error_1 = (robot.vel'*layer.vel(:,1) + pos_err_1);
%     adapt_error_2 = (robot.vel'*layer.vel(:,2) + pos_err_2);
%     adapt_error = robot.B(1).*adapt_error_1 + robot.B(2).*adapt_error_2;

%     robot.Error(end+1,:) = [adapt_error_1, adapt_error_2,adapt_error_3,...
%                             adapt_error];
%     
%     term1 = robot.vel'*(layer.vel(:,1) - layer.vel(:,2));
%     term2 =  (robot.B(1)*layer.vel(:,1) + robot.B(2)*layer.vel(:,2))'*...
%              (robot.F(:,1) - robot.F(:,2)) ;
% 
% %     b1_dot = - epsilon * (term1 + term2 + term3);
%     b1_dot = - epsilon * (term1 + term2)
%     robot.B(1) = robot.B(1) + b1_dot .* dt;
%     robot.b1_dot(end+1) = b1_dot;
%     if(robot.B(1)>1),robot.B(1)=1;end
%     if(robot.B(1)<0),robot.B(1)=0;end
% 
%     %should take into account the case with only one centroid
% %     if(layer.nbr==1)
% %         robot.B(1)=1;
% %     end
%     robot.B(2) = 1-robot.B(1);
%     robot.B_log(:,end+1) = [robot.B(1); robot.B(2)];
%     
%     robot.vel_desired = robot.B(1).*robot.F(:,1) + robot.B(2).*robot.F(:,2);
% 
%     % robot's movement
%     F_control = -1 * D .* (robot.vel-robot.vel_desired);
%     robot.acc = (1/M) * (F_control);
%     robot.vel = robot.vel + robot.acc.*dt;
%     robot.pos   = robot.pos   + robot.vel.*dt;
% 
%     % limiting movements to workspace
%     robot.pos = Lim_ws(robot.pos);
end

