function [ assignedOptions ] = assignOptions( inputOptions, defaultOptions )
%ASSIGNOPTIONS Takes input options and assigns any missing options from
%default options.
assignedOptions = inputOptions;
mustHaveFields = fieldnames(defaultOptions);
for i = 1:length(mustHaveFields)
    if(~isfield(inputOptions, mustHaveFields{i}))
        assignedOptions.(mustHaveFields{i}) = defaultOptions.(mustHaveFields{i});
    end
end
end

