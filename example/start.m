% entry point for a WOMBAT experiment
% Framework for Online Behavioural Experiments FOBEX
function start(nm, version, sblock)
    % seed matlabs random generator
    RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
    % Use the timing functions so they are loaded before the first real use
    %KbCheck;
    %KbName;
    [a, t, k, d] = KbCheck;
    %a = CharAvail;
    %a = GetChar;
    FlushEvents;

    % Add this at top of new scripts for maximum portability due to unified names on all systems:
    KbName('UnifyKeyNames'); 
    % Select maximum allowable realtime priority for current operating system:
    %Priority(1);%MaxPriority);
    Priority(2);

    %clear all;
    close all;
	oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
    oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
    %Screen('Preference', 'SuppressAllWarnings', 1);
    %Screen('Preference', 'VisualDebuglevel', 0);
    %Screen('Preference', 'Verbosity', 0);
    %Screen('Preference', 'TextRenderer', 1);
    %Screen('Preference', 'TextAntiAliasing', 2); % anti aliased

    name = '';
    fmri = 0;
    if (nargin > 0)
        name = nm;
    end

    if (nargin > 1)
        fmri = version;
    end

    startblock = 0;
    if (nargin > 2)
        startblock = sblock;
    end

    screenNumber=max(Screen('Screens'));

    [w, h] = Screen('WindowSize', screenNumber);

    %w = 1024;
    %h = 768;

    disp(['Screen size: ',num2str(w),'x',num2str(h)]);

    % disable matlab console key input
    ListenChar(2);

    % create a new experiment
    experiment = WBExp;

    experiment.design.screenNumber = screenNumber;
    experiment.design.useMouse = 0;
    experiment.design.setScreenSize(w, h);

    experiment.flow.dataDir = [pwd '/data/'];
    experiment.flow.variable('forFMRI', fmri);
    if (length(name) > 0)
        experiment.flow.variable('participantID', name);
    end

    if (strcmp(name, 'shorty'))
        experiment.flow.variable('trialMultiplier', 1);
    else
        if (fmri)
            experiment.flow.variable('trialMultiplier', 2);
            experiment.flow.variable('totalNumBlocks', 6);
        else
            experiment.flow.variable('trialMultiplier', 2);
            experiment.flow.variable('totalNumBlocks', 2);
        end
    end

    experiment.flow.variable('BlockNum', startblock - 1);

    sTrial = TrialStart;
    if (length(name) > 0 )
        sTrial.skipID = 1;
    end

    if (fmri == 1)
        [y1, Fs1] = wavread('tone_low.wav');
        wavplay(y1, Fs1, 'async');
    end

    experiment.flow.trial = sTrial;
    % start the experiment
    experiment.start();

    % re-enable matlab console key input
    ListenChar(0);
    ShowCursor();
end

