classdef ImageProcessingApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure         matlab.ui.Figure
        LoadButton       matlab.ui.control.Button
        ComputeButton    matlab.ui.control.Button
        NextButton       matlab.ui.control.Button
        PrevButton       matlab.ui.control.Button
        ExitButton       matlab.ui.control.Button
        UIAxes           matlab.ui.control.UIAxes
        ThresholdSlider  matlab.ui.control.Slider
        ThresholdLabel   matlab.ui.control.Label
    end
    
    properties (Access = private)
        ImageData % 画像データの格納場所
        Threshold = 128 % 初期閾値を0-255の範囲に設定
        Mode = 1 % 初期モードを1に設定
    end
    
    methods (Access = private)

        % "Load" ボタンを押した時のコールバック
        function onLoadButtonPushed(app, event)
            [file, path] = uigetfile({'*.png;*.jpg;*.bmp','Image Files'});
            if isequal(file, 0)
                return; % ユーザーがキャンセルした場合
            end
            fullPath = fullfile(path, file);
            app.ImageData = imread(fullPath);
            imshow(app.ImageData, 'Parent', app.UIAxes);
        end

        % "Compute" ボタンを押した時のコールバック
        function onComputeButtonPushed(app, event)
            app.applyProcessing();
            if app.Mode == 1 % モード1 (二値化) がアクティブな時
                app.ThresholdSlider.Visible = 'on'; % スライダーを表示
                app.ThresholdLabel.Visible = 'on'; % ラベルを表示
            end
        end

        % "Next" ボタンを押した時のコールバック
        function onNextButtonPushed(app, event)
            app.Mode = mod(app.Mode, 3) + 1; % モードを1から3に循環
            app.updateButtonLabel();
            if app.Mode ~= 1 % モード1 (二値化) でないときはスライダーを非表示
                app.ThresholdSlider.Visible = 'off';
                app.ThresholdLabel.Visible = 'off';
            end
        end

        % "Prev" ボタンを押した時のコールバック
        function onPrevButtonPushed(app, event)
            app.Mode = mod(app.Mode - 2, 3) + 1; % モードを1から3に循環
            app.updateButtonLabel();
            if app.Mode ~= 1 % モード1 (二値化) でないときはスライダーを非表示
                app.ThresholdSlider.Visible = 'off';
                app.ThresholdLabel.Visible = 'off';
            end
        end

        % スライダーが変わった時のコールバック
        function onSliderValueChanged(app, event)
            app.Threshold = app.ThresholdSlider.Value;
            app.ThresholdLabel.Text = ['Threshold: ' num2str(app.Threshold)];
            if app.Mode == 1 % モード1 (二値化) がアクティブな時
                app.applyProcessing();
            end
        end

        % モードに応じた処理を実行
        function applyProcessing(app)
            if isempty(app.ImageData)
                uialert(app.UIFigure, 'No image loaded.', 'Error');
                return;
            end
            switch app.Mode
                case 1 % 二値化
                    grayImage = rgb2gray(app.ImageData);
                    normalizedThreshold = app.Threshold / 255; % 閾値を0-1の範囲に正規化
                    binaryImage = imbinarize(grayImage, normalizedThreshold);
                    imshow(binaryImage, 'Parent', app.UIAxes);
                case 2 % エッジ検出
                    grayImage = rgb2gray(app.ImageData);
                    edgeImage = edge(grayImage, 'Canny');
                    imshow(edgeImage, 'Parent', app.UIAxes);
                case 3 % ガウシアンフィルタ
                    gaussianImage = imgaussfilt(app.ImageData, 2); % ガウシアンフィルタを適用、標準偏差2
                    imshow(gaussianImage, 'Parent', app.UIAxes);
            end
        end

        % ボタンのラベルを更新
        function updateButtonLabel(app)
            switch app.Mode
                case 1
                    app.ComputeButton.Text = 'Compute'; % 二値化モード
                case 2
                    app.ComputeButton.Text = 'Compute2'; % エッジ検出モード
                case 3
                    app.ComputeButton.Text = 'Compute3'; % ガウシアンフィルタモード
            end
        end

        % 終了ボタンを押した時のコールバック
        function onExitButtonPushed(app, event)
            delete(app.UIFigure); % アプリケーションを閉じる
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'UI Figure';

            % Create LoadButton
            app.LoadButton = uibutton(app.UIFigure, 'push');
            app.LoadButton.Position = [50 420 100 22];
            app.LoadButton.Text = 'Load';
            app.LoadButton.ButtonPushedFcn = createCallbackFcn(app, @onLoadButtonPushed, true);

            % Create ComputeButton
            app.ComputeButton = uibutton(app.UIFigure, 'push');
            app.ComputeButton.Position = [230 420 100 22];
            app.ComputeButton.Text = 'Compute';
            app.ComputeButton.ButtonPushedFcn = createCallbackFcn(app, @onComputeButtonPushed, true);

            % Create NextButton
            app.NextButton = uibutton(app.UIFigure, 'push');
            app.NextButton.Position = [340 420 100 22];
            app.NextButton.Text = 'Next';
            app.NextButton.ButtonPushedFcn = createCallbackFcn(app, @onNextButtonPushed, true);

            % Create PrevButton
            app.PrevButton = uibutton(app.UIFigure, 'push');
            app.PrevButton.Position = [120 420 100 22];
            app.PrevButton.Text = 'Previous';
            app.PrevButton.ButtonPushedFcn = createCallbackFcn(app, @onPrevButtonPushed, true);

            % Create ExitButton
            app.ExitButton = uibutton(app.UIFigure, 'push');
            app.ExitButton.Position = [450 420 100 22];
            app.ExitButton.Text = 'Exit';
            app.ExitButton.ButtonPushedFcn = createCallbackFcn(app, @onExitButtonPushed, true);

            % Create ThresholdSlider
            app.ThresholdSlider = uislider(app.UIFigure);
            app.ThresholdSlider.Limits = [0 255]; % スライダーの範囲を0-255に設定
            app.ThresholdSlider.Position = [250 375 150 3];
            app.ThresholdSlider.Value = app.Threshold; % 初期値を範囲内に設定
            app.ThresholdSlider.ValueChangedFcn = createCallbackFcn(app, @onSliderValueChanged, true);
            app.ThresholdSlider.Visible = 'off'; % 初期状態では非表示

            % Create ThresholdLabel
            app.ThresholdLabel = uilabel(app.UIFigure);
            app.ThresholdLabel.Position = [410 365 120 22];
            app.ThresholdLabel.Text = ['Threshold: ' num2str(app.Threshold)];
            app.ThresholdLabel.Visible = 'off'; % 初期状態では非表示

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            app.UIAxes.Position = [50 50 540 300];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App initialization and construction
    methods (Access = public)

        % Construct app
        function app = ImageProcessingApp

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % 更新処理を行う
            app.updateButtonLabel();

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
