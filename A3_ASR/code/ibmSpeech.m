dir_test = '/u/cs401/speechdata/Testing';

output = fopen('hypo.txt','w');

flacfiles = dir([dir_test, filesep, '*.flac']);
for i = 1:length(flacfiles)
    fileName = [dir_test, filesep, 'unkn_', num2str(i), '.flac'];
    [status, result] = unix(['env LD_LIBRARY_PATH='''' curl -u da15a506-7899-46cf-9929-73f9f566b29d:GkNQhyD4g03H -X POST --header "Content-Type: audio/flac" --header "Transfer-Encoding: chunked" --data-binary @', fileName, ' "https://stream.watsonplatform.net/speech-to-text/api/v1/recognize?continuous=true"']);
    disp(result);
    result = regexp(result, '"transcript": "(?<transcript>.+)"\n', 'names');
    result = result.transcript

    fprintf(output, [result, '\n']);
end

fclose(output);

[SE IE DE LEV_DIST] = Levenshtein('hypo.txt', dir_test);
disp(SE);
disp(IE);
disp(DE);
disp(LEV_DIST);

unix('rm -rf syn*');
outputName = 'syn.txt';
outFile = fopen(outputName, 'w');
txtFiles = dir([dir_test, filesep, 'unkn_*.txt']);
for i = 1:length(txtFiles)
    txtFile = textread([dir_test, filesep, 'unkn_', num2str(i), '.txt'], '%s');
    text = '';
    for j = 3:length(txtFile)
        text = [text, txtFile{j}, ' '];
    end
    text = strtrim(text);
    text = strrep(text, '''', '''''');

    likFile = ['unkn_', num2str(i), '.lik']
    likFile = textread(likFile, '%s')
    voice = 'en-US_LisaVoice';
    if strncmpi(likFile(1), 'M', 1)
        voice = 'en-US_MichaelVoice';
    end
    tempFlac = ['syn_unkn_', num2str(i), '.flac'];
    unix(['env LD_LIBRARY_PATH='''' curl -u f68e017a-2b5e-47ce-8b4d-8d108e75cbe8:S5QhBuRF3quy -X POST --header ''Content-Type: application/json'' --header ''Accept: audio/flac'' --data ''{"text":"' text, '"}'' ''https://stream.watsonplatform.net/text-to-speech/api/v1/synthesize?voice=', voice, ''' > ', tempFlac]);
    [status, result] = unix(['env LD_LIBRARY_PATH='''' curl -u da15a506-7899-46cf-9929-73f9f566b29d:GkNQhyD4g03H -X POST --header "Content-Type: audio/flac" --header "Transfer-Encoding: chunked" --data-binary @', tempFlac, ' "https://stream.watsonplatform.net/speech-to-text/api/v1/recognize?continuous=true"']);
    result = regexp(result, '"transcript": "(?<transcript>.+)"\n', 'names');
    result = result.transcript
    fprintf(outFile, [result, '\n']);
end

fclose(outFile);

[SE IE DE LEV_DIST] = Levenshtein('syn.txt', dir_test);
disp(SE);
disp(IE);
disp(DE);
disp(LEV_DIST);

