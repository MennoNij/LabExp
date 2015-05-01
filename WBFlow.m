classdef WBFlow < handle
% Handles the 'flow' of the experiment: trials, events, etc.

    properties (SetAccess = public, GetAccess = public)
        name = 'ExperimentFlow';    % name/id of the experiment flow
        design                      % design which the flow can manipulate
        eventBuffer                 % the even buffer shared between the design and the flow
        trial                       % the currently active experimental trial

        dataDir
    end % properties

    properties (SetAccess = private, GetAccess = public)
        startTime = 0;              % the timestamp at which the flow was started
        trialCount = 0;             % a counter for the number of trials that have been run so far
    end

    properties (SetAccess = private, GetAccess = private)
        dataArray                   % an array of all the currently active databases
        variables = {};             % contains all 'global' variables which can be used inside trial objects

        started = 0;                % flag indicating that the experiment/flow has started
        finished = 0;               % flag indicating that the flow has just finished the experiment
    end

    methods
        function obj = WBFlow(evnts)
            if (nargin == 1)
                obj.eventBuffer = evnts;
            end
        end % constructor

        function update(this)
        % UPDATE called at each iteration of the experiment loop. Updates the current trial
            this.trial.update();
        end % update

        function start(this)
        % START start the flow (and thus the actual experiment)
            this.started = 1;
            this.startTime = GetSecs;
        end % start

        function finish(this)
        % FINISH called when the flow has completed. This will signal the experiment to stop iterating
            this.finished = 1;

            % close all the databases
            %for (i = 1:length(this.dataArray))
                %this.dataArray{i}.close();
            %end
            fclose('all');
        end % finish

        function bool = isFinished(this)
            % ISFINISHED flag indicating whether the flow has finished
           bool = this.finished;
        end % isFinished

        % GETTERS AND SETTERS

        function addDatabase(this, base)
        % ADDDATABASE add a new database to which data can be written
            idx = this.findDatabase(base.name);
            if (idx > 0)
                %this.dataArray{idx} = base;
                error(['Attempted to overwrite database (' base.name ')']);
            else
                this.dataArray{end+1} = base;
                base.open();
            end
        end

        function value = database(this, name)
        % DATABASE try to find a currently active database
            value = 0;
            idx = this.findDatabase(name);

            if (idx > 0)
                value = this.dataArray{idx};
            else
                error(['Could not find requested database (' name ')']);
            end
        end

        function idx = findDatabase(this, name)
        % FINDDATABASE retrieve the index of a database given its name
            idx = 0;
            for (i = 1:length(this.dataArray))
                if (strcmp(this.dataArray{i}.name, name))
                    idx = i;
                end
            end
        end

        function set.eventBuffer(this, value)
            this.eventBuffer = value;
        end

        function value = get.eventBuffer(this)
            value = this.eventBuffer;
        end

        function set.design(this, value)
            if (~this.started) % avoid this can of worms
                this.design = value;
            end
        end

        function set.trial(this, value)
        % TRIAL set the currently active trial
            this.trial = value;
            this.trial.design = this.design;
            this.trial.flow = this;

            this.trialCount = this.trialCount + 1;

            if (this.started)
                this.trial.start();
                this.trial.startTime = GetSecs;
            end
        end

        function value = variable(this, name, val)
        % VARIABLE grab or set a 'global' variable. This list of name/value pairs is available to all trials
            value = '';

            idx = 0;
            n = length(this.variables);

            if (n > 0)
                vNames = this.variables(1:2:length(this.variables));
                %disp('var names');
                loc = strcmp(vNames, name);
                idx = find(loc)*2;
            end

            if (nargin > 2)
                % set value of the supplied variable name
                if (idx > 0)
                    % update the value
                    %disp(['updating ' name ' at ' num2str(idx)]);
                    this.variables{idx} = val;
                else
                    %disp(['appending ' name]);
                    % if it doesn't exist, append it to the globals array
                    this.variables{end+1} = name;
                    this.variables{end+1} = val;
                end
            else
                % retrieve value of the supplied variable name
                if (idx > 0)
                    value = this.variables{idx};
                else
                    error('Could not find requested variable (', name, ')');
                end
            end
        end

        function value = time(this)
            value = GetSecs - this.startTime;
        end
    end % methods
end
