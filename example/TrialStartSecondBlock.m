classdef TrialStartSecondBlock < WBTrial

    methods
        function start(this)
            this.flow.variable('BlockNum', 2);
            doFMRI = this.flow.variable('forFMRI');

            this.design.loadScene('TEXT SCREEN');
            % set proper text
            txt = {'You have completed the first block.' '' ...
                    'You are about to start the second block of the experiment. You can take a short break' ...
                    'before starting, if you want to.' '' ...
                   '' 'Press Q'};

            if (doFMRI)
                txt = {'You have completed the first block.' '' ...
                        'You will now have a break of around 10 minutes.' ...
                        'During this time we will make a high-resolution scan of your brain.' ...
                        'You will be notified when the second block starts.' ...
                       };
            end

            this.design.findTask('STATIC TEXT').text = txt;

            % create databases for the second block
            id = this.flow.variable('participantID');

            trialData = WBDatabase('Block2-Trials', [this.flow.dataDir id '-trials-block2.dat'], ...
                                   {'pp' 'trial' 'condition' 'task1' 'task2' 'duration' 'expStarttime' 'expEndtime' 'expStartRawtime' 'expEndRawtime'});
            this.flow.addDatabase(trialData);
            nbData = WBDatabase('Block2-Nback', [this.flow.dataDir id '-nback-block2.dat'], ...
                                 {'pp' 'trial' 'condition' 'RT' 'n' 'correct' 'wasNBack' 'stimulus' 'nBackStim' 'wasNewStim' 'stimNum' 'trialtime' 'exptime' 'rawtime'});
            this.flow.addDatabase(nbData);
            %nb1Data = WBDatabase('Block2-1back', [this.flow.dataDir id '-1back-block2.dat'], ...
            %                     {'pp' 'trial' 'RT' 'n' 'correct' 'response' 'stimulus' 'nBackStim' 'wasNewStim' 'stimNum' 'time'});
            %this.flow.addDatabase(nb1Data);
            trData = WBDatabase('Block2-Tracking', [this.flow.dataDir id '-tracking-block2.dat'], ...
                                {'pp' 'trial' 'condition' 'distance' 'inside' 'x' 'targetPos' 'trialtime' 'exptime' 'rawtime'});
            this.flow.addDatabase(trData);
            movData = WBDatabase('Block2-TrackingMovement', [this.flow.dataDir id '-trackingmovement-block2.dat'], ...
                                {'pp' 'trial' 'condition' 'distance' 'dx' 'trialtime' 'exptime' 'rawtime'});
            this.flow.addDatabase(movData);
            toData = WBDatabase('Block2-Tones', [this.flow.dataDir id '-tones-block2.dat'], ...
                                {'pp' 'trial' 'condition' 'correct' 'response' 'answer' 'total' 'RT' 'trialtime' 'exptime' 'rawtime'});
            this.flow.addDatabase(toData);
            totiData = WBDatabase('Block2-ToneTimes', [this.flow.dataDir id '-tonetimes-block2.dat'], ...
                                {'pp' 'trial' 'condition' 'freq' 'trialtime' 'exptime' 'rawtime'});
            this.flow.addDatabase(totiData);

            mriData = WBDatabase('Block2-MRITriggers', [this.flow.dataDir id '-triggers-block2.dat'], ...
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

            base = [nB Tr Tc nBTr nBTc TcTr];
            order = [];
            for (i = 1:mult)
                if (i == fixpos(1) | i == fixpos(2))
                    order = [order base(randperm(length(base))) Fx];
                else
                    order = [order base(randperm(length(base)))];
                end
            end

            this.flow.variable('Block2-Order', order);
            %this.flow.variable('Block2-Order', [4]);
            this.flow.variable('Block2-TrialNum', 0);

            pN = this.flow.variable('p-N');
            pT = this.flow.variable('p-T');
            pC = this.flow.variable('p-C');

            pN_NT = this.flow.variable('p-N (NT)');
            pT_NT = this.flow.variable('p-T (NT)');
            pC_CT = this.flow.variable('p-C (CT)');
            pT_CT = this.flow.variable('p-T (CT)');
            pN_NC = this.flow.variable('p-N (NC)');
            pC_NC = this.flow.variable('p-C (NC)');

            % print performance over block 1
            disp( '-- BLOCK 1 -----------------');
            disp( '-- Task ------ Performance -');
            disp(['-- Nback:      ' num2str(mean(pN))]);
            disp(['-- Tracking:   ' num2str(mean(pT))]);
            disp(['-- Counting:   ' num2str(mean(pC))]);

            disp('-- Nback + Tracking --------');
            disp(['-- Nback:      ' num2str(mean(pN_NT))]);
            disp(['-- Tracking:   ' num2str(mean(pT_NT))]);
            disp('-- Nback + Counting --------');
            disp(['-- Nback:      ' num2str(mean(pN_NC))]);
            disp(['-- Counting:   ' num2str(mean(pC_NC))]);
            disp('-- Counting + Tracking -----');
            disp(['-- Counting:   ' num2str(mean(pC_CT))]);
            disp(['-- Tracking:   ' num2str(mean(pT_CT))]);

            % reset vars
            this.flow.variable('p-N', []);
            this.flow.variable('p-T', []);
            this.flow.variable('p-C', []);

            this.flow.variable('p-N (NT)', []);
            this.flow.variable('p-T (NT)', []);
            this.flow.variable('p-C (CT)', []);
            this.flow.variable('p-T (CT)', []);
            this.flow.variable('p-N (NC)', []);
            this.flow.variable('p-C (NC)', []);

            this.design.startAllTasks();
        end

        function update(this)
            if (this.design.newEvents())
                e = this.design.findEvents('STATIC TEXT:keyPressed');
                if(~isempty(e))
                    key = lower(e{1}.measure('key'));
                    if (strcmp('return', key) | strcmp('q', key))
                        % start with the trial block
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

