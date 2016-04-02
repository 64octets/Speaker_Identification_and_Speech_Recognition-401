trainPath = '/u/cs401/speechdata/Training';
% trainPath = '/h/u8/g5/00/g5ran/Speech_Recognition_401/speechdata/Training';
% gmms = gmmTrain(trainPath, 100, 0.01, 10);
% save( ['gmms.mat'], 'gmms', '-mat');
gmms = load('gmms.mat', '-mat');
gmms = gmms.gmms;

testPath = '/u/cs401/speechdata/Testing';
mfccs = dir([testPath, filesep, '*.mfcc']);
D = 14;
M = 10;

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
    disp(['For file ', mfccs(i).name, ', the most possible speaker is ', person.name, ' and probability is ', num2str(person.prob), '\n']);
    for m = 1:5
        person = probs{m};
        fprintf(output, ['For file ', mfccs(i).name, ', the ', num2str(m), 'th most possible speaker is ', person.name, ' and probability is ', num2str(person.prob), '\n']);
    end
    fclose(output);
end