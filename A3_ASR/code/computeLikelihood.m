function [p, L] = computeLikelihood(X, gmm, D, M)
    T = length(X);
    p = zeros(T, M);
    b = zeros(T, M);
    for t = 1:T
        weightedSum = 0;
        for m = 1:M
            diff_mean = X(t, :) - transpose(gmm.means(:, m));
            b(t, m) = exp((-1 / 2) * diff_mean * gmm.cov(:, :, m) * transpose(diff_mean)) / ((2 * pi) ^ (D / 2) * sqrt(det(gmm.cov(:, :, m))));
            weightedSum = weightedSum + gmm.weights(1, m) * b(t, m);
        end
        for m = 1:M
            p(t, m) = (gmm.weights(1, m) * b(t, m)) / weightedSum;
        end
    end
    L = 0;
    for t = 1:T
        for m = 1:M
            L = L + p(t, m) * b(t, m);
        end
    end 
end