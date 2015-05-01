classdef WBTimer < handle
    properties (SetAccess = private, SetAccess = private)
        offset = 0;
        target = 0;
    end

    properties (SetAccess = private, GetAccess = public)
        running = 0;
    end

    properties (Dependent = true)
        passed
    end

    methods
        function start(this, trgt)
            this.offset = GetSecs;
            if (nargin > 1)
                this.target = trgt;
            end

            this.running = 1;
        end

        function stop(this)
            this.running = 0;
        end

        function reset(this)
            this.offset = GetSecs;
        end

        function duration = time(this)
            duration = GetSecs - this.offset;
        end

        function done = get.passed(this)
            done = 0;
            if (this.offset + this.target < GetSecs)
                done = 1;
                this.running = 0;
            end
        end
    end

end
