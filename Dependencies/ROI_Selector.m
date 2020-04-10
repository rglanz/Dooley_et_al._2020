function ROI = ROI_Selector(videoObject)
% ROI = ROI_Selector(videoObject)
%
% GUI for selecting multiple (up to 5) ROIs in a video frame.
%
% Input                     videoObject             video object read by
%                                                   VideoReader()
%
% Output                    ROI                     structure containing
%                                                   ROI labels and
%                                                   positions
%
% Contributed by Ryan Glanz (ryan-glanz@uiowa.edu)
% Last updated 3.4.20 by RG
%

%% ROI Structure
ROI = struct('Label', cell(1, 5), 'Position', cell(1, 5));  % Pre-allocate ROI
ROIColor = lines(3);

%% Display First Frame
videoName = videoObject.Name;
videoDuration = videoObject.Duration;
videoFrameRate = videoObject.FrameRate;
firstFrame = read(videoObject, 1);

f = figure('NumberTitle', 'off', 'Name', videoName);
imageHandle = imshow(firstFrame);

%% Slider
sliderControl = uicontrol(f, 'Style', 'slider', 'Units', 'normalized',...
    'Position', [0.2 0.05, 0.5, 0.02]);
sliderControl.Min = 1;
sliderControl.Max = videoDuration * videoFrameRate;
sliderControl.Value = 1;

textBox = uicontrol('Style', 'text','Units', 'norm', 'Position', [0.2 0.07 0.05 0.03]);
set(textBox,'string', sprintf('%s %d', 'Frame Number:', ceil(sliderControl.Value)));

sliderControl.Callback = @Slider_Event;

    function Slider_Event(source, event)
        sliderValue = ceil(sliderControl.Value);
        
        currentFrame = read(videoObject, sliderValue);
        set(textBox,'string', sprintf('%s %d', 'Frame Number:', ceil(sliderControl.Value)));
        imageHandle = imshow(currentFrame);
        imageHandle.UIContextMenu = contextMenu;
    end

%% Create Context Menu
contextMenu = uicontextmenu;
imageHandle.UIContextMenu = contextMenu;

menuOption1 = uimenu(contextMenu, 'Label', 'ROI 1', 'Callback', @Label_ROI);
menuOption2 = uimenu(contextMenu, 'Label', 'ROI 2', 'Callback', @Label_ROI);
menuOption3 = uimenu(contextMenu, 'Label', 'ROI 3', 'Callback', @Label_ROI);
menuOption4 = uimenu(contextMenu, 'Label', 'ROI 4', 'Callback', @Label_ROI);
menuOption5 = uimenu(contextMenu, 'Label', 'ROI 5', 'Callback', @Label_ROI);

    function Label_ROI(source, callbackdata)
        switch source.Label
            case 'ROI 1'
                ROI(1).Label = inputdlg('ROI 1 Label', 'Label');
                currentRectangle = drawrectangle('Color', ROIColor(1, :),...
                    'Label', ROI(1).Label{1});
                ROI(1).Position = currentRectangle.Position;
            case 'ROI 2'
                ROI(2).Label = inputdlg('ROI 2 Label', 'Label');
                currentRectangle = drawrectangle('Color', ROIColor(2, :),...
                    'Label', ROI(2).Label{1});
                ROI(2).Position = currentRectangle.Position;
            case 'ROI 3'
                ROI(3).Label = inputdlg('ROI 3 Label', 'Label');
                currentRectangle = drawrectangle('Color', ROIColor(3, :),...
                    'Label', ROI(3).Label{1});
                ROI(3).Position = currentRectangle.Position;
        end
    end

waitfor(f)

end
