classdef WBZoneTracking < WBTask
    properties
        trialTimer

        lineWidth = 2;
        rScale = 0.1;
        distance = 130;
        xS = 0;
        yS = 0;
    end

    methods
        function obj = WBZoneTracking(nm)
            obj@WBTask(nm);

            obj.trialTimer = WBTimer;
        end % constructor

        function stop(this)
            stop@WBTask(this);
        end % stop

        function start(this)
            start@WBTask(this);

            this.nextTrial();
        end

        function update(this)
            if (this.trialTimer.running & this.trialTimer.passed)
                this.nextTrial();
            end
        end

        function nextTrial(this)
            this.trialStartTime = GetSecs;

            this.paintZone();

            %SetMouse(400, 300);
            ShowCursor('CrossHair');
            this.setPointerLocation();
            this.canvas.setMouse(this.xS, this.yS);

            this.trialTimer.start(2);
        end

        function paintZone(this)
            % blank the screen
            Screen('FillRect', this.canvas.area, 255, [0 0 this.canvas.width this.canvas.height]);
            xC = this.canvas.width*0.5;
            yC = this.canvas.height*0.5;
            r = yC*this.rScale;

            % draw the target zone
            Screen('FrameOval', this.canvas.area, 0, [xC-r yC-r xC+r yC+r], this.lineWidth, this.lineWidth);

            this.canvas.paint();
        end

        function setPointerLocation(this)
            % select a location within the task area, that is at least a certain distance from the zone

            xC = this.canvas.width*0.5;
            yC = this.canvas.height*0.5;

            % randomly set a point on the circle with the requested cursor distance as radius
            dist = min(this.distance, min(this.canvas.width*0.5, this.canvas.height*0.5));
            x = rand(1)*dist;
            if (rand(1) > 0.5)
                x = -x;
            end
            y = sqrt(dist^2 - x^2);
            if (rand(1) > 0.5)
                y = -y;
            end

            this.xS = round(xC+x);
            this.yS = round(yC+y);

            % set random offset from the center of the canvas
            %r = yC*this.rScale;
            %minDist = yC*this.minDistScale;
            %xN = r + minDist + (rand(1)*(xC-r-minDist));
            %yN = r + minDist + (rand(1)*(yC-r-minDist));

            %% randomly flip direction
            %if (rand(1) > 0.5)
                %xN = -1*xN;
            %end

            %if(rand(1) > 0.5)
                %yN = -1*yN;
            %end

            %this.xS = round(xC + xN);
            %this.yS = round(yC + yN);
        end
    end
end
