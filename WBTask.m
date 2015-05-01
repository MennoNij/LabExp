classdef WBTask < handle
% Interface class for tasks. All actual implemented tasks should inherit from this class

    properties (SetAccess = public, GetAccess = public)
        name = 'Task';                      % the name of the task
        eventBuffer                         % the buffer to which the task can send events
        canvas
        active = 1;                         % whether the task is currently active (running and accepting input)
        startTime = 0;                      % the timestamp at which the task was started
        trialStartTime = 0;                 % start time of the current trial within the task (for RT measurements)

    end % properties

    properties (Dependent = true)
        activeTime
    end

    methods
        function obj = WBTask(nm)
            obj.name = nm;
        end % constructor

        function update(this)
        % UPDATE called during each iteration of the design

        end % update

        function stop(this)
        % STOP stop the task from updating each iteration
            this.active = 0;

            this.canvas.paintVeil();
        end % disable

        function reset(this)
        % RESET reset the task to 'default' values
            this.startTime = GetSecs;
        end % reset

        function start(this)
        % START start running the task (ie update each iteration of the design)
            this.startTime = GetSecs;
            this.active = 1;
        end % enable

        function keyboardInput(this, c)
        % KEYBOARDINPUT receive keyboard input

        end % keyboardInput

        function mouseInput(this, x, y, buttons)
        % MOUSEINPUT receive mouse input

        end % mouseInput

        function bool = isActive(this)
        % ISACTIVE flag indicating whether the task is currently running
            bool = this.active;
        end % isActive

        function bool = isAlphabetic(this, c)
            bool = 0;
            if ((c > 64 & c < 91) | (c > 96 & c < 123)) % char codes for A-Z and a-z
                bool = 1;
            end
        end

        function bool = isNumeric(this, c)
            bool = 0;
            if (c > 47 & c < 58) % char codes for 0-9
                bool = 1;
            end
        end

        function perf = avgPerformance(this)
        % AVGPERFORMANCE The average performance over the last trial
            perf = 0;
        end

        % GETTERS AND SETTERS
        function set.eventBuffer(this, value)
            this.eventBuffer = value;
        end

        function value = get.eventBuffer(this)
            value = this.eventBuffer;
        end

        function value = get.activeTime(this)
            value = GetSecs - this.startTime;
        end

    end % methods

end
