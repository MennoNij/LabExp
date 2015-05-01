classdef WBInputbox < handle

    properties
        canvas
        fontSize
        box
        maxChars

        input = '';
    end

    methods
        function obj = WBInputbox(cnvs, fntSz, x, y, len)

            obj.fontSize = fntSz;
            obj.canvas = cnvs;

            if (strcmp(x, 'center'))
                [xC, yC] = cnvs.getCenter();
                x0 = xC - fntSz*len*0.5;
                x1 = xC + fntSz*len*0.5;
            else
                x0 = x;
                x1 = x0 + fntSz*len;
            end

            if (strcmp(y, 'center'))
                [xC, yC] = cnvs.getCenter();
                y0 = yC - 0.9*fntSz;
                y1 = yC + 0.9*fntSz;
            else
                y0 = y;
                y1 = y0 + 1.8*fntSz;
            end

            obj.box = [x0 y0 x1 y1];
            obj.maxChars = len;

        end

        function paint(this)
            Screen('FillRect', this.canvas.area, 0, this.box);
            Screen('FrameRect', this.canvas.area, 255, this.box);

            Screen('TextSize', this.canvas.area, this.fontSize);
            Screen('TextFont', this.canvas.area, 'Arial');
            Screen('DrawText', this.canvas.area, this.input, this.box(1)+0.3*this.fontSize, ...
                               this.box(2)+0.3*this.fontSize, [255 255 255]);

        end

        function add(this, c)
            if (length(this.input) < this.maxChars)
                this.input = [this.input c];
            end
        end

        function remove(this, n)
            if (n > 0)
                this.input = this.input(1:end-n);
            end
        end
    end % methods

end
