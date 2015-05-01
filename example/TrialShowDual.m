classdef TrialShowDual < WBTrial

    properties
        condition = 0;
    end

    methods
        function start(this)

            % new trial; update trial number
            trial = this.flow.variable('Block2-TrialNum');
            trial = trial+1;
            this.flow.variable('Block2-TrialNum', trial);

            % get the trial type from the trial order var
            order = this.flow.variable('Block2-Order');
            this.condition = order(trial);

            switch (this.condition)
                case {0}
                    this.design.loadScene('BLOCK2 nB-Tr');
                case {1}
                    this.design.loadScene('BLOCK2 Tc-Tr');
                otherwise
                    this.design.loadScene('BLOCK2 nB-Tc');
            end

            this.design.startAllTasks();
        end

        function update(this)
            if (GetSecs - this.startTime > 2)
                nextTrial = TrialDualTask;

                nextTrial.condition = this.condition;

                this.flow.trial = nextTrial;
            end
        end
    end % methods
end

