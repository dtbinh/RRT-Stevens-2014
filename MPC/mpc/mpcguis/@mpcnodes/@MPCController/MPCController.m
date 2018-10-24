function this = MPCController(varargin)
% Constructor for MPCController class.

%   Author:  Larry Ricker
%	Copyright 1986-2007 The MathWorks, Inc.
%	$Revision: 1.1.8.11 $  $Date: 2007/11/09 20:42:25 $

% Create class instance
this = mpcnodes.MPCController;
if nargin == 0
    % Recreating during a load.  Just return.
    return
end

this.label = varargin{1};
% Set flag to indicate that MPC object has not been set yet.
this.HasUpdated = 1;

% Initialize disturbance estimation property fields
EstimData(1) = struct('ModelUsed', {false}, 'ModelName', '', 'Model', []);
EstimData(2) = EstimData(1);
EstimData(3) = EstimData(1);
this.EstimData = EstimData;
this.DefaultEstimator = true;
this.EstimRefreshOK = true;

% Other defaults and initial conditions
this.ModelName = '';
this.Model = [];
this.Blocking = false;
this.Ts = '1.0';
this.P = '10';
this.M = '2';

this.icon = fullfile('toolbox','mpc','mpcutils','mpc_controller_icon.gif');
this.setInitial;

this.SaveFields = {'Handles.GainUDD.Value', ...
    'Handles.eHandles(1).UDD.CellData', ...
    'Handles.eHandles(2).UDD.CellData', ...
    'Handles.eHandles(3).UDD.CellData', ...
    'Handles.ULimits.CellData', 'Handles.YLimits.CellData', ...
    'Handles.Uwts.CellData', 'Handles.Ywts.CellData', ...
    'Handles.Usoft.CellData', 'Handles.Ysoft.CellData', ...
    'Handles.TrackingUDD.Value', 'Handles.HardnessUDD.Value'};
    
