omega=ones(100, 1);
marginefase=ones(100, 1);

for w=1:40
    cost=0;

    while true
    cost=cost+0.1;
    num=[1/((w)*10^(-cost)), 1];
    den=[1/((w)*10^(cost)), 1];
    R2=tf(num, den);
    
    for mu=1:20
        
        R1=tf(mu, 1);
        R=series(R1, R2);
        L2=series(R, G);
        F=feedback(L2, 1);
        ys=r_fin*step(F, t);
        y_inf=r_fin*ones(size(t));
        Info=lsiminfo(ys, t);
        Ta_reale=Info.SettlingTime;
        S_reale=(Info.Max-r_fin)/r_fin;
        
        if (Ta_reale<Ta && S_reale<S && allmargin(L2).PhaseMargin>60)
            break
        end
    end
    if (Ta_reale<Ta && S_reale<S && allmargin(L2).PhaseMargin>60)
            break
    end
end
 omega(w, 1)=cost;
 marginefase(w, 1)=allmargin(L2).PhaseMargin;
 
end

[min_cost, w_omega]=min(omega);
[max_fase, w_fase]=max(marginefase);


