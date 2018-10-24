function result = subsref(mpcsimopt,Struct)
%SUBSREF  Subscripted reference for mpcsimopt objects.
%
%   The following reference operation can be applied to any
%   mpcsimopt object:
%      mpcsimopt.Fieldname  equivalent to GET(mpcsimopt,'Fieldname')
%   These expressions can be followed by any valid subscripted
%   reference of the result, as in  SYS(1,[2 3]).inputname  or
%   SYS.num{1,1}.
%
%
%   See also GET.

%   Author: A. Bemporad
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2007/11/09 20:40:54 $


% Effect on mpcsimopt properties: all inherited

ni = nargin;
if ni==1,
    result = sys;
    return
end
StructLength = length(Struct);

% Peel off first layer of subreferencing
switch Struct(1).type
    case '.'

        % The first subreference is of the form sys.fieldname
        % The output is a piece of one of the system properties
        try
            if StructLength==1,
                result = get(mpcsimopt,Struct(1).subs);
            else
                %Struct(2).subs=names(Struct(1).subs,Struct(2).subs);
                result = subsref(get(mpcsimopt,Struct(1).subs),Struct(2:end));
            end
        catch ME
            throw(ME);
        end
    otherwise
        ctrlMsgUtils.error('MPC:object:InvalidSubs',Struct(1).type);
end
