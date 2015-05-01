classdef TrialSync < WBTrial
    properties
        block = 0;
    end

    methods
        function start(this)
            this.block = this.flow.variable(['BlockNum']);
            %doFMRI = this.flow.variable('forFMRI');

            this.design.loadScene('SYNC SCREEN');
            this.design.startAllTasks();
        end

        function update(this)
            if (this.design.newEvents())
                e = this.design.findEvents('SYNC TEXT:keyPressed');
                if(~isempty(e))
                    key = e{1}.measure('key');
                    key = key(1);

                    if (key == 't' | key == '5')

                        db = this.flow.database(['Block' num2str(this.block) '-MRITriggers']);
                        db.addData({'pp' this.flow.variable('participantID') ...
                                    'trial' 0 ...
                                    'condition' 'SY' ...
                                    'key' key ...
                                    'exptime' (e{1}.measure('time') - this.flow.startTime) ...
                                    'rawtime' e{1}.measure('time') ...
                                   });
                        db.write();

                        this.flow.trial = TrialFixation;
                    end
                end
            end

        end
    end
end
