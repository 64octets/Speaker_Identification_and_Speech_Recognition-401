function [p, L] = computeLikelihood(X, gmm, D, M)
    T = length(X);
    p = zeros(T, M);
    b = zeros(T, M);
    for t = 1:T
        weightedSum = 0;
        for m = 1:M
            temp1 = 0;
            temp2 = 1;
            for d = 1:D
                temp1 = temp1 + (((X(t, d) - gmm.means(d, m)) ^ 2) / gmm.cov(d, d, m));
                temp2 = temp2 * gmm.cov(d, d, m);
            end
            b(t, m) = temp1 / (-2) - log(((2 * pi) ^ (D / 2)) * sqrt(abs(temp2)));
            weightedSum = weightedSum + gmm.weights(1, m) * b(t, m);
        end
        for m = 1:M
            p(t, m) = (gmm.weights(1, m) * b(t, m)) / weightedSum;
        end
    end
    L = 0;
    for t = 1:T
        for m = 1:M
            L = L + log(p(t, m)) * b(t, m);
        end
    end 
end