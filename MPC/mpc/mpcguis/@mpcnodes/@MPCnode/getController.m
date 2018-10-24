function MPCobj = getController(this, Controller)
% Searches for the designated MPCController node and retrieves its MPC object.

%  Author:  Larry Ricker
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2007/11/09 20:45:11 $

if nargin > 1
    MPCobj = this.getRoot.getController(Controller);
else
    MPCobj = this.getRoot.getController;
end
