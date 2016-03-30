addpath(genpath('/u/cs401/A3_ASR/code/FullBNT-1.0.4'));

dir_train = '/u/cs401/speechdata/Training';
% dir_train = '/h/u8/g5/00/g5ran/Speech_Recognition_401/speechdata/Training';
dir_test = '/u/cs401/speechdata/Testing';

trainingData = struct();
trainD = dir(dir_train);
for s = 1:length(trainD)
    folderName = trainD(s).name;
    if strcmp(folderName, '..') || strcmp(folderName, '.')
        continue;
    end
    mfccFiles = dir([dir_train, filesep, folderName, filesep, '*.mfcc']);
    for iMfcc = 1:length(mfccFiles)
        mfccFileName = mfccFiles(iMfcc).name;
        mfccData = dlmread([dir_train, filesep, folderName, filesep, mfccFileName]);
        phnData = textread([dir_train, filesep, folderName, filesep, strtok(mfccFileName, '.'), '.phn'], '%s','delimiter','\n');
        for iPhn = 1:length(phnData)
            phnDataLine = phnData{iPhn};
            phnDataLine = regexp(phnDataLine,'\s+','split');
            endIndex = min(str2num(phnDataLine{2}) / 128, length(mfccData));
            pnn = genvarname(phnDataLine{3});
            if ~isfield(trainingData, pnn)
                trainingData.(pnn) = [];
            end
            len = length(trainingData.(pnn));
            trainingData.(pnn){len + 1} = transpose(mfccData((str2num(phnDataLine{1}) / 128) + 1: endIndex, :));
        end
    end
end

pnns = fieldnames(trainingData);
HMMs = struct();
for i = 1:length(pnns)
    pnn = pnns{i};
    HMM = initHMM(trainingData.(pnn));
    [HMM, L] = trainHMM(HMM, trainingData.(pnn), 5);
    HMMs.(pnn) = HMM;
end
save( ['HMMs.mat'], 'HMMs', '-mat');
