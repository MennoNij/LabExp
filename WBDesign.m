classdef WBDesign < handle
% The scene contains the tasks, determines where they are located, and runs them. User input is also processed here.
    properties (SetAccess = public, GetAccess = public)
        name = 'Design';        % the name/id of the design
        eventBuffer             % the event buffer in which the design deposits events

        scene                   % the currently active (displayed) scene
        sceneStore              % the collection of all scenes stored in the design

        screenNumber = 0;
        screenWidth = 1;        % the width of the screen in which the design is displayed
        screenHeight = 1;       % the height of the screen in which the design is displayed

        wPtr = 0;

        finished = 0;
        useMouse = 0;
    end % properties

    properties (SetAccess = private, GetAccess = public)
        startTime = 0;
        active = 1;
        %keyPressed = 0;
        pressedKeys = zeros(1, 256);
        mouseClicked = 0;
        prevMousePos = [0 0];
    end

    methods
        function obj = WBDesign(evnts)
            if (nargin == 1)
                obj.eventBuffer = evnts;
            end

            obj.startTime = GetSecs;

            % more accurate button responses
            %KbQueueCreate;
            %KbQueueStart;
        end % constructor

        function update(this)
            % UPDATE perform one iteration of the design. All input is broadcast to the apropriate tasks
            if (this.active)

                this.scene.update();

                [keyDown, keyVal, ts] = this.retrieveKeyboardInput();

                if (keyDown)
                    %disp(['Typed key ', keyVal, ' at ', num2str(ts)]);
                    %this.eventBuffer.add('KeyPress');
                    if (keyVal(1) == '.')
                        this.finished = 1;
                    end

                    this.scene.keyboardInput(keyVal);

                    %FlushEvents;
                end

                if (this.useMouse)
                    [xM, yM, buttons] = this.retrieveMouseInput();
                    %buttons = [0 0 0];
                    %mDiff = 0;%abs(xM - this.prevMousePos(1)) + abs(yM - this.prevMousePos(2));
                    xmDiff = xM - this.prevMousePos(1);
                    ymDiff = yM - this.prevMousePos(2);

                    % was the mouse used?
                    if (sum(buttons) > 0 | xmDiff ~= 0 | ymDiff ~= 0)
                        this.prevMousePos = [xM yM];
                        this.scene.mouseInput(xM, yM, buttons);

                    end
                end
            end

        end % update

        function [aKeyWasPressed, keyVal, ts] = retrieveKeyboardInput(this)
            % RETRIEVEKEYBOARDINPUT grab key information if one was pressed
            ts = 0;
            keyVal = '';
            aKeyWasPressed = 0;

            %[aKeyIsDown, timestamp, keyCode] = KbCheck;
            %[key, timestamp] = GetChar;
            aKeyIsDown = CharAvail;
            if (aKeyIsDown)

                % what keys were pressed?
                keyVal = GetChar;

                ts = GetSecs - this.startTime;
                aKeyWasPressed = 1;
            end

            %this.pressedKeys = keyCode;
        end % listenForKeyboardInput

        function [x, y, buttons] = retrieveMouseInput(this);
            buttons = [0 0 0];

            [x, y, bttns] = GetMouse();
            if (any(bttns) & ~this.mouseClicked)
                % a new mouse click event
                buttons = bttns;
                this.mouseClicked = 1;
            elseif (~any(bttns) & this.mouseClicked)
                % the mouse button was released
                this.mouseClicked = 0;
            end

            %if (any(buttons))
                %disp(buttons);
            %end
        end

        function task = findTask(this, name)
            % FINDTASK find a task in the currently active scene
            task = this.scene.findTask(name);
        end

        function startAllTasks(this)
            this.scene.startAllTasks();
        end

        function buildScene(this, name, tasks, arrangement)
            % BUILDSCENE a quick way to build a scene from tasks with the given layout
            scene = WBScene(name, this.screenWidth, this.screenHeight);
            scene.wPtr = this.wPtr;
            scene.eventBuffer = this.eventBuffer;
            scene.setArrangement(arrangement);

            for (i = 1:length(tasks))
                %disp(['adding task ',tasks{i}.name]);
                scene.addTask(tasks{i}, i);
            end

            this.storeScene(scene);
        end

        function storeScene(this, scene)
            % STORESCENE put a new scene in the store, or overwrite an old one

            scene.wPtr = this.wPtr;

            % check if the name is already in the store
            fIdx = this.findByName(scene.name, this.sceneStore);

            if (fIdx > 0)
                % overwrite the scene if it was found
                this.sceneStore{fIdx} = scene;
            else
                % add a new scene at the end otherwise
                this.sceneStore{end+1} = scene;
            end
        end

        function loadScene(this, name)
            % LOADSCENE set a sceme from the store as active scene
            scene = this.findScene(name);

            if (scene ~= 0)
                this.scene = scene;
            end

            this.scene.clearScreen();
        end

        function scene = findScene(this, name)
            % FINDSCENE find a scne in the store using the name/id
            scene = 0;
            sceneIdx = this.findByName(name, this.sceneStore);
            if (sceneIdx > 0)
                scene = this.sceneStore{sceneIdx};
            else
                error(['Could not find the specified scene (' char(name) ')']);
            end
        end

        function hasNew = newEvents(this)
            hasNew = this.eventBuffer.filled;
        end

        function e = findEvents(this, name)
            % FINDEVENT find an event in the event buffer
            e = this.eventBuffer.find(name);
        end

        % GETTERS AND SETTERS

        function setScreenSize(this, w, h)
            this.screenWidth = w;
            this.screenHeight = h;
        end

        function [w, h] = getScreenSize(this)
            w = this.screenWidth;
            h = this.screenHeight;
        end

        function value = get.startTime(this)
            value = this.startTime;
        end
        
        function set.eventBuffer(this, value)
            this.eventBuffer = value;
        end

        function value = get.eventBuffer(this)
            value = this.eventBuffer;
        end

        function set.scene(this, value)
            % check if scene has been properly initialized
            this.scene = value;
            this.scene.eventBuffer = this.eventBuffer;
            this.scene.wPtr = this.wPtr;
            this.scene.rebindTasks();

            %hide cursor by default when loading a new scene
            HideCursor();
        end

        function value = get.scene(this)
            value = this.scene;
        end

        function set.wPtr(this, value)
            this.wPtr = value;
            %disp(['DESIGN wPtr: ', num2str(this.wPtr)]);
        end

    end % methods

    methods (Access = private)
        function idx = findByName(this, needle, haystack)
            % FINDBYNAME find an object in an object array using its name property
            idx = 0;

            for (i = 1:length(haystack))
                if (strcmp(needle, haystack{i}.name))
                    idx = i;
                end
            end
        end
    end % methods
end
