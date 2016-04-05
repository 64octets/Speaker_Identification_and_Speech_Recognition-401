trainPath = '/u/cs401/speechdata/Training';
% trainPath = '/h/u8/g5/00/g5ran/Speech_Recognition_401/speechdata/Training';
max_iter = 100;
M = 20

gmms = gmmTrain(trainPath, max_iter, 0.01, M);
save( ['gmms_', num2str(max_iter), '_', num2str(M),'.mat'], 'gmms', '-mat');
% gmms = load('gmms.mat', '-mat');
% gmms = gmms.gmms;

testPath = '/u/cs401/speechdata/Testing';
mfccs = dir([testPath, filesep, '*.mfcc']);
D = 14;

for i = 1:length(mfccs)
    output = fopen([strtok(mfccs(i).name, '.'), '.lik'], 'w');
    mfcc = dlmread([testPath, filesep, mfccs(i).name]);
    probs = [];
    for j = 1:length(gmms)
        speakerGmm = gmms{j};
        speakerName = speakerGmm.name;
        [p, L] = computeLikelihood(mfcc, speakerGmm, D, M);
        result = struct();
        result.name = speakerName;
        result.prob = L;
        probs{j} = result;
    end 

    for m = 1:length(probs) - 1
        for n = m + 1:length(probs)
            a = probs{m};
            b = probs{n};
            if a.prob < b.prob || isnan(a.prob)
                c = a;
                probs{m} = b;
                probs{n} = c;
            end
        end
    end

    person = probs{1};
    disp(['For file ', mfccs(i).name, ', the most possible speaker is ', person.name, ' and probability is ', num2str(person.prob)]);
    for m = 1:5
        person = probs{m};
        fprintf(output, [person.name, '\n']);
    end
    fclose(output);
end