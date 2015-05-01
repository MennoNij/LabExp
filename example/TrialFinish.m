classdef TrialFinish < WBTrial
    methods
        function start(this)
            doFMRI = this.flow.variable('forFMRI');
            blocknum = this.flow.variable('BlockNum');

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
            disp( ['-- BLOCK ' num2str(blocknum) ' -----------------']);
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

            % CREATE THE EXPERIMENT CONCLUDED SCREEN
            to = WBTextDisplay('END TEXT', '', 30);
            to.text = {'The experiment is is now concluded. Thank you for your participation!' ...
                       'You can now notify the supervisor.' '' 'Press Q'};

            if (doFMRI)
                to.text = {'The experiment is is now concluded.' 'Thank you for your participation!' ...
                           };
            end

            this.design.buildScene('END SCREEN', {to}, '1');
            this.design.loadScene('END SCREEN');
            this.design.findTask('END TEXT').start();
        end

        function update(this)
            %if (this.design.newEvents())
                e = this.design.findEvents('END TEXT:keyPressed');

                if (~isempty(e))
                    key = lower(e{1}.measure('key'));
                    if (strcmp('return', key) | strcmp('q', key))
                        this.flow.finish();
                    end
                end
            %end
        end
    end
end
