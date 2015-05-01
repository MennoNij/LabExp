classdef WBDatabase < handle
% Data manager class that writes CSV files according to its internal format

    properties (SetAccess = public, GetAccess = public)
        name = 'Database';      % name/id of the database
        filename                % filename to which the data will be written
        format                  % the column/field names of the database
        entries                   % the current line to be written to the database

        delimiter = '\t';       % the delimiter between columns/fields
    end

    properties (SetAccess = private, GetAccess = private)
        fid                     % file pointer of the database file
    end

    methods
        function obj = WBDatabase(nm, flnm, frmt)
            obj.name = nm;
            obj.filename = flnm;
            obj.format = frmt;
            obj.entries = {};
        end

        function addData(this, data)
        % ADDDATA add a list of field/value pairs at the correct place in the current entry

            % check if all pairs are complete
            if (mod(length(data), 2) > 0)
                error([name ': not all data pairs are complete.']);
            else
                entry{length(this.format)} = {};
                % go through each pair and add them to the correct place in the current entry
                for (i = 1:2:length(data))
                    % find entry index to store value
                    idx = this.findMeasure(data{i});

                    if (idx ~= 0)
                        % add the measure if its name was found in the format
                        entry{idx} = data{i+1};
                    end
                end

                this.entries = cat(1, this.entries, {entry});
            end
        end

        function addMeasure(this, name, value)
        % ADDMEASURE add a single field/value pair to the current entry
            idx = this.findMeasure(name);

            if (idx ~= 0)
                this.entry{idx} = value;
            end
        end

        function open(this)
        % OPEN open and prepare the database file
            this.fid = fopen(this.filename, 'w');
            % write column names
            this.writeRow(this.format);
        end

        function close(this)
        % CLOSE close the database file
            fclose(this.fid);
        end

        function writeRow(this, data)
        % WRITEROW write a row of concatenated data elements to the database file
            out = num2str(data{1});
            if (length(data) > 1)
                % concatenate remaining data into the row
                for (i = 2:length(data))
                    out = [out this.delimiter num2str(data{i})];
                end
            end
            out = [out '\n'];
            % replace all % with %%, otherwise fprintf will get confused
            out = strrep(out, '%', '%%');

            fprintf(this.fid, out);
        end

        function write(this)
        % WRITE write the current entry to the database file and clear the entry
            if(length(this.entries) > 0)
                for (i = 1:length(this.entries))
                    this.writeRow(this.entries{i});
                end

                this.emptyEntry();
            end
        end

        function emptyEntry(this)
        % EMPTYENTRY empty the current entry
            %empty{length(this.format)} = [];
            %this.entry = empty;
            this.entries = {};
        end

        function set.format(this, value)
            this.format = value;
            % make sure the format consists of strings

            this.emptyEntry();
        end

        function set.delimiter(this, value)
            this.delimiter = value;
        end

    end % methods

    methods (Access = private)
        function idx = findMeasure(this, name)
        % FINDMEASURE find the column number of the given field name
            loc = strcmp(this.format, name);
            idx = find(loc);
        end

    end

end
