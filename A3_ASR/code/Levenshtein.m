function [SE IE DE LEV_DIST] = Levenshtein(hypothesis,annotation_dir)
% Input:
%	hypothesis: The path to file containing the the recognition hypotheses
%	annotation_dir: The path to directory containing the annotations
%			(Ex. the Testing dir containing all the *.txt files)
% Outputs:
%	SE: proportion of substitution errors over all the hypotheses
%	IE: proportion of insertion errors over all the hypotheses
%	DE: proportion of deletion errors over all the hypotheses
%	LEV_DIST: proportion of overall error in all hypotheses

    SE = [];
    IE = [];
    DE = [];
    LEV_DIST = [];

    hypoLines = textread(hypothesis, '%s','delimiter','\n');

    for i = 1:length(hypoLines)
        hypoLine = hypoLines{i};
        hypoWords = strsplit(strtrim(hypoLine));
        refWords = transpose(textread([annotation_dir, filesep, 'unkn_', num2str(i), '.txt'], '%s'));

        del = 0;
        sub = 0;
        ins = 0;
        n = length(refWords);
        m = length(hypoWords);
        R = zeros(n + 1, m + 1);
        B = zeros(n + 1, m + 1);
        for i = 2:n + 1
            R(i, 1) = Inf;
        end
        for j = 2:m + 1
            R(1, j) = Inf;
        end
        for i = 2: n + 1
            for j = 2: m + 1
                del = R(i - 1, j) + 1;
                sub = R(i - 1, j - 1) + (~strcmp(refWords{i}, hypoWords{j}));
                ins = R(i, j - 1) + 1;
                R(i, j) = min(del, sub);
                R(i, j) = min(R(i, j), ins);

                if R(i, j) == del
                    R(i, j) = R(i - 1, j);
                elseif
                    R(i, j) = R(i, j - 1);
                else
                    R(i, j) = R(i - 1, j - 1);
                end
            end
        end

        SE{i} = sub / n;
        IE{i} = ins / n;
        DE{i} = del / n;
        LEV_DIST{i} = R(n + 1, m + 1) / n;
    end
end

