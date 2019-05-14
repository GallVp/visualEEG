# How to Add New Operations?

## Contents:

<ul>
    <li>
        <a href="https://github.com/GallVp/visualEEG/tree/master/docs/README.md">Overview of visualEEG</a>
    </li>
    <li>
        <a href="https://github.com/GallVp/visualEEG/tree/master/docs/importData.md">How to Import Data in visualEEG?</a>
    </li>
    <li>
        <a href="https://github.com/GallVp/visualEEG/tree/master/docs/sampleData.md">Sample Data Explained</a>
    </li>
</ul>

## Adding New Operations

New operations/functions can be added to visualEEG by simply placing the function file in the **operations** folder. However, this function should conform to the following template. This template is implementing the `newFunction`.

```MATLAB
function [argFunc, opFunc] = newFunction
%newFunction This function is doing something new.
%
% Your copyright notice

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Ask for arguments
    function returnArgs = askArgs(opData)
        returnArgs = [];
    end
%% Apply the operation
    function opDataOut = applyOperation(opData, args)
        opDataOut = opData;

        opDataOut.updateView = [];
    end
%% Update the view
    function opDataOut = updateView(axH, opData)
	opDataOut = opData;
    end
end
```

The code for asking the user to provide the options for the operation go into the `askArgs` function. The code for performing the operation goes into `applyOperation` function. And if special plotting capabilities are required by the operation, they should be implemented in the `updateView` function. Already implemented operations can be easily changed and saved as new functions.
