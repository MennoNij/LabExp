classdef WBSubtraction < WBTask

    properties (SetAccess = private, GetAccess = public)
        numDigits = 10;

        term1
        term2
        answer
        response

        feedbackTimer
        feedbackDuration = 0.5;

        showAllDigits = 0;
        fontSize = 40;

        currentDigit = 0;
        digitStartTime = 0;
    end

    properties (SetAccess = public, GetAccess = public)
        numCarries = 4;
        showFeedback = 0;
    end

    methods
        function obj = WBSubtraction(nm)
            obj@WBTask(nm);

            obj.feedbackTimer = WBTimer;
        end % constructor

        function stop(this)
            %disp(['Disabling task ', this.name]);
            stop@WBTask(this);
        end % stop

        function start(this)
            %disp(['Enabling task ', this.name]);
            start@WBTask(this);

            this.nextTrial();
        end % start

        function update(this)
            if (this.active)
                if (this.feedbackTimer.running & this.feedbackTimer.passed)
                    this.eventBuffer.add([this.name ':finishedFeedback'], {});
                end
            end
        end

        function generate(this)
            free = ones(1, this.numDigits); % keep track of free positions

            this.term1 = zeros(1, this.numDigits);
            this.term2 = zeros(1, this.numDigits);
            this.response = zeros(1, this.numDigits);

            % set the largest decimal, as the first term must be at least 2 larger than the second term
            % this avoids the last digit needing a carry (and thus resulting in a negative number)
            free(1) = 0; % first position is taken

            d2 = round(1+rand(1)*6); % a number between 1 and 7
            minD1 = d2 + 2;
            d1 = minD1 + round(rand(1)*(9-minD1));

            this.term1(1) = d1;
            this.term2(1) = d2;

            % add all the remaining digit pairs randomly, making sure the correct amount of carries are generated
            for (i = 1:(this.numDigits-1))

                d2 = 1+round(rand(1)*7); % avoid requiring a carry at a non-carry pair, and limit it to 8
                d1 = d2+1 + round(rand(1)*(8-d2)); % d1 must be at least 1 larger than d2, and at most 9

                if (i <= this.numCarries)
                    % add a carry pair, which is the opposite of a non-carry pair, so switch
                    td = d1;
                    d1 = d2;
                    d2 = td;

                    %disp(['carry pair: ' num2str(d1) ',' num2str(d2)]);
                end

                % randomly select an open digit slot to add the pair into
                openSlots = find(free);
                idx = 1+round(rand(1)*(length(openSlots)-1));
                openIdx = openSlots(idx);
                free(openIdx) = 0;

                this.term1(openIdx) = d1;
                this.term2(openIdx) = d2;
            end

            % now convert the array to an actual number to get the result of the subtraction
            term1Num = [];
            term2Num = [];

            for (i = 1:this.numDigits)
                term1Num = [term1Num int2str(this.term1(i))];
                term2Num = [term2Num int2str(this.term2(i))];
            end

            term1Num = str2num(term1Num);
            term2Num = str2num(term2Num);
            result = int2str(term1Num - term2Num);

            % now convert the result back into an array of digits
            this.answer = zeros(1, this.numDigits);
            for (i = 1:this.numDigits)
                this.answer(i) = str2num(result(i));
            end

            this.currentDigit = this.numDigits + 1;

            %disp(this.term1);
            %disp(this.term2);
            %disp(this.answer);

        end

        function nextTrial(this)
            if(this.active)
                this.generate();
                this.trialStartTime = GetSecs;
                this.digitStartTime = this.trialStartTime;

                this.nextDigit();
            end
        end

        function nextDigit(this)
            this.currentDigit = this.currentDigit - 1;

            if (this.currentDigit == 0) % reached the end
                totalRT = GetSecs - this.trialStartTime;
                this.eventBuffer.add([this.name ':finishedTrial'], {{'time' totalRT}});
            else
                %disp(this.answer(this.currentDigit));
                if (this.showAllDigits)
                    this.paintAll();
                else
                    this.paintDigit();
                end
                this.digitStartTime = GetSecs;
            end
        end

        function paintDigit(this)
            % determine the location at which to print the number
            if (this.currentDigit > 0)
                [xC, yC] = this.canvas.getCenter();

                Screen('TextSize', this.canvas.area, this.fontSize);
                Screen('TextFont', this.canvas.area, 'Courier');
                Screen('FillRect', this.canvas.area, 255, [0 0 this.canvas.width this.canvas.height]);

                dPre = this.currentDigit-1;
                dPost = this.numDigits - this.currentDigit;

                % show the visible digits stacked on top of each other
                hashes = repmat('#', 1, dPre);
                stripes = repmat('.', 1, dPost);
                txt = [hashes num2str(this.term1(this.currentDigit), '%d'), stripes '\n' hashes ...
                       num2str(this.term2(this.currentDigit), '%d') stripes];

                % draw the digits of the subtraction terms
                [nx, ny, bounds] = DrawFormattedText(this.canvas.area, txt, 'center', yC-2*this.fontSize, 0, 0, 0, 0, 1); 

                % find the location where the box should be drawn
                if (dPre > 0)
                    [nx, ny, aBounds] = DrawFormattedText(this.canvas.area, blanks(dPre), ...
                                                          bounds(1), bounds(4)+0.3*this.fontSize, 0, 0, 0, 0, 1);
                else
                    aBounds = [bounds(1) bounds(4)+0.3*this.fontSize bounds(1) bounds(4)+1.3*this.fontSize];
                end

                % draw the subtraction line and minus sign
                %Screen('DrawLine', this.canvas.area, 0, aBounds(3), aBounds(2), aBounds(3)+this.fontSize, aBounds(2), 2);
                %Screen('DrawLine', this.canvas.area, 0, aBounds(3)+1.25*this.fontSize, aBounds(2), ...
                       %aBounds(3)+1.75*this.fontSize, aBounds(2), 2);
                Screen('DrawLine', this.canvas.area, 0, bounds(1), bounds(4), bounds(3), bounds(4), 2);
                Screen('DrawLine', this.canvas.area, 0, bounds(3)+0.25*this.fontSize, bounds(4), ...
                                                        bounds(3)+0.75*this.fontSize, bounds(4), 2);

                % draw answer box
                Screen('FrameRect', this.canvas.area, 0, [aBounds(3)-0.15*this.fontSize aBounds(2)+0.35*this.fontSize ...
                                                          aBounds(3)+0.9*this.fontSize aBounds(2)+1.5*this.fontSize]);

                this.canvas.paint();
            end
        end

        function paintAll(this)
            [xC, yC] = this.canvas.getCenter();

            Screen('TextSize', this.canvas.area, this.fontSize);
            Screen('TextFont', this.canvas.area, 'Courier');
            Screen('FillRect', this.canvas.area, 255, [0 0 this.canvas.width this.canvas.height]);

            % get a string representation of the terms
            term1Str = num2str(this.term1, '%d');
            term2Str = num2str(this.term2, '%d');

            % 'pad' the response with spaces
            respFilled = ' ';
            if (this.currentDigit < this.numDigits)
                respFilled = num2str(this.response(this.currentDigit+1:this.numDigits), '%d');
            end
            respStr = [blanks(this.currentDigit) respFilled];

            % draw the subtraction terms
            [nx, ny, bounds] = DrawFormattedText(this.canvas.area, [term1Str '\n' term2Str], ... 
                                                 'center', yC-2*this.fontSize, 0, 0, 0, 0, 1);

            % draw the subtraction line and minus sign
            lineY = bounds(4)+0.25*this.fontSize;
            Screen('DrawLine', this.canvas.area, 0, bounds(1), lineY, bounds(3), lineY, 2);
            Screen('DrawLine', this.canvas.area, 0, bounds(3)+0.25*this.fontSize, lineY, ...
                                                    bounds(3)+0.75*this.fontSize, lineY, 2);

            % draw the response box
            Screen('FrameRect', this.canvas.area, 0, [bounds(1)-0.15*this.fontSize bounds(4)+0.6*this.fontSize ...
                                                      bounds(3)+0.15*this.fontSize bounds(4)+1.8*this.fontSize]);

            % draw the response up to now
            DrawFormattedText(this.canvas.area, respStr, 'center', bounds(4)+this.fontSize*0.8, 0, 0, 0, 0, 1);

            this.canvas.paint();

        end

        function paintFeedback(this, d, color)
            [xC, yC] = this.canvas.getCenter();

            Screen('TextSize', this.canvas.area, this.fontSize);
            Screen('TextFont', this.canvas.area, 'Courier');
            DrawFormattedText(this.canvas.area, [blanks(this.currentDigit-1) num2str(d) ...
                              blanks(this.numDigits-this.currentDigit)], 'center', yC+0.8*this.fontSize, color, 0, 0, 0, 1);

            this.canvas.paint();
        end

        function keyboardInput(this, c)
            if (this.active & ~this.feedbackTimer.running)
                correct = 0;
                fbColor = [150 0 0];
                RT = GetSecs - this.digitStartTime;
                %disp(['Expecting ', num2str(this.currentDigit)]);

                c = c(1); % take the first char as the number row passes the digit AND the alt char value (ie 6^)
                d = str2num(c);

                if (~isempty(d))
                    if (d >= 0 & d <= 9)
                        this.response(this.currentDigit) = d;

                        if (d == this.answer(this.currentDigit))
                            correct = 1;
                            fbColor = [0 100 0];
                        end

                        if (this.showFeedback)
                            this.paintFeedback(c, fbColor);
                            this.feedbackTimer.start(this.feedbackDuration);
                        else
                            %this.eventBuffer.add([this.name ':finishedFeedback'], {});
                            this.paintFeedback(c, 0);
                            this.feedbackTimer.start(this.feedbackDuration*0.5);
                        end

                        this.eventBuffer.add([this.name ':typedDigit'], {{'RT' RT} ...
                                                                         {'correct' correct} ...
                                                                         {'response' d} ...
                                                                         {'answer' this.answer(this.currentDigit)} ...
                                                                         {'position' this.currentDigit} ...
                                                                         {'numCarries' this.numCarries} ...
                                                                         {'term1' this.term1(this.currentDigit)} ...
                                                                         {'term2' this.term2(this.currentDigit)} ...
                                                                        });
                    end
                end
            end
        end

    end % methods
end
