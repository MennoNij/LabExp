classdef LoginScreen < WBTask

    properties
        title = 'Multitask';
        pIDBox
    end

    methods
        function obj = LoginScreen(nm)
            obj@WBTask(nm);
        end
            
        function start(this)
            [xC, yC] = this.canvas.getCenter();
            this.pIDBox = WBInputbox(this.canvas, 30, 'center', 'center', 8);

            this.canvas.wipe(0);
            Screen('TextFont', this.canvas.area, 'Geneva');
            Screen('TextSize', this.canvas.area, 60);
            Screen('TextStyle', this.canvas.area, 1);
            Screen('DrawText', this.canvas.area, this.title, 100, 100, [255 255 255]);
            txt = 'Please type your ID number, followed by an enter.';
            %wrapAt = 40;
            %DrawFormattedText(this.canvas.area, txt, 0, 0, [0 0 0], wrapAt);
            Screen('TextFont', this.canvas.area, 'Helvetica');
            Screen('TextSize', this.canvas.area, 24);
            Screen('TextStyle', this.canvas.area, 0);
            %Screen('DrawText', this.canvas.area, txt, 100, yC - 100, [0 0 0]);
            DrawFormattedText(this.canvas.area, txt, 'center', yC-50, [255 255 255]);

            % draw input box
            this.pIDBox.paint();

            this.canvas.paint();
        end

        function keyboardInput(this, c)
            if ((strcmp(lower(c), 'return') | strcmp(lower(c), 'enter')) & length(this.pIDBox.input) > 0)
                this.eventBuffer.add([this.name ':submitted'], {{'ID' this.pIDBox.input}});
            elseif (strcmp(lower(c), 'backspace') | strcmp(lower(c), 'delete'))
                this.pIDBox.remove(1);
                this.pIDBox.paint();
                this.canvas.paint();
            else
                c = c(1);
                if (this.isNumeric(c) | this.isAlphabetic(c))
                    % update textfield
                    this.pIDBox.add(c);
                    this.pIDBox.paint();
                    this.canvas.paint();
                end
            end

        end

    end

end
