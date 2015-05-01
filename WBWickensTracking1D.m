classdef WBWickensTracking1D < WBTask
    properties
        trialTimer

        lineWidth = 2;
        w = 145;
        h = 10;
        tuneSpeed = 1;
        speed = 0.7; % initial speed
        %speedChange = 0.001
        %updateFreq = 1/30;
        updateFreq = 1/20;
        performanceCheckFreq = 1/3;
        useMouse = 1;

        xS = 0;
        prevUpdateTime = 0;
        prevPerformanceCheck = 0;
        prevMouseCenter = 0;
        prevMX = 0;
        latestMovement = 0;

        direction = 1;
        speedNoise = 0;
        speedUpdate = 0;

        %winningCheck = 0;
        insideSamples = 0;
        outsideSamples = 0;
        firstUpdate = 1;

        distance = [];
        prevInside = 1;
        Fs = 22050;
        tone = [];

        t = 0;
        %dt = 1/45; % too easy
        %dt = 1/27; % for 30 Hz update freq
        dt = 1/18; % for 20 Hz update freq

        tPos = 0;
        r = 20;

        xC = 0;
        yC = 0;

        keyLeft = 'u';
        keyRight = 'i';
        keyLeftAlt = '(';
        keyRightAlt = ')';
    end

    properties (Dependent = true)
        currentDistance
    end

    methods
        function obj = WBWickensTracking1D(nm)
            obj@WBTask(nm);

            obj.trialTimer = WBTimer;

            dur = 0.05;
            obj.tone= audioplayer(0.4*sin(linspace(0, dur*500*2*pi, round(dur*obj.Fs))), obj.Fs);
        end % constructor

        function stop(this)
            stop@WBTask(this);
        end % stop

        function start(this)
            start@WBTask(this);

            this.nextTrial();
        end

        function update(this)
            %if (this.trialTimer.running & this.trialTimer.passed)
                %this.nextTrial();
            %end
            if (this.active)

                if (this.firstUpdate)
                    this.eventBuffer.add([this.name ':start'], {{'t' this.t} ...
                                                                });
                    this.firstUpdate = 0;
                end

                t = GetSecs;

                % keep track of accuracy over time
                if (this.prevPerformanceCheck+this.performanceCheckFreq < t)
                    this.prevPerformanceCheck = t;

                    inside = this.isInside();
                    ins = 0;
                    %this.numSamples = this.numSamples + 1;
                    if (inside)
                        this.insideSamples = this.insideSamples + 1;
                        ins = 1;
                    else
                        this.outsideSamples = this.outsideSamples + 1;
                    end

                    d = this.currentDistance;
                    this.distance = [this.distance d];
                    % generate event
                    this.eventBuffer.add([this.name ':update'], {{'distance' d} ...
                                                                 {'timestamp' t} ...
                                                                 {'x' this.xS-this.xC} ...
                                                                 {'targetPos' this.tPos} ...
                                                                 {'inside' ins} ...
                                                                 {'movement' this.latestMovement} ...
                                                                });
                    %if (~inside & inside ~= this.prevInside)
                        %% play an annoying tone when you cross the circle threshold
                        %play(this.tone);
                    %end

                    this.prevInside = inside;
                end

                % change speed
                %if (this.speedUpdate+1 < t)
                    %this.determineSpeedNoise();
                    %this.speedUpdate = t;
                %end
                    
                % update the screen at a constant rate
                if (this.prevUpdateTime+this.updateFreq < t)
                    this.prevUpdateTime = t;
                    this.determineTargetPos();
                    %this.updatePointLocation(t);
                    this.paint();
                end
            end
        end

        function nextTrial(this)
            if (this.active)
                this.trialStartTime = GetSecs;
                this.distance = [];

                this.xC = this.canvas.width*0.5;
                this.yC = this.canvas.height*0.5;

                this.insideSamples = 0;
                this.outsideSamples = 0;

                this.t = rand(1)*300;
                this.firstUpdate = 1;
                this.determineTargetPos();

                %this.speedUpdate = this.trialStartTime;
                %this.determineDirection();

                %this.xS = this.canvas.width*0.5;
                this.xS = this.canvas.width*0.5+this.tPos;

                this.prevMX = this.xS;

                this.paint();
            end
        end

        function determineTargetPos(this) 
            pi2t = pi*2*this.t;
            this.tPos = 55*sin(pi2t*0.05) + 39*sin(pi2t*0.2) + 24*sin(pi2t*0.08);
            this.t = this.t + this.dt;
        end

        function determineDirection(this)

            if (rand(1) > 0.5)
                this.direction = 1;
            else
                this.direction = -1;
            end

        end

        function determineSpeedNoise(this)
            % add noise (-0.2..0.2)
            this.speedNoise = (rand(1)-0.5)*0.4;
        end

        function paint(this)
            % blank the screen
            %Screen('FillRect', this.canvas.area, 0, [0 0 this.canvas.width this.canvas.height]);
            %xC = this.canvas.width*0.5;
            %yC = this.canvas.height*0.5;

            % draw the target zone
            col = [180 0 0];
            if (this.isInside())
                col = [0 160 0];
            end

            %Screen('FrameRect', this.canvas.area, col, [xC-this.w yC-this.h xC+this.w yC+this.h], 1);
            crss = 10;
            lns = [0    0   ...
                  -crss crss];
            %Screen('DrawLine', this.canvas.area, col, xC, yC-crss, xC, yC+crss, 2);
            xT = this.xC+this.tPos;
            r2 = this.r*2;
            Screen('FillRect', this.canvas.area, 0, [0 this.yC-r2 this.canvas.width this.yC+r2]);

            Screen('FillOval', this.canvas.area, [255 255 255], [xT-4 this.yC-4, xT+4 this.yC+4]);
            Screen('DrawLine', this.canvas.area, col, xT-this.r, this.yC-crss, xT-this.r, this.yC+crss, 2);
            Screen('DrawLine', this.canvas.area, col, xT+this.r, this.yC-crss, xT+this.r, this.yC+crss, 2);

            % draw the tracking dot
            Screen('FrameOval', this.canvas.area, [0 120 184], [this.xS-7 this.yC-7, this.xS+7 this.yC+7], 2);

            this.canvas.paint();
        end

        function keyboardInput(this, c)
            if (this.active)
                c = c(1);
                m = 15;
                s = 2;

                if (c == this.keyLeft | c == this.keyLeftAlt)
                    % move left
                    this.xS = this.xS - m;
                %elseif (c == 'h')
                    %% move left double speed
                    %this.xS = this.xS - m*s;
                elseif (c == this.keyRight | c == this.keyRightAlt)
                    % move right
                    this.xS = this.xS + m;
                %elseif (c =='l')
                    %% move right double speed
                    %this.xS = this.xS + m*s;
                end

                % snap to the center when close enough
                if (this.currentDistance() < m*0.5)
                    %this.xS = this.canvas.width*0.5;
                    this.xS = this.xC+this.tPos;
                    %this.determineDirection();
                end

                % report movement amount
                dX = m;
                if (c == this.keyLeft)
                    dX = -dX;
                end
                this.eventBuffer.add([this.name ':movement'], {{'distance' m} ...
                                                             {'x' dX} ...
                                                            });
            end

        end

        function value = get.currentDistance(this)
            % translate to the center
            %x = this.xS - this.canvas.width*0.5;
            value = abs(this.xS - (this.xC + this.tPos));

        end

        function updatePointLocation(this, t)
            this.xS = this.xS + this.direction*(this.speed+this.speedNoise);
        end

        function perf = avgPerformance(this)
            perf = this.insideSamples / (this.insideSamples + this.outsideSamples);
        end

    end % methods

    methods (Access = private)
        function bool = isInside(this)
            %bool = 0;
            %%x = this.xS - this.canvas.width*0.5;
            %x = this.xS - (this.canvas.width*0.5 + this.tPos);

            %len = sqrt(x^2);
            %if (len < this.r)
                %bool = 1;
            %end
            bool = abs(this.xS-(this.xC+this.tPos)) < this.r;

        end

    end % methods
end

