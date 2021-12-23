function t_rec = generate_t_rec(t_o,new_loc,x_antenna,y_antenna,sd,c)

t_true = t_o + sqrt((x_antenna-new_loc(1)).^2 + (y_antenna-new_loc(2)).^2)/c;    

N = length(x_antenna); w = sd*randn(1,N);

t_rec = t_true + w; %the corrupted times at the recorders

end