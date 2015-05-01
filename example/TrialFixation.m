classdef TrialFixation < WBTrial
    properties
        block = 1;
    end

    methods

        function start(this)
            this.block = this.flow.variable(['BlockNum']);
            this.design.loadScene('DOFIXATION')

            this.design.startAllTasks();
            %this.design.findTask('FIXATION').start();

        end

        function update(this)
            trial = this.flow.variable(['Block' num2str(this.block) '-TrialNum']);
            trial = trial+1;
            order = this.flow.variable(['Block' num2str(this.block) '-Order']);
            condition = order(trial);

            if (GetSecs - this.startTime > 8)
                doFMRI = this.flow.variable('forFMRI');
                if (doFMRI & this.block > 0) % sync trial with fMRI
                    e = this.design.findEvents('FIXATION:MRISync');
                    if(~isempty(e))
                        this.flow.trial = TrialPresent;
                        %disp('Synced\n');
                        %disp(GetSecs);
                        %fprintf('%.3f\n',GetSecs);
                    end
                else
                    this.flow.trial = TrialPresent;
                end
                %if (this.block == 1)
                    %this.flow.trial = TrialShowSingle;
                %else
                    %this.flow.trial = TrialShowDual;
                %end

            end

            e = this.design.findEvents('FIXATION:MRISync');
            if(~isempty(e))

                cond = 'Fx';
                switch (condition)
                    case {1}
                        cond = 'N_';
                    case {2}
                        cond = 'T_';
                    case {3}
                        cond = 'C_';
                    case {4}
                        cond = 'NT';
                    case {5}
                        cond = 'CT';
                    case {6}
                        cond = 'NT';
                    otherwise
                        cond = 'Fx';
                end

                %fprintf('%.2f',GetSecs);
                %disp(trial);
                %disp(cond);

                db = this.flow.database(['Block' num2str(this.block) '-MRITriggers']);
                db.addData({'pp' this.flow.variable('participantID') ...
                            'trial' num2str(trial) ...
                            'condition' ['Fx' cond] ...
                            'key' e{1}.measure('key') ...
                            'exptime' (e{1}.measure('time') - this.flow.startTime) ...
                            'rawtime' e{1}.measure('time') ...
                           });
                db.write();
            end
        end

    end
end

%classdef TrialFixation < WBTrial

    %methods

        %function start(this)
            %this.design.loadScene('DOFIXATION');

            %this.design.startAllTasks();

        %end

        %function update(this)
            %if (GetSecs - this.startTime > 30)
                %% practiced for 20 seconds, go to the next trial
                %this.flow.trial = TrialTrackingInstruction;

            %end

        %end
    %end
%end
