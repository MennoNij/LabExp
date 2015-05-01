classdef TrialTonesPrac < WBTrial

    methods

        function start(this)
            this.design.loadScene('SINGLE-TONES')

            this.design.startAllTasks();

        end

        function update(this)
            if (GetSecs - this.startTime > 29.5)

                this.design.findTask('TONES').finishTrial();

                e = this.design.findEvents('TONES:finished');
                if (~isempty(e))

                    roundn = this.flow.variable(['Block0-RoundNum']);
                    roundn = roundn+1;
                    this.flow.variable(['Block0-RoundNum'], roundn);

                    maxround = this.flow.variable('Block0-MaxRound');

                    if (roundn < maxround)
                        this.flow.trial = TrialNbackInstruction;
                    else
                        % done with practice, do block 1 (after 1back practice)
                        this.flow.variable('BlockNum', 0);
                        this.flow.trial = TrialStartBlock;
                    end
                end
            end

        end
    end
end
