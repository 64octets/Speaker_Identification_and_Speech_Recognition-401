addpath(genpath('/u/cs401/A3_ASR/code/FullBNT-1.0.4'));

dir_train = '/u/cs401/speechdata/Training';
% dir_train = '/h/u8/g5/00/g5ran/Speech_Recognition_401/speechdata/Training';
dir_test = '/u/cs401/speechdata/Testing';

trainingData = [];
i = 1;
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
            trainingData{i} = transpose(mfccData((str2num(phnDataLine{1}) / 128) + 1: endIndex, :));
            i = i + 1;
        end
    end
end

HMM = initHMM(trainingData);
[HMM, L] = trainHMM(HMM, trainingData, 5);

save( 'HMM.mat', 'HMM', '-mat');

testData = [];
fileName = dir([dir_test, filesep, '*.mfcc']);
for iMfcc = 1:length(fileName)
    testData = dlmread([dir_test, filesep, fileName(iMfcc).name]);

    disp(loglikHMM(HMM, testData));
end



