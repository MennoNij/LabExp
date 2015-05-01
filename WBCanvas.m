classdef WBCanvas < handle
% Defines the area in which its Task child can render its output. Also forwards mouse information from inside the region
% to its Task. Furthermore, the Canvas takes care of some Matlab class hetrogenity issues in matlab (ie, different
% object classes in the same array)
    properties (SetAccess = public, GetAccess = public)
        task = 0;                   % the task encapsuled by the canvas
    end % properties

    properties (SetAccess = private, GetAccess = public)
        rectangle = [0 0 1 1];      % the screen region in which the task will be displayed
        area = -1;
    end
    
    properties (SetAccess = public, GetAccess = private)
        wPtr = -1;
    end

    properties (Dependent = true, GetAccess = private)
        originRectangle
    end

    properties (Dependent = true, GetAccess = public)
        width
        height
    end

    methods
        function obj = WBCanvas(rct, tsk)
            if (nargin > 0)
                obj.rectangle = rct;
            end

            if (nargin > 1)
                obj.task = tsk;
            end

            %obj.rectangle = [10 10 300 300];
        end % constructor

        function update(this)
        % UPDATE update the task if it is active
            this.drawBorder();
            %Screen('glScissor', 0, 0, 200, 200);

            if (this.task.isActive())
                this.task.update();
            end
        end % update

        function keyboardInput(this, c)
        % KEYBOARDINPUT forward keyboard input to the task
            if (this.task.isActive())
                this.task.keyboardInput(c);
            end
        end % keyboardInput

        function mouseInput(this, x, y, buttons)
            if (this.task.isActive())
                xW = x - this.rectangle(1);
                yW = y - this.rectangle(2);
                this.task.mouseInput(xW, yW, buttons);
            end
        end

        function drawBorder(this)

        end

        function wipe(this, clr)
            Screen('FillRect', this.area, clr, this.originRectangle);
            %this.paint();
        end

        function paint(this)
            Screen('CopyWindow', this.area, this.wPtr, this.originRectangle, this.rectangle);
            %Screen('DrawTexture', this.wPtr, this.area, this.originRectangle, this.rectangle);
            Screen(this.wPtr, 'Flip', 0, 1); % don't clear, or the entire screen would need to be redrawn
        end

        function paintVeil(this)
            oRect = this.originRectangle;
            veil = Screen('OpenOffscreenWindow', this.wPtr, [0 0 0 190], oRect);
            Screen('DrawTexture', this.wPtr, veil, oRect, this.rectangle);
            Screen(this.wPtr, 'Flip', 0, 1);
        end

        % GETTERS AND SETTERS

        function setMouse(this, x, y)
            % calculate coords relative to the canvas
            xW = x + this.rectangle(1);
            yW = y + this.rectangle(2);

            SetMouse(xW, yW, this.wPtr);
        end

        function [x, y] = getCenter(this)
            x = (this.rectangle(3)-this.rectangle(1))*0.5;
            y = (this.rectangle(4)-this.rectangle(2))*0.5;
        end

        function value = get.task(this)
            value = this.task;
        end % get.task

        function set.task(this, value)
            %disp(['TASK via CANVAS wPtr to', num2str(this.wPtr)]);
            this.task = value;
            this.task.canvas = this;
        end % set.task

        function rebindTask(this)
            this.task.canvas = this;
        end

        function set.wPtr(this, value)
            this.wPtr = value;
            %disp(['CANVAS wPtr to', num2str(this.wPtr)]);

            % if it doesn't exist already, create an offscreen window for this canvas to render into
            if (this.area < 0)
                this.area = Screen('OpenOffscreenWindow', this.wPtr, 0, this.originRectangle);
            end
        end % set.wPtr

        function value = get.originRectangle(this)
            value = [0 0 this.rectangle(3)-this.rectangle(1) this.rectangle(4)-this.rectangle(2)];
        end

        function value = get.width(this)
            value = this.rectangle(3)-this.rectangle(1);
        end

        function value = get.height(this)
            value = this.rectangle(4)-this.rectangle(2);
        end

        function print(this)
        % PRINT print the canvas information to the command line
            disp(['(',num2str(this.rectangle(1)),',',num2str(this.rectangle(2)),')(',
                      num2str(this.rectangle(3)),',',num2str(this.rectangle(4)),')']);
        end

    end % methods
end
