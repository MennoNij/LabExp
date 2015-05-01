classdef WBFixation < WBTask

    properties
        type = 0;
    end

    methods
        function obj = WBFixation(nm)
            obj@WBTask(nm);
        end

        function start(this)
            start@WBTask(this);

            this.paintFixation();
        end

        function stop(this)
            this.active = 0;
        end

        function update(this)

        end

        function paintFixation(this)
            [xC, yC] = this.canvas.getCenter();

            this.canvas.wipe(0);
            col = [255 255 255];
            crss = 25;
            lns = [0    0   -crss crss; ...
                  -crss crss 0    0];
            Screen('DrawLines', this.canvas.area, lns, 2, col, [xC yC]);

            if (this.type > 0)

                Screen('FrameOval', this.canvas.area, col, [xC-crss yC-crss xC+crss yC+crss], 3);
            end

            this.canvas.paint();
        end

        function keyboardInput(this, c)
                c = c(1);

                if (c == '5' | c == 't')
                    % do scan synchronization

                    this.eventBuffer.add([this.name ':MRISync'], {{'key' c} ...
                                                                 {'time' GetSecs} ...
                                                                });
                end
        end
    end


end
