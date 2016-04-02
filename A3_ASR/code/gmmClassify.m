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
    mostLogProb = -Inf;
    mostProbSpeaker = '';
    for j = 1:length(gmms)
        speakerGmm = gmms{j};
        speakerName = speakerGmm.name;
        [p, L] = computeLikelihood(mfcc, speakerGmm, D, M);
        if L > mostLogProb
            mostLogProb = L;
            mostProbSpeaker = speakerName;
        end
        disp(['For file ', mfccs(i).name, ', the most possible speaker is ', mostProbSpeaker]);
    end
end