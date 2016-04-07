function [p, L] = computeLikelihood(X, gmm, D, M)
    T = length(X);
    p = zeros(T, M);
    b = zeros(T, M);
    for t = 1:T
        weightedSum = 0;
        for m = 1:M
            deter = 1;
            sum = 0;
            for d = 1:D
                sum = sum - 0.5 * ((X(t, d) - gmm.means(d, m)) ^ 2) * (1 / gmm.cov(d, d, m));
                deter = deter * gmm.cov(d, d, m);
            end
            b(t, m) = exp(sum) / ((2 * pi) ^ (D / 2) * sqrt(abs(deter)));
            weightedSum = weightedSum + gmm.weights(1, m) * b(t, m);
        end
        for m = 1:M
            p(t, m) = (gmm.weights(1, m) * b(t, m)) / weightedSum;
        end
    end
    L = 0;
    for t = 1:T
        sub_L = 0;
        for m = 1:M
            sub_L = sub_L + p(t, m) * b(t, m);
        end
        L = L + log(sub_L);
    end 
end