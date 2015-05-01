classdef TrialInstruction < WBTrial
    properties
        screenNum = 0;
    end

    methods
        function start(this)

            % CREATE THE INSTRUCTION SCREEN
            ti = WBTextDisplay('INTRO TEXT', '', 24);
            %ti.xLoc = 50;
            ti.text = {'As this experiment is about multitasking, you will be performing two tasks' ...
                       'at the same time. First, however, you will practice each task seperately.' ...
                       '' ...
                       'Place the fingers of your left hand on the E and R keys, and the fingers' ...
                       'of your right hand over the U and I keys' ...
                       'of the keyboard.' ...
                       'Press Q'};

            this.design.buildScene('INSTRUCTIONS', {ti}, '1');

            %this.flow.variable('Block0-RoundNum', 0);

            this.design.loadScene('INSTRUCTIONS');
            this.design.findTask('INTRO TEXT').start();
        end

        function update(this)
            if (this.design.newEvents())
                e = this.design.findEvents('INTRO TEXT:keyPressed');

                if (~isempty(e))
                    key = lower(e{1}.measure('key'));
                    if (strcmp('return', key) | strcmp('q', key))
                        % start practice block
                        this.flow.trial = TrialNbackInstruction;
                        %this.flow.trial = Trial1BackInstruction;
                        %this.flow.trial = TrialStartFirstBlock;
                        %this.flow.trial = TrialTonesInstruction;
                        %this.flow.trial = TrialTrackingInstruction;
                        %this.flow.trial = TrialStartSecondBlock;
                        %this.flow.trial = TrialFixation;
                        %this.flow.trial = TrialSingleTask;
                        %this.flow.trial=Trial1back;
                    end
                end
            end

        end
    end
end
