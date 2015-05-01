classdef TrialPresent < WBTrial

    properties
        condition = 0;
    end

    methods
        function start(this)
            block = this.flow.variable(['BlockNum']);
            nb = num2str(block);

            % new trial; update trial number
            trial = this.flow.variable(['Block' nb '-TrialNum']);
            trial = trial+1;
            this.flow.variable(['Block' nb '-TrialNum'], trial);

            % get the trial type from the trial order var
            order = this.flow.variable(['Block' nb '-Order']);
            this.condition = order(trial);

            switch (this.condition)
                case {0}
                    this.design.loadScene('SHOW Fx');
                case {1}
                    this.design.loadScene('SHOW NB');
                case {2}
                    this.design.loadScene('SHOW TR');
                case {3}
                    this.design.loadScene('SHOW TC');
                case {4}
                    this.design.loadScene('SHOW nB-Tr');
                case {5}
                    this.design.loadScene('SHOW Tc-Tr');
                otherwise
                    this.design.loadScene('SHOW nB-Tc');
            end

            this.design.startAllTasks();
        end

        function update(this)
            if (GetSecs - this.startTime > 1.95)
                %disp('Done with type');
                %disp(GetSecs - this.startTime)
                %fprintf('%.3f\n',GetSecs);

                nextTrial = TrialDualTask;

                if (this.condition < 4)
                    nextTrial = TrialSingleTask;
                end

                nextTrial.condition = this.condition;

                this.flow.trial = nextTrial;
            end
        end
    end % methods
end


