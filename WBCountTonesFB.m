classdef WBCountTonesFB < WBCountTones

    methods
        function obj = WBCountTonesFB(nm)
            obj@WBCountTones(nm);
        end

        function showFeedback(this, correct)
            txt = ['Wrong: ' num2str(this.toneCounts(this.targetTone))];
            col = [200 0 0];

            ftSzMult = 1.0;
            feedbackDur = this.feedbackDuration;

            if (correct)
                txt = 'Correct';
                col = [0 100 0];
            else
                ftSzMult = 4.0;
                feedbackDur = 6.0;
            end

            [xC, yC] = this.canvas.getCenter();
            Screen('TextSize', this.canvas.area, this.fontSize*ftSzMult);
            DrawFormattedText(this.canvas.area, txt, 'center', yC + this.fontSize*3.0, col, 0, 0, 0, 1);

            this.feedbackTimer.start(feedbackDur);
            this.canvas.paint();

            if (~correct)
                dur = 0.3;
                wrong = sin(linspace(0, dur*500*2*pi, round(dur*this.Fs)));
                sound(wrong);
            end

        end
    end % methods

end
