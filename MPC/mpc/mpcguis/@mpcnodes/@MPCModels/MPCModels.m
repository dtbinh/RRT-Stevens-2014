function this = MPCModels(varargin)
% Constructor for MPCModels class

%  Author(s):  Larry Ricker
%  Revised:
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.8 $ $Date: 2007/11/09 20:44:05 $

% Create class instance
this = mpcnodes.MPCModels;
if nargin == 0
    % Reloading.  Just return
    return
end
this.Label = varargin{1};
this.Editable = false;
this.Icon = fullfile('toolbox','mpc','mpcutils','mpc_models_icon.gif');
this.AllowsChildren = true; %jgo
this.Handles = struct('PopupMenuItems', [], 'UDDtable', []);
this.setInitial;
