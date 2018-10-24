function [varargout] = mpctool(varargin)
% MPCTOOL 
%
% Open the MPC design graphical user interface (gui).
%
% MPCTOOL by itself opens the gui, creating a new MPC design task if none
% exists.
%
% MPCTOOL(MPCobj) loads MPCobj (an MPC controller object) for
% testing and modification by the user.
%
% MPCTOOL(MPCobj,'OBJNAME') assigns string OBJNAME as the controller name
% used in the gui.  If a name is not supplied, the object's variable name
% is used.  If the object doesn't have a name (e.g., it has been
% created in an expression), a default name is assigned.
%
% MPCTOOL(MPCobj1,MPCobj2, ...) loads multiple objects.  Each may be
% followed by a name string, e.g., MPCTOOL(MPCobj1,'name1',MPCobj2, ...).
%
% MPCTOOL('TaskName') opens the gui (if necessary) and creates a new 
% design task, "TaskName" (a string) within the gui.
%
% See also MPC

%	Author:  Larry Ricker
%	Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.13 $  $Date: 2008/05/31 23:21:23 $

% [w, h] = MPCTOOL(...) returns optional outputs:
%    w      The explorer.Workspace handle.
%    h      The mpcnodes.MPCGUI handle -- a pointer to the new
%             design.  If no design task has been created
%             (e.g., because one already exists), h = [];
%
% this syntax could be changed in the future

import com.mathworks.toolbox.control.explorer.*
import com.mathworks.toolbox.control.util.*;
import com.mathworks.toolbox.mpc.*;
import javax.swing.*;
import com.mathworks.mwswing.*;

if ~usejava('swing')
    ctrlMsgUtils.error('MPC:object:NoSwing','mpctool');            
end

% See whether or not the user has supplied an MPC object
if nargin < 1
    MPCobjects = {};
    TaskName = '';
elseif nargin == 1 && ischar(varargin{1})
    % This version creates a new project.  The input argument is the
    % project name.
    MPCobjects = {};
    TaskName = varargin{1};
else
    % Process the input arguments.  Each must be either an MPC object
    % or a name (character string).  If no name is supplied,
    % use the variable's name (if any) or a default name.
    TaskName = '';
    i = 1;
    nobj = 0;
    while i <= nargin
        NextClass = class(varargin{i});
        if ~strcmpi('mpc', NextClass)
            ctrlMsgUtils.error('MPC:object:InvalidMPCTOOLObject','mpctool',i,NextClass);        
        end
        nobj = nobj + 1;
        MPCobjects{nobj,1} = varargin{i};
        
        % Define default name
        ObjName = inputname(i);
        if isempty(ObjName)
            ObjName = sprintf('MPC%i',nobj);
        end
        i = i + 1;
        if i > nargin
            MPCobjects{nobj,2} = ObjName;
            break
        end
        
        % Previous input was an object so next can be either its name
        % or another object.
        if ischar(varargin{i})
            % It is a string, so assume it's a name.
            MPCobjects{nobj,2} = varargin{i};
            i = i + 1;
        else
            % Not a string, so use default name.
            MPCobjects{nobj,2} = ObjName;
        end
    end
end

% Get the frame handles etc.
try
    wb = waitbar(0, ctrlMsgUtils.message('MPC:designtool:ToolWaitbarTitle'), 'Name', 'MPC Tool');
    [Frame, MPC_WSh, MPC_MANh, h, Project] = slmpctool('initialize', ...
        '', [], TaskName, '', MPCobjects, wb);
    close(wb);
catch ME
    close(wb);
    throw(ME);
end

if nargout < 1
    return
else
    varargout(1) = {MPC_WSh};
end

if nargout >= 2
    varargout(2) = {h};
end
