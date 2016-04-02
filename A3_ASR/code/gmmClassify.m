trainPath = '/u/cs401/speechdata/Training';
% trainPath = '/h/u8/g5/00/g5ran/Speech_Recognition_401/speechdata/Training';
gmms = gmmTrain(trainPath, 100, 0.01, 10);

testPath = '/u/cs401/speechdata/Testing';
mfccs = dir([testPath, filesep, '*.mfcc']);
D = 14;
M = 10;

for i = 1:length(mfccs)
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
            if a.prob < b.prob
                c = a;
                probs{m} = b;
                probs{n} = c;
            end
        end
    end
    for m = 1:5
        person = probs{m};
        disp(['For file ', mfccs(i).name, ', the most possible speaker is ', person.speakerName, ' and probability is ', person.prob]);
    end
end