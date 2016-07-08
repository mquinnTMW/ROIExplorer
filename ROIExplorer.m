classdef ROIExplorer < handle
    %
    % ROI Explorer
    %
    % This is a tool which allows the user to explore the pixel intensity
    % statistics in one or two regions of interest defined in an image.
    %
    % Written by Michael Quinn, PhD
    % michael.quinn@mathworks.com
    % 2016/04/27
    %
    %
    % version 1.0
    % 2016/04/27
    % Initial release
    %
    %
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties
        
        % Figure
        Figure % the main figure window

        % Panels for UI objects organization
        PanelImage
        PanelHistograms
        PanelStats

        % Axes
        AxesImage % where the original image is shown
        AxesHistograms % where the ROI histograms are shown
        
        % Line objects for histogram display
        HistLine1
        HistLine2
        
        % File Menu
        MenuFile
        MenuFile_Open
        MenuFile_Quit
        
        % the Image menu
        MenuROI
        MenuROI_CreateROI1
        MenuROI_CreateROI2
        
        % the Help menu
        MenuHelp
        MenuHelp_About
        
        % variables
        Image % the original image
        DataRange % for histogram display
        ROI1 % first ROI
        ROI2 % second ROI

        % Stats Table graphics objects
        TableStats
        TitleStats

    end
    methods
        %% Class Constructor
        function app = ROIExplorer;
            % the main figure window
            app.Figure = figure('Units', 'Normalized',...
                'MenuBar','none', ...
                'Toolbar','none',...
                'NumberTitle', 'off',...
                'Name', 'ROI Explorer',...
                'Position', [0.25 0.05 0.5 0.85],...
                'Color', [1,1,1]);
            
            % Panel for original
            app.PanelImage = uipanel('Parent', app.Figure, ...
                'Units', 'Normalized', 'Position', [0 0.03 1 0.67],...
                'BackgroundColor', [1,1,1],...
                'BorderType', 'none');
            % Panel for histograms
            app.PanelHistograms = uipanel('Parent', app.Figure, ...
                'Units', 'Normalized', 'Position', [0 0.7 0.7 0.3],...
                'BackgroundColor', [1,1,1],...
                'BorderType', 'none');
            % Slider panel to contain all of the controls
            app.PanelStats = uipanel('Parent', app.Figure, 'Units', 'Normalized',...
                'Position', [0.7 0.7 0.3 0.3], 'BackgroundColor', [1,1,1],...
                'BorderType', 'none');

            
            % The Axes object for the image
            app.AxesImage = axes('Parent', app.PanelImage, 'Units', 'Normalized',...
                'Position', [0 0 1 1],...
                'XTickLabel',[],'YTickLabel',[]);

            % The Axes object for the histograms
            app.AxesHistograms = axes('Parent', app.PanelHistograms, 'Units', 'Normalized',...
                'OuterPosition', [0 0 1 1], 'Box', 'on');
            title(app.AxesHistograms, 'Normalized ROI Histograms');

            % Add empty line object to start. Change XData, YData later
            % when we have data.
            app.HistLine1 = line('Parent', app.AxesHistograms, 'XData', nan, 'YData', nan, 'Color', 'b', 'LineWidth', 1);
            hold(app.AxesHistograms, 'on');
            app.HistLine2 = line('Parent', app.AxesHistograms, 'XData', nan, 'YData', nan, 'Color', 'r', 'LineWidth', 1);
            legend(app.AxesHistograms, {'ROI 1', 'ROI2'});

            % Create the stats panel and display
            CN = {'ROI 1', 'ROI 2'};
            RN = {'Mean', 'Std', 'Min', 'Max', 'Entropy'};
            app.TableStats = uitable('Parent', app.PanelStats, 'Data', num2cell(zeros(5,2)),...
                'ColumnName', CN, 'RowName', RN,...
                'FontUnits', 'Normalized', 'FontSize', 0.1,...
                'Units', 'Normalized',...
                'Position', [0.05 0.05 0.9 0.7]);
            app.TableStats.Position(3) = app.TableStats.Extent(3);
            app.TableStats.Position(4) = app.TableStats.Extent(4);
            app.TableStats.Position(2) = 0.75 - app.TableStats.Position(4);
            app.TitleStats = uicontrol('Style', 'text',...
                'Parent', app.PanelStats, 'Units', 'Normalized',...
                'Position', [0 0.75 1 0.15], 'String', 'Statistics',...
                'BackgroundColor', [1 1 1], 'FontName', 'Arial',...
                'FontSize', 14);

            
            % Add the menu bar
            
            % FILE menu
            app.MenuFile = uimenu(...
                'Parent',app.Figure,...
                'HandleVisibility','callback', ...
                'Label','File');
            app.MenuFile_Open = uimenu(...
                'Parent',app.MenuFile,...
                'Label','Load Image',...
                'HandleVisibility','callback', ...
                'Callback', @app.LoadImage);
            app.MenuFile_Quit = uimenu(...
                'Parent',app.MenuFile,...
                'Label','Quit',...
                'HandleVisibility','callback', ...
                'Callback', @app.CloseApp);
            
            % ROI menu
            app.MenuROI = uimenu(...
                'Parent',app.Figure,...
                'HandleVisibility','callback', ...
                'Label','ROI');
            app.MenuROI_CreateROI1 = uimenu(...
                'Parent',app.MenuROI,...
                'Label','Add ROI 1',...
                'HandleVisibility','callback', ...
                'Callback', @app.AddROI1);
            app.MenuROI_CreateROI2 = uimenu(...
                'Parent',app.MenuROI,...
                'Label','Add ROI 2',...
                'HandleVisibility','callback', ...
                'Callback', @app.AddROI2);
            
            % HELP menu
            app.MenuHelp = uimenu(...
                'Parent',app.Figure,...
                'HandleVisibility','callback', ...
                'Label','Help');
            app.MenuHelp_About = uimenu(...
                'Parent',app.MenuHelp,...
                'Label','About This App',...
                'HandleVisibility','callback', ...
                'Callback', @app.ShowAbout);

            % Load and display the default image
            app.Image = imread('cameraman.tif');
            imshow(app.Image, 'Parent', app.AxesImage)
            app.DataRange = [0, 255];
            xlim(app.AxesHistograms, [app.DataRange]);
            
        end
        
        %% Callbacks for the "File" menu
        function LoadImage(app, hObject, eventdata)
            % this function allows the user to load a custom image from
            % either the workspace or from a file.
            [img,cmap,~,~,userCanceled] = getNewImage(false);
            
            if ~userCanceled
                % convert to gray if image is indexed
                if ~isempty(cmap)
                    img = ind2gray(img, cmap);
                    msgbox('ROIExplorer: Indexed image was converted to grayscale', 'modal')
                end
                
                % convert to gray if image is color
                if size(img,3)==3
                    img = rgb2gray(img);
                    msgbox('ROIExplorer: Color image was converted to grayscale', 'modal')
                end
                
                % display the image
                app.Image = img;
                cla(app.AxesImage);
                imshow(app.Image, 'Parent', app.AxesImage)

                % set the range based on the image data type
                if isa(img, 'uint8')
                    app.DataRange = [0, 255];
                elseif isa(img, 'uint16')
                    app.DataRange = [0, 65535];
                else
                    app.DataRange = [0, 1];
                end

                xlim(app.AxesHistograms, [app.DataRange])
                
                % Reset the ROIs
                app.ROI1 = [];
                app.ROI2 = [];
                
                % Reset the histogram
                set(app.HistLine1, 'XData', nan, 'YData', nan);
                set(app.HistLine2, 'XData', nan, 'YData', nan);
            end
        end
        
        %% Callbacks for the "ROI" menu
        function AddROI1(app, hObject, eventdata)
            
            % if ROI1 already exists, delete it
            if isa(app.ROI1, 'imrect')
                delete(app.ROI1);
            end
            app.ROI1 = [];
                
            % Add the first ROI and add callbacks
            app.ROI1 = imrect(app.AxesImage);
            
            % Add callback to display histogram
            addNewPositionCallback(app.ROI1, @(pos)roiPosCallbackHistogram(pos, app.Image, app.HistLine1));

            % Add callback to display statistics
            addNewPositionCallback(app.ROI1, @(pos)roiPosCallbackStats(pos, app.Image, 1, app.TableStats));
            
            % Update the histogram and statistics
            pos = getPosition(app.ROI1);
            roiPosCallbackHistogram(pos, app.Image, app.HistLine1);
            roiPosCallbackStats(pos, app.Image, 1, app.TableStats);

        end
        function AddROI2(app, hObject, eventdata)

            % if ROI2 already exists, delete it
            if isa(app.ROI2, 'imrect')
                delete(app.ROI2);
            end
            app.ROI2 = [];

            % Add the second ROI and add callbacks
            app.ROI2 = imrect(app.AxesImage);
            setColor(app.ROI2, [1 0 0]);
            
            % Add callback to display histogram
            addNewPositionCallback(app.ROI2, @(pos)roiPosCallbackHistogram(pos, app.Image, app.HistLine2));
            
            % Add callback to display statistics
            addNewPositionCallback(app.ROI2, @(pos)roiPosCallbackStats(pos, app.Image, 2, app.TableStats));
            
            % Update the histogram and statistics
            pos = getPosition(app.ROI2);
            roiPosCallbackHistogram(pos, app.Image, app.HistLine2);
            roiPosCallbackStats(pos, app.Image, 2, app.TableStats);
        end
        
        %% Callbacks for the "Help" menu
        function ShowAbout(app, hObject, eventdata)
            % This function displays the "About this tool" dialog
            hf = figure('Units', 'Normalized', 'Position', [0.4, 0.55, 0.25, 0.25],...
                'MenuBar','none', 'Toolbar','none', 'Name', 'About This Tool',...
                'NumberTitle', 'off', 'Color', [1 1 1]);
            htitle = uicontrol('Style', 'text', 'String', 'Image ROI Explorer',...
                'FontSize', 16, 'Units', 'Normalized',...
                'Position', [0.02 0.85 0.9 0.12], 'BackgroundColor', [1, 1, 1],...
                'HorizontalAlignment', 'Left');
            hversion = uicontrol('Style', 'text', 'String', 'Version 1.0 - 2016',...
                'FontSize', 12, 'Units', 'Normalized',...
                'Position', [0.07 0.75 0.4 0.08], 'BackgroundColor', [1, 1, 1],...
                'HorizontalAlignment', 'Left');
            desc = {'This tool allows the user to explore and compare the statistics of regions of interest in a grayscale image.'};
            hdescription = uicontrol('Style', 'text', 'String', '2016',...
                'FontSize', 10, 'Units', 'Normalized',...
                'Position', [0.05 0.35 0.9 0.3], 'BackgroundColor', [1, 1, 1],...
                'HorizontalAlignment', 'Left');
            desc = textwrap(hdescription, desc);
            set(hdescription, 'String', desc)
        end
        
        function CloseApp(app, hObject, eventdata)
            % This function is pretty self-explanatory
            delete(app.Figure)
        end
    end
    
    methods(Static)
        % None
    end
end
