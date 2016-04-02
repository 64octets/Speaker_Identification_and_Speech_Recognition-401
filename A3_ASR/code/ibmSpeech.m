dir_test = '/u/cs401/speechdata/Testing';

output = fopen('hypo.txt','w');

flacfiles = dir([dir_test, filesep, '*.flac']);
for i = 1:length(flacfiles)
    [status, result] = unix(['env LD_LIBRARY_PATH='''' curl -u da15a506-7899-46cf-9929-73f9f566b29d:GkNQhyD4g03H -X POST --header "Content-Type: audio/flac" --header "Transfer-Encoding: chunked" --data-binary @', dir_test, filesep, flacfiles{i}.name, ' "https://stream.watsonplatform.net/speech-to-text/api/v1/recognize?continuous=true"']);
    result = regexp(result, '"transcript": "(?<transcript>[\w|\s]+)"', 'names');

    fprintf(output, [result, '\n']);
end

fclose(output);