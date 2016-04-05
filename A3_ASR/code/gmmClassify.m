trainPath = '/u/cs401/speechdata/Training';
% trainPath = '/h/u8/g5/00/g5ran/Speech_Recognition_401/speechdata/Training';
max_iter = 100;
M = 20;

% gmms = gmmTrain(trainPath, max_iter, 0.01, M);
% save( ['gmms_', num2str(max_iter), '_', num2str(M),'.mat'], 'gmms', '-mat');
gmms = load('gmms.mat', '-mat');
gmms = gmms.gmms;

testPath = '/u/cs401/speechdata/Testing';
mfccs = dir([testPath, filesep, '*.mfcc']);
D = 14;

correct_count = 0;
target_file = textread([testPath, filesep, phnFileName], '%s','delimiter','\n');

for i = 1:length(mfccs)
    output = fopen(['unkn_', num2str(i), '.', '.lik'], 'w');
    mfcc = dlmread([testPath, filesep, 'unkn_', num2str(i), '.mfcc']);
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
    disp(['For file ', 'unkn_', num2str(i), '.mfcc', ', the most possible speaker is ', person.name, ' and probability is ', num2str(person.prob)]);
    for m = 1:5
        person = probs{m};
        fprintf(output, [person.name, '\n']);
    end
    fclose(output);
    correct_count = correct_count + (~isempty(findstr(target_file{i}, probs{1})));
end