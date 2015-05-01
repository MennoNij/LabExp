classdef TrialNbackPrac < WBTrial

    methods

        function start(this)
            this.design.loadScene('SINGLE-NBACK')

            this.design.startAllTasks();

        end

        function update(this)
            if (GetSecs - this.startTime > 29.5)
                % practiced for 20 seconds, go to the next trial
                this.flow.trial = TrialTonesInstruction;

            end

        end
    end
end
