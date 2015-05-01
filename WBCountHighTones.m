classdef WBCountHighTones < WBTask

    properties
        Fs = 22050;
        tones = {};
        players = {};
        duration = 0.05;
        presRate = 1;
        fontSize = 24;
        probabilities = [];
        freqs = [];

        trialDuration = 29.5;
        toneTimes = [];
        toneSequence = [];
        foilTone = 1;
        foilChance = 0.3;
        toneIdx = 1;
        answerSpace = [10 11 12 13 14 15 16 17];
        remainingAnswers = [];

        answerSide = 0;

        triggeredTones = 1;

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

        digits = [0 0];
        correct = 0;
        distance = 0;

        feedbackTimer;
        feedbackDuration = 0.8;
        answerTimeout = 0;

        runningWindows = 0;
        winLow = [];
        winHigh = [];
        numberFont = 'Courier';
        keyLeftTens = 'e';
        keyLeftOnes = 'r';
        keyRightTens = 'u';
        keyRightOnes = 'i';

        keyLeftTensAlt = '(';
        keyLeftOnesAlt = ')';
        keyRightTensAlt = '_';
        keyRightOnesAlt = '+';
    end

    methods
        function obj = WBCountHighTones(nm)
            obj@WBTask(nm);
            freq = 0.28;
            obj.buildTones([261.63 493.88], [0.3 0.7], 0.15); % C4 and A4 tones

            %obj.buildTones([493.88], [1], 0.10);
            %obj.presRate = 2.2;
            %obj.presRate = 1.8;
            obj.presRate = 1.5;
            %obj.targetTone = 2;
            obj.targetTone = 2;

            %dur = 0.1;
            %obj.buzzer = sin(linspace(0, dur*500*2*pi, round(dur*obj.Fs)));
            [y1, Fs1] = wavread('tone_low.wav');
            [y2, Fs2] = wavread('tone_high.wav');
            obj.winLow = y1;
            obj.winHigh = y2;

            obj.feedbackTimer = WBTimer;
        end

        function start(this)
            start@WBTask(this);

            this.responseBox = WBInputbox(this.canvas, 30, 'center', 'center', 4);

            this.nextTrial();
        end

        function stop(this)
            this.active = 0;
        end

        function buildTones(this, toneFreqs, probs, dur)
            this.duration = dur;
            this.probabilities = probs;
            this.freqs = toneFreqs;

            for (i = 1:length(toneFreqs))
                this.tones{i} = sin(linspace(0, dur*toneFreqs(i)*2*pi, round(dur*this.Fs)));
                this.players{i} = audioplayer(this.tones{i}, this.Fs);
            end

        end

        function update(this)
            if (this.active)
                t = GetSecs;
                if (~this.finishedTrial & t > this.presTime)
                    % play tone
                    %sound(this.tones{this.nextTone}, this.Fs); % not asynchronous!
                    if (this.runningWindows) % fmri stim PC doesn't understand audioplayer...
                        if (this.nextTone == 1)
                            wavplay(this.winLow, this.Fs, 'async');
                        else
                            wavplay(this.winHigh, this.Fs, 'async');
                        end

                    else
                        play(this.players{this.nextTone});
                    end

                    this.eventBuffer.add([this.name ':playedTone'], ...
                                         {{'freq' this.freqs(this.nextTone)} ...
                                         });

                    this.toneCounts(this.nextTone) = this.toneCounts(this.nextTone) + 1;

                    this.toneIdx = this.toneIdx + 1;
                    if (this.toneIdx <= length(this.toneTimes))
                        this.presTime = this.toneTimes(this.toneIdx);
                        this.nextTone = this.toneSequence(this.toneIdx);
                    else
                        this.presTime = t+99999;
                    end

                else
                    % wait until feedback is done
                    if (this.feedbackTimer.running & this.feedbackTimer.passed)
                        this.eventBuffer.add([this.name ':finished'], {});
                    else
                        if (t > this.answerTimeout)
                            this.keyboardInput('+');
                        end
                    end
                end
            end

        end

        function nextTrial(this)
            if (this.active)
                this.finishedTrial = 0;
                this.RT = 0;
                this.toneCounts = zeros(1, length(this.tones));
                this.digits = [0 0];

                this.canvas.setMouse(0, 0);

                this.canvas.wipe(0);
                this.paintFixation();
                %this.canvas.paint();

                this.generateTones();
                this.toneIdx = 1;
                this.nextTone = this.toneSequence(1);
                this.presTime = this.toneTimes(1);
            end
        end

        function paintFixation(this)
            [xC, yC] = this.canvas.getCenter();

            col = [255 255 255];
            crss = 25;
            lns = [-crss crss -crss crss; ...
                   -crss crss crss  -crss];
            Screen('DrawLines', this.canvas.area, lns, 2, col, [xC yC]);

            this.canvas.paint();
        end

        function testGenerator(this)

    end

        function generateTones(this)
            this.toneSequence = [];
            this.toneTimes = [];

            %s = 0.5*this.presRate; % max 'noise' in presentation frequency
            %prevTone = GetSecs+0.1;
            %trialEnd = GetSecs+this.trialDuration-0.5;
            %%prevTone = 0.5;
            %%trialEnd = 29.0;

            %while (prevTone < trialEnd)
                %offset = this.presRate-s + 2*s*rand(1);
                %nextTone = prevTone+offset;

                %if (nextTone >= trialEnd)
                    %break; % no more extra tones
                %end

                %this.toneTimes = [this.toneTimes nextTone];
                %this.toneSequence = [this.toneSequence this.targetTone];

                %prevTone = nextTone;
            %end

            %disp(this.toneTimes)

            % generate the tones and jitter the presentation time
            this.toneTimes = jitter(0.5:this.presRate:(this.trialDuration-0.4), 2);
            this.toneTimes(this.toneTimes < 0.3) = 0.3;
            this.toneTimes(this.toneTimes > this.trialDuration) = this.trialDuration;
            this.toneTimes = this.toneTimes+GetSecs;

            num = length(this.toneTimes);
            this.toneSequence = ones(1, num)*this.targetTone;

            if (length(this.remainingAnswers) == 0)
                % all answers have been used once, reset the set
                this.remainingAnswers = this.answerSpace;
            end

            % pick an answer
            pickIdx = randi([1 length(this.remainingAnswers)]);
            answer = min(this.remainingAnswers(pickIdx), num);
            this.remainingAnswers(pickIdx) = [];

            %minFoils = 2;
            %maxFoils = round(num*0.5);
            %numFoils = round(this.foilChance*num);

            % vary foils a bit
            %if (rand(1) > 0.5)
                %numFoils = numFoils + randi([0 2]);
            %else
                %numFoils = numFoils - randi([0 2]);
            %end

            %if (numFoils < 2)
                %numFoils = 2;
            %end

            %disp(numFoils)
            %actualTones = num-numFoils

            places = [2:num];
            numFoils = num-answer;
            %numFoils = randi([minFoils maxFoils]);

            for (i = 1:numFoils)

                idx = randi([1 length(places)]);
                repIdx = places(idx);
                places(idx) = [];

                this.toneSequence(repIdx) = this.foilTone;
            end

            %disp(this.toneSequence)
        end

        % messy code, but it works
        function generateTone(this)
            %s = 0.5*this.presRate; % max 'noise' in presentation frequency
            s = 0.5*this.presRate; % max 'noise' in presentation frequency
            tOff = this.presRate-s + 2*s*rand(1);

            % presentation time of the next tone
            this.presTime = GetSecs + tOff;

            % determine which tone to show
            idx = 0;
            totalProb = 0;

            rn = rand(1);
            % use the probabilities as a partitioning to determine the tone index
            for (i = 1:length(this.probabilities-1))
                totalProb = totalProb + this.probabilities(i);
                if (rn <= totalProb)
                    idx = i;
                    break;
                end
            end

            if (idx < 1)
                idx = length(this.probabilities);
            end

            %disp(idx);
            %this.nextTone = round(1 + (length(this.tones)-1)*rand(1));
            this.nextTone = idx;
            if (this.firstTone == 1)
                this.nextTone = this.targetTone;
                this.firstTone = 0;
            end
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
                this.canvas.wipe(0);

                Screen('TextFont', this.canvas.area, 'Helvetica');
                Screen('TextSize', this.canvas.area, this.fontSize);
                Screen('TextStyle', this.canvas.area, 0);
                DrawFormattedText(this.canvas.area, 'Select the number of high tones \n you heard and wait. \n (note: 0 will appear again after 9)', ...
                                                    'center', yC - this.fontSize*8.0, 255, 0, 0, 0, 1);

                %this.responseBox.paint();
                this.paintAnswerDial();
                this.canvas.paint();

                this.responseStart = GetSecs;
                this.finishedTrial = 1;
                this.answerTimeout = this.responseStart + 9.2;
            end
        end

        function showFeedback(this, correct)
            txt = ['Incorrect: ' num2str(this.toneCounts(this.targetTone))];
            col = [180 0 0];

            if (correct)
                txt = 'Correct';
                col = [0 160 0];
            end

            [xC, yC] = this.canvas.getCenter();
            DrawFormattedText(this.canvas.area, txt, 'center', yC + this.fontSize*5.0, col, 0, 0, 0, 1);

            this.feedbackTimer.start(this.feedbackDuration);
            this.canvas.paint();

        end

        function paintAnswerDial(this)
            [xC, yC] = this.canvas.getCenter();
            d = 50;

            Screen('FillRect', this.canvas.area, 0, [(xC-d) (yC-d) (xC+d) (yC+d)]);

            Screen('TextFont', this.canvas.area, this.numberFont);
            Screen('TextSize', this.canvas.area, this.fontSize*2);
            Screen('TextStyle', this.canvas.area, 0);

            [nx, ny, bounds] = DrawFormattedText(this.canvas.area, [num2str(this.digits(1)) ' ' num2str(this.digits(2))], 'center', 'center', 255, 0, 0, 0, 1); 
            %Screen('FrameRect', this.canvas.area, [0 0 0], bounds);

            % draw triangles
            p1x = bounds(1);                    p1y = bounds(2)-5;
            p3x = bounds(1)+this.fontSize*1.25; p3y = bounds(2)-5;
            p2x = (p1x+p3x)*0.5;                p2y = p3y - this.fontSize*0.5;

            trans = bounds(3)-p3x;
            Screen('FillPoly', this.canvas.area, [255 255 255], [p1x p1y; p2x p2y; p3x p3y]);
            Screen('FillPoly', this.canvas.area, [255 255 255], [p1x+trans p1y; p2x+trans p2y; p3x+trans p3y]);

            %invert stuff for lower triangles
            %q1x = p1x;      q1y = bounds(4)+5;
            %q3x = p3x;      q3y = bounds(4)+5;
            %q2x = p2x;      q2y = q3y + this.fontSize*0.5;

            %Screen('FillPoly', this.canvas.area, [0 0 0], [q1x q1y; q2x q2y; q3x q3y]);
            %Screen('FillPoly', this.canvas.area, [0 0 0], [q1x+trans q1y; q2x+trans q2y; q3x+trans q3y]);

            Screen('TextFont', this.canvas.area, 'Helvetica');
            Screen('TextSize', this.canvas.area, this.fontSize);
            Screen('TextStyle', this.canvas.area, 0);

            if (this.answerSide == 0)
                DrawFormattedText(this.canvas.area, [upper(this.keyRightTens)], p1x+0.25*this.fontSize, p2y-this.fontSize*1.5, 255, 0, 0, 0, 1);
                DrawFormattedText(this.canvas.area, [upper(this.keyRightOnes)], p1x+0.25*this.fontSize+trans, p2y-this.fontSize*1.5, 255, 0, 0, 0, 1);
                %DrawFormattedText(this.canvas.area, ['O'], p1x+0.25*this.fontSize, q2y+5, 0, 0, 0, 0, 1);
                %DrawFormattedText(this.canvas.area, ['P'], p1x+0.25*this.fontSize+trans, q2y+5, 0, 0, 0, 0, 1);
            else
                DrawFormattedText(this.canvas.area, [upper(this.keyLeftTens)], p1x+0.25*this.fontSize, p2y-this.fontSize*1.5, 255, 0, 0, 0, 1);
                DrawFormattedText(this.canvas.area, [upper(this.keyLeftOnes)], p1x+0.25*this.fontSize+trans, p2y-this.fontSize*1.5, 255, 0, 0, 0, 1);
            end

        end

        function perf = avgPerformance(this)
            perf = this.correct;
        end

        function dist = avgDistance(this)
            dist = this.distance;
        end

        function keyboardInput(this, c)
            if (this.active & this.finishedTrial & ~this.feedbackTimer.running)

                %if (strcmp(lower(c), 'q') | strcmp(lower(c), 'return'))
                if (strcmp(lower(c), '+'))
                    % response was submitted, generate event
                    this.correct = 0;

                    input = 10*this.digits(1) + this.digits(2);

                    if (input == this.toneCounts(this.targetTone))
                        this.correct = 1;
                    end

                    this.distance = abs(input - this.toneCounts(this.targetTone));

                    this.showFeedback(this.correct);

                    this.eventBuffer.add([this.name ':submittedResponse'], ...
                                         {{'response' input} ...
                                          {'answer' this.toneCounts(this.targetTone)} ...
                                          {'correct' this.correct} ...
                                          {'total' sum(this.toneCounts)} ...
                                          {'allCounts' this.toneCounts} ...
                                          {'RT' this.RT} ...
                                         });

                else
                    d = c(1);

                    up1 = this.keyRightTens;
                    up2 = this.keyRightOnes;
                    up11 = this.keyRightTensAlt;
                    up22 = this.keyRightOnesAlt;

                    if (this.answerSide == 1)
                        up1 = this.keyLeftTens;
                        up2 = this.keyLeftOnes;
                        up11 = this.keyLeftTensAlt;
                        up22 = this.keyLeftOnesAlt;
                    end

                    switch (d)
                        case {up1}
                            this.digits(1) = mod(this.digits(1)+1, 10);
                        case {up11}
                            this.digits(1) = mod(this.digits(1)+1, 10);
                        %case {'o'}
                            %this.digits(1) = mod(this.digits(1)-1, 10);
                        case {up2}
                            this.digits(2) = mod(this.digits(2)+1, 10);
                        case {up22}
                            this.digits(2) = mod(this.digits(2)+1, 10);
                        %case {'p'}
                            %this.digits(2) = mod(this.digits(2)-1, 10);
                    end

                    this.paintAnswerDial();
                    this.canvas.paint();

                end
            end
        end

        %function mouseInput(this, x, y, buttons)
           %if (this.tonePlayed > 0 & sum(buttons) > 0)
               %button = 'L';
               %if (buttons(2))
                   %button = 'R';
               %end
               %RT = GetSecs - this.tonePlayed;

               %this.eventBuffer.add([this.name ':click'], {{'button' button} {'RT' RT}});
               %this.tonePlayed = 0;
           %end

        %end

    end % methods

end

