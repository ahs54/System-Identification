clear all 
clc

%% Import the data


%% Modeling
clearvars

model = idpoly([1 -0.8],[0 0.2],[1 0.7]);
u = randn(1000,1);
w = randn(1000,1);
y = sim(model,[u w]);
dat = iddata(y,u);
h=1;
vec_aic = 50*ones(1,64);
vec_fpe = 50*ones(1,64);

for k=1:4
    for j=1:4
        for i=1:4
            g = armax(dat,[i j k 1]);
            vec_aic(h) = aic(g);
            vec_fpe(h) = fpe(g);        
            if  min(vec_fpe)  <= vec_fpe(h)
                opt_order = [i j k];
                FPE = min(vec_fpe);
                AIC = vec_aic(h);
            end 
            h=h+1;
        end
    end 
         
end
figure;plot(vec_aic);grid on;title('AIC')
figure;plot(vec_fpe);grid on;title('FPE') 
% [FPE, ind] = min(vec_fpe);
% [AIC, n] = min(vec_aic);