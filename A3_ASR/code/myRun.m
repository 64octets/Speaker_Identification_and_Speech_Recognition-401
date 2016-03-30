dir_test = '/u/cs401/speechdata/Testing';

HMMs = load('HMMs.mat', '-mat');
HMMs = HMMs.HMMs;

phnfiles = dir([dir_test, filesep, '*.phn']);
totalCount = 0;
correctCount = 0;
for phnfile = 1:length(phnfiles)
    phnFileName = phnfiles(phnfile).name;
    phnData = textread([dir_test, filesep, phnFileName], '%s','delimiter','\n');
    mfccData = dlmread([dir_test, filesep, strtok(phnFileName, '.'), '.mfcc']);
    for iPhn = 1:length(phnData)
        totalCount = totalCount + 1;
        phnDataLine = phnData{iPhn};
        phnDataLine = regexp(phnDataLine,'\s+','split');
        endIndex = min(str2num(phnDataLine{2}) / 128, length(mfccData));
        realPhn = genvarname(phnDataLine{3});
        testMfcc = transpose(mfccData((str2num(phnDataLine{1}) / 128) + 1: endIndex, :));

        maxLogProb = 0;
        mostProbPhn = '';
        phns = fieldnames(HMMs);
        for i = 1:length(phns)
            phn = phns{i};
            logProb = loglikHMM(HMMs.(phn), testMfcc);
            if logProb > maxLogProb
                maxLogProb = logProb;
                mostProbPhn = phn;
            end
        end
        correctCount = correctCount + strcmp(mostProbPhn, realPhn);
    end
end

disp(['Accuracy: ', num2str(correctCount / totalCount)]);
