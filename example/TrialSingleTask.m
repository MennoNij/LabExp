classdef TrialSingleTask < WBTrial

    properties
        Fx = 0;
        nB = 1;
        Tr = 2;
        Tc = 3;
        condition = 0;
        conditionStr = '?';
        firstTask = '?';
        block = 1;
        blockStr = '1';
    end

    methods

        function start(this)

            switch (this.condition)
                case {this.nB}
                    this.design.loadScene('SINGLE-NBACK');
                    this.conditionStr = 'N_';
                    this.firstTask = 'N';
                case {this.Tr}
                    this.design.loadScene('SINGLE-TRACKING');
                    this.conditionStr = 'T_';
                    this.firstTask = 'T';
                case {this.Tc}
                    this.design.loadScene('SINGLE-TONES');
                    this.conditionStr = 'C_';
                    this.firstTask = 'C';
                    tc = this.design.findTask('TONES');
                    tc.answerSide = 0;
                otherwise
                    this.design.loadScene('SINGLE-FX');
                    this.conditionStr = 'FX';
                    this.firstTask = 'F';
            end

            %fprintf('start trial\n');
            %fprintf('secs %.3f\n',GetSecs);
            %fprintf('start %.3f\n',this.startTime);

            this.block = this.flow.variable(['BlockNum']);
            this.blockStr = num2str(this.block);

            this.design.startAllTasks();
        end

        function update(this)
            if (this.design.newEvents())
                if (this.condition == this.nB)

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
                        %db.write();
                    end

                elseif (this.condition == this.Tr)

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
                        %db.write();
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
                        %db.write();
                    end

                else % Tc
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
                        %db.write();
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
                        %db.write();
                    end
                end
            end

            if (GetSecs - this.startTime > 29.5)
                % end trial
                done = 0;
                if (this.condition == this.Tc)
                    this.design.findTask('TONES').finishTrial();

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
                                'task1' this.firstTask ...
                                'task2' '?' ...
                                'duration' this.time ...
                                'expStarttime' (this.startTime - this.flow.startTime) ...
                                'expEndtime' this.flow.time() ...
                                'expStartRawtime' this.startTime ...
                                'expEndRawtime' GetSecs ...
                               });
                    db.write();

                    this.flow.database(['Block' this.blockStr '-Nback']).write();
                    this.flow.database(['Block' this.blockStr '-Tracking']).write();
                    this.flow.database(['Block' this.blockStr '-TrackingMovement']).write();
                    this.flow.database(['Block' this.blockStr '-Tones']).write();
                    this.flow.database(['Block' this.blockStr '-ToneTimes']).write();
                    this.flow.database(['Block' this.blockStr '-MRITriggers']).write();

                    % store performance
                    if (this.condition ~= this.Fx)
                        tsk = 'TONES';
                        vr = 'p-C';
                        if (this.condition == this.nB)
                            tsk = 'NBACK';
                            vr = 'p-N';
                        elseif (this.condition == this.Tr)
                            tsk = 'TRACKING';
                            vr = 'p-T';
                        end
                        perf = this.design.findTask(tsk).avgPerformance();
                        perfHist = this.flow.variable(vr);
                        this.flow.variable(vr, [perfHist perf]);
                        
                        if (this.condition == this.Tc)
                            perf = this.design.findTask('TONES').avgDistance();
                            perfHist = this.flow.variable('d-C');
                            this.flow.variable('d-C', [perfHist perf]);
                        end
                    end

                    % check trial
                    trial = this.flow.variable(['Block' this.blockStr '-TrialNum']);
                    order = this.flow.variable(['Block' this.blockStr '-Order']);

                    if (trial < length(order))
                        %disp(trial);

                        % still have trials left

                        this.flow.trial = TrialFixation;
                    else
                        this.flow.database(['Block' this.blockStr '-Trials']).close();
                        this.flow.database(['Block' this.blockStr '-Nback']).close();
                        %this.flow.database(['Block1-1back']).close();
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
            end

        end
    end % methods

end


