classdef WBTextDisplay < WBTask

    properties (SetAccess = public, GetAccess = public)
        font
        fontSize = 24;
        text = {};
        xLoc = 'center';
        yLoc = 'center';
        hFlip = 0;
        vFlip = 0;
        lineSpacing = 2;
    end

    methods
        function obj = WBTextDisplay(nm, txt, fntSz)
            obj@WBTask(nm);

            if (nargin > 1)
                obj.text = txt;
            end
            
            if (nargin > 2)
                obj.fontSize = fntSz;
            end
        end

        function start(this)
            start@WBTask(this);
            Screen('FillRect', this.canvas.area, 0, [0 0 this.canvas.width this.canvas.height]);
            Screen('TextFont', this.canvas.area, 'Helvetica');
            Screen('TextStyle', this.canvas.area, 0);
            Screen('TextSize', this.canvas.area, this.fontSize);

            % concatenate all lines with newlines
            str = [];
            for (i = 1:length(this.text))
                str = [str '\n' this.text{i}];
            end

            DrawFormattedText(this.canvas.area, str, this.xLoc, this.yLoc, 255, 0, this.hFlip, this.vFlip, this.lineSpacing);

            this.canvas.paint();

            %disp(this.text);
        end

        function update(this)
            %disp('yay');
        end

        function keyboardInput(this, c)
            % finish screen on any input
            this.eventBuffer.add([this.name ':keyPressed'], {{'key' c} {'time' GetSecs}});
        end

        function set.text(this, txt)
            if (iscell(txt))
                this.text = txt;
            else
                this.text = {};
                this.text{end+1} = txt;
            end
        end

        function addLine(this, txt)
            this.text{end+1} = txt;
        end

        function changeLine(this, idx, txt)
            if (idx > 0 & idx < length(this.text))
                this.text{idx} = txt;
            end
        end

    end
end
