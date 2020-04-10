function Data = Logical_Consecutive(LogicalInput)
% Data = Logical_Consecutive(LogicalInput)
%
% This takes a logical input (only 1s and 0s) and gives you the value of
% the first data point (1 or 0), the number of repeats at each value, and a
% modified vector that replaces 1s and 0s with the duration of that value.
% 
% Input                 LogicalInput        A 1xn vector of 1s and 0s
% 
%
% Output                Data                A structure with the following
%                                           fields:
%
%                           .FirstDataPoint     The value of the first
%                                               number (0 or 1)
%                           .ConsecutiveOutput  A 1xn string with each
%                                               value replaced with an
%                                               integer of the number of
%                                               repeats
%                           .nRepeats           A vector of the length of
%                                               each repeat.
%
% Example: LogicalInput =  [0 0 0 1 1 1 1 0 0 0 0 0 1 1 1 0 0 1] 
% 
% Data.FirstDataPoint =    [0]
% Data.ConsecutiveOutput = [3 3 3 4 4 4 4 5 5 5 5 5 3 3 3 2 2 1]
% Data.nRepeats = [4 5 3 2]
%
% NOTE: The nRepeats shaves off the first and last values, since you don't
%       know whether those numbers started or ended outside of sampling.
%
% Contributed by Jimmy Dooley (james-c-dooley@uiowa.edu)
% Last updated 2.20.20 by JD
%

FirstDataPoint = LogicalInput(1);
dLogicalInput = abs(diff(LogicalInput));
dLogicalInputIndex = find(dLogicalInput == 1);
d_dLogicalInputIndex = diff(dLogicalInputIndex);

Output = zeros(length(LogicalInput),1);

Output(1:dLogicalInputIndex) = dLogicalInputIndex(1);
for iIndex = 1:length(dLogicalInputIndex)-1
    Output((dLogicalInputIndex(iIndex)+1):dLogicalInputIndex(iIndex+1)) = d_dLogicalInputIndex(iIndex);
end
Output(dLogicalInputIndex(end):end) = d_dLogicalInputIndex(end);

Data.FirstDataPoint = FirstDataPoint;
Data.ConsecutiveOutput = Output;
Data.nRepeats = d_dLogicalInputIndex;
    
end