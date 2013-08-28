/*****************************************************************************
*
* Copyright (c) 2000 - 2012, Lawrence Livermore National Security, LLC
* Produced at the Lawrence Livermore National Laboratory
* LLNL-CODE-442911
* All rights reserved.
*
* This file is  part of VisIt. For  details, see https://visit.llnl.gov/.  The
* full copyright notice is contained in the file COPYRIGHT located at the root
* of the VisIt distribution or at http://www.llnl.gov/visit/copyright.html.
*
* Redistribution  and  use  in  source  and  binary  forms,  with  or  without
* modification, are permitted provided that the following conditions are met:
*
*  - Redistributions of  source code must  retain the above  copyright notice,
*    this list of conditions and the disclaimer below.
*  - Redistributions in binary form must reproduce the above copyright notice,
*    this  list of  conditions  and  the  disclaimer (as noted below)  in  the
*    documentation and/or other materials provided with the distribution.
*  - Neither the name of  the LLNS/LLNL nor the names of  its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT  HOLDERS AND CONTRIBUTORS "AS IS"
* AND ANY EXPRESS OR  IMPLIED WARRANTIES, INCLUDING,  BUT NOT  LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND  FITNESS FOR A PARTICULAR  PURPOSE
* ARE  DISCLAIMED. IN  NO EVENT  SHALL LAWRENCE  LIVERMORE NATIONAL  SECURITY,
* LLC, THE  U.S.  DEPARTMENT OF  ENERGY  OR  CONTRIBUTORS BE  LIABLE  FOR  ANY
* DIRECT,  INDIRECT,   INCIDENTAL,   SPECIAL,   EXEMPLARY,  OR   CONSEQUENTIAL
* DAMAGES (INCLUDING, BUT NOT  LIMITED TO, PROCUREMENT OF  SUBSTITUTE GOODS OR
* SERVICES; LOSS OF  USE, DATA, OR PROFITS; OR  BUSINESS INTERRUPTION) HOWEVER
* CAUSED  AND  ON  ANY  THEORY  OF  LIABILITY,  WHETHER  IN  CONTRACT,  STRICT
* LIABILITY, OR TORT  (INCLUDING NEGLIGENCE OR OTHERWISE)  ARISING IN ANY  WAY
* OUT OF THE  USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
* DAMAGE.
*
*****************************************************************************/

// ************************************************************************* //
//                               PseudocolorPluginInfo.h                            //
// ************************************************************************* //

#ifndef PSEUDOCOLOR_PLUGIN_INFO_H
#define PSEUDOCOLOR_PLUGIN_INFO_H
#include <PlotPluginInfo.h>
#include <plot_plugin_exports.h>

class PseudocolorAttributes;

// ****************************************************************************
//  Class: PseudocolorPluginInfo
//
//  Purpose:
//    Five classes that provide all the information about a Pseudocolor
//    plot plugin.  The information is broken up into five classes since
//    portions of it are only relevant to particular components within
//    visit.  There is the general information which all the components
//    are interested in, the gui information which the gui is interested in,
//    the viewer information which the viewer is interested in, the
//    engine information which the engine is interested in, and finally a.
//    scripting portion that enables the Python VisIt extension to use the
//    plugin.
//
//  Programmer: generated by xml2info
//  Creation:   omitted
//
// ****************************************************************************

class PseudocolorGeneralPluginInfo: public virtual GeneralPlotPluginInfo
{
  public:
    virtual const char *GetName() const;
    virtual const char *GetVersion() const;
    virtual const char *GetID() const;
    virtual bool  EnabledByDefault() const;
};

class PseudocolorCommonPluginInfo : public virtual CommonPlotPluginInfo, public virtual PseudocolorGeneralPluginInfo
{
  public:
    virtual AttributeSubject *AllocAttributes();
    virtual void CopyAttributes(AttributeSubject *to, AttributeSubject *from);
};

class PseudocolorGUIPluginInfo : public virtual GUIPlotPluginInfo, public virtual PseudocolorCommonPluginInfo
{
  public:
    virtual QString *GetMenuName() const;
    virtual int GetVariableTypes() const;
    virtual QvisPostableWindowObserver *CreatePluginWindow(int type,
        AttributeSubject *attr, const QString &caption, const QString &shortName,
        QvisNotepadArea *notepad);
    virtual const char **XPMIconData() const;
};

class PseudocolorViewerPluginInfo : public virtual ViewerPlotPluginInfo, public virtual PseudocolorCommonPluginInfo
{
  public:
    virtual AttributeSubject *GetClientAtts();
    virtual AttributeSubject *GetDefaultAtts();
    virtual void SetClientAtts(AttributeSubject *atts);
    virtual void GetClientAtts(AttributeSubject *atts);

    virtual avtPlot *AllocAvtPlot();

    virtual void InitializePlotAtts(AttributeSubject *atts, const ViewerPlot *);
    virtual QString *GetMenuName() const;
    virtual const char **XPMIconData() const;
    virtual int GetVariableTypes() const;

    static void InitializeGlobalObjects();
  private:
    static PseudocolorAttributes *defaultAtts;
    static PseudocolorAttributes *clientAtts;
};

class PseudocolorEnginePluginInfo : public virtual EnginePlotPluginInfo, public virtual PseudocolorCommonPluginInfo
{
  public:
    virtual avtPlot *AllocAvtPlot();
};

class PseudocolorScriptingPluginInfo : public virtual ScriptingPlotPluginInfo, public virtual PseudocolorCommonPluginInfo
{
  public:
    virtual void InitializePlugin(AttributeSubject *subj, void *data);
    virtual void *GetMethodTable(int *nMethods);
    virtual bool TypesMatch(void *pyobject);
    virtual char *GetLogString();
    virtual void SetDefaults(const AttributeSubject *atts);
};

#endif
