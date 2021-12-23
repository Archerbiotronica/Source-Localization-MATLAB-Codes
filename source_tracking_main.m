clear all; close all;

c = 300; %speed of signal(m/s)
v = 30; %speed of source(m/s)
del_t = 5; %time interval between sending the signals 
sq_lim = 1000; %display limit of the grid at the begining 

%locations of antenna, length = N(min=3)
x_antenna = [-2500,-1000,1000,2000,3000,5000]; y_antenna = [1000,-1000,2500,-2500,-2000,0];

total_points = 20;
x_act = zeros(1,total_points); y_act = zeros(1,total_points); %array storing actual positions
x_est = zeros(1,total_points); y_est = zeros(1,total_points); %array storing estimated positions

%% Defining the Covariance matrix used in the BLUE(Best Linear Unbiased Estimator)  
sd = 0.01;

N = length(x_antenna);
C = 2*(sd^2)*ones(N-1,N-1);%covariance matrix, to be chosen as per knowledge of the noise
for ind_i = 1:(N-1)
for ind_j = 1:(N-1)
if abs(ind_j-ind_i) == 1
C(ind_i,ind_j) = -sd^2;
end
end
end

%% Loop for estimation at every time point when the signal is received

x_est(1) = x_act(1); y_est(1) = y_act(1); %we have knowledge of the starting position

for time_step = 2:total_points

[x_click,y_click] = ginput(1);%decides the direction of source, (0.5,0.5) is the centre  
x_dir = x_click - 0.5; y_dir = y_click - 0.5;
dir = [x_dir,y_dir]/sqrt(x_dir^2 + y_dir^2); %the mouse-click decides the direction(unit vector) of movement

x_act(time_step) = x_act(time_step-1)+dir(1)*v*del_t; 
y_act(time_step) = y_act(time_step-1)+dir(2)*v*del_t; %new location using past location and input directions

new_loc = [x_act(time_step),y_act(time_step)];

t_rec = generate_t_rec(time_step,new_loc,x_antenna,y_antenna,sd,c);

new_loc_est = pred_new_loc(x_antenna,y_antenna,[x_est(time_step-1),y_est(time_step-1)],t_rec,c,C);
x_est(time_step) = new_loc_est(1); y_est(time_step) = new_loc_est(2); 

%Plotting the estimated and the actual locations in the figure
plot(x_act(1:total_points),y_act(1:total_points),'gx','LineWidth',3); hold on; 
plot(x_est(1:total_points),y_est(1:total_points),'bo','LineWidth',3); 
xlim([-sq_lim,sq_lim]); ylim([-sq_lim,sq_lim]); axis equal;
hold off;

end

%Final plot showing actual and estimated trajectories
plot(x_est,y_est,'bo-',LineWidth = 2,MarkerSize = 10); hold on;
plot(x_act,y_act,'gx-',LineWidth = 2,MarkerSize = 10);
scatter(x_antenna,y_antenna,'rd','filled')

legend('Estimated Positions','Actual Positions','Antennas');


%% Analyzing the errors
x_errors = x_est - x_act;
y_errors = y_est - y_act;

var_x = var(x_errors); var_y = var(y_errors);
SD_x = sqrt(var_x); SD_y = sqrt(var_y);
cov_xy = cov([x_errors;y_errors]');


plt_ylim = max(sqrt(x_errors.^2 + y_errors.^2));
t = 0:del_t:((total_points-1)*del_t);
figure;
subplot(3,1,1); plot(t,x_errors,'cp--',LineWidth=3); grid on;
ylim([-plt_ylim,plt_ylim]);
ylabel("Errors in x co-ordinate"); xlabel("Time in seconds");

subplot(3,1,2); plot(t,y_errors,'mp--',LineWidth=3); grid on;
ylim([-plt_ylim,plt_ylim]);
ylabel("Errors in y co-ordinate"); xlabel("Time in seconds");

subplot(3,1,3); plot(t,sqrt(x_errors.^2 + y_errors.^2),'kd--',LineWidth=3); grid on;
ylim([-plt_ylim,plt_ylim]);
ylabel("Magitude of the errors"); xlabel("Time in seconds");

disp("Standard deviation of estimated x-location error is: "); disp(SD_x);
disp("Standard deviation of estimated y-location error is: "); disp(SD_y);
disp("Covariance matrix of errors in x-location and y-location is: "); disp(cov_xy);
