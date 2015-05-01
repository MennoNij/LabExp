classdef TrialStartFirstBlock < WBTrial

    methods
        function start(this)
            this.flow.variable('BlockNum', 1);
            doFMRI = this.flow.variable('forFMRI');

            this.design.loadScene('TEXT SCREEN');
            % set proper text
            txt = {'You have completed the practice block.' 'You are about to start the first block of the experiment.' ...
                    'In this block you will perform all the tasks seperately,' 'or combinations of two tasks.' ...
                    'In between each trial you will see a cross for 10 seconds,' ...
                    'and you can simply wait until the next trial appears.' ...
                    'Some of the trials will be a "No Task" trial: simply remain still and empty your mind.' ...
                    'This block will last approximately half an hour.' ...
                    '' ...
                   'Press Q'};
            if (doFMRI)
                txt = { 'You are about to start the first block of the experiment.' ...
                       };
            end

            this.design.findTask('STATIC TEXT').text = txt;

            % create databases for the first block
            id = this.flow.variable('participantID');

            trialData = WBDatabase('Block1-Trials', [this.flow.dataDir id '-trials-block1.dat'], ...
                                   {'pp' 'trial' 'condition' 'task1' 'task2' 'duration' 'expStarttime' 'expEndtime' 'expStartRawtime' 'expEndRawtime'});
            this.flow.addDatabase(trialData);
            nbData = WBDatabase('Block1-Nback', [this.flow.dataDir id '-nback-block1.dat'], ...
                                 {'pp' 'trial' 'condition' 'RT' 'n' 'correct' 'wasNBack' 'stimulus' 'nBackStim' 'wasNewStim' 'stimNum' 'trialtime' 'exptime' 'rawtime'});
            this.flow.addDatabase(nbData);
            %nb1Data = WBDatabase('Block1-1back', [this.flow.dataDir id '-1back-block1.dat'], ...
            %                     {'pp' 'trial' 'RT' 'n' 'correct' 'response' 'stimulus' 'nBackStim' 'wasNewStim' 'stimNum' 'time'});
            %this.flow.addDatabase(nb1Data);
            trData = WBDatabase('Block1-Tracking', [this.flow.dataDir id '-tracking-block1.dat'], ...
                                {'pp' 'trial' 'condition' 'distance' 'inside' 'x' 'targetPos' 'trialtime' 'exptime' 'rawtime'});
            this.flow.addDatabase(trData);
            movData = WBDatabase('Block1-TrackingMovement', [this.flow.dataDir id '-trackingmovement-block1.dat'], ...
                                {'pp' 'trial' 'condition' 'distance' 'dx' 'trialtime' 'exptime' 'rawtime'});
            this.flow.addDatabase(movData);
            toData = WBDatabase('Block1-Tones', [this.flow.dataDir id '-tones-block1.dat'], ...
                                {'pp' 'trial' 'condition' 'correct' 'response' 'answer' 'total' 'RT' 'trialtime' 'exptime' 'rawtime'});
            this.flow.addDatabase(toData);

            totiData = WBDatabase('Block1-ToneTimes', [this.flow.dataDir id '-tonetimes-block1.dat'], ...
                                {'pp' 'trial' 'condition' 'freq' 'trialtime' 'exptime' 'rawtime'});
            this.flow.addDatabase(totiData);

            mriData = WBDatabase('Block1-MRITriggers', [this.flow.dataDir id '-triggers-block1.dat'], ...
                                {'pp' 'trial' 'condition' 'key' 'exptime' 'rawtime'});
            this.flow.addDatabase(mriData);

            nB = 1;
            Tr = 2;
            Tc = 3;
            nBTr = 4;
            TcTr = 5;
            nBTc = 6;
            Fx = 0;

            mult = this.flow.variable('trialMultiplier');

            % randomly insert two fixation trials
            fixpos = randperm(mult);
            %disp(fixpos)

            base = [nB Tr Tc nBTr nBTc TcTr];
            order = [];
            for (i = 1:mult)
                if (i == fixpos(1) | i == fixpos(2))
                    order = [order base(randperm(length(base))) Fx];
                else
                    order = [order base(randperm(length(base)))];
                end
            end

            %disp(order)

            this.flow.variable('Block1-Order', order);
            %this.flow.variable('Block1-Order', [1 2 3 6 5  6 5 4 6 5 4 6 4 5]);
            this.flow.variable('Block1-Order', [5 6 3 1 3 3 2 5 6]);
            this.flow.variable('Block1-TrialNum', 0);

            this.design.startAllTasks();
        end

        function update(this)
            if (this.design.newEvents())
                e = this.design.findEvents('STATIC TEXT:keyPressed');
                if(~isempty(e))
                    % start with the trial block
                    key = lower(e{1}.measure('key'));
                    if (strcmp('return', key) | strcmp('q', key))
                        doFMRI = this.flow.variable('forFMRI');

                        if (doFMRI)
                            this.flow.trial = TrialSync;
                        else
                            this.flow.trial = TrialFixation;
                        end
                    end
                end
            end

        end
    end % methods

end
