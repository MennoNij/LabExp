classdef WBCountTones < WBTask

    properties
        Fs = 22050;
        tones = {};
        duration = 0.05;
        presRate = 1;
        fontSize = 24;
        probabilities = [];

        triggeredTones = 1;
        triggerProbability = 0.8;

        presTime
        toneCounts
        targetTone
        nextTone
        finishedTrial = 0;
        response = [];
        responseBox
        responseStart = 0;
        RT = 0;

        tonePlayed = 0;
        clickSpan = 1.5;
        buzzer = [];

        feedbackTimer;
        feedbackDuration = 0.5;
    end

    methods
        function obj = WBCountTones(nm)
            obj@WBTask(nm);
            freq = 0.28;
            %obj.buildTones([1000 2500], [1/4 3/4], 0.05);
            obj.buildTones([1000], [1], 0.05);
            obj.presRate = 1/freq;
            obj.targetTone = 1;

            dur = 0.1;
            obj.buzzer = sin(linspace(0, dur*500*2*pi, round(dur*obj.Fs)));

            obj.feedbackTimer = WBTimer;
        end

        function start(this)
            start@WBTask();

            this.responseBox = WBInputbox(this.canvas, 30, 'center', 'center', 4);

            this.nextTrial();
        end

        function stop(this)
            this.active = 0;
        end

        function buildTones(this, toneFreqs, probs, dur)
            this.duration = dur;
            this.probabilities = probs;

            for (i = 1:length(toneFreqs))
                this.tones{i} = sin(linspace(0, dur*toneFreqs(i)*2*pi, round(dur*this.Fs)));
            end

        end

        function update(this)
            t = GetSecs;
            if (~this.finishedTrial & GetSecs > this.presTime)
                % play tone
                sound(this.tones{this.nextTone}, this.Fs);
                this.toneCounts(this.nextTone) = this.toneCounts(this.nextTone) + 1;

                this.tonePlayed = t;

                if (~this.triggeredTones)
                    % set next one
                    this.generateTone();
                else
                    % don't play the tone again
                    this.presTime = this.presTime + 9999;
                    this.generateTone();
                end
            elseif (this.tonePlayed > 0 & this.tonePlayed+this.clickSpan < t)
                % pp hasn't clicked yet, sound buzzer
                this.tonePlayed = 0;
                sound(this.buzzer);
            else
                % wait until feedback is done
                if (this.feedbackTimer.running & this.feedbackTimer.passed)
                    this.eventBuffer.add([this.name ':finished'], {});
                end
            end

        end

        function nextTrial(this)
            if (this.active)
                this.finishedTrial = 0;
                this.RT = 0;
                this.toneCounts = zeros(1, length(this.tones));

                this.canvas.setMouse(0, 0);

                this.canvas.wipe(255);
                this.canvas.paint();

                if (~this.triggeredTones)
                    this.generateTone();
                else
                    % possibly trigger a tone before entering the first digit
                    this.triggerTone();
                end
            end
        end

        function generateTone(this)
            s = 0.5*this.presRate; % 'noise' in presentation frequency
            tOff = this.presRate-s + 2*s*rand(1);

            % presentation time of the next tone
            this.presTime = GetSecs + tOff;

            % determine which tone to show
            idx = 0;
            totalProb = 0;

            % use the probabilities as a partitioning to determine the tone index
            for (i = 1:length(this.probabilities-1))
                totalProb = totalProb + this.probabilities(i);
                if (rand(1) < totalProb)
                    idx = i;
                    break;
                end
            end

            if (idx < 1)
                idx = length(this.probabilities);
            end

            %disp(idx);
            this.nextTone = round(1 + (length(this.tones)-1)*rand(1));
        end

        function triggerTone(this)
            % randomly determine if a tone should be played

            if (rand(1) < this.triggerProbability)
                offset = 0.1 + 0.95*rand(1);
                this.presTime = GetSecs + offset;
            end

            this.nextTone = length(this.tones);
        end

        function finishTrial(this)
            % display tone count input field

            if (~this.finishedTrial)
                [xC, yC] = this.canvas.getCenter();

                Screen('TextFont', this.canvas.area, 'Helvetica');
                Screen('TextSize', this.canvas.area, this.fontSize);
                Screen('TextStyle', this.canvas.area, 0);
                DrawFormattedText(this.canvas.area, 'How many tones did you count?', 'center', yC - this.fontSize*3.0, 0, 0, 0, 0, 1);

                this.responseBox.paint();
                this.canvas.paint();

                this.responseStart = GetSecs;
                this.finishedTrial = 1;
            end
        end

        function showFeedback(this, correct)
            txt = ['Incorrect: ' num2str(this.toneCounts(this.targetTone))];
            col = [200 0 0];

            if (correct)
                txt = 'Correct';
                col = [0 100 0];
            end

            [xC, yC] = this.canvas.getCenter();
            DrawFormattedText(this.canvas.area, txt, 'center', yC + this.fontSize*3.0, col, 0, 0, 0, 1);

            this.feedbackTimer.start(this.feedbackDuration);
            this.canvas.paint();

        end

        function keyboardInput(this, c)
            if (this.active & this.finishedTrial & ~this.feedbackTimer.running)

                if (strcmp(lower(c), 'return') | strcmp(lower(c), 'enter'))
                    % response was submitted, generate event
                    correct = 0;

                    if (str2num(this.responseBox.input) == this.toneCounts(this.targetTone))
                        correct = 1;
                    end

                    this.showFeedback(correct);

                    this.eventBuffer.add([this.name ':submittedResponse'], ...
                                         {{'response' this.responseBox.input} ...
                                          {'answer' this.toneCounts(this.targetTone)} ...
                                          {'correct' correct} ...
                                          {'allCounts' this.toneCounts} ...
                                          {'RT' this.RT} ...
                                         });

                elseif (strcmp(lower(c), 'backspace') | strcmp(lower(c), 'delete'))
                    this.responseBox.remove(1);
                    this.canvas.paint();
                else
                    if (this.RT == 0)
                        this.RT = GetSecs - this.responseStart;
                    end

                    c = c(1);
                    if (this.isNumeric(c))
                        % add it to the current response
                        this.responseBox.add(c);
                        this.responseBox.paint();
                        this.canvas.paint();

                    end
                end
            end
        end

        function mouseInput(this, x, y, buttons)
           if (this.tonePlayed > 0 & sum(buttons) > 0)
               button = 'L';
               if (buttons(2))
                   button = 'R';
               end
               RT = GetSecs - this.tonePlayed;

               this.eventBuffer.add([this.name ':click'], {{'button' button} {'RT' RT}});
               this.tonePlayed = 0;
           end

        end

    end % methods

end
