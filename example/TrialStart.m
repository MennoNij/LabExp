classdef TrialStart < WBTrial

    properties
        skipID = 0;
    end

    methods

        function start(this)

            [w, h] =  this.design.getScreenSize();
            doFMRI = this.flow.variable('forFMRI');

            % define global variables that will be used by trials
            this.flow.variable('trueTrialCount', 0);
            this.flow.variable('finalBlock', 0);


            % CREATE THE LOGIN SCREEN
            tID = LoginScreen('ID FORM');
            this.design.buildScene('GET ID', {tID}, '1');

            % CREATE GENERAL TEXT TASK
            statTxt = WBTextDisplay('STATIC TEXT', '', 26);
            this.design.buildScene('TEXT SCREEN', {statTxt}, '1');
            syncTxt = WBTextDisplay('SYNC TEXT', 'Waiting for scanner...', 26);
            this.design.buildScene('SYNC SCREEN', {syncTxt}, '1');

            % BLOCK 1 SINGLE TASK TRIAL INFORMATION SCREENS
            inb = WBTextDisplay('INDICATE NBACK', '2-Back', 54);
            i1b = WBTextDisplay('INDICATE 1BACK', 'Repetition Detection', 54);
            itr = WBTextDisplay('INDICATE TRACKING', 'Tracking', 54);
            itc = WBTextDisplay('INDICATE TONECOUNTING', 'Tone Counting', 54);
            ifx = WBTextDisplay('INDICATE FIXATION', 'No Tasks', 54);
            %pressAny = WBTextDisplay('PRESS ANY KEY', 'Press Any Key', 34);

            this.design.buildScene('SHOW NB', {inb}, '1');
            this.design.buildScene('SHOW TR', {itr}, '1');
            this.design.buildScene('SHOW TC', {itc}, '1');
            this.design.buildScene('SHOW Fx', {ifx}, '1');
            this.design.buildScene('SHOW 1B', {i1b}, '1');

            % BLOCK 2 COMBI TASK TRIAL SCREENS
            nbTr = WBTextDisplay('INDICATE NB-TR', '2-back + Tracking', 44);
            TcTr = WBTextDisplay('INDICATE TC-TR', 'Tone Counting + Tracking', 44);
            nbTc = WBTextDisplay('INDICATE NB-TC', '2-back + Tone Counting', 44);
            pressAny = WBTextDisplay('PRESS ANY KEY', 'Press Any Key', 34);
            nbTitle = WBTextDisplay('1BACK TITLE', 'Repetition detection', 44);

            this.design.buildScene('SHOW nB-Tr', {nbTr}, '1');
            this.design.buildScene('SHOW Tc-Tr', {TcTr}, '1');
            this.design.buildScene('SHOW nB-Tc', {nbTc}, '1');

            % CREATE THE TASK SCREENS ARRANGEMENTS

            tx = WBFixation('FIXATION');

            %t0 = WBNback('1BACK');
            %t0.n = 1;
            %t0.setNumbers();
            %t0.font = 'Helvetica';
            %t0.fontColor = [0 0 80];

            tfx = WBFixation('FX');
            tfx.type = 1;
            ta = WBNback('NBACK');
            ta.n = 2;
            tb = WBWickensTracking1D('TRACKING');
            tc = WBCountHighTones('TONES');
            tc.triggeredTones = 0; % no subtraction in this exp, so no events to trigger tones
            %tcl = WBCountHighTones('TONES');
            %tcl.triggeredTones = 0;
            %tcl.answerSide = 1;

            if (doFMRI)
                % windows PC's interpret font sizes differently...
                % also, Courier isn't available
                nbTc.fontSize = 30;
                nbTr.fontSize = 30;
                TcTr.fontSize = 30;
                inb.fontSize = 30;
                itr.fontSize = 30;
                itc.fontSize = 30;
                ifx.fontSize = 30;

                ta.keySame = '1';
                ta.keySameAlt = 'b';
                ta.keyDifferent = '2';
                ta.keyDifferentAlt = 'y';
                ta.font = 'Courier New';
                ta.fontSize = 30;

                tb.keyLeft = '3';
                tb.keyLeftAlt = 'g';
                tb.keyRight = '4';
                tb.keyRightAlt = 'r';

                tc.keyRightTens = '3';
                tc.keyRightTensAlt = 'g';
                tc.keyRightOnes = '4';
                tc.keyRightOnesAlt = 'r';
                tc.keyLeftTens = '1';
                tc.keyLeftTensAlt = 'b';
                tc.keyLeftOnes = '2';
                tc.keyLeftOnesAlt = 'y';
                tc.fontSize = 15;
                tc.numberFont = 'Courier New';
                if (doFMRI == 1) % 1 = WIN, 2 = MAC
                    tc.runningWindows = 1;
                end
            end

            arrange = [150,     40, w/2-10, h-10, ...
                       w/2+10, 40, w-150,   h-10];
            this.design.buildScene('NB-TR', {ta, tb}, arrange);
            this.design.buildScene('TC-TR', {tc, tb}, arrange);
            this.design.buildScene('NB-TC', {ta, tc}, arrange);
            arrange = [10, 40, w-10, h-10];
            this.design.buildScene('DOFIXATION', {tx}, arrange);
            this.design.buildScene('SINGLE-NBACK', {ta}, arrange);
            this.design.buildScene('SINGLE-TRACKING', {tb}, arrange);
            this.design.buildScene('SINGLE-TONES', {tc}, arrange);
            this.design.buildScene('SINGLE-FX', {tfx}, arrange);

            %arrange = [10,     10, w-10, h*0.1-10, ...
                       %10, h*0.1+10, w-10,   h-10];
            %this.design.buildScene('SINGLE-1BACK', {t0}, arrange);


            % task performance history
            this.flow.variable('p-N', []);
            this.flow.variable('p-T', []);
            this.flow.variable('p-C', []);
            this.flow.variable('d-C', []);

            this.flow.variable('p-N (NT)', []);
            this.flow.variable('p-T (NT)', []);
            this.flow.variable('p-C (CT)', []);
            this.flow.variable('d-C (CT)', []);
            this.flow.variable('p-T (CT)', []);
            this.flow.variable('p-N (NC)', []);
            this.flow.variable('p-C (NC)', []);
            this.flow.variable('d-C (NC)', []);

            this.design.loadScene('GET ID');

            if (~this.skipID)
                % load the scene into the design
                this.design.findTask('ID FORM').start();
            end

        end

        function update(this)
            doFMRI = this.flow.variable('forFMRI');
            blockNum = this.flow.variable('BlockNum');

            if (doFMRI)
                this.flow.variable('Block0-RoundNum', 1);
                this.flow.variable('Block0-MaxRound', 6);
            else
                this.flow.variable('Block0-RoundNum', 0);
                this.flow.variable('Block0-MaxRound', 2);
            end

            if (~this.skipID)
                % check if an ID was submitted
                e = this.design.findEvents('ID FORM:submitted');

                % if so, start up the actual experiment
                if (~isempty(e))
                    % load the first real trial into the flow
                    %disp(e{1}.measure('ID'));
                    this.flow.variable('participantID', e{1}.measure('ID'));

                    if (blockNum > 0)
                        this.flow.trial = TrialStartBlock;

                    else
                        if (doFMRI)
                            %this.flow.trial = TrialInstruction;
                            %this.flow.trial = TrialStartBlock;
                            this.flow.trial = TrialStartPracticeBlock;
                        else
                            this.flow.trial = TrialInstruction;
                            %this.flow.trial = TrialStartSecondBlock;
                            %this.flow.trial = TrialStartFirstBlock;
                        end
                    end
                end
            else
                if (blockNum > 0)
                    this.flow.trial = TrialStartBlock;

                else
                    if (doFMRI)
                        %this.flow.trial = TrialInstruction;
                        %this.flow.trial = TrialStartBlock;
                        this.flow.trial = TrialStartPracticeBlock;
                    else
                        this.flow.trial = TrialInstruction;
                        %this.flow.trial = TrialStartSecondBlock;
                        %this.flow.trial = TrialStartBlock;
                    end
                end
            end

        end

    end
end
