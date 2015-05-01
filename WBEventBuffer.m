classdef WBEventBuffer < handle
% The intermediary between the Scene and the Flow: the Scene adds events to the buffer, which can be read by the Flow.

    properties (SetAccess = private, GetAccess = private)
        buffer = {};        % the list of events currently in the buffer
        len = 0;
    end % properties

    properties (SetAccess = private, GetAccess = public)
        filled = 0;
    end

    methods
        function add(this, name, measures)
        % ADD add a new event object to the buffer
            if (nargin < 3)
                measures = {};
            end

            %disp(['Added event ', name]);
            this.buffer{end+1} = WBEvent(name, measures);
            this.len = this.len+1; %length(this.buffer);
            this.filled = 1;
        end % add

        function found = find(this, name)
        % FIND find an event in the buffer given its name
            found = {};

            for (i = 1:this.len) % gives the low number of events created during each main loop, a for works fine here
                if (strcmp(this.buffer{i}.name, name))
                    % add to output
                    found{end+1} = this.buffer{i};
                end
            end
        end % found

        function empty(this)
        % EMPTY delete all events from the current buffer
            this.buffer = {};
            this.len = 0;
            this.filled = 0;
        end % empty
    end % methods
end
