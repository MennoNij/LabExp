classdef WBNback < WBTask
    properties
        trialTimer
        stimStartTime

        n = 1;
        %isi = 0.25;
        isi = 1.5;
        %presTime = 2.0;
        %presTime = 1.5;
        presTime = 1.0;
        respondTime = 1.5;
        trialLength = 29.5;

        %characterSet = ['A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J'];
        %characterSet = ['C' 'H' 'I' 'K' 'L' 'Q' 'R' 'S' 'T' 'W'];
        characterSet = [];
        sequence = [];
        currentLetter = 1;

        %characterSet = ['B' 'D' 'J' 'I' 'U' 'V' 'E' 'F' 'N'];
        %characterSet = ['0' '1' '2' '3' '4' '5' '6' '7' '8' '9'];
        history = [];

        fontSize = 50;
        font = 'Courier';
        fontColor = [255 255 255];

        inISI = 0;

        responded = 0;

        performance = [];

        %nbackChance = 0.45; %0.33333;
        nbackChance = 0.33333;

        keySame = 'e';
        keyDifferent = 'r';
        keySameAlt = '(';
        keyDifferentAlt = ')';
    end

    methods
        function obj = WBNback(nm)
            obj@WBTask(nm);

            obj.respondTime = obj.presTime+(obj.isi*0.5);
            obj.trialTimer = WBTimer;
        end

        function stop(this)
            stop@WBTask(this);
        end % stop

        function start(this)
            start@WBTask(this);

            this.nextTrial();
        end

        function update(this)
            if (this.active)
                t = GetSecs;

                if(~this.inISI)

                    if (t > this.stimStartTime+this.presTime)
                        % time to show ISI
                        this.inISI = 1;
                        this.paintISI();
                    end
                else % currently showing blank ISI

                    if (t > this.stimStartTime+this.presTime+this.isi)
                        % time for the next stimulus
                        this.inISI = 0;

                        this.nextStimulus();
                        this.paint();
                    end
                end

                if (t > this.stimStartTime+this.respondTime) 

                    if (length(this.history) > this.n & ~this.responded)
                        % no user reply yet? Count as wrong answer
                        currentStim = this.history(end);
                        nbackStim = this.history(end-this.n);

                        c = this.keySame;
                        if (currentStim == nbackStim)
                            c = this.keyDifferent; % wrong, which is right :p
                        end

                        this.keyboardInput(c);
                    end
                end

                %if (~this.inISI) % currently showing the stimulus
                    %if (t > this.stimStartTime+this.presTime) 

                        %if (length(this.history) > (this.n+1) & ~this.responded)
                            %% no user reply yet? Count as wrong answer
                            %currentStim = this.history(end);
                            %nbackStim = this.history(end-this.n);

                            %c = 'e';
                            %if (currentStim == nbackStim)
                                %c = 'r'; % wrong, which is right :p
                            %end

                            %this.keyboardInput(c);
                        %end

                        %% time to show ISI
                        %this.inISI = 1;
                        %this.paintISI();
                    %end

                %else % currently showing blank ISI
                    %if (t > this.stimStartTime+this.presTime+this.isi)
                        %% time for the next stimulus
                        %this.inISI = 0;

                        %this.nextStimulus();
                        %this.paint();
                    %end

                %end

            end
        end

        function nextTrial(this)

            this.history = [];
            this.performance = [];
            this.currentLetter = 1;

            this.generateSet();
            this.nextStimulus();
            this.paint();

        end

        function generateSet(this)
            if (rand(1) < 0.5)
                this.characterSet = ['B' 'D' 'J' 'I' 'U' 'V' 'E' 'F' 'N'];
            else
                this.characterSet = ['G' 'C' 'J' 'L' 'S' 'E' 'I' 'M' 'N'];
            end

            % create a uniformly distributed sequence of items
            numLetters = round(this.trialLength / (this.presTime+this.isi));
            nl = length(this.characterSet);
            sets = ceil(numLetters / nl);

            letters = [];
            for (i = 1:sets)
                letters = [letters this.characterSet];
            end

            order = randperm(numLetters);
            this.sequence = letters(order);

            % determine the n-backs
            numNB = ceil(this.nbackChance*numLetters);
            numNB = randi([numNB (numNB+1)]);

            nbPlaces = 3:numLetters;
            for (i = 1:numNB)
                idx = nbPlaces(randi([1 length(nbPlaces)]));
                this.sequence(idx-2) = this.sequence(idx);

                % remove both options from the set
                nbPlaces(nbPlaces == idx) = [];
                %nbPlaces(nbPlaces == idx | nbPlaces == (idx-2)) = [];
                if (idx+2 <= length(this.sequence))
                    nbPlaces(nbPlaces == (idx+2)) = [];
                end
            end

        end

        function nextStimulus(this)

            % make sure it's not an nback, or a foil (the n-1 or n+1 letters)
            %reduced = this.characterSet;
            %if (length(this.history > this.n+1))
                %for (i = (this.n-1):min(length(this.history), (this.n+1)))
                    %reduced(reduced==this.history(end-i+1)) = [];
                %end
            %end

            %stim = reduced(randi([1, length(reduced)]));

            %% there is an X percent chance that the current stimulus is equal to the n-back stimulus
            %if (rand(1) < this.nbackChance & length(this.history) > this.n)
                %stim = this.history(end-this.n+1); % n-1 back, technically...
                %%disp('do nback');
            %end

            %disp(stim);
            if (this.currentLetter <= length(this.sequence))
                stim = this.sequence(this.currentLetter);
                this.currentLetter = this.currentLetter + 1;

                this.history = [this.history, stim];
                this.inISI = 0;
                this.responded = 0;
                this.stimStartTime = GetSecs;
            end
        end

        function paint(this)
            [xC, yC] = this.canvas.getCenter();

            Screen('TextSize', this.canvas.area, this.fontSize);
            Screen('TextFont', this.canvas.area, this.font);
            Screen('FillRect', this.canvas.area, 0, [0 0 this.canvas.width this.canvas.height]);

            [nx, ny, bounds] = DrawFormattedText(this.canvas.area, this.history(end), 'center', 'center', this.fontColor, 0, 0, 0, 1); 

            this.canvas.paint();
        end


        function paintISI(this)
            [xC, yC] = this.canvas.getCenter();
            d = 20;

            % blank stimulus
            Screen('FillRect', this.canvas.area, 0, [(xC-d) (yC-d) (xC+d) (yC+d)]);

            this.canvas.paint();
        end

        function paintFeedback(this, correct)
            [xC, yC] = this.canvas.getCenter();
            d = 50;
            r = 30;
            i = 15;

            %if (correct)
                %% paint green circle
                %Screen('FillOval', this.canvas.area, [0 100 0], [xC-d-r yC-r xC-d+r yC+r]);
            %else
                %% paint red circle
                %Screen('FillOval', this.canvas.area, [150 0 0], [xC+d-r yC-r xC+d+r yC+r]);
            %end

            col = [0 160 0]; % green circle
            if (~correct)
                col = [180 0 0]; % red circle
            end

            Screen('FrameOval', this.canvas.area, col, [xC-r yC-r xC+r yC+r], 3);

            this.canvas.paint();
        end

        function setNumbers(this)
            this.characterSet = ['0' '1' '2' '3' '4' '5' '6' '7' '8' '9'];
        end

        function perf = avgPerformance(this)
            perf = mean(this.performance);
        end

        function keyboardInput(this, c)
            if (this.active) %& ~this.inISI)
                c = c(1);
                if ((c == this.keySame | c == this.keySameAlt | ...
                     c == this.keyDifferent | c == this.keyDifferentAlt) & ~this.responded)
                    this.responded = 1;

                    if (length(this.history) > this.n)
                        currentStim = this.history(end);
                        nbackStim = this.history(end-this.n);

                        correct = 0;
                        wasNBack = 0;
                        RT = GetSecs - this.stimStartTime;

                        if (currentStim == nbackStim)
                            wasNBack = 1;
                            if (c == this.keySame | c == this.keySameAlt)
                                correct = 1;
                            end
                        else
                            if (c == this.keyDifferent | c == this.keyDifferentAlt)
                                correct = 1;
                            end
                        end

                        this.performance = [this.performance correct];
                        this.paintFeedback(correct);

                        wasNewStim = 0;
                        if (sum(this.history==currentStim) < 2)
                            wasNewStim = 1;
                        end

                        this.eventBuffer.add([this.name ':responded'], {{'RT' RT} ...
                                                                        {'correct' correct} ...
                                                                        {'n' this.n} ...
                                                                        {'wasNBack' wasNBack} ...
                                                                        {'currentStim' currentStim} ...
                                                                        {'nBackStim' nbackStim} ...
                                                                        {'wasNewStim' wasNewStim} ...
                                                                        {'totalStimSeen' length(this.history)} ...
                                                                       });
                    end
                end
            end

        end
    end
end
