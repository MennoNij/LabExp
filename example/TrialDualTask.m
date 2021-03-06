classdef TrialDualTask < WBTrial

    properties
        nB = 0;
        Tr = 0;
        Tc = 0;
        condition = 0;
        conditionStr = '?';
        t1 = '?';
        t2 = '?';
        block = 1;
        blockStr = '1';

        finishing = 0;
    end

    methods

        function start(this)

            switch (this.condition)
                case {4}
                    this.design.loadScene('NB-TR');
                    this.conditionStr = 'NT';
                    this.nB = 1;
                    this.t1 = 'N';
                    this.Tr = 1;
                    this.t2 = 'T';
                case {5}
                    this.design.loadScene('TC-TR');
                    this.conditionStr = 'CT';
                    this.Tc = 1;
                    this.t1 = 'C';
                    this.Tr = 1;
                    this.t2 = 'T';
                    tc = this.design.findTask('TONES');
                    tc.answerSide = 1;
                otherwise
                    this.design.loadScene('NB-TC');
                    this.conditionStr = 'NC';
                    this.nB = 1;
                    this.t1 = 'N';
                    this.Tc = 1;
                    this.t2 = 'C';
                    tc = this.design.findTask('TONES');
                    tc.answerSide = 0;
            end

            this.block = this.flow.variable(['BlockNum']);
            this.blockStr = num2str(this.block);

            %fprintf('start trial\n');
            %fprintf('secs %.3f\n',GetSecs);
            %fprintf('start %.3f\n',this.startTime);

            this.design.startAllTasks();
        end

        function update(this)
            if (this.design.newEvents())
                if (this.nB)

                    e = this.design.findEvents('NBACK:responded');
                    if (~isempty(e))

                        db = this.flow.database(['Block' this.blockStr '-Nback']);
                        db.addData({'pp' this.flow.variable('participantID') ...
                                    'trial' this.flow.variable(['Block' this.blockStr '-TrialNum']) ...
                                    'condition' this.conditionStr ...
                                    'RT' e{1}.measure('RT') ...
                                    'n' e{1}.measure('n') ...
                                    'correct' e{1}.measure('correct') ...
                                    'wasNBack' e{1}.measure('wasNBack') ...
                                    'stimulus' e{1}.measure('currentStim') ...
                                    'nBackStim' e{1}.measure('nBackStim') ...
                                    'wasNewStim' e{1}.measure('wasNewStim') ...
                                    'stimNum' e{1}.measure('totalStimSeen') ...
                                    'trialtime' this.time() ...
                                    'exptime' this.flow.time() ...
                                    'rawtime' GetSecs ...
                                   });
                        db.write();
                    end
                end

                if (this.Tr)

                    e = this.design.findEvents('TRACKING:update');
                    if (~isempty(e))
                        db = this.flow.database(['Block' this.blockStr '-Tracking']);
                        db.addData({'pp' this.flow.variable('participantID') ...
                                    'trial' this.flow.variable(['Block' this.blockStr '-TrialNum']) ...
                                    'condition' this.conditionStr ...
                                    'distance' e{1}.measure('distance') ...
                                    'inside' e{1}.measure('inside') ...
                                    'x' e{1}.measure('x') ...
                                    'targetPos' e{1}.measure('targetPos') ...
                                    'trialtime' this.time() ...
                                    'exptime' this.flow.time() ...
                                    'rawtime' GetSecs ...
                                   });
                        db.write();
                    end

                    e = this.design.findEvents('TRACKING:start');
                    if (~isempty(e))
                        db = this.flow.database(['Block' this.blockStr '-TrackingStart']);
                        db.addData({'pp' this.flow.variable('participantID') ...
                                    'trial' this.flow.variable(['Block' this.blockStr '-TrialNum']) ...
                                    'condition' this.conditionStr ...
                                    't' e{1}.measure('t') ...
                                   });
                        db.write();
                    end

                    e = this.design.findEvents('TRACKING:movement');
                    if (~isempty(e))
                        db = this.flow.database(['Block' this.blockStr '-TrackingMovement']);
                        db.addData({'pp' this.flow.variable('participantID') ...
                                    'trial' this.flow.variable(['Block' this.blockStr '-TrialNum']) ...
                                    'condition' this.conditionStr ...
                                    'distance' e{1}.measure('distance') ...
                                    'dx' e{1}.measure('x') ...
                                    'trialtime' this.time() ...
                                    'exptime' this.flow.time() ...
                                    'rawtime' GetSecs ...
                                   });
                        db.write();
                    end
                end

                if (this.Tc)
                    e = this.design.findEvents('TONES:playedTone');
                    if (~isempty(e))
                        db = this.flow.database(['Block' this.blockStr '-ToneTimes']);
                        db.addData({'pp' this.flow.variable('participantID') ...
                                    'trial' this.flow.variable(['Block' this.blockStr '-TrialNum']) ...
                                    'condition' this.conditionStr ...
                                    'freq' e{1}.measure('freq') ...
                                    'trialtime' this.time() ...
                                    'exptime' this.flow.time() ...
                                    'rawtime' GetSecs ...
                                   });
                        db.write();
                    end

                    e = this.design.findEvents('TONES:submittedResponse');
                    if (~isempty(e))
                        allCounts = e{1}.measure('allCounts');

                        db = this.flow.database(['Block' this.blockStr '-Tones']);
                        db.addData({'pp' this.flow.variable('participantID') ...
                                    'trial' this.flow.variable(['Block' this.blockStr '-TrialNum']) ...
                                    'condition' this.conditionStr ...
                                    'correct' e{1}.measure('correct') ...
                                    'response' e{1}.measure('response') ...
                                    'answer' e{1}.measure('answer') ...
                                    'total' e{1}.measure('total') ...
                                    'RT' e{1}.measure('RT') ...
                                    'trialtime' this.time() ...
                                    'exptime' this.flow.time() ...
                                    'rawtime' GetSecs ...
                                   });
                        db.write();
                    end
                end
            end

            if (GetSecs - this.startTime > 29.5)
                % end trial

                done = 0;
                if (this.Tc)
                    if (~this.finishing)
                        if (this.nB)
                            this.design.findTask('NBACK').stop();
                        else
                            this.design.findTask('TRACKING').stop();
                        end

                        this.design.findTask('TONES').finishTrial();
                    end

                    e = this.design.findEvents('TONES:finished');
                    if (~isempty(e))
                        done = 1;
                    end
                else
                    done = 1;
                end

                if (done)
                    db = this.flow.database(['Block' this.blockStr '-Trials']);
                    db.addData({'pp' this.flow.variable('participantID') ...
                                'trial' this.flow.variable(['Block' this.blockStr '-TrialNum']) ...
                                'condition' this.conditionStr ...
                                'task1' this.t1 ...
                                'task2' this.t2 ...
                                'duration' this.time ...
                                'expStarttime' (this.startTime - this.flow.startTime) ...
                                'expEndtime' this.flow.time() ...
                                'expStartRawtime' this.startTime ...
                                'expEndRawtime' GetSecs ...
                               });
                    db.write();

                    % store performance
                    if (this.nB & this.Tc)
                        perf = this.design.findTask('NBACK').avgPerformance();
                        perfHist = this.flow.variable('p-N (NC)');
                        this.flow.variable('p-N (NC)', [perfHist perf]);

                        perf = this.design.findTask('TONES').avgPerformance();
                        perfHist = this.flow.variable('p-C (NC)');
                        this.flow.variable('p-C (NC)', [perfHist perf]);

                        perf = this.design.findTask('TONES').avgDistance();
                        perfHist = this.flow.variable('d-C (NC)');
                        this.flow.variable('d-C (NC)', [perfHist perf]);

                    elseif (this.nB & this.Tr)
                        perf = this.design.findTask('NBACK').avgPerformance();
                        perfHist = this.flow.variable('p-N (NT)');
                        this.flow.variable('p-N (NT)', [perfHist perf]);

                        perf = this.design.findTask('TRACKING').avgPerformance();
                        perfHist = this.flow.variable('p-T (NT)');
                        this.flow.variable('p-T (NT)', [perfHist perf]);

                    else %(this.Tc & this.Tr)
                        perf = this.design.findTask('TONES').avgPerformance();
                        perfHist = this.flow.variable('p-C (CT)');
                        this.flow.variable('p-C (CT)', [perfHist perf]);

                        perf = this.design.findTask('TRACKING').avgPerformance();
                        perfHist = this.flow.variable('p-T (CT)');
                        this.flow.variable('p-T (CT)', [perfHist perf]);

                        perf = this.design.findTask('TONES').avgDistance();
                        perfHist = this.flow.variable('d-C (CT)');
                        this.flow.variable('d-C (CT)', [perfHist perf]);
                    end

                    trial = this.flow.variable(['Block' this.blockStr '-TrialNum']);
                    order = this.flow.variable(['Block' this.blockStr '-Order']);

                    if (trial < length(order))
                        %disp(trial);

                        % still have trials left
                        this.flow.trial = TrialFixation;
                    else
                        this.flow.database(['Block' this.blockStr '-Trials']).close();
                        this.flow.database(['Block' this.blockStr '-Nback']).close();
                        %this.flow.database(['Block2-1back']).close();
                        this.flow.database(['Block' this.blockStr '-Tracking']).close();
                        this.flow.database(['Block' this.blockStr '-TrackingMovement']).close();
                        this.flow.database(['Block' this.blockStr '-TrackingStart']).close();
                        this.flow.database(['Block' this.blockStr '-Tones']).close();
                        this.flow.database(['Block' this.blockStr '-ToneTimes']).close();
                        this.flow.database(['Block' this.blockStr '-MRITriggers']).close();

                        lastBlock = this.flow.variable('totalNumBlocks');

                        if (this.block == lastBlock)
                            this.flow.trial = TrialFinish;
                        else
                            this.flow.trial = TrialStartBlock;
                        end

                    end
                end
                this.finishing = 1;
            end

        end
    end % methods

end


