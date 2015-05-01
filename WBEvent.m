classdef WBEvent
% A single event which is stored in the event buffer.

    properties (SetAccess = public, GetAccess = public)
        name                % name of the event
        timestamp           % the timestamp at which the event was created
        measures            % a tuple list of measures appended to the event
    end

    methods
        function obj = WBEvent(nm, msrs)
            obj.name = nm;
            obj.timestamp = GetSecs;
            obj.measures = msrs;
        end

        function value = measure(this, name)
        % MEASURE retrieve measure from the event, given its name
            for (i = 1:length(this.measures))
                if (strcmp(name, this.measures{i}{1}))
                    value = this.measures{i}{2};
                end
            end
        end

        function value = get.name(this)
            value = this.name;
        end

        function value = get.timestamp(this)
            value = this.timestamp;
        end

    end % methods

end
