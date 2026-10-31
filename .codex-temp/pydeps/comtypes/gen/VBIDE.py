from enum import IntFlag

import comtypes.gen._0002E157_0000_0000_C000_000000000046_0_5_3 as __wrapper_module__
from comtypes.gen._0002E157_0000_0000_C000_000000000046_0_5_3 import (
    vbext_wt_Toolbox, vbext_wt_Watch, vbext_ct_StdModule,
    LinkedWindows, _ProjectTemplate, Window, vbextFileTypeExe,
    vbextFileTypeModule, VBProjects, Property, vbext_pt_StandAlone,
    BSTR, _VBComponent_Old, VBComponent, Reference, Properties,
    _dispCommandBarControlEvents, vbext_wt_Immediate,
    vbextFileTypeProject, vbext_pk_Set, vbext_ct_MSForm, Addins,
    _Windows_old, vbext_wt_Find, vbextFileTypeRes, SelectedComponents,
    vbextFileTypeBinary, _check_version, GUID, _VBComponentsEvents,
    dispid, vbext_ct_ClassModule, _CodePane, _CodePanes, CodeModule,
    Application, Windows, vbextFileTypePropertyPage, CodePane,
    ReferencesEvents, DISPMETHOD, vbextFileTypeGroupProject,
    vbext_pk_Proc, _dispReferences_Events, vbextFileTypeDocObject,
    _VBProject_Old, _Component, _VBProjects_Old, AddIn,
    _dispVBComponentsEvents, COMMETHOD, _CodeModule, vbext_pk_Get,
    HRESULT, VARIANT_BOOL, vbext_pp_locked, CodePanes,
    vbext_vm_Design, vbext_wt_ToolWindow, ProjectTemplate,
    VBComponents, _CommandBarControlEvents, vbext_rk_TypeLib,
    vbext_wt_Designer, CoClass, vbext_wt_FindReplace, References, VBE,
    _dispReferencesEvents, vbextFileTypeForm, vbext_wt_Locals,
    vbext_cv_ProcedureView, IDispatch, vbext_wt_LinkedWindowFrame,
    _VBProjects, IUnknown, vbext_vm_Break, VBProject, typelib_path,
    vbext_pk_Let, CommandBarEvents, vbext_pt_HostProject,
    vbext_wt_Browser, _Properties, _Components, Library,
    vbext_ws_Normal, vbextFileTypeClass, _VBComponents, _VBProject,
    vbext_vm_Run, _ReferencesEvents, vbextFileTypeDesigners, _lcid,
    vbext_ws_Minimize, VARIANT, vbext_wt_ProjectWindow,
    _dispVBProjectsEvents, vbext_pp_none, _VBComponent,
    _VBComponents_Old, vbext_ct_Document, vbext_cv_FullModuleView,
    _References, vbextFileTypeFrx, vbext_wt_MainWindow, _Windows,
    vbext_rk_Project, _AddIns, vbextFileTypeUserControl, Component,
    Events, vbext_ws_Maximize, vbext_wt_CodeWindow,
    vbext_ct_ActiveXDesigner, vbext_wt_PropertyWindow,
    _VBProjectsEvents, _LinkedWindows, Components
)


class vbext_ComponentType(IntFlag):
    vbext_ct_StdModule = 1
    vbext_ct_ClassModule = 2
    vbext_ct_MSForm = 3
    vbext_ct_ActiveXDesigner = 11
    vbext_ct_Document = 100


class vbext_RefKind(IntFlag):
    vbext_rk_TypeLib = 0
    vbext_rk_Project = 1


class vbext_WindowType(IntFlag):
    vbext_wt_CodeWindow = 0
    vbext_wt_Designer = 1
    vbext_wt_Browser = 2
    vbext_wt_Watch = 3
    vbext_wt_Locals = 4
    vbext_wt_Immediate = 5
    vbext_wt_ProjectWindow = 6
    vbext_wt_PropertyWindow = 7
    vbext_wt_Find = 8
    vbext_wt_FindReplace = 9
    vbext_wt_Toolbox = 10
    vbext_wt_LinkedWindowFrame = 11
    vbext_wt_MainWindow = 12
    vbext_wt_ToolWindow = 15


class vbext_ProcKind(IntFlag):
    vbext_pk_Proc = 0
    vbext_pk_Let = 1
    vbext_pk_Set = 2
    vbext_pk_Get = 3


class vbext_ProjectType(IntFlag):
    vbext_pt_HostProject = 100
    vbext_pt_StandAlone = 101


class vbext_WindowState(IntFlag):
    vbext_ws_Normal = 0
    vbext_ws_Minimize = 1
    vbext_ws_Maximize = 2


class vbext_VBAMode(IntFlag):
    vbext_vm_Run = 0
    vbext_vm_Break = 1
    vbext_vm_Design = 2


class vbext_ProjectProtection(IntFlag):
    vbext_pp_none = 0
    vbext_pp_locked = 1


class vbext_CodePaneview(IntFlag):
    vbext_cv_ProcedureView = 0
    vbext_cv_FullModuleView = 1


class vbextFileTypes(IntFlag):
    vbextFileTypeForm = 0
    vbextFileTypeModule = 1
    vbextFileTypeClass = 2
    vbextFileTypeProject = 3
    vbextFileTypeExe = 4
    vbextFileTypeFrx = 5
    vbextFileTypeRes = 6
    vbextFileTypeUserControl = 7
    vbextFileTypePropertyPage = 8
    vbextFileTypeDocObject = 9
    vbextFileTypeBinary = 10
    vbextFileTypeGroupProject = 11
    vbextFileTypeDesigners = 12


__all__ = [
    'vbext_wt_Toolbox', 'LinkedWindows', '_ProjectTemplate',
    'vbextFileTypeExe', 'vbext_CodePaneview', 'vbext_pt_StandAlone',
    'vbext_ComponentType', 'Properties',
    '_dispCommandBarControlEvents', 'vbext_pk_Set', '_Windows_old',
    'vbext_wt_Find', '_VBComponentsEvents', '_CodePane', '_CodePanes',
    'CodeModule', 'Windows', 'ReferencesEvents',
    '_dispReferences_Events', 'vbextFileTypeDocObject', '_Component',
    'AddIn', '_CodeModule', 'vbext_pk_Get', 'vbext_pp_locked',
    'ProjectTemplate', 'VBComponents', '_CommandBarControlEvents',
    'vbext_rk_TypeLib', 'vbext_wt_Designer', 'vbext_WindowType',
    'VBE', '_dispReferencesEvents', 'vbext_wt_Locals',
    'vbext_cv_ProcedureView', 'vbext_wt_LinkedWindowFrame',
    'vbextFileTypes', 'vbext_vm_Break', 'CommandBarEvents',
    'vbext_wt_Browser', '_Properties', 'vbext_ws_Normal',
    'vbextFileTypeClass', '_VBComponents', 'vbext_vm_Run',
    'vbext_wt_ProjectWindow', '_dispVBProjectsEvents', '_VBComponent',
    'vbext_ct_Document', '_References', 'vbextFileTypeFrx',
    'vbext_wt_MainWindow', 'vbext_rk_Project', '_AddIns',
    'vbextFileTypeUserControl', 'vbext_wt_CodeWindow',
    'vbext_ct_ActiveXDesigner', 'vbext_wt_PropertyWindow',
    '_VBProjectsEvents', 'vbext_wt_Watch', 'vbext_ct_StdModule',
    'Window', 'vbext_ProjectProtection', 'vbextFileTypeModule',
    'VBProjects', 'Property', '_VBComponent_Old', 'VBComponent',
    'Reference', 'vbext_VBAMode', 'vbext_wt_Immediate',
    'vbextFileTypeProject', 'vbext_ct_MSForm', 'Addins',
    'vbextFileTypeRes', 'SelectedComponents', 'vbextFileTypeBinary',
    'vbext_RefKind', 'vbext_ct_ClassModule', 'Application',
    'vbextFileTypePropertyPage', 'CodePane',
    'vbextFileTypeGroupProject', 'vbext_pk_Proc', '_VBProject_Old',
    '_VBProjects_Old', '_dispVBComponentsEvents', 'CodePanes',
    'vbext_vm_Design', 'vbext_wt_ToolWindow', 'vbext_wt_FindReplace',
    'References', 'vbextFileTypeForm', '_VBProjects', 'VBProject',
    'typelib_path', 'vbext_pk_Let', 'vbext_pt_HostProject',
    '_Components', 'Library', '_VBProject', '_ReferencesEvents',
    'vbextFileTypeDesigners', 'vbext_ws_Minimize', 'vbext_pp_none',
    '_VBComponents_Old', 'vbext_cv_FullModuleView', '_Windows',
    'vbext_ProjectType', 'Component', 'Events', 'vbext_ws_Maximize',
    'vbext_WindowState', 'vbext_ProcKind', '_LinkedWindows',
    'Components'
]

