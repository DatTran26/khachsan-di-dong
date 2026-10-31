from enum import IntFlag

import comtypes.gen._00020430_0000_0000_C000_000000000046_0_2_0 as __wrapper_module__
from comtypes.gen._00020430_0000_0000_C000_000000000046_0_2_0 import (
    OLE_XPOS_CONTAINER, OLE_CANCELBOOL, FONTUNDERSCORE, BSTR,
    Unchecked, Picture, StdPicture, GUID, Checked, OLE_XSIZE_PIXELS,
    EXCEPINFO, _check_version, dispid, IPictureDisp, DISPMETHOD,
    OLE_XPOS_PIXELS, COMMETHOD, OLE_YPOS_HIMETRIC, OLE_YSIZE_PIXELS,
    OLE_XSIZE_CONTAINER, Default, HRESULT, VARIANT_BOOL, VgaColor,
    FontEvents, OLE_XSIZE_HIMETRIC, IFont, DISPPARAMS, IPicture,
    OLE_XPOS_HIMETRIC, CoClass, OLE_OPTEXCLUSIVE, OLE_YPOS_CONTAINER,
    IDispatch, IEnumVARIANT, OLE_YSIZE_CONTAINER,
    OLE_ENABLEDEFAULTBOOL, IUnknown, Font, OLE_COLOR, typelib_path,
    IFontEventsDisp, StdFont, FONTSIZE, OLE_YPOS_PIXELS, Library,
    DISPPROPERTY, Gray, OLE_HANDLE, _lcid, FONTSTRIKETHROUGH,
    OLE_YSIZE_HIMETRIC, FONTNAME, Monochrome, IFontDisp, FONTITALIC,
    FONTBOLD, Color
)


class LoadPictureConstants(IntFlag):
    Default = 0
    Monochrome = 1
    VgaColor = 2
    Color = 4


class OLE_TRISTATE(IntFlag):
    Unchecked = 0
    Checked = 1
    Gray = 2


__all__ = [
    'OLE_XSIZE_HIMETRIC', 'IFont', 'OLE_XPOS_CONTAINER',
    'OLE_CANCELBOOL', 'FONTUNDERSCORE', 'IPicture',
    'OLE_XPOS_HIMETRIC', 'OLE_OPTEXCLUSIVE', 'OLE_YPOS_CONTAINER',
    'Unchecked', 'OLE_YSIZE_CONTAINER', 'OLE_ENABLEDEFAULTBOOL',
    'Font', 'OLE_COLOR', 'typelib_path', 'IFontEventsDisp',
    'OLE_TRISTATE', 'StdFont', 'FONTSIZE', 'Picture', 'StdPicture',
    'OLE_YPOS_PIXELS', 'Checked', 'OLE_XSIZE_PIXELS', 'Library',
    'IPictureDisp', 'Gray', 'OLE_HANDLE', 'LoadPictureConstants',
    'FONTSTRIKETHROUGH', 'OLE_YSIZE_HIMETRIC', 'FONTNAME',
    'Monochrome', 'OLE_XPOS_PIXELS', 'IFontDisp', 'OLE_YPOS_HIMETRIC',
    'FONTITALIC', 'FONTBOLD', 'OLE_YSIZE_PIXELS',
    'OLE_XSIZE_CONTAINER', 'Default', 'VgaColor', 'Color',
    'FontEvents'
]

