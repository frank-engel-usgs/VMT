# The Velocity Mapping Toolbox (VMT)
# SVN Changelog (Google Code)
# Depreciated July, 30, 2014
# 
# This file contains the commit messages from the SVN repository hosted
# on the Google Code/Google Projects VMT page (https://code.google.com/p/velocity-mapping-tool/)
# As of June 2014, all development of VMT has moved to GitHub (https://github.com/frank-engel-usgs)
# This changelog will be retained, but no longer updated.
#
# Frank L. Engel, USGS
# July 30, 2014

Revision: 95
Author: Frank L. Engel
Date: Thursday, July 03, 2014 11:25:13 AM
Message:
Revert to r90 for Google Code copy of the repo
----

Revision: 94
Author: Frank L. Engel
Date: Thursday, July 03, 2014 9:34:37 AM
Message:
Reversion to HEAD r90 resolved conflicts
This gets rid of the editPlotDiagram stuff that has been problematic.
Makes a stable VMT v4.06
----

Revision: 93
Author: Frank L. Engel
Date: Wednesday, July 02, 2014 3:02:15 PM
Message:
First attempt at Figure editor modal GUI. It's not complete, only testing currently
----

Revision: 92
Author: Frank L. Engel
Date: Thursday, June 19, 2014 2:54:37 PM
Message:
Prep for testing v4.06 r6
----

Revision: 91
Author: Frank L. Engel
Date: Thursday, June 19, 2014 12:19:03 PM
Message:
Prep for testing v4.06 r4
----

Revision: 90
Author: Frank L. Engel
Date: Wednesday, June 11, 2014 3:51:41 PM
Message:
Prep for testing v4.06
----

Revision: 89
Author: Frank L. Engel
Date: Wednesday, June 04, 2014 3:46:51 PM
Message:
----

Revision: 88
Author: Frank L. Engel
Date: Wednesday, June 04, 2014 2:21:52 PM
Message:
Several changes. Will likely need several iterations of compiled code to ensure it all works.
1. Fixed Backscatter contour plot crash when plotting in English units. (the title_handle variable wasn't being created due to a syntax error).
2. Fixed overlap issues with the reference arrow label (MeanXS Contour Plot). It now plots as a dimensionless function of Distance and Depth. 
3. I turned on the plot toolbar again. This way, users can adjust the figures a bit for custom applications.
4. Put a string of the filename or some identifier in the figures. This works, and so long as the edit tool is enabled, the user can manipulate of even delete the box. For large multiple XS sites, the list may obstruct the figure. In that case users will need to try and adjust manually.
5. Updated doc
----

Revision: 87
Author: Frank L. Engel
Date: Tuesday, April 29, 2014 3:30:35 PM
Message:
stoopid error...
----

Revision: 86
Author: Frank L. Engel
Date: Tuesday, April 29, 2014 2:35:28 PM
Message:
1. Fixed savefile name construction in VMT_ReadFiles.m and VMT_ReadFiles_SonTek.m
2. Hopefully finally killed all callbacks to the non-existent 'pptfigure'
3. Fixed bug in ASCII2GIS_GUI.m which was looking for \tools and \doc when deployed
4. Since Google Code is soon to let me down, I have 5. Tweaks to VMT_BatchMode.m allowing users to save and load desired hgns, vgns, and wse
6. Updated html \doc
----

Revision: 85
Author: Frank L. Engel
Date: Monday, April 28, 2014 1:44:58 PM
Message:
fixed bug for data with bad ensembles at the edge. 
----

Revision: 84
Author: Frank L. Engel.com
Date: Wednesday, April 23, 2014 2:58:43 PM
Message:
pptfigure is pesky...hopefully this fixes it
----

Revision: 83
Author: Frank L. Engel.com
Date: Wednesday, April 23, 2014 12:41:00 PM
Message:
Minor bug fixes.
Updated html docs.

----

Revision: 82
Author: Frank L. Engel.com
Date: Wednesday, April 23, 2014 9:43:02 AM
Message:
Minor tweaks and bug fixes.
----

Revision: 81
Author: Frank L. Engel.com
Date: Friday, April 11, 2014 9:54:43 AM
Message:
----

Revision: 80
Author: Frank L. Engel.com
Date: Friday, April 11, 2014 9:00:21 AM
Message:
Removed image toolbox dependencies, and 
Also, looks like I forgot to add/version the modifications to VMT_BatchMode.m and it's related files/doc.
----

Revision: 79
Author: Frank L. Engel.com
Date: Thursday, April 10, 2014 4:03:33 PM
Message:
Update Documentation and Batch Tool
----

Revision: 78
Author: Frank L. Engel.com
Date: Wednesday, April 09, 2014 4:02:17 PM
Message:
The following features are [X]Hidden M9 functionality (Ctrl+Shift+S)
[X]RiverRay support
[X]Persistent preferences for units and graphics renderer
[X]Custom flat file builder (Ctrl+Alt+E)
[X]Bug fixes for Excel output
[X]Bug fixes for ASCII2GIS
[ ]VMT Batch Mode for M9/RiverRay
[X]If RG probe, pull the bin size for vgns
[ ]Update documentation
----

Revision: 77
Author: Frank L. Engel.com
Date: Tuesday, March 18, 2014 3:16:08 PM
Message:
Move to version 4.06:
-Mainly many small bug fixes. 
-Updated doc 

This version is not being pushed or compiled as of yet. Nobody seems to grab the SVN anyway :/

The next version to be compiled will probably have other improvements...
----

Revision: 76
Author: Frank L. Engel.com
Date: Monday, November 18, 2013 1:56:28 PM
Message:
Edited wiki page UserGuide through web user interface.
----

Revision: 75
Author: Frank L. Engel.com
Date: Monday, November 18, 2013 11:43:30 AM
Message:
Update to v4.05
1) Several bug fixes (mainly graphics rendering)
2) Batch mode enabled
----

Revision: 74
Author: Frank L. Engel.com
Date: Thursday, August 22, 2013 11:11:29 AM
Message:
v4.04 
Fixes some minor bugs
1. Can now specify HGNS less than 1 m (before it was rounding to nearest integer)
2. When loading a previously saved single MAT file, VMT will now populate the HGNS edit box with the HGNS used when the file was made. This is important, b/c VMT now reprocesses that data before plotting anything. 
----

Revision: 73
Author: Frank L. Engel.com
Date: Wednesday, August 14, 2013 8:38:46 AM
Message:
Brings VMT to v4.03
Lots of minor bug fixes in preparation for the upcoming VMT class
----

Revision: 72
Author: Frank L. Engel.com
Date: Wednesday, July 31, 2013 10:31:13 AM
Message:
This commit brings VMT to version 4.02. Several minor bug fixes (Part 3 is a minor bug fix, and update of doc).
New functionality:
1. Export to Excel
2. Graphics control sub-GUI add a lot of new features to how VMT works with the plots. Users can now also load custom colormaps in cpt format. Some example/useful cpt files are included in this update.
3. When deployed, VMT writes error log text files
4. Ability to visualize East/North components in the MCS

Major bug fixes:
1. Export multibeam bathy was crashing (#303)
2. Several of the persistent prefs were not being updated correctly
3. Many other small bugs
----

Revision: 71
Author: Frank L. Engel.com
Date: Wednesday, July 31, 2013 10:16:40 AM
Message:
This commit brings VMT to version 4.02. Several minor bug fixes (Part 3 is a minor bug fix, and update of doc).
New functionality:
1. Export to Excel
2. Graphics control sub-GUI add a lot of new features to how VMT works with the plots. Users can now also load custom colormaps in cpt format. Some example/useful cpt files are included in this update.
3. When deployed, VMT writes error log text files
4. Ability to visualize East/North components in the MCS

Major bug fixes:
1. Export multibeam bathy was crashing (#303)
2. Several of the persistent prefs were not being updated correctly
3. Many other small bugs
----

Revision: 70
Author: Frank L. Engel.com
Date: Thursday, July 25, 2013 11:12:55 AM
Message:
This commit brings VMT to version 4.02. Several minor bug fixes (Part 2 of 2).
New functionality:
1. Export to Excel
2. Graphics control sub-GUI add a lot of new features to how VMT works with the plots. Users can now also load custom colormaps in cpt format. Some example/useful cpt files are included in this update.
3. When deployed, VMT writes error log text files
4. Ability to visualize East/North components in the MCS

Major bug fixes:
1. Export multibeam bathy was crashing (#303)
2. Several of the persistent prefs were not being updated correctly
3. Many other small bugs
----

Revision: 69
Author: Frank L. Engel.com
Date: Thursday, July 25, 2013 11:10:00 AM
Message:
This commit brings VMT to version 4.02. Several minor bug fixes (Part 1 of 2).
New functionality:
1. Export to Excel
2. Graphics control sub-GUI add a lot of new features to how VMT works with the plots. Users can now also load custom colormaps in cpt format. Some example/useful cpt files are included in this update.
3. When deployed, VMT writes error log text files
4. Ability to visualize East/North components in the MCS

Major bug fixes:
1. Export multibeam bathy was crashing (#303)
2. Several of the persistent prefs were not being updated correctly
3. Many other small bugs
----

Revision: 68
Author: Frank L. Engel.com
Date: Wednesday, May 29, 2013 11:01:15 AM
Message:
This fixes the following minor bugs
1. Problem with loading multiple MAT files due to set_enable (Mantis bug #299)
2. Problems with the plotting functionality of the ASCII2GIS_GUI (Mantis bug #300)
3. Small syntax errors in ASCII2GIS_GUI.m and ASCII2KML_GUI.m
4. Update documentation in preparation for recompile
5. Changed version tag to v4.01 to cause users to see update if they check
----

Revision: 67
Author: Frank L. Engel.com
Date: Monday, May 20, 2013 10:45:15 AM
Message:
This Commit upgrades VMT out of beta release. The only feature 1. VMT upgraded to v4.0
2. Docs Updated
----

Revision: 66
Author: Frank L. Engel.com
Date: Wednesday, May 01, 2013 11:59:28 AM
Message:
Wiki update in preparation for building v4.0 documentation.
----

Revision: 65
Author: Frank L. Engel.com
Date: Wednesday, May 01, 2013 11:58:38 AM
Message:
Wiki update in preparation for building v4.0 documentation.
----

Revision: 64
Author: Frank L. Engel.com
Date: Wednesday, May 01, 2013 11:54:52 AM
Message:
Wiki update in preparation for building v4.0 documentation.
----

Revision: 63
Author: Frank L. Engel.com
Date: Tuesday, April 30, 2013 10:43:20 AM
Message:
Tag of VMTv4.0br2
----

Revision: 62
Author: Frank L. Engel.com
Date: Tuesday, April 30, 2013 10:40:29 AM
Message:
I forgot to update the documentation before tagging. This commit:
1. Deletes the incorrect tags/VMTv4.0br2
2. Updates documentation
----

Revision: 61
Author: Frank L. Engel.com
Date: Tuesday, April 30, 2013 9:56:29 AM
Message:
Tag of VMTv4.0br2
----

Revision: 60
Author: Frank L. Engel.com
Date: Tuesday, April 30, 2013 9:54:02 AM
Message:
This commit brings the source up to version 4.0 beta release 2.

Several small bugs are fixed, and the menu bar has been rearranged. 
----

Revision: 59
Author: Frank L. Engel.com
Date: Thursday, March 21, 2013 1:01:50 PM
Message:
Tag of VMTv4.0ar1
----

Revision: 58
Author: Frank L. Engel.com
Date: Thursday, March 21, 2013 11:50:05 AM
Message:
This Commit is the reintegration of the v4.0 branch into the trunk. Trunk is now VMTv4.0 source code!
----

Revision: 57
Author: Frank L. Engel.com
Date: Thursday, March 21, 2013 11:30:54 AM
Message:
Commit all v4.0 changes to branch in preparation for merge/reintegration to the trunk
----

Revision: 56
Author: Frank L. Engel.com
Date: Thursday, March 21, 2013 11:24:45 AM
Message:
Branch that will contain v4.0. This branch will be merged (reintegrated) back into the trunk
----

Revision: 55
Author: Frank L. Engel.com
Date: Thursday, March 21, 2013 10:53:30 AM
Message:
Tag of VMTv2.42ar2
----

Revision: 54
Author: Frank L. Engel.com
Date: Monday, March 11, 2013 9:08:18 PM
Message:
Edited wiki page InputReqs through web user interface.
----

Revision: 53
Author: Frank L. Engel.com
Date: Monday, March 11, 2013 9:06:37 PM
Message:
Edited wiki page Introduction through web user interface.
----

Revision: 52
Author: Frank L. Engel.com
Date: Monday, March 11, 2013 9:06:06 PM
Message:
Edited wiki page Introduction through web user interface.
----

Revision: 51
Author: Frank L. Engel.com
Date: Friday, December 14, 2012 9:54:28 AM
Message:
Updated VMT/VMT_RepBadGPS.m to have a slightly less severe filter for flyaways
----

Revision: 50
Author: Frank L. Engel.com
Date: Thursday, December 13, 2012 1:39:41 PM
Message:
VMT v 2.42br2
Updated the filtering in VMT_RepBadGPS.m to handle GPS fly-aways. The new A.Comp outputs are in logical indexes
Updated VMT_MapEns2MeanXSV2.m to plot data explicitly excluded from MCS computation (i.e., GPS fly-aways)
Updated VMT_GridData2MeanXS_INT.m to more effieciently sort by station. This is a drastic performance update.
----

Revision: 49
Author: Frank L. Engel.com
Date: Tuesday, November 27, 2012 1:50:56 PM
Message:
Edited wiki page TableOfContents through web user interface.
----

Revision: 48
Author: Frank L. Engel.com
Date: Tuesday, November 27, 2012 1:50:29 PM
Message:
Edited wiki page TableOfContents through web user interface.
----

Revision: 47
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 3:20:10 PM
Message:
Edited wiki page VMTQuickRef through web user interface.
----

Revision: 46
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 3:18:56 PM
Message:
Edited wiki page TransectAvg through web user interface.
----

Revision: 45
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 3:18:40 PM
Message:
Edited wiki page OutputFigures through web user interface.
----

Revision: 44
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 12:04:02 PM
Message:
Edited wiki page UserGuide through web user interface.
----

Revision: 43
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 12:03:07 PM
Message:
Edited wiki page TableOfContents through web user interface.
----

Revision: 42
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 11:56:04 AM
Message:
Created wiki page through web user interface.
----

Revision: 41
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 11:49:55 AM
Message:
Edited wiki page OutputFormat through web user interface.
----

Revision: 40
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 11:49:08 AM
Message:
Created wiki page through web user interface.
----

Revision: 39
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 11:48:46 AM
Message:
----

Revision: 38
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 11:47:56 AM
Message:
Created wiki page through web user interface.
----

Revision: 37
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 11:15:14 AM
Message:
Created wiki page through web user interface.
----

Revision: 36
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 11:08:43 AM
Message:
Created wiki page through web user interface.
----

Revision: 35
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 10:46:01 AM
Message:
Created wiki page through web user interface.
----

Revision: 34
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 10:45:14 AM
Message:
Edited wiki page TableOfContents through web user interface.
----

Revision: 33
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 10:37:17 AM
Message:
Created wiki page through web user interface.
----

Revision: 32
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 9:54:00 AM
Message:
Edited wiki page VMTQuickRef through web user interface.
----

Revision: 31
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 9:51:27 AM
Message:
Edited wiki page TableOfContents through web user interface.
----

Revision: 30
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 9:50:39 AM
Message:
Edited wiki page KnownBugs through web user interface.
----

Revision: 29
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 9:49:37 AM
Message:
Created wiki page through web user interface.
----

Revision: 28
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 9:30:55 AM
Message:
Edited wiki page TableOfContents through web user interface.
----

Revision: 27
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 9:30:00 AM
Message:
Edited wiki page TableOfContents through web user interface.
----

Revision: 26
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 9:28:36 AM
Message:
Edited wiki page InstallGuide through web user interface.
----

Revision: 25
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 9:27:03 AM
Message:
Edited wiki page InputReqs through web user interface.
----

Revision: 24
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 9:25:12 AM
Message:
Edited wiki page GettingStarted through web user interface.
----

Revision: 23
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 9:24:11 AM
Message:
Edited wiki page GettingStarted through web user interface.
----

Revision: 22
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 9:18:15 AM
Message:
Edited wiki page TableOfContents through web user interface.
----

Revision: 21
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 9:17:35 AM
Message:
Edited wiki page TableOfContents through web user interface.
----

Revision: 20
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 9:16:29 AM
Message:
Edited wiki page TableOfContents through web user interface.
----

Revision: 19
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 9:14:08 AM
Message:
Edited wiki page TableOfContents through web user interface.
----

Revision: 18
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 9:07:55 AM
Message:
Edited wiki page TableOfContents through web user interface.
----

Revision: 17
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 9:07:28 AM
Message:
Created wiki page through web user interface.
----

Revision: 16
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 9:05:59 AM
Message:
----

Revision: 15
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 9:01:48 AM
Message:
Edited wiki page WikiSidebar through web user interface.
----

Revision: 14
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 8:58:15 AM
Message:
Created wiki page through web user interface.
----

Revision: 13
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 8:54:14 AM
Message:
Edited wiki page GettingStarted through web user interface.
----

Revision: 12
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 8:46:59 AM
Message:
Created wiki page through web user interface.
----

Revision: 11
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 8:28:45 AM
Message:
Created wiki page through web user interface.
----

Revision: 10
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 8:22:55 AM
Message:
Created wiki page through web user interface.
----

Revision: 9
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 8:16:53 AM
Message:
Created wiki page through web user interface.
----

Revision: 8
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 8:11:16 AM
Message:
Edited wiki page PreliminaryNotes through web user interface.
----

Revision: 7
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 8:10:01 AM
Message:
Edited wiki page PreliminaryNotes through web user interface.
----

Revision: 6
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 8:09:03 AM
Message:
Edited wiki page PreliminaryNotes through web user interface.
----

Revision: 5
Author: Frank L. Engel.com
Date: Wednesday, November 21, 2012 8:06:13 AM
Message:
Created wiki page through web user interface.
----

Revision: 4
Author: Frank L. Engel.com
Date: Monday, November 19, 2012 3:22:01 PM
Message:
----

Revision: 3
Author: Frank L. Engel.com
Date: Monday, November 19, 2012 2:55:03 PM
Message:
fixed bug due to tfile bringing in draft as uint32- depthxyz.m now converts draft to double before processing
----

Revision: 2
Author: Frank L. Engel.com
Date: Monday, November 05, 2012 8:43:38 AM
Message:

----

Revision: 1
Author: 
Date: Monday, November 05, 2012 8:35:03 AM
Message:
Initial directory structure.
----