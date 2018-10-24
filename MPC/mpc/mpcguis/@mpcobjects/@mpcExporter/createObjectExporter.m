function createObjectExporter(this)
% CREATEOBJECTEXPORTER Create the MPC object export dialog window object.

% Author(s): Larry Ricker
% Revised:
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.6.13 $ $Date: 2008/10/31 06:21:49 $

import com.mathworks.toolbox.mpc.*;
import com.mathworks.mwswing.*;
import javax.swing.*;
import javax.swing.border.*;
import java.awt.*;

% Constants
nHor = 350;
nVer = 240;

% Panel
%Dialog = MJDialog;
Dialog = MJFrame;
Dialog.setSize(Dimension(nHor,nVer));
Dialog.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
Dialog.setResizable(false);
Dialog.setTitle('MPC Controller Exporter');

DialogFont = Font('Dialog',Font.PLAIN,12);
ComboDimension = Dimension(100,25);

% Source selection combo
ProjLabel = MJLabel('Controller source:', SwingConstants.RIGHT);
ProjLabel.setFont(DialogFont);
ProjCombo = MJComboBox;
ProjCombo.setEditable(false);
ProjCombo.setPreferredSize(ComboDimension);
ProjCombo.setName('Export_Source');

% Combo box for selecting the object to be exported
ComboLabel = MJLabel('Controller to export:', SwingConstants.RIGHT);
ComboLabel.setFont(DialogFont);
ObjectCombo = MJComboBox;
ObjectCombo.setPreferredSize(ComboDimension);
ObjectCombo.setEditable(false);
ObjectCombo.setName('Export_Object');

% Edit box for variable name
nameLabel = MJLabel('Name to assign:', SwingConstants.RIGHT);
nameLabel.setFont(DialogFont);
nameText = MJTextField(20);
nameText.setName('Export_Name');

% Radio buttons to control export destination
rbGroup = ButtonGroup;
rbWorkspace = MJRadioButton('Export to MATLAB workspace', true);
rbWorkspace.setFont(DialogFont);
rbWorkspace.setName('Export_Workspace');
rbFile = MJRadioButton('Export to MAT-file', false);
rbFile.setFont(DialogFont);
rbFile.setName('Export_File');
rbGroup.add(rbWorkspace);
rbGroup.add(rbFile);

% Buttons
OK = MJButton('Export');
OK.setName('Export_OK');
Cancel = MJButton('Close');
Cancel.setName('Export_Close');
Help = MJButton('Help');
Help.setName('Export_Help');
butPanel = MJPanel;
butPanel.add(OK);
butPanel.add(Cancel);
butPanel.add(Help);

% Final panel assembly

p = Dialog.getContentPane;
p.setLayout(GridBagLayout);
c = GridBagConstraints;
c.fill = GridBagConstraints.HORIZONTAL;
c.weightx = 1;
c.weighty = 1;
c.insets = Insets(5, 10, 5, 10);
c.gridx = 0;
c.gridy = 0;
p.add(ProjLabel, c);
c.gridx = 1;
p.add(ProjCombo, c);
c.gridx = 0;
c.gridy = 1;
p.add(ComboLabel, c);
c.gridx = 1;
p.add(ObjectCombo, c);
c.gridx = 0;
c.gridy = 2;
p.add(nameLabel, c);
c.gridx = 1;
p.add(nameText, c);
c.gridx = 0;
c.gridy = 3;
c.gridwidth = 2;
p.add(rbWorkspace, c);
c.gridy = 4;
p.add(rbFile, c);
c.gridy = 5;
p.add(butPanel, c);

% File chooser
fulpathname = java.lang.String(pwd);
Chooser = MJFileChooser(fulpathname);
Chooser.setDialogTitle(java.lang.String('Specify MAT-file For Export'));
Chooser.setFileSelectionMode(JFileChooser.FILES_ONLY);
Chooser.setMultiSelectionEnabled(false);

% Save handles
this.Handles.Dialog = Dialog;
this.Handles.ProjCombo = ProjCombo;
this.Handles.ExportComboBox = ObjectCombo;
this.Handles.ExportEditBox = nameText;
this.Handles.ExportButtons = {OK, Cancel, Help};
this.Handles.ExportRadios = {rbGroup, rbWorkspace, rbFile};
this.Handles.ExportChooser = Chooser;

% Define callbacks
set(handle(OK,'callbackproperties'), ...
    'ActionPerformedCallback', {@LocalOKAction, this} );
set(handle(ProjCombo,'callbackproperties'), ...
    'ActionPerformedCallback', {@LocalProjectAction, this} );
set(handle(Cancel,'callbackproperties'), ...
    'ActionPerformedCallback', {@LocalCloseAction, this} );
set(handle(Help,'callbackproperties'), ...
    'ActionPerformedCallback', {@mpcCSHelp, 'MPCOBJEXPORTER'});
set(handle(ObjectCombo,'callbackproperties'), ...
    'ActionPerformedCallback', {@LocalSelectionListener, this} );
set(handle(Dialog,'callbackproperties'), ...
    'WindowActivatedCallback', {@LocalWindowActivationListener, this} );
set(handle(Dialog,'callbackproperties'), ...
    'WindowDeactivatedCallback', {@LocalWindowDeactivationListener, this} );

% --------------------------------------------------------------------

function LocalProjectAction(Source, Event, this) %#ok<*INUSL>

% Respond to change in project combo selection

Isel = this.Handles.ProjCombo.getSelectedIndex + 1;
if Isel > 0
    this.SelectedRoot = this.Tasks(Isel);
    LocalExportUpdater(this);
end


% --------------------------------------------------------------------

function LocalWindowDeactivationListener(Source, Event, this)
mpcupdatecetmstatus(this.SelectedRoot, '');

% --------------------------------------------------------------------

function LocalWindowActivationListener(Source, Event, this)

% Need to refresh the project combo box with names of mpc projects in
% the gui and highlight the selected one (if possible).

import javax.swing.*;

SelectedRoot = this.SelectedRoot;
Root = SelectedRoot.up;
while ~isempty(Root.up)
    Root = Root.up;
end
this.Tasks = Root.getChildren.find('-class', 'mpcnodes.MPCGUI');
Combo = this.Handles.ProjCombo;

% disable listener for object combo selection
set(handle(Combo,'callbackproperties'),'ActionPerformedCallback', {});
awtinvoke(Combo,'removeAllItems');

for i = 1:length(this.Tasks)
    L = java.lang.String(this.Tasks(i).Label);
    awtinvoke(Combo,'addItem(Ljava.lang.Object;)',L);
end

L = java.lang.String(SelectedRoot.Label);
awtinvoke(Combo,'setSelectedItem(Ljava.lang.Object;)',L);

LocalExportUpdater(this);

% enable listener for object combo selection
set(handle(Combo,'callbackproperties'),'ActionPerformedCallback', {@LocalProjectAction, this});



% --------------------------------------------------------------------

function LocalOKAction(Source, Event, this)

% Export the selected MPC object
Root = this.SelectedRoot;
mpcCursor(this.Handles.Dialog, 'wait')
% Get the MPC object (may require object calculation)
SelectedController = [];
while ~isa(SelectedController, 'mpcnodes.MPCController')
    % Keep trying until combo box returns a reasonable value
    ObjectName = this.Handles.ExportComboBox.getSelectedItem;
    SelectedController = Root.getMPCControllers.getChildren.find( ...
        'Label', ObjectName);
end
mpcupdatecetmstatus(this.SelectedRoot, ctrlMsgUtils.message('MPC:designtool:ExportingObject', ObjectName));
MPCobj = SelectedController.getController;
if isempty(MPCobj)
    % Bad object, so cancel export
    LocalCancelAction(this, ObjectName);
    return
end
Name = char(this.Handles.ExportEditBox.getText);
NameErrMsg = ctrlMsgUtils.message('MPC:designtool:InvalidVarName',Name);
if this.Handles.ExportRadios{2}.isSelected
    % Exporting to the MATLAB Workspace
    % Check whether or not the specified variable name exists in the workspace
    Destination = 'your workspace';
    if evalin('base',sprintf('exist(''%s'', ''var'')',Name)) == 1
        % Name already exists, so ask for overwrite permission
        mpcCursor(this.Handles.Dialog, 'default')
        Message = ctrlMsgUtils.message('MPC:designtool:OverwriteMLVar',Name);        
        ButtonName = questdlg(Message,ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'),'Yes','No','No');
        if strcmp(ButtonName,'No')
            LocalCancelAction(this, ObjectName);
            return
        end
        mpcCursor(this.Handles.Dialog, 'wait')
    end
    % If we get here, we have a unique name.  Try to save the variable
    try
        assignin('base', Name, MPCobj);
    catch ME %#ok<*NASGU>
        % If the assignin fails, assume the chosen name was invalid
        uiwait(errordlg(NameErrMsg, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));
        LocalCancelAction(this, ObjectName);
        return
    end
else
    % Exporting to a MAT file
    % Save the object using the chosen name
    try
        eval(sprintf('%s = MPCobj;', Name));
    catch ME
        % If the eval fails, assume the chose name was invalid
        uiwait(errordlg(NameErrMsg, ctrlMsgUtils.message('MPC:designtool:DialogTitleError'), 'modal'));        
        LocalCancelAction(this, ObjectName);
        return
    end
    % The assignin worked, so use the file chooser to get a file name
    fulpathname = java.io.File(pwd);
    this.Handles.ExportChooser.setCurrentDirectory(fulpathname);
    this.Handles.ExportChooser.setSelectedFile(java.io.File(Name));
    Result = this.Handles.ExportChooser.showSaveDialog(this.Handles.Dialog);
    if Result == javax.swing.JFileChooser.APPROVE_OPTION
        % A file has been selected
        File = this.Handles.ExportChooser.getSelectedFile;
        Path = char(File.getPath);
        Destination = sprintf('"%s"', char(File.getName));
        if exist(Path,'file') == 2 || exist([Path, '.mat'],'file') == 2 
            Message = ctrlMsgUtils.message('MPC:designtool:OverwriteMLFile',Destination);                    
            ButtonName = questdlg(Message,ctrlMsgUtils.message('MPC:designtool:DialogTitleQuestion'),'Yes','No','No');
            if strcmp(ButtonName,'No')
                LocalCancelAction(this, ObjectName);
                return
            end
        end
        Destination = ['MAT-file ', Destination];
        save(Path, Name)
    else
        LocalCancelAction(this, ObjectName);
        return
    end
    
end
mpcCursor(this.Handles.Dialog, 'default')
mpcupdatecetmstatus(this.SelectedRoot, ctrlMsgUtils.message('MPC:designtool:FinishingExportingObject', ObjectName));
mpcupdatecetmtext(this.SelectedRoot, ctrlMsgUtils.message('MPC:designtool:ControllerSaved', ObjectName, Name, Destination));
SelectedController.ExportNeeded = 0;

% --------------------------------------------------------------------

function LocalCancelAction(this, ObjectName)

% Prepare to cancel without exporting anything
mpcupdatecetmtext(this.SelectedRoot, ctrlMsgUtils.message('MPC:designtool:ExportControllerCancel', ObjectName));
mpcCursor(this.Handles.Dialog, 'default')
        
% --------------------------------------------------------------------

function LocalCloseAction(Source, Event, this)

% Close the dialog window
%this.Handles.Dialog.dispose;
awtinvoke(this.Handles.Dialog,'setVisible(Z)',false);
mpcupdatecetmstatus(this.SelectedRoot, '');

% --------------------------------------------------------------------

function LocalSelectionListener(Source, Event, this)

% When selection changes, move new name to edit box

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;
Item = this.Handles.ExportComboBox.getSelectedItem;
if ~isempty(Item)
    this.Handles.ExportEditBox.setText(Item);
end

% --------------------------------------------------------------------

function LocalExportUpdater(this)

% Update controller list in the export updater

import javax.swing.*;

% disable listener for object combo selection
set(handle(this.Handles.ExportComboBox,'callbackproperties'), ...
    'ActionPerformedCallback', {});

% Get the current project
Isel = 0;
while ~isnumeric(Isel) || Isel < 1  
    % Keep trying until ProjCombo returns a reasonable value
    Isel = this.Handles.ProjCombo.getSelectedIndex + 1;
end
Root = this.Tasks(Isel);

% Get the list of controller node labels
Controllers = Root.getMPCControllers.Controllers;
if isempty(Controllers)
    ListData = {'(none available)'};
    isEnabled = false;
else
    ListData = Controllers;
    isEnabled = true;
end

% Initialize the java objects in export dialog
awtinvoke(this.Handles.ExportComboBox,'removeAllItems');
for i = 1:length(ListData)
    awtinvoke(this.Handles.ExportComboBox,'addItem(Ljava.lang.Object;)',java.lang.String(ListData{i}));
end

if isEnabled
    % Default the selected item to the current controller
    if this.CurrentController.getRoot==this.SelectedRoot
        Current = java.lang.String(this.CurrentController.Label);
        awtinvoke(this.Handles.ExportComboBox, 'setSelectedItem(Ljava.lang.Object;)',Current);
        if ~strcmp(this.Handles.ExportEditBox.getText,this.CurrentController.Label)
            awtinvoke(this.Handles.ExportEditBox,'setText(Ljava.lang.String;)',Current);
        end
    else
        awtinvoke(this.Handles.ExportComboBox, 'setSelectedIndex(I)',0);
        Current = this.Handles.ExportComboBox.getSelectedItem;
        if ~strcmp(this.Handles.ExportEditBox.getText,Current)
            awtinvoke(this.Handles.ExportEditBox,'setText(Ljava.lang.String;)',Current);
        end
    end
    mpcupdatecetmstatus(this.SelectedRoot, xlate('Ready'));    
else
    this.Handles.ExportEditBox.setText(' ');
    mpcupdatecetmstatus(this.SelectedRoot, ctrlMsgUtils.message('MPC:designtool:NoControllerAvailable'));    
end

awtinvoke(this.Handles.ExportButtons{1}, 'setEnabled(Z)', isEnabled);
awtinvoke(this.Handles.ExportEditBox, 'setEnabled(Z)', isEnabled);

% enable listener for object combo selection
set(handle(this.Handles.ExportComboBox,'callbackproperties'), ...
    'ActionPerformedCallback', {@LocalSelectionListener, this} );

