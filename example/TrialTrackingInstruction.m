classdef TrialTrackingInstruction < WBTrial

    methods
        function start(this)
            roundn = this.flow.variable(['Block0-RoundNum']);

            % CREATE THE INSTRUCTION SCREEN
            ti = WBTextDisplay('TRACKING TEXT', '', 26);
            %ti.xLoc = 50;
            if (roundn == 0)
                ti.text = {'Now you will practice the dot tracking task.' ...
                           'Your goal is to keep the circle on top of the moving dot.' ...
                           'This is done with the U and I keys. By pressing U you push the dot to the left, and' ...
                           'by pressing I you push the dot to the right.' ...
                           'If the circle goes outside the two moving lines surrounding the dot, it will be too far away,' ...
                           'and the lines will turn red.' ...
                           '' ...
                           'Press Q'};
            else
                ti.text = {'Practice: Tracking' ...
                            };

            end

            this.design.buildScene('TRACKING INSTRUCTIONS', {ti}, '1');

            this.design.loadScene('TRACKING INSTRUCTIONS');
            this.design.findTask('TRACKING TEXT').start();
        end

        function update(this)
            roundn = this.flow.variable(['Block0-RoundNum']);
            if (roundn > 0)
                if (GetSecs - this.startTime > 2)
                    this.flow.trial = TrialTrackingPrac;
                end
            else
                if (this.design.newEvents())
                    e = this.design.findEvents('TRACKING TEXT:keyPressed');

                    if (~isempty(e))
                        key = lower(e{1}.measure('key'));
                        if (strcmp('return', key) | strcmp('q', key))
                            % start practice block
                            this.flow.trial = TrialTrackingPrac;
                        end
                    end
                end
            end

        end
    end
end
