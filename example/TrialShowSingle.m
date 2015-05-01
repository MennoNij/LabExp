classdef TrialShowSingle < WBTrial

    properties
        condition = 0;
    end

    methods
        function start(this)

            % new trial; update trial number
            trial = this.flow.variable(['Block1-TrialNum']);
            trial = trial+1;
            this.flow.variable(['Block1-TrialNum'], trial);

            % get the trial type from the trial order var
            order = this.flow.variable(['Block1-Order']);
            this.condition = order(trial);

            switch (this.condition)
                case {0}
                    this.design.loadScene('BLOCK1 NB');
                case {1}
                    this.design.loadScene('BLOCK1 TR');
                otherwise
                    this.design.loadScene('BLOCK1 TC');
            end

            this.design.startAllTasks();
        end

        function update(this)
            if (GetSecs - this.startTime > 2)
                nextTrial = TrialSingleTask;
                nextTrial.condition = this.condition;

                this.flow.trial = nextTrial;
            end
        end
    end % methods
end

