function new_loc = pred_new_loc(x_antenna,y_antenna,old_loc,t_rec,c,C)

N = length(x_antenna);
x_start = old_loc(1); y_start = old_loc(2);

num_cos = x_start - x_antenna; num_sin =  y_start - y_antenna; 
R_start = sqrt((num_cos.^2)+(num_sin.^2));
cos_terms = num_cos./R_start; sin_terms = num_sin./R_start;

H = zeros(N-1,2); %assign the H matrix values
H(:,1) = cos_terms(2:N) - cos_terms(1:(N-1)); H(:,2) = sin_terms(2:N) - sin_terms(1:(N-1));  
H = H/c;

tau_rec = t_rec - R_start/c;
X = transpose(tau_rec(2:N) - tau_rec(1:(N-1)));%Observation(LHS) of the BLUE equation

%final estimation using the BLUE equation
del_blue = (inv(transpose(H)*inv(C)*H))*transpose(H)*inv(C)*X;

new_loc = old_loc + transpose(del_blue);

end