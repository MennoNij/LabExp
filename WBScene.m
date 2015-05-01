classdef WBScene < handle
% A scene defines the position of tasks over the entire screenspace

    properties (SetAccess = public, GetAccess = public)
        name = 'Scene';     % the identifier/name of the scene

        eventBuffer         % handle to the event buffer, in which the tasks of the scene can deposit events
        wPtr = 0;

        %clearColor = [255 255 255];
        clearColor = [0 0 0];
    end % properties

    properties (SetAccess = private, GetAccess = public)
        canvasArray         % all the canvases in the scene, each of which contains a task (at a certain screen pos)

        width= 0;           % the width of the screen (should be the screen width)
        height = 0;         % the height of the screen (should be the screen height)
    end

    methods
        function obj = WBScene(nm, w, h)
            obj.name = nm;

            obj.width = w;
            obj.height = h;
        end % constructor

        function update(this)
        % UPDATE called at each frame/loop of the experiment, and calls the update of each task

            %white = WhiteIndex(this.wPtr);
            %Screen('FillRect',this.wPtr,white);
            %Screen(this.wPtr, 'Flip');

            for (i = 1:length(this.canvasArray))
                this.canvasArray(i).update();
            end
        end % update

        function addCanvas(this, cnvs)
            % check whether canvas area interferes with others
        end % addCanvas

        function addTask(this, tsk, pos)
        % ADDTASK adds a task to the specified canvas
            if (pos > 0 & pos <= length(this.canvasArray))
                this.canvasArray(pos).task = tsk;
                this.canvasArray(pos).task.eventBuffer = this.eventBuffer;
            else
                error(['Invalid task position (' num2str(pos) ') specified (' this.name ')']);
            end
        end % addTask

        function setArrangement(this, arrangement)
        % SETARRANGEMENT define the screen arrangement of tasks in the scene. Each canvas has a rectangular area.
            if (ischar(arrangement))
                m = 5;
                % set up an array of canvases according to a predefinition
                switch (lower(arrangement))
                    case {'2'}
                        % a row of 2 equal sized canvases
                        a(1) = WBCanvas([0+m, 0+m, round(this.width/2)-m, this.height-m]);
                        a(2) = WBCanvas([round(this.width/2)+m,  0+m, this.width-m, this.height-m]);
                        %a(1).print();
                        %a(2).print();
                    case {'12'}
                        % a single canvas followed by a row of two canvases
                    case {'11'}
                        a(1) = WBCanvas([0+m, 0+m, this.width-m, round(this.height/2)-m]);
                        a(2) = WBCanvas([0+m, round(this.height/2)+m, this.width-m, this.height-m]);
                    otherwise
                        % just add one, 'full screen'
                        a(1) = WBCanvas([0+m, 0+m, this.width-m, this.height-m]);
                end
            else
                % use rectangle data to define canvas areas
                n = length(arrangement);
                j = 0;
                if (mod(n, 4) == 0)
                    for (i = 1:4:n)
                        % check if the rectangle doesn't overlap with the rectangles already added to the scene
                        jRect = [round(arrangement(i)) round(arrangement(i+1)) round(arrangement(i+2)) round(arrangement(i+3))];

                        if (jRect(1) > jRect(3) | jRect(2) > jRect(4))
                            error(['The first point of rectangle ' num2str(j) ' should be before the second one (' this.name ')']);
                        end

                        if (j > 0)
                            for (k = 1:j)
                                kRect = a(k).rectangle;
                                if (this.isOverlapping(kRect, jRect))
                                    error(['The canvas specified in the arrangement at position ' num2str(i) ' to ' ...
                                          num2str(i+3) ' overlaps with a previous canvas (' this.name ')']);
                                end
                            end
                        end

                        % add a canvas with the specified size
                        j = j + 1;
                        a(j) = WBCanvas(jRect);
                    end
                else
                    error(['Arrangement array length was not a multiple of 4 (', this.name, ')']);
                end
            end

            this.canvasArray = a; % using a temp var is more efficient in matlab for some reason

            % bind the screen to which output of the task will be written to
            for (i = 1:length(this.canvasArray))
                %disp(['hur', num2str(this.wPtr)]);
                this.canvasArray(i).wPtr = this.wPtr;
                %disp('dur');
            end

        end % setArrangement

        function clearScreen(this)
            Screen('FillRect', this.wPtr, this.clearColor, [0 0 this.width this.height]);
            Screen(this.wPtr, 'Flip');
        end

        function keyboardInput(this, c)
        % KEYBOARDINPUT broadcasts keyboard input to all canvases
            for (i = 1:length(this.canvasArray))
                this.canvasArray(i).keyboardInput(c);
            end
        end % keyboardInput

        function mouseInput(this, x, y, buttons)
            for (i = 1:length(this.canvasArray))
                this.canvasArray(i).mouseInput(x, y, buttons);
            end
        end

        function task = findTask(this, name)
        % FINDTASK find a task in a particular scene based on its name/id 
            task = 0;
            for (i = 1:length(this.canvasArray))
                if (strcmp(name, this.canvasArray(i).task.name))
                    task = this.canvasArray(i).task;
                end
            end

            if (task == 0)
                error(['Could not find the specified task (' name ')']);
            end
        end

        function startAllTasks(this)
            for (i = 1:length(this.canvasArray))
                this.canvasArray(i).task.start();
            end
        end

        function set.eventBuffer(this, value)
            this.eventBuffer = value;

            % bind buffer to all the tasks
            for (i = 1:length(this.canvasArray))
                this.canvasArray(i).task.eventBuffer = this.eventBuffer;
            end
        end

        function value = get.eventBuffer(this)
            value = this.eventBuffer;
        end

        function set.wPtr(this, value)
            %disp (['SCENE:',this.name,' setting wPtr: ', num2str(value)]);
            this.wPtr = value;

            % propagate to canvas children
            for (i = 1:length(this.canvasArray))
                this.canvasArray(i).wPtr = this.wPtr;
            end
        end

        function rebindTasks(this)
            for (i = 1:length(this.canvasArray))
                this.canvasArray(i).rebindTask();
            end
        end

        function setSize(this, w, h)
            % SETSIZE set the size of the scene. Typically, this should be the screen size
            if (w < 1 | h < 1)
                error(['Invalid size specified :' w 'x' h '(' this.name ')']);
            else
                % make sure integers are used to define screen regions
                this.width = round(w);
                this.height = round(h);
            end

            % resize the canvases accordingly
        end
    end % methods

    methods (Access = private)
        function bool = isOverlapping(this, rect, rect2)
            % ISOVERLAPPING check if two rectangles (format (x1,y1)(x2,y2)) overlap
            bool = 0;
            if (rect(1) >= rect2(1) & rect(1) <= rect2(3) & rect(2) >= rect2(2) & rect(2) <= rect2(4))
                % the first point of rect falls inside the area of rect2
                bool = 1;
            elseif (rect(3) >= rect2(1) & rect(3) <= rect2(3) & rect(4) >= rect2(2) & rect(4) <= rect2(4))
                % the second point of rect falls inside rect2
                bool = 1;
            end

        end % overlaps
    end

end
