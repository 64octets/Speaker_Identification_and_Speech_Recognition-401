trainPath = '/u/cs401/speechdata/Training';
% trainPath = '/h/u8/g5/00/g5ran/Speaker_Identification_and_Speech_Recognition-401/A3_ASR/data';
max_iter = 10;
M = 2;

gmms = gmmTrain(trainPath, max_iter, 500, M);
save( ['gmms_', num2str(max_iter), '_', num2str(M),'.mat'], 'gmms', '-mat');
% load('gmms.mat', '-mat');

testPath = '/u/cs401/speechdata/Testing';
mfccs = dir([testPath, filesep, '*.mfcc']);
D = 14;

person_correct_count = 0;
gender_correct_cound = 0;
target_file = textread([testPath, filesep, 'TestingIDs1-15.txt'], '%s','delimiter','\n');

for i = 1:length(mfccs)
    output = fopen(['unkn_', num2str(i), '.lik'], 'w');
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
    for m = 1:length(probs)
        person = probs{m};
    end

    person = probs{1};
    disp(['For file ', 'unkn_', num2str(i), '.mfcc', ', the most possible speaker is ', person.name, ' and log probability is ', num2str(person.prob)]);
    for m = 1:5
        person = probs{m};
        fprintf(output, [person.name, '\n']);
    end
    fclose(output);
    if i <= 15
        person = probs{1};
        name = strtrim(person.name);
        target_line = strsplit(target_file{i + 1}, ':');
        target = strtrim(target_line(2));
        person_correct_count = person_correct_count + (strcmp(target, name));
        gender_correct_cound = gender_correct_cound + (strcmp(target{1}(1), name(1)));
    end
end

disp(['Person accuracy for the first 15 mfcc files is ', num2str(person_correct_count / 15)]);
disp(['Gender accuracy for the first 15 mfcc files is ', num2str(gender_correct_cound / 15)]);


