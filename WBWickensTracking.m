classdef WBWickensTracking < WBTask
    properties
        trialTimer

        lineWidth = 2;
        r = 50;
        speed = 0.015; % initial speed
        speedChange = 0.001
        updateFreq = 1/30;
        performanceCheckFreq = 1/3;
        useMouse = 1;

        xS = 0;
        yS = 0;
        prevUpdateTime = 0;
        prevPerformanceCheck = 0;
        prevMouseCenter = 0;
        prevMX = 0;
        prevMY = 0;
        latestMovement = 0;

        winningCheck = 0;

        distance = [];
        prevInside = 1;
        Fs = 22050;
        tone = [];
    end

    properties (Dependent = true)
        currentDistance
    end

    methods
        function obj = WBWickensTracking(nm)
            obj@WBTask(nm);

            obj.trialTimer = WBTimer;

            dur = 0.05;
            obj.tone= 0.4*sin(linspace(0, dur*400*2*pi, round(dur*obj.Fs)));
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

                t = GetSecs;

                % keep the mouse from going offscreen
                if (this.prevMouseCenter+1 < t)
                    this.prevMouseCenter = t;
                    this.prevMX = this.canvas.width*0.5;
                    this.prevMY = this.canvas.height*0.5;
                    this.canvas.setMouse(this.prevMX, this.prevMY);
                end

                % keep track of accuracy over time
                if (this.prevPerformanceCheck+this.performanceCheckFreq < t)
                    this.prevPerformanceCheck = t;
                    %this.numSamples = this.numSamples + 1;
                    %if (this.isInside())
                        %this.inCircleSamples = this.inCircleSamples + 1;
                    %end
                    d = this.currentDistance;
                    this.distance = [this.distance d];
                    % generate event
                    this.eventBuffer.add([this.name ':update'], {{'distance' d} ...
                                                                 {'timestamp' t} ...
                                                                 {'x' this.xS-0.5*this.canvas.width} ...
                                                                 {'y' this.yS-0.5*this.canvas.height} ...
                                                                 {'speed' this.speed} ...
                                                                 {'movement' this.latestMovement} ...
                                                                });
                    inside = this.isInside();
                    if (~inside & inside ~= this.prevInside)
                        % play an annoying tone when you cross the circle threshold
                        sound(this.tone, this.Fs);

                        % task may be too difficult; change the movement speed a bit
                        this.speed = max(0.015, this.speed - this.speedChange*2);
                    %disp(['decreasing movement speed ' num2str(this.speed)]);
                    end
                    this.prevInside = inside;
                end
                    
                if (this.winningCheck+3 < t)
                    % task may be too easy; increase movement speed a bit
                    this.speed = this.speed + this.speedChange;
                    this.winningCheck = t;
                    %disp(['increasing movement speed ' num2str(this.speed)]);
                end

                % update the screen at a constant rate
                if (this.prevUpdateTime+this.updateFreq < t)
                    this.prevUpdateTime = t;
                    this.updatePointLocation(t);
                    this.paint();
                end
            end
        end

        function nextTrial(this)
            if (this.active)
                this.trialStartTime = GetSecs;
                this.distance = [];

                this.xS = this.canvas.width*0.5;
                this.yS = this.canvas.height*0.5;

                this.prevMX = this.xS;
                this.prevMY = this.yS;

                this.paint();
            end
        end

        function paint(this)
            % blank the screen
            Screen('FillRect', this.canvas.area, 255, [0 0 this.canvas.width this.canvas.height]);
            xC = this.canvas.width*0.5;
            yC = this.canvas.height*0.5;

            % draw the target zone
            col = [150 0 0];
            if (this.isInside())
                col = [0 100 0];
            end

            Screen('FrameOval', this.canvas.area, col, [xC-this.r yC-this.r xC+this.r yC+this.r], this.lineWidth, this.lineWidth);
            crss = 25;
            lns = [0    0   -crss crss; ...
                  -crss crss 0    0];
            Screen('DrawLines', this.canvas.area, lns, 2, col, [xC yC]);

            % draw the tracking dot
            Screen('FillOval', this.canvas.area, [0 58 104], [this.xS-5 this.yS-5 this.xS+5 this.yS+5]);

            this.canvas.paint();
        end

        function mouseInput(this, x, y, buttons)
            if (this.active)
                dX = -(x - this.prevMX);
                dY = -(y - this.prevMY);

                move = sqrt(dX*dX + dY*dY);
                if (move > 500)
                    move = 9999;
                end
                this.latestMovement = move;

                this.eventBuffer.add([this.name ':movement'], {{'distance' move} ...
                                                             {'x' dX} ...
                                                             {'y' dY} ...
                                                            });

                if (abs(dX) < 200 & abs(dY) < 200)

                    this.xS = this.xS - dX;
                    this.yS = this.yS - dY;

                    % always keep the point inside the canvas area
                    this.xS = min(max(0, this.xS), this.canvas.width);
                    this.yS = min(max(0, this.yS), this.canvas.height);

                end
                    this.prevMX = x;
                    this.prevMY = y;
            end

        end

        function value = get.currentDistance(this)
            % translate to the center
            x = this.xS - this.canvas.width*0.5;
            y = this.yS - this.canvas.height*0.5;

            value = sqrt(x^2 + y^2);
        end

        function updatePointLocation(this, t)
            pi2 = pi*2;

            offH = 69*sin(pi2*0.08*t) + 32*sin(pi2*0.5*t) + 17*sin(pi2*0.3*t);
            offV = 55*sin(pi2*0.05*t) + 39*sin(pi2*0.2*t) + 24*sin(pi2*0.08*t);

            %disp(['offset: ' num2str(offH) ',' num2str(offV)]);
            x = round(this.xS + offH*this.speed);
            if (x > 0 & x < this.canvas.width)
                this.xS = x;
            end

            y = round(this.yS + offV*this.speed);
            if (y > 0 & y < this.canvas.height)
                this.yS = y;
            end

        end

    end % methods

    methods (Access = private)
        function bool = isInside(this)
        bool = 0;
            x = this.xS - this.canvas.width*0.5;
            y = this.yS - this.canvas.height*0.5;

            len = sqrt(x^2 + y^2);
            if (len < this.r)
                bool = 1;
            end

        end

    end % methods
end

