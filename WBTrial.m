classdef WBTrial < handle

    properties (SetAccess = public, GetAccess = public)
        name = 'Trial';         % The trial (type) name
        id                      % unique id for the trial
        startTime               % the time at which the trial was started
        design                  % the design which the trial can manipulate
        flow                    % the flow 'parent' to which the trial belongs
    end % properties

    methods

        function start(this)
        % START called when the trial is set as the active trial

        end % start

        function update(this)
        % UPDATE called each iteration of the experiment
            
        end

        function set.startTime(this, value)
            this.startTime = value;
        end

        function set.design(this, value)
            this.design = value;
        end

        function set.flow(this, value)
            this.flow = value;
        end

        function value = time(this)
            value = GetSecs - this.startTime;
        end
    end

end
