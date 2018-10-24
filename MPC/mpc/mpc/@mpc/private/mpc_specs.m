function newSpecs=mpc_specs(Specs,n,type,p,MinOutputECR,names,index,InheritNameFromPlant)
%MPC_SPECS Check Specs
%
%   type='ManipulatedVariables' or 'OutputVariables' or 'DisturbanceVariables'
%
%   Given the array of structures Specs, convert data to matrix format

%    A. Bemporad
%    Copyright 2001-2007 The MathWorks, Inc.
%    $Revision: 1.1.6.3 $  $Date: 2008/05/19 23:18:48 $

verbose = mpccheckverbose;

if nargin<8 || isempty(InheritNameFromPlant),
    InheritNameFromPlant=1; % Inheritance of names from DV/OV/MV has been disabled
end

default=mpc_defaults;
u=default.u;
y=default.y;
d=default.d;

if isempty(Specs),
    if n==0,
        newSpecs=Specs;
        return
    end
    for i=1:n,
        Specs(i).Name=''; % Create a cell array of length n
    end
end

if ~isa(Specs,'struct'),
    if n>1,
        ctrlMsgUtils.error('MPC:utility:InvalidSpecType',type,n);
    else
        ctrlMsgUtils.error('MPC:utility:InvalidSpecStruct',type);
    end
end

len=length(Specs);
if len>n,
    ctrlMsgUtils.error('MPC:utility:InvalidSpecLength',type,n);
end

if len<n,
    if verbose,
        if len==0,
            fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:NoSpecSpecified',type));
        else
            fprintf('-->%s\n',ctrlMsgUtils.message('MPC:object:SpecTooSmall',type,n));
        end
    end
    for i=len+1:n,
        s=fieldnames(Specs(1));
        Specs(i).(s{1})=[];
    end
end

switch type
    case 'ManipulatedVariables'
        fields={'Min','Max','MinECR','MaxECR',...
            'RateMin','RateMax','RateMinECR','RateMaxECR','Target',...
            'Name',... %'Zero','Span',
            'Units'};
        deftype='u';
    case 'OutputVariables'
        fields={'Min','Max','MinECR','MaxECR','Name',...%'Zero','Span',
            'Units','Integrator'};
        deftype='y';
    case 'DisturbanceVariables'
        fields={'Name',...%'Zero','Span',
            'Units'};
        deftype='d';
end


for h=1:n,

    clear Struct
    s=fieldnames(Specs(h)); % get field names

    % Check for wrong fields
    for i=1:length(s),
        name=s{i};
        if isempty(ismember(lower(fields),lower(name))), % field inexistent
            ctrlMsgUtils.error('MPC:utility:InvalidSpecStructField',name,type,h);
        end
    end

    if isfield(Specs(h),'Name') && ~isempty(Specs(h).Name) &&...
            (~strcmp(Specs(h).Name,names{index(h),:}) && ~InheritNameFromPlant),
        ctrlMsgUtils.error('MPC:utility:InvalidSpecName');
    end

    if InheritNameFromPlant || ~isfield(Specs(h),'Name') || isempty(Specs(h).Name) || ...
            strcmp(Specs(h).Name,names{index(h),:}),
        % Inherit signal names from Plant I/O names. Names previously stored in
        % Specs will be lost.
        Specs(h).Name='';

        %eval(sprintf('%s.name=''%s'';',deftype,names{index(h),:}));
        switch deftype
            case 'u'
                u.name=names{index(h),:};
            case 'y'
                y.name=names{index(h),:};
            case 'd'
                d.name=names{index(h),:};
        end
    end

    % Assign all fields
    for j=1:length(fields),
        aux=fields{j};
        i=find(ismember(lower(s),lower(aux))); % locate fields{j} within s

        switch deftype
            case 'u'
                faux=u.(lower(aux));
            case 'y'
                faux=y.(lower(aux));
            case 'd'
                faux=d.(lower(aux));
        end

        if isempty(i),
            %eval(sprintf('Struct.%s=%s.%s;',aux,deftype,lower(aux)));
            Struct.(aux)=faux;
        else
            % In case of duplicate names because of different case, the last
            % element i(end) is the one supplied as latest (through SET)
            aux=s{i(end)};

            %eval(sprintf('field=Specs(h).%s;',aux));
            field=Specs(h).(aux);
            if isempty(field),
                %eval(sprintf('field=%s.%s;',deftype,lower(aux)));
                field=faux;
            end

            switch lower(aux)
                case {'name','units'}
                    if ~isa(field,'char'),
                        ctrlMsgUtils.error('MPC:utility:InvalidNameUnits',sprintf('%s(%d).%s',type,h,aux));
                    end
                case 'target'
                    if isa(field,'char'),
                        if ~strcmp(field,u.target),
                            ctrlMsgUtils.error('MPC:utility:InvalidTarget',sprintf('%s(%d).%s',type,h,aux),u.target);
                        end
                    else
                        if ~isa(field,'double'),
                            ctrlMsgUtils.error('MPC:utility:InvalidTarget',sprintf('%s(%d).%s',type,h,aux),u.target);
                        end
                    end
                otherwise
                    if ~isa(field,'double'),
                        ctrlMsgUtils.error('MPC:utility:InvalidOtherField',sprintf('%s(%d).%s',type,h,aux));
                    end
            end

            if ~isempty(field),

                % Check nonnegativity of ECRs and check input Target
                switch deftype

                    case 'u'
                        % ECR
                        if ismember(j,[3 4 7 8]),
                            if any(field<0) || ~all(isfinite(field(:))),
                                ctrlMsgUtils.error('MPC:utility:InvalidUYField',sprintf('%s(%d).%s',type,h,aux));
                            end
                        end
                        % Target
                        if j==9
                            if isa(field,'char'),
                                if ~strcmp(field,u.target),
                                    ctrlMsgUtils.error('MPC:utility:InvalidTarget',sprintf('%s(%d).%s',type,h,aux),u.target);
                                end
                            else
                                if ~isa(field,'double') || ~all(isfinite(field(:)))
                                    ctrlMsgUtils.error('MPC:utility:InvalidTarget',sprintf('%s(%d).%s',type,h,aux),u.target);
                                end
                            end
                        end

                    case 'y'
                        if ismember(j,[3 4]),
                            if any(field<=MinOutputECR),
                                if verbose,
                                    fprintf('-->%s\n',ctrlMsgUtils.message('MPC:computation:MinOutputECRTooSmall',sprintf('%s(%d).%s',type,h,aux),MinOutputECR));
                                end
                                field(field<=MinOutputECR)=MinOutputECR;
                            elseif ~all(isfinite(field(:))),
                                ctrlMsgUtils.error('MPC:utility:InvalidUYField',sprintf('%s(%d).%s',type,h,aux));
                            end
                        elseif (j==7),
                            if any(field<0) || ~all(isfinite(field(:))),
                                ctrlMsgUtils.error('MPC:utility:InvalidUYField',sprintf('%s(%d).%s',type,h,aux));
                            end
                        end
                end
            end

            if isnumeric(field), % Don't do the following for char arrays
                field=field(:);
                if length(field)>p, % Longer than prediction horizon ?
                    if verbose,
                        fprintf('-->%s\n',ctrlMsgUtils.message('MPC:computation:SpecTruncated',sprintf('%s(%d).%s',type,h,aux),p,p));
                    end
                    field=field(1:p);
                end
            end

            %eval(sprintf('Struct.%s=field;',fields{j}));
            Struct.(fields{j})=field;
        end
    end

    % Check consistency of limits

    if deftype~='d',
        Max = Struct.Max;
        Min = Struct.Min;
        len = max(length(Max),length(Min));
        Max(length(Max):len) = Max(end);
        Min(length(Min):len) = Min(end);
        if any(Max(:)<Min(:)),
            ctrlMsgUtils.error('MPC:utility:InvalidMinMax',type,h,type,h);
        end
    end
    if deftype=='u',
        RateMax = Struct.RateMax;
        RateMin = Struct.RateMin;
        len = max(length(RateMax),length(RateMin));
        RateMax(length(RateMax):len) = RateMax(end);
        RateMin(length(RateMin):len) = RateMin(end);
        if any(RateMax(:)<RateMin(:)),
            ctrlMsgUtils.error('MPC:utility:InvalidRateMinMax',type,h,type,h);
        end
    end

    %if Struct.Span<Struct.Zero,
    %   error(sprintf('%s(%d).Span should be greater than %s(%d).Zero.',type,h,type,h));
    %end
    newSpecs(h)=Struct;

end
