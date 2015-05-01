classdef TrialStartBlock < WBTrial

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
            if (blockNum == 1)
                txt = {'You have completed the practice block.' 'You are about to start the first block of the experiment.' ...
                        'In this block you will perform all the tasks seperately,' 'or combinations of two tasks.' ...
                        'In between each trial you will see a cross for 10 seconds,' ...
                        'and you can simply wait until the next trial appears.' ...
                        'Some of the trials will be a "No Task" trial: simply remain still and empty your mind.' ...
                        'Each block will last approximately ten minutes.' ...
                        '' ...
                       'Press Q'};
                if (doFMRI)
                    txt = { 'You are about to start the first block of the experiment.' ...
                           };
                end
            else

                txt = { ['You are about to start block ' bn ' of the experiment. You can take a short break'] ...
                        'before starting, if you want to.' '' ...
                       '' 'Press Q'};

                if (doFMRI)
                    txt = { ['You are about to start block ' bn ' of the experiment.'] ...
                           };
                end
            end

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

            mult = this.flow.variable('trialMultiplier');

            % randomly insert two fixation trials
            fixpos = randperm(mult);
            %disp(fixpos)

            base = [nB Tr Tc nBTr nBTc TcTr];
            order = [];
            for (i = 1:mult)
                if (i == fixpos(1) & doFMRI > 0)
                    bFx = [base Fx];
                    order = [order bFx(randperm(length(bFx)))];
                else
                    order = [order base(randperm(length(base)))];
                end
            end

            %disp(order)

            this.flow.variable(['Block' bn '-Order'], order);
            %this.flow.variable('Block1-Order', [1 2 3 6 5  6 5 4 6 5 4 6 4 5]);
            %this.flow.variable(['Block' bn '-Order'], [5 ]);
            this.flow.variable(['Block' bn '-TrialNum'], 0);

            if (blockNum > 1)
                pN = this.flow.variable('p-N');
                pT = this.flow.variable('p-T');
                pC = this.flow.variable('p-C');
                dC = this.flow.variable('d-C');

                pN_NT = this.flow.variable('p-N (NT)');
                pT_NT = this.flow.variable('p-T (NT)');
                pC_CT = this.flow.variable('p-C (CT)');
                dC_CT = this.flow.variable('d-C (CT)');
                pT_CT = this.flow.variable('p-T (CT)');
                pN_NC = this.flow.variable('p-N (NC)');
                pC_NC = this.flow.variable('p-C (NC)');
                dC_NC = this.flow.variable('d-C (NC)');

                % print performance over block x
                disp( ['-- BLOCK ' num2str(blockNum-1) ' -----------------']);
                disp( '-- Task ------ Performance -');
                disp(['-- Nback:      ' num2str(mean(pN))]);
                disp(['-- Tracking:   ' num2str(mean(pT))]);
                disp(['-- Counting:   ' num2str(mean(pC))]);
                disp(['-- Counting E:   ' num2str(mean(dC))]);

                disp('-- Nback + Tracking --------');
                disp(['-- Nback:      ' num2str(mean(pN_NT))]);
                disp(['-- Tracking:   ' num2str(mean(pT_NT))]);
                disp('-- Nback + Counting --------');
                disp(['-- Nback:      ' num2str(mean(pN_NC))]);
                disp(['-- Counting:   ' num2str(mean(pC_NC))]);
                disp(['-- Counting E:   ' num2str(mean(dC_NC))]);
                disp('-- Counting + Tracking -----');
                disp(['-- Counting:   ' num2str(mean(pC_CT))]);
                disp(['-- Counting E:   ' num2str(mean(dC_CT))]);
                disp(['-- Tracking:   ' num2str(mean(pT_CT))]);

                % reset vars
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
            end

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
