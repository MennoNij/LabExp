classdef TrialTonesInstruction < WBTrial

    methods
        function start(this)
            roundn = this.flow.variable(['Block0-RoundNum']);

            % CREATE THE INSTRUCTION SCREEN
            ti = WBTextDisplay('TONES TEXT', '', 26);
            %ti.xLoc = 50;
            if (roundn == 0)
            ti.text = {'Now you will practice the tone counting task.' ...
                       'You will hear a series of high and low tones during the trial. Your goal is to' ...
                       'count all the *high* tones you hear (the first tone will always be high). At the end of a trial' ...
                       'you must enter the number of high tones you heard, after which you will receive feedback.' ...
                       'You have around 10 seconds to input the answer' ...
                       '' ...
                       'Entering the number of tones will by done by cycling through the digits using' ...
                       'the keys shown above the triangles. If you went a digit too far, just keep pressing until' ...
                       'the digit goes from 9 back to 0. After selecting, just wait for the next trial to start.' ...
                       '' ...
                       'Press Q'};
            else
                ti.text = {'Practice: Tone Counting' ...
                            };

            end

            this.design.buildScene('TONES INSTRUCTIONS', {ti}, '1');

            this.design.loadScene('TONES INSTRUCTIONS');
            this.design.findTask('TONES TEXT').start();
        end

        function update(this)
            roundn = this.flow.variable(['Block0-RoundNum']);
            if (roundn > 0)
                if (GetSecs - this.startTime > 2)
                    this.flow.trial = TrialTonesPrac;
                end
            else
                if (this.design.newEvents())
                    e = this.design.findEvents('TONES TEXT:keyPressed');

                    if (~isempty(e))
                        key = lower(e{1}.measure('key'));
                        if (strcmp('return', key) | strcmp('q', key))
                            % start practice block
                            this.flow.trial = TrialTonesPrac;
                        end
                    end
                end
            end

        end
    end
end
