classdef TrialTrackingPrac < WBTrial

    methods

        function start(this)
            this.design.loadScene('SINGLE-TRACKING')

            this.design.startAllTasks();

        end

        function update(this)
            if (GetSecs - this.startTime > 29.5)
                this.flow.trial = TrialTonesInstruction;

            end

        end
    end
end
