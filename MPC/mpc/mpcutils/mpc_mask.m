function mpc_mask(varargin)
% MPC_MASK Mask for MPC Controller block

%   Authors: A. Bemporad, R. Chen
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.25 $  $Date: 2009/07/18 15:53:03 $

% Syntax with input args is:
%
% Case 1: mpc_mask()
% open from double-clicking MPC block mask dialog
%
% Case 2: mpc_mask('load', blksystem, '', mpc_block, hGUI)
% an saved mpc block design task has been loaded from a CETM project (called by postLoad) 
%
% Case 3: mpc_mask('open_by_mmpc', blksystem, '', mpc_block) 
% opens the mask related to an MPC block underlying a Multiple MPC block,
% in order to invoke the GUI on that MPC block 
%
% Case 4: mpc_mask('open_by_cetm', blksystem, proj)
% start a new design task from CETM's new project and new task dialogs
%

%% Quantity to automatically enlarge and vertically shift all items in mask
voffset=1.7; 
EditHeight=1.54;

%% Initialization
if nargin==0
    % Case 1
    blksystem = bdroot(gcs);
    proj = [];
    blk = gcb;
    blkh = gcbh;
else
    option=varargin{1};
    switch option
        case 'load'
            % Case 2
            blksystem = varargin{2};
            if isempty(find_system('Name',blksystem))
                open_system(blksystem)
            end
            proj = varargin{3};            
            blk = varargin{4};
            if isempty(blk)
                % Select the right mpc block
                blk = mpc_getblockpath(blksystem,'MPC'); 
            end
            if isempty(blk)
                return % There is no MPC block in the model
            end
            blkh = get_param(blk,'Handle');
            task_name = varargin{5};
        case 'open_by_mmpc'
            % Case 3
            blksystem = varargin{2};
            proj = varargin{3};            
            blk = varargin{4};
            blkh = get_param(blk,'Handle');
        case 'open_by_cetm'
            % Case 4
            blksystem = varargin{2};
            proj = varargin{3};            
            % Select the right block automatically and manually
            blk = mpc_getblockpath(blksystem,'MPC'); 
            if isempty(blk)
                return % There is no MPC block in the model
            end
            blkh = get_param(blk,'Handle');
        otherwise
            ctrlMsgUtils.error('Controllib:general:UnexpectedError','wrong syntax when using "slmpctool" command');                        
    end
end

%% check wehther mask exists
oldsh = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
fig = findobj('Type','figure', 'Tag', 'MPC_mask');
set(0,'ShowHiddenHandles',oldsh');
f = findobj(fig, 'flat', 'UserData', blkh);

%% Create mask dialog when not exisitng
if isempty(f)
    %% Get values from MPC block
    mpcobj = get_param(blkh,'mpcobj');                  %'mpc(tf(1,[1 1]))'
    x0 = get_param(blkh,'x0');                          %'[]'
    
    ref_from_ws = get_param(blkh,'ref_from_ws');        %'off'
    ref_signal_name = get_param(blkh,'ref_signal_name');%'[]'
    ref_preview = get_param(blkh,'ref_preview');        %'on'
    
    md_from_ws = get_param(blkh,'md_from_ws');          %'off'
    md_signal_name = get_param(blkh,'md_signal_name');  %'[]'
    md_preview = get_param(blkh,'md_preview');          %'on'
    
    md_inport= get_param(blkh,'md_inport');             %'on'
    mv_inport= get_param(blkh,'mv_inport');             %'off'
    lims_inport= get_param(blkh,'lims_inport');         %'off'
    switch_inport= get_param(blkh,'switch_inport');     %'off'
    
    % UICONTROL wants 0 or 1, not 'on' or 'off' as the checkbox variable
    ref_from_ws=~strcmp(ref_from_ws,'off');
    ref_preview=~strcmp(ref_preview,'off');
    md_from_ws=~strcmp(md_from_ws,'off');
    md_preview=~strcmp(md_preview,'off');
    md_inport=~strcmp(md_inport,'off');
    mv_inport=~strcmp(mv_inport,'off');
    lims_inport=~strcmp(lims_inport,'off');
    switch_inport=~strcmp(switch_inport,'off');
    
    % Gray out everything if the mask is invoked from the MPC Library
    ref_enabled = 'off';
    md_enabled = 'off';
    if strcmp(blk,'mpclib/MPC Controller'),
        enabled = 'off'; 
    else
        enabled = 'on';
        if ref_from_ws,
            ref_enabled = 'on';
        end
        if md_from_ws,
            md_enabled = 'on';
        end
    end

    %% Create Mask Figure
    f = figure('Visible','off');
    set(f, 'Tag', 'MPC_mask', 'UserData',blkh, 'units', 'characters',...
        'numbertitle','off','name','Block Parameters: MPC Controller','Dockcontrols','off',...
        'position',[103.8 18 92 35.7+voffset],'MenuBar','none','Resize','off',...
        'NumberTitle','off','PaperPosition',get(0,'defaultfigurePaperPosition'),...
        'Color',get(0,'DefaultUIcontrolBackgroundColor'),'HandleVisibility','off');

    %% Boxes
    % Description Box
    frame1 = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[1.8 22+voffset 88 13],...
        'String',{ 'Frame' },...
        'Style','frame',...
        'Tag','frame1','Enable',enabled); %#ok<NASGU>
    % Parameter Box
    frame2 = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[1.8 16.05+voffset 88.2 4.87],...
        'String',{ 'Frame' },...
        'Style','frame',...
        'Tag','frame2','Enable',enabled); %#ok<NASGU>
    % Signal Box
    frame3 = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[1.8 9.20+voffset 88.2 5.7],...
        'String',{ 'Frame' },...
        'Style','frame',...
        'Tag','frame3','Enable',enabled); %#ok<NASGU>

    %% Description
    % Box title
    text1 = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[3.2 34+voffset 27 1.3],...
        'String','MPC block (mask) (link)',...
        'Style','text',...
        'Tag','text1','Enable',enabled); %#ok<NASGU>
    % Text
    msg = sprintf('%s\n%s\n%s%s%s%s%s',...
        'The MPC Controller block lets you design, simulate, and tune model predictive controllers. ',...
        'You can use the MPC Design Tool to create a new controller or modify an existing one. ',...
        'Reference and measured disturbance signals, by default, are external inputs to the MPC block. ',...
        'In alternative you can specify custom workspace structures, ',...
        'generated for example by a ''To Workspace'' block (see ''From Workspace'' block for structure format). ',...
        'If the Look Ahead option is selected, the MPC controller ',...
        'will use future values of the corresponding signal when computing current control actions. ');
    h101 = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'HorizontalAlignment','left',...
        'Position',[2.6 22.43+voffset 80 1.2*9],...
        'String',msg,...
        'Style','text',...
        'Tag','text101','Enable',enabled); %#ok<NASGU>

    %% Parameter
    % Box title
    text2 = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[7.6 20.15+voffset 12.4 1.31],...
        'String','Parameters',...
        'Style','text',...
        'Tag','text3','Enable',enabled); %#ok<NASGU>
    % mpc controller label
    h115 = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'HorizontalAlignment','left',...
        'Position',[4.4 18.7+voffset 15.6 1.15],...
        'String','MPC controller',...
        'Style','text','TooltipString','Specify an MPC object',...
        'Tag','text16','Enable',enabled); %#ok<NASGU>
    % mpc controller edit field
    editBoxObj = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'BackgroundColor',[1 1 1],...
        'HorizontalAlignment','left',...
        'Position',[25 18.7+voffset 40 EditHeight],...
        'String', mpcobj,...
        'Style','edit',...
        'TooltipString','Insert an MPC object here',...
        'Tag','edit5','Enable',enabled,'Visible','on');
    % initial state label
    tooltipstate = 'Initial state of the MPC controller (extended state estimate). Type HELP MPCSTATE for more info';
    h37 = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'HorizontalAlignment','left',...
        'Position',[4.2 16.60+voffset 19.8 1.15],...
        'String','Initial controller state',...
        'Style','text','TooltipString',tooltipstate,...
        'Tag','text16','Enable',enabled); %#ok<NASGU>
    % initial state edit field
    editBoxX = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'BackgroundColor',[1 1 1],...
        'HorizontalAlignment','left',...
        'Position',[25 16.5+voffset 40 EditHeight],...
        'String',x0,...
        'Style','edit',...
        'TooltipString',tooltipstate,...
        'Tag','edit6','Enable',enabled);
    % Design button
    btnGUI = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[69 18.6+voffset 15.8 1.77],...
        'String','Design','TooltipString','Design/Edit MPC controller in the MPC Design Tool',...
        'Tag','pushbutton10','Enable',enabled);

    %% Signal
    % Box title
    text3 = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[5.6 14.2+voffset 12.5 1.15],...
        'String','Input signals',...
        'Style','text',...
        'Tag','text4','Enable',enabled); %#ok<NASGU>
    % Text
    text4 = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'HorizontalAlignment','left',...
        'Position',[3.6 12.8+voffset 12.4 1.15],...
        'String','Use custom',...
        'Style','text',...
        'Tag','text5','Enable',enabled); %#ok<NASGU>
    % custom ref checkbox
    chkref_from_ws = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[3 11.3+voffset 25 1.15],...
        'String','Reference signal',...
        'Style','checkbox',...
        'Value',ref_from_ws,...
        'TooltipString','Load reference signal from workspace','value',strcmp(ref_enabled,'on'),...
        'Tag','checkbox_refws','Enable',enabled);
    % custom ref edit field
    editBoxRef = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'BackgroundColor',[1 1 1],...
        'HorizontalAlignment','left',...
        'Position',[31.8 11.5+voffset 33.2 EditHeight],...
        'String',ref_signal_name,...
        'TooltipString','Output reference signal (structure with fields ''time'' and ''signals'' -- See ''To Workspace'' block)',...
        'Style','edit',...
        'Tag','edit1','Enable',ref_enabled);
    % custom ref preview checkbox
    chkref_preview = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[69.8 11.4+voffset 17.2 1.61538461538462],...
        'String','Look ahead',...
        'TooltipString','Use future samples of reference signals (anticipative action)',...
        'Style','checkbox',...
        'Tag','checkbox_refpre','Enable',ref_enabled,'Value',ref_preview);
    % custom md checkbox
    chkMD_from_ws = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[3 9.7+voffset 28 1.15],...
        'String','Measured disturbance',...
        'Style','checkbox',...
        'Value',md_from_ws,...
        'TooltipString','Load measured disturbance signal from workspace',...
        'Tag','checkbox_mdws','Enable',enabled);
    % custom md edit field
    editBoxMD = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'BackgroundColor',[1 1 1],...
        'HorizontalAlignment','left',...
        'Position',[31.8 9.6+voffset 33.2 EditHeight],...
        'String',md_signal_name,...
        'Style','edit',...
        'TooltipString','Measured disturbance signal (structure with fields ''time'' and ''signals'' -- See ''To Workspace'' block)',...
        'Tag','edit4','Enable',md_enabled);
    % custom md preview checkbox
    chkMD_preview = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[69.8 9.5+voffset 17.2 1.61538461538462],...
        'String','Look ahead',...
        'Style','checkbox',...
        'TooltipString','Use future samples of measured disturbance signals (anticipative action)',...
        'Tag','checkbox_mdpre','Enable',md_enabled,'Value',md_preview);

    %% Optional Signals
    % MD
    chkMDInputPort = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[1.8 7.0+voffset 47.4 1.15],...
        'String','Enable input port for measured disturbance',...
        'Value',md_inport,...
        'Style','checkbox',...
        'Tag','checkbox_md','Enable',enabled);
    % Ext.MV
    chkMVInputPort = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[1.8 5.4+voffset 120 1.15],...
        'String','Enable input port for externally supplied manipulated variables to plant',...
        'Value',mv_inport,...
        'Style','checkbox',...
        'Tag','checkbox_mv','Enable',enabled,...
        'TooltipString','Update the internal MPC state estimate through the externally supplied signal');%,...

    % Bounds
    chkLIMSInputPort = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[1.8 3.8+voffset 47.4 1.15],...
        'String','Enable input port for input and output limits',...
        'Value',lims_inport,...
        'Style','checkbox',...
        'Tag','checkbox_lims','Enable',enabled);
    % Switch input port
    chkSWITCHInputPort = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[1.8 2.2+voffset 55 1.15],...
        'String','Enable input port for switching optimization off',...
        'Value',switch_inport,...
        'Style','checkbox',...
        'Tag','checkbox_switch','Enable',enabled,...
        'callback',{@SWITCHInportCallBack chkMVInputPort});%,...

    %% Buttons
    % OK
    h20 = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[22.8 0.615 15 1.77],...
        'String','OK','TooltipString','Apply latest changes and close the dialog',...
        'Tag','pushbutton3','Enable',enabled,...
        'callback',{@OKCallBack f enabled blkh editBoxObj ...
        editBoxX ...
        chkref_from_ws editBoxRef chkref_preview ...
        chkMD_from_ws editBoxMD chkMD_preview chkMDInputPort chkMVInputPort ...
        chkLIMSInputPort chkSWITCHInputPort});
    % Cancel
    h30 = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[40 0.615 15 1.769],...
        'String','Cancel','TooltipString','Close the dialog without applying latest changes',...
        'Tag','pushbutton6','Enable','on','callback',{@CancelCallBack f editBoxObj blkh});
    % Help
    h31 = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[57.6 0.615 15 1.769],...
        'String','Help','TooltipString','Open the content sensitive help window',...
        'Tag','pushbutton7','Enable',enabled,...
        'callback',{@mpcCSHelp, 'MPCmask'}); %#ok<NASGU>
    % Apply
    h32 = uicontrol(...
        'Parent',f,...
        'Units','characters',...
        'Position',[75 0.615 15 1.769],...
        'String','Apply','TooltipString','Apply latest changes and leave the dialog open',...
        'Tag','pushbutton8','Enable',enabled,...
        'callback',{@applyCallBack blkh f editBoxObj editBoxX ... %chkObs ss_flag ...
        chkref_from_ws editBoxRef chkref_preview chkMD_from_ws editBoxMD ...
        chkMD_preview chkMDInputPort chkMVInputPort ...
        chkLIMSInputPort chkSWITCHInputPort});

    %% Callbacks
    set(btnGUI,'callback',{@GUICallBack 'DesignButton' f editBoxObj blkh blksystem proj});
    set(chkref_from_ws,'callback',{@ChkCallBack [editBoxRef chkref_preview]});
    set(chkMD_from_ws,'callback',{@ChkCallBack [editBoxMD chkMD_preview]});

end % end of if isempty(f)

%% Bring up mask dialog 
if nargin==0
    set(f, 'Visible','on');
    figure(f); 
else
    editBoxObj = findobj(f,'Tag','edit5');    
    switch option
        case 'load'
            [hJava,hUDD,M] = slctrlexplorer('initialize');
            M.ExplorerPanel.setSelected(hUDD.getTreeNodeInterface);
            [project, FRAME] = getvalidproject(blksystem,true);
            project_name=project.Label;
            setappdata(f,'project_name',project_name);
            setappdata(f,'task_name',task_name);
%             % Listener object for MPC object being destroyed in GUI, e.g.
%             % because the GUI is closed
%             MPCNode=hGUI.getMPCControllers.getChildren;
%             MPCNode=MPCNode(1);
%             Ldestroy = handle.listener(MPCNode, 'ObjectBeingDestroyed',{@mpc_guimask 'destroy' editBoxObj});
%             % Move listener to ApplicationData, so it's always in scope
%             setappdata(f,'ExportController',Ldestroy);
            setappdata(f,'editBoxObj',editBoxObj);
        case 'open_by_mmpc'
            feval(@GUICallBack, [], [], option, f, editBoxObj, blkh, blksystem, proj);
        case 'open_by_cetm'
            % If this mask has been opened from the New Task menu - check that it
            % doesn't already exist
            if ~isempty(proj) && ~isempty(proj.find('-class','mpcnodes.MPCGUI','Block',blk))
                errordlg(ctrlMsgUtils.message('MPC:designtool:MPCTaskExisting',blk),...
                    ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal')
                return
            end
            feval(@GUICallBack, [], [], option, f, editBoxObj, blkh, blksystem, proj);
    end
end

%-------------------------------------------------------------------
% CALLBACKS
%-------------------------------------------------------------------
%% OK
function OKCallBack(eventSrc, eventData, f, enabled ,blkh, editBoxObj,  editBoxX, ...
    chkref_from_ws, editBoxRef, chkref_preview, chkMD_from_ws, editBoxMD, chkMD_preview, ...
    chkMDInputPort, chkMVInputPort, chkLIMSInputPort, chkSWITCHInputPort)

if strcmp(enabled,'on'),
    applyCallBack(eventSrc, eventData, blkh, f, editBoxObj, editBoxX, ...
        chkref_from_ws, editBoxRef, chkref_preview, chkMD_from_ws, editBoxMD, ...
        chkMD_preview, chkMDInputPort, chkMVInputPort, chkLIMSInputPort, chkSWITCHInputPort);
end

CloseMask(f);

%% Cancel
function CancelCallBack(eventSrc, eventData, f, editBoxObj,blkh)

CloseMask(f);

%% Apply
function applyCallBack(eventSrc, eventData, blkh, hfig, editBoxObj,  editBoxX, ...
    chkref_from_ws, editBoxRef, chkref_preview, chkMD_from_ws, editBoxMD, chkMD_preview,...
    chkMDInputPort, chkMVInputPort, chkLIMSInputPort, chkSWITCHInputPort)

mpcobj = get(editBoxObj,'string');
x0 = get(editBoxX,'string');
task_name=char(getappdata(hfig,'task_name'));

ref_from_ws = onoff(get(chkref_from_ws,'value'));
ref_signal_name = get(editBoxRef,'string');
ref_preview = onoff(get(chkref_preview,'value'));
md_from_ws = onoff(get(chkMD_from_ws,'value'));
md_signal_name = get(editBoxMD,'string');
md_preview = onoff(get(chkMD_preview,'value'));
md_inport = onoff(get(chkMDInputPort,'value'));
mv_inport = onoff(get(chkMVInputPort,'value'));
lims_inport = onoff(get(chkLIMSInputPort,'value'));
switch_inport = onoff(get(chkSWITCHInputPort,'value'));

% NOTE: SET_PARAM also invokes MPC_GET_PARAM_SIM, MPC_BLOCK_RESIZE
set_param(blkh,'mpcobj',mpcobj,'x0',x0,... %'u0',u0,... %'ss_flag',ss_flag,...
    'ref_from_ws',ref_from_ws,'ref_signal_name',ref_signal_name,'ref_preview',ref_preview,...
    'md_from_ws',md_from_ws,'md_signal_name',md_signal_name,'md_preview',md_preview,...
    'task_name',task_name,'md_inport',md_inport,'mv_inport',mv_inport,...
    'lims_inport',lims_inport,'switch_inport',switch_inport);

% If the mpcobject has been cleared, clear the number of mvs so that it
% does not become a hidden state that the user cannot change
if isempty(mpcobj)
    set_param(blkh,'n_mv','0');
end

%% Design
function GUICallBack(eventSrc, eventData, option, hfig, editBoxObj, blkh, blksystem, proj)

% Interface between MPC masks and GUI

persistent oldheaders blockheaders

if ~usejava('swing')
    errordlg(ctrlMsgUtils.message('MPC:designtool:JAVANotFound'),...
        ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal');
    return
end

if isempty(blockheaders),
    % First block
    oldheaders={0};
    blockheaders={blkh};
    block=1;
else
    nn=length(blockheaders);
    block=[];
    for i=1:nn,
        if blockheaders{i}==blkh,
            block=i;
        end
    end
    if isempty(block),
        blockheaders{nn+1}=blkh;
        oldheaders{nn+1}=0;
        block=nn+1;
    end
end
oldheader=oldheaders{block};

% GUI already open ?
[GUIopen,hGUI] = mpc_getGUIstatus(blkh);

% DO NOT call set_param when calling from Multi MPC to avoid parameterized
% link warning. the 'mpcobj' field is already set by the parent mask.
if strcmp(option,'open_by_mmpc')
    mpcobjname = get_param(blkh,'mpcobj');
    set(editBoxObj,'string',mpcobjname);
else
    mpcobjname = get(editBoxObj,'string');
    set_param(blkh,'mpcobj',mpcobjname);
end

% If no mpcobject is specified open an instance of the Simulink Control
% Manager with an option to use a linearized Simulink model
if isempty(mpcobjname)
    % Is the block fully unconnected ?
    if strcmp(option,'open_by_mmpc')
        blkp = get_param(blkh,'Parent');
        ports=get_param(blkp,'PortConnectivity');
        connected=0;
        for i=1:length(ports),
            if (~isempty(ports(i).SrcBlock)) && (ports(i).SrcBlock~=-1),
                connected=1;
            end
        end
    else
        ports=get_param(blkh,'PortConnectivity');
        connected=0;
        for i=1:length(ports),
            if (~isempty(ports(i).SrcBlock)) && (ports(i).SrcBlock~=-1),
                connected=1;
            end
        end
    end
    if connected,
        if ~mpcchecktoolboxinstalled('scd')
            errordlg(ctrlMsgUtils.message('MPC:designtool:SCDNotFound'),...
                ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal');
            return
        end
        try
            % start the wizard to obtain a linear model, build a default
            % mpc object and create a mpc design task in GUI
            fullblockname=[get(blkh,'Path') '/' get(blkh,'Name')];
            [success,hRoot,hWS,hTree,hGUI,hProj,MPCNode] = mpc_openscm(fullblockname, option, proj);
        catch ME
            msg = sprintf('%s %s',ctrlMsgUtils.message('MPC:designtool:LinerizationFailed'),ME.message);
            uiwait(errordlg(msg,ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal'));
            return
        end
        if ~success,
            return
        end
        setappdata(hfig,'hGUI',hGUI);
        setappdata(hfig,'GUIopen',1);
        project_name = hProj.Label;
        setappdata(hfig,'project_name',project_name);

        % (jgo) hTask may be a vector if there is more than one block
        % hTask=hWS.find('-class','mpcnodes.MPCGUI','Block',blk);
        task_name = hGUI.Label;
        setappdata(hfig,'task_name',task_name);

        % SETUP LISTENER (as in Destroy) to prompt the user to export the object to
        % the workspace once the GUI is closed. Otherwise in the meantime run a
        % simulation through MPC_INIT as in the case when the user edits an MPC
        % object with the GUI
        if ~isempty(MPCNode)
%             % If the "Obtain Plant Model From Linearized ..." is not checked
%             % or linearization failed, MPCNode may be empty
%             Ldestroy = handle.listener(MPCNode, 'ObjectBeingDestroyed', ...
%                 {@mpc_guimask 'lin_destroy' editBoxObj blkh});
%             % Move listener to ApplicationData, so it's always in scope
%             setappdata(hfig,'ExportController',Ldestroy);
            setappdata(hfig,'editBoxObj',editBoxObj);

            if strcmp(option,'open_by_mmpc')
                mpcname = get_param(blkh,'Name');
                set(editBoxObj,'String',mpcname);
                set(MPCNode,'Label',mpcname)
            else
                mpcnames = get(MPCNode,{'Label'});
                mpcname = mpcnames{1};
                set(editBoxObj,'String',mpcname);
                set_param(blkh,'mpcobj',mpcname);
            end
            
        end
    else
        msg = sprintf('%s',ctrlMsgUtils.message('MPC:designtool:BlockIsNotConnected'));
        uiwait(errordlg(msg,ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal'));
    end
% If there is a mpc object, it must be available in base workspace
else
    % Check whether it's a pure MPC object or it's part of an array/struct
    if any(mpcobjname=='.') || any(mpcobjname=='(') || any(mpcobjname=='{') || any(mpcobjname=='['),
        uiwait(errordlg(ctrlMsgUtils.message('MPC:designtool:EditMPCObjectFailed',mpcobjname),...
            ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal'));
        return
    end
    try
        mpcobj = evalin('base',mpcobjname);
        isgood = isa(mpcobj,'mpc');
    catch ME
        uiwait(errordlg(ctrlMsgUtils.message('MPC:designtool:MPCObjectNotFoundinWorkspace',mpcobjname),...
            ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal'));
        return
    end
    if isgood,
        if ~GUIopen,
            if strcmp(option,'open_by_mmpc')
                blkp = get_param(blkh,'Parent');
                task_name=get_param(blkp,'Name');
            else
                task_name=get_param(blkh,'Name');
            end
            % evalin is used because the mpc object is in the base workspace
            fullblockname = [get(blkh,'Path') '/' get(blkh,'Name')];
            if mpc_nmvquest(fullblockname)
                try
                    wb = waitbar(0, ctrlMsgUtils.message('MPC:designtool:ToolWaitbarTitle'), 'Name', 'MPC Tool');
                    [hRoot, hWS, hTree, hGUI, hProj] = slmpctool('initialize', ...
                        blksystem, [], task_name, fullblockname, {mpcobj, mpcobjname}, wb);
                    close(wb);                
                catch ME
                    close(wb);                
                    msg = sprintf('%s %s',ctrlMsgUtils.message('MPC:designtool:StartGUIFailed'),ME.message);
                    uiwait(errordlg(msg,ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal'));
                    return
                end
            else
                msg = sprintf('%s %s',ctrlMsgUtils.message('MPC:designtool:StartGUIFailed'),...
                    ctrlMsgUtils.message('MPC:designtool:InvalidNMV'));
                uiwait(errordlg(msg,ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal'));
                return
            end
            setappdata(hfig,'hGUI',hGUI);
            setappdata(hfig,'GUIopen',1);
            if ~isempty(hProj),
                project_name=hProj.Label;
            else
                project_name=[];
            end
            setappdata(hfig,'project_name',project_name);
            setappdata(hfig,'task_name',task_name);

%             % Listener object for MPC object being destroyed in GUI, e.g.
%             % because the GUI is closed
%             MPCNode=hGUI.getMPCControllers.getChildren;
%             MPCNode=MPCNode(1);
%             Ldestroy = handle.listener(MPCNode, 'ObjectBeingDestroyed',{@mpc_guimask 'destroy' editBoxObj});
% 
%             % Move listener to ApplicationData, so it's always in scope
%             setappdata(hfig,'ExportController',Ldestroy);
            setappdata(hfig,'editBoxObj',editBoxObj);
            % GUI is already open
        else
            task_name=getappdata(hfig,'task_name');
            fullblockname = [get(blkh,'Path') '/' get(blkh,'Name')];
            if mpc_nmvquest(fullblockname)
                try
                    wb = waitbar(0, ctrlMsgUtils.message('MPC:designtool:ToolWaitbarTitle'), 'Name', 'MPC Tool');
                    slmpctool('initialize', blksystem, [], task_name, fullblockname, {mpcobj, mpcobjname}, wb);
                    close(wb);
                catch ME
                    close(wb);
                    msg = sprintf('%s %s',ctrlMsgUtils.message('MPC:designtool:StartGUIFailed'),ME.message);
                    uiwait(errordlg(msg,ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal'));
                    return
                end
            else
                msg = sprintf('%s %s',ctrlMsgUtils.message('MPC:designtool:StartGUIFailed'),...
                    ctrlMsgUtils.message('MPC:designtool:InvalidNMV'));
                uiwait(errordlg(msg,ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal'));
                return
            end
        end
    else
        uiwait(errordlg(ctrlMsgUtils.message('MPC:designtool:MPCObjectNotFoundinWorkspace',mpcobjname),...
            ctrlMsgUtils.message('MPC:designtool:DialogTitleError'),'modal'));
    end
end

%-------------------------------------------------------------------
% Checkbox callback
function ChkCallBack(eventSrc, eventData, uis)
% Change Enable property
newstatus=get(eventSrc,'value');
for i=1:length(uis),
    set(uis(i),'Enable',onoff(newstatus));
end

%-------------------------------------------------------------------
% Utility
%-------------------------------------------------------------------
function CloseMask(f)
%set(f,'visible','off');
close(f)

function str=onoff(value)
% Converts 1/0 to 'on'/'off', to avoid the following Matlab message:
% 'Specifying an enumerated value by its corresponding integer value is being phased out'
if value,
    str='on';
else
    str='off';
end

%-------------------------------------------------------------------
function SWITCHInportCallBack(eventSrc, eventData, chkMVInputPort)
% turn on ext.mv port if QP switch is on
newstatus=get(eventSrc,'value');
if newstatus,
    set(chkMVInputPort,'Value',1);
end
