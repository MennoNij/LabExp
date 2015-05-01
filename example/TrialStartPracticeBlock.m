classdef TrialStartPracticeBlock < WBTrial

    methods
        function start(this)
            %this.flow.variable('BlockNum', 1);
            doFMRI = this.flow.variable('forFMRI');

            blockNum = this.flow.variable('BlockNum');
            blockNum = blockNum + 1;
            this.flow.variable('BlockNum', blockNum);

            bn = num2str(blockNum);

            this.design.loadScene('TEXT SCREEN');
            % set proper text
            txt = {'You are about to start the practice block of the experiment.'  ...
                    'It is just like the practice session you did before.' ...
                    'For 2-back: press the button under your left middle-finger (1)' ...
                    'when the letter is the same as two letters ago, and press the' ...
                    'button under your left index-finger (2) when it is different.' ...
                    '' 'For tracking: use the right handed buttons (3 and 4).' ...
                    'Press any button on the box to start' ...
                   };

            this.design.findTask('STATIC TEXT').text = txt;

            % create databases for the first block
            id = this.flow.variable('participantID');

            trialData = WBDatabase(['Block' bn '-Trials'], [this.flow.dataDir id '-trials-block' bn '.dat'], ...
                                   {'pp' 'trial' 'condition' 'task1' 'task2' 'duration' 'expStarttime' 'expEndtime' 'expStartRawtime' 'expEndRawtime'});
            this.flow.addDatabase(trialData);
            nbData = WBDatabase(['Block' bn '-Nback'], [this.flow.dataDir id '-nback-block' bn '.dat'], ...
                                 {'pp' 'trial' 'condition' 'RT' 'n' 'correct' 'wasNBack' 'stimulus' 'nBackStim' 'wasNewStim' 'stimNum' 'trialtime' 'exptime' 'rawtime'});
            this.flow.addDatabase(nbData);
            %nb1Data = WBDatabase('Block1-1back', [this.flow.dataDir id '-1back-block1.dat'], ...
            %                     {'pp' 'trial' 'RT' 'n' 'correct' 'response' 'stimulus' 'nBackStim' 'wasNewStim' 'stimNum' 'time'});
            %this.flow.addDatabase(nb1Data);
            trData = WBDatabase(['Block' bn '-Tracking'], [this.flow.dataDir id '-tracking-block' bn '.dat'], ...
                                {'pp' 'trial' 'condition' 'distance' 'inside' 'x' 'targetPos' 'trialtime' 'exptime' 'rawtime'});
            this.flow.addDatabase(trData);
            movData = WBDatabase(['Block' bn '-TrackingMovement'], [this.flow.dataDir id '-trackingmovement-block' bn '.dat'], ...
                                {'pp' 'trial' 'condition' 'distance' 'dx' 'trialtime' 'exptime' 'rawtime'});
            this.flow.addDatabase(movData);
            trstartData = WBDatabase(['Block' bn '-TrackingStart'], [this.flow.dataDir id '-trackingstart-block' bn '.dat'], ...
                                {'pp' 'trial' 'condition' 't' });
            this.flow.addDatabase(trstartData);
            toData = WBDatabase(['Block' bn '-Tones'], [this.flow.dataDir id '-tones-block' bn '.dat'], ...
                                {'pp' 'trial' 'condition' 'correct' 'response' 'answer' 'total' 'RT' 'trialtime' 'exptime' 'rawtime'});
            this.flow.addDatabase(toData);

            totiData = WBDatabase(['Block' bn '-ToneTimes'], [this.flow.dataDir id '-tonetimes-block' bn '.dat'], ...
                                {'pp' 'trial' 'condition' 'freq' 'trialtime' 'exptime' 'rawtime'});
            this.flow.addDatabase(totiData);

            mriData = WBDatabase(['Block' bn '-MRITriggers'], [this.flow.dataDir id '-triggers-block' bn '.dat'], ...
                                {'pp' 'trial' 'condition' 'key' 'exptime' 'rawtime'});
            this.flow.addDatabase(mriData);

            nB = 1;
            Tr = 2;
            Tc = 3;
            nBTr = 4;
            TcTr = 5;
            nBTc = 6;
            Fx = 0;

            order = [nB Tr Tc nB Tr Tc Fx nBTr TcTr nBTc nBTr TcTr nBTc];
            %order = [Tr];

            this.flow.variable(['Block' bn '-Order'], order);
            %this.flow.variable('Block1-Order', [1 2 3 6 5  6 5 4 6 5 4 6 4 5]);
            %this.flow.variable(['Block' bn '-Order'], [5 ]);
            this.flow.variable(['Block' bn '-TrialNum'], 0);

            this.design.startAllTasks();
        end

        function update(this)
            if (this.design.newEvents())
                e = this.design.findEvents('STATIC TEXT:keyPressed');
                if(~isempty(e))
                    % start with the trial block
                    key = lower(e{1}.measure('key'));
                    %if (strcmp('return', key) | strcmp('q', key))
                        doFMRI = this.flow.variable('forFMRI');

                        if (doFMRI)
                            this.flow.trial = TrialSync;
                        else
                            this.flow.trial = TrialFixation;
                        end
                    %end
                end
            end

        end
    end % methods

end
