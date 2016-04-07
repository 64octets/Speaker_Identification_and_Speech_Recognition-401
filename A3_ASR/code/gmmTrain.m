function gmms = gmmTrain( dir_train, max_iter, epsilon, M )
% gmmTain
%
%  inputs:  dir_train  : a string pointing to the high-level
%                        directory containing each speaker directory
%           max_iter   : maximum number of training iterations (integer)
%           epsilon    : minimum improvement for iteration (float)
%           M          : number of Gaussians/mixture (integer)
%
%  output:  gmms       : a 1xN cell array. The i^th element is a structure
%                        with this structure:
%                            gmm.name    : string - the name of the speaker
%                            gmm.weights : 1xM vector of GMM weights
%                            gmm.means   : DxM matrix of means (each column 
%                                          is a vector
%                            gmm.cov     : DxDxM matrix of covariances. 
%                                          (:,:,i) is for i^th mixture
    gmms = [];
    trainD = dir(dir_train);
    n = 1;
    for s = 1:length(trainD)
        speaker = trainD(s).name;
        if strcmp(speaker, '..') || strcmp(speaker, '.')
            continue;
        end
        speakerD = dir([dir_train, filesep, speaker, filesep, '*.mfcc']);
        X = [];
        for mfcc = 1:length(speakerD)
            X = [X; dlmread([dir_train, filesep, speaker, filesep, speakerD(mfcc).name])];
        end
        sizeX = size(X);
        D = sizeX(2);
        gmm = gmmInit(speaker, D, M, X);
        prev_L = -Inf;
        improvement = Inf;
        for i = 1:max_iter
            [p, L] = computeLikelihood(X, gmm, D, M);
            if isnan(L) || isinf(L)
                disp('Exit unexpectedlly!');
                break;
            end
            gmm_prev = gmm;
            gmm = updateParameters(gmm, X, p, D, M);
            improvement = L - prev_L;
            prev_L = L;
            if improvement <= epsilon
                break;
            end
        end
        gmms{n} = gmm;
        n = n + 1;
        disp(['Finished training with speaker ', speaker]);
    end
end

function gmm = updateParameters(gmm, X, p, D, M)
    T = length(X);
    for m = 1:M
        sumCommon = sum(p(:, m));
        gmm.weights(1, m) = sumCommon / T;
        sumForMean = zeros(D, 1);
        sumForVariance = zeros(D, D);
        for t = 1:T
            sumForMean = sumForMean + p(t, m) * transpose(X(t, :));
            sumForVariance = sumForVariance + p(t, m) * transpose(X(t, :)) * X(t, :);
        end
        gmm.means(:, m) = sumForMean / sumCommon;
        gmm.cov(:, :, m) = (sumForVariance / sumCommon) - gmm.means(:, m) * transpose(gmm.means(:, m));
    end
end

function gmm_init = gmmInit(name, D, M, X)
    gmm_init = struct();

    gmm_init.name = name;
    gmm_init.weights = zeros(1, M) + 1 / M;
    gmm_init.cov = repmat(eye(D) * 1000, 1, 1, M);
    gmm_init.means = transpose(mean(X)) * rand(1, M);
end