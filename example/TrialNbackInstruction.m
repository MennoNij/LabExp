classdef TrialNbackInstruction < WBTrial

    methods
        function start(this)
            roundn = this.flow.variable(['Block0-RoundNum']);

            % CREATE THE INSTRUCTION SCREEN
            ti = WBTextDisplay('NBACK TEXT', '', 26);
            %ti.xLoc = 50;
            if (roundn == 0)
                ti.text = {'First you will practice the 2-back task.' ...
                        'You will see a series of letters appearing on the screen. Your goal is to indicate' ...
                        'if the letter on the screen is the same one you saw two letters ago.' '' ...
                        'For instance: if you previously saw A L Q T S and are now looking at T, then' ...
                        'you should indicate that it is the same by pressing the E key on the keyboard' ...
                        'If the letter you currently see is not the same as the one two letters ago, then' ...
                        'you should press the R key on the keyboard. You can still respond after the letter' ...
                        'has disappeared. You will get feedback in the form of a green or red circle whether' ...
                        'you were correct. If you react too slowly, it will be counted as an incorrect response.' ...
                           '' ...
                           'Press Q'};
            else
                ti.text = {'Practice: 2-back' ...
                           };
            end

            this.design.buildScene('NBACK INSTRUCTIONS', {ti}, '1');

            this.design.loadScene('NBACK INSTRUCTIONS');
            this.design.findTask('NBACK TEXT').start();
        end

        function update(this)
            roundn = this.flow.variable(['Block0-RoundNum']);
            if (roundn > 0)
                if (GetSecs - this.startTime > 2)
                    this.flow.trial = TrialNbackPrac;
                end
            else
                if (this.design.newEvents())
                    e = this.design.findEvents('NBACK TEXT:keyPressed');

                    if (~isempty(e))
                        key = lower(e{1}.measure('key'));
                        if (strcmp('return', key) | strcmp('q', key))
                            % start practice block
                            this.flow.trial = TrialNbackPrac;
                        end
                    end
                end
            end

        end
    end
end
