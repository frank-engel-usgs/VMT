commit 1908013f81762a08f278c63e35764d8c23fc3057 (HEAD -> master, issue9b)
Author: Engel <fengel@usgs.gov>
Date:   Mon Dec 4 10:28:13 2017 -0600

    Update html docs

commit 3b26d78a2b14cb258b9c1ceea4a1ee690c597a86
Author: Engel <fengel@usgs.gov>
Date:   Fri Dec 1 10:22:50 2017 -0600

    Revised the auxdata outputs so that it will work for 5 beam
    instruments. The new approach should be more robust to work for whatever
    valid data are present.

commit 9255bc11742d3cb28ca09bfe89e9c81e26a86ba2 (origin/master, origin/HEAD)
Author: Engel <fengel@usgs.gov>
Date:   Thu Nov 30 15:38:48 2017 -0600

    Changelog

commit 0c98df100405c5f58b6f69c1824648c75cb8f5fa
Author: Engel <fengel@usgs.gov>
Date:   Thu Nov 30 15:37:48 2017 -0600

    Updated documentation, and modified the VMT error text file
    process. VMT will now attempt to write a text file and MAT-file (guiparams &
    guiprefs) to the %userprofile% directory, which is typically
    C:\users\[username]. This variable is looked up with Matlab's
    getenv('USERPROFILE') command.

commit 6a8cccbdbd2b28aa0037e380241437e33532df5c (issue9)
Author: Engel <fengel@usgs.gov>
Date:   Thu Nov 30 12:31:19 2017 -0600

    The MBB export is now working with SonTek probes and TRDI probes.

commit 2099d3df93ab95c1f6e69b55daff8fcf74244cb1
Author: Engel <fengel@usgs.gov>
Date:   Thu Nov 30 11:13:22 2017 -0600

    Added depthxyzRS as supplied from DSM to address SonTek probes.
    This new function looks for the frequency and shifts the XYZ slant-corrected
    for each beam appropriately. I've modified all the hooks into VMT so that the
    new version runs. I still need to modify VMT_MBBathy to keep the vertical
    beam elevation outputs.
    
    Also, this solution may work for VB from RiverRay and RiverPro, but I will
    need to open a seperate issue for that.

commit 351fe7b6ca89920ce33848be3d03a820baf932ce
Author: Engel <fengel@usgs.gov>
Date:   Thu Oct 5 11:16:17 2017 -0500

    Updated changelog.md. This fixes issue #6.

commit 389124b7a5712447724bf42c28b6396ceb7fd383 (origin/issue-6-exceloutput, issue-6-exceloutput)
Author: Engel <fengel@usgs.gov>
Date:   Thu Oct 5 11:07:10 2017 -0500

    Updated documentation.

commit 8d4d5104a5c3feece0ac338f5c83aa2e7d8f7ac0
Author: Engel <fengel@usgs.gov>
Date:   Thu Oct 5 10:59:56 2017 -0500

    Small typo fix. This issue has been tested, and is ready to resolve.

commit 6c4a2277a45426e6061a957eb118020f7eaef4c6
Author: Engel <fengel@usgs.gov>
Date:   Mon Aug 7 11:33:29 2017 -0500

    Fixed some minor syntax errors in excel output.

commit fc9c86b748ae66be989e2755c70e152cc2a6d136
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue May 2 10:03:13 2017 -0500

    The Excel functionality is now working. Will test before
    merging.

commit 92b7db7b712354a0478dbb43e5560a738bb04a3d
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Mon May 1 14:36:47 2017 -0500

    In this commit, I have changed the way VMT_SaveExcelOutput.m functions
    to use the ActiveX controls to write and format the Excel file, rather
    than the xlswrite built-in matlab function. I added the function suite
    Excel_Write_Format from the FEX to accomadate managing most of the
    ActiveX server handles.
    
    This commit has the function working in a basic form. Still need to work
    on Excel clean up, and perhaps formatting.

commit dcfc40d0b2665ba4b44a15b713ee33196eca4c5a
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Fri Apr 28 14:40:25 2017 -0500

    Fixed syntax errors. Preparing to revise Excel output to
    include formatting control over xlsx file.

commit d77658214c60fbda83c1f3978076bece11be0772
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Apr 27 15:15:38 2017 -0500

    Now have both multiple and single cross section Excel output
    functionality working as previous (with PRJ updates), but with a new
    function VMT_SaveExcelOutput

commit c77c062584265c7e5067a118bb9ee2a5f26da6bd
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Apr 27 10:51:44 2017 -0500

    Added automatic shiptracks for SonTek.

commit 7e9fe3c55489e3761a7229bc514d294c1c5887a1
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Apr 27 10:37:02 2017 -0500

    Working to get the Excel feature pulled into its own function.
    One thing that I needed to do was get the plot settings saved into the V
    struct. To do this, it is convinient to get the ShipTracks to automatically
    plot upon loading a file (ASCIIs or Single VMT Mat). Not implemented for
    SonTek yet.

commit a4af259737af9427e58e8f6585e9a756ea9b853d
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Apr 27 09:07:49 2017 -0500

    These are the changes suggested by Ryan Jackson to correct
    the Excel outputs and log window.

commit 3d527069d5a37cec56647fefff99389852033596
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Apr 26 15:39:45 2017 -0500

    This issue was reproducible. The math used in the outputs was correct, however, like @Ryan-Jackson-USGS mentions, the plotting routine was recomputing the normal vector, in this case incorrectly. I removed the computations from the plotting routine and simplified the math in VMT_MapEns2MeanXS a bit. Tested all quadrants. Fixes #5.

commit ef6c7a781dc9a5762c8e25a419aa04fcfe574489
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Apr 26 15:29:57 2017 -0500

    Updated user guide

commit 377fe1f2fc0c79403aacca9e9a584413fa633914
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Apr 26 15:20:18 2017 -0500

    Isolated the issue to bad syntax in VMT_PlotShipTracks.
    I verified that N and M are computed correctly in VMT_MapEns2MeanXS, and then
    assigned new vars to V.N and V.M. Now the plotting routine calls those vars
    instead.

commit 915c80c98c785328796fb8af1f22901a28017437 (tag: v4.08-r20170404)
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Apr 4 10:34:45 2017 -0500

    This is v4.08-r20170404.

commit b7a5de9057e376273b1361e4c7ae4de72a3b57f8
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Apr 4 09:55:20 2017 -0500

    Modified the way VMT sorts time. Also added some new info to
    the Excel VMT_Summary sheet. This Fixes #3

commit 6553a311415387733970c323216452de561af995 (hotfix-multimatfiles-hzgns)
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Mar 23 14:44:12 2017 -0500

    Fixes issue with loading multiple mat-files as described in email
    by Ryan Jackson:
    MAT files processed and saved when loading back into VMT have an issue with the horizontal grid node spacing. The HGNS is taken from the file and correctly placed in the HGNS edit box, but subsequent plotting uses a HGNS of 1m by default unless the HGNS edit box is edited or the plot shiptracks button is pressed. It pulls the right HGNS number from the file, but does not use it automatically.

commit 843836679e077637a03b8d3d68ddcaf714a968e4 (tag: v4.08-r20170131)
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Jan 31 08:47:02 2017 -0600

    Update ChangeLog

commit e1fb0bd28c9f3ede92a37f017402cafa11602d26
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Jan 31 08:44:55 2017 -0600

    For v4.08 r20160131 which fixes issue 349

commit d58b0900f4dfe801817d8cb5a80ada9f2b55745d
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Jan 31 08:27:08 2017 -0600

    Issues 349 was caused by mishandled logic in an IF statement
    in VMT_MapEns2MeanXS.m that did not handle all cases of duplicate GPS
    locations. Solution was to modify IF statement to include all cases on
    line 343.

commit b41a13861d9c19ac74208d432f29980a375e83ea (tag: v4.08)
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Oct 11 10:45:49 2016 -0500

    Updated HTML documentation.

commit f78aec53fedb943e3dc336cfeb5feb19fbbe7da7
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Oct 11 10:41:25 2016 -0500

    Fixed bug in batch processing mode related to starting bank mode.

commit 6ee69d87d48da46b881624298eacda361f09e2f0
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Fri Oct 7 07:55:19 2016 -0500

    Updated license to conform to USGS policy. Updated User Guide.

commit d3b3de85a0752199fd85822814093713d13dcb6b
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Oct 6 12:56:01 2016 -0500

    Updated documentation and changelog. This commit is v4.08rc7.

commit 3ed7342e6125cdc8f98803fdd9f30824dbba950b
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Oct 6 12:49:03 2016 -0500

    Fixed bugs related to importing RSL mat files and time.
    Added all of the Sup struct time variables into parseSonTekVMT.m

commit 665b1031d484daaf7497579e2cb264c42803977c
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Aug 9 10:44:51 2016 -0500

    Updated doc html

commit 629ad3b47c7e73cfa9bc4ebe4ec8e7e67e3b44d2
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Jul 27 16:44:50 2016 -0500

    Met with Ricardo Szupiany concerning excessive censoring of
    near-bed data when VMT uses TriScatteredInterp. Solution was to use the
    old method of interp2 in the case of a RioGrande ADCP. Those ADCPs with
    multicell profiling and changing bin sizes will continue to use
    TriScatteredInterp.

commit 12f01a55df4c57a6a2f2e9873eb7e3b10f36b85d
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Jul 27 15:39:55 2016 -0500

    Update.

commit 6181d74b607d970410209d891cf9f528bbed439a
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Jul 19 15:47:58 2016 -0500

    Added more vars to differentiate beam freq and mode. Propagates those changes into the TDRI functions as well. Still testing.

commit c097d76a59358144326b9eaad127d910faf95227
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Jul 14 15:16:03 2016 -0500

    Added SonTek SNR as the backscatter variable (Wat.backscatter).
    Also added a variable Wat.beamFreq.
    So far, cannot differentiate whether oulse coherent or not yet.
    Also, currently, VMT will now process the backscatter into the VMT Grid. This
    is not a good practice, and needs to be addressed.

commit 997b5ffc188c5eb1a094fad7cdba398417dce60b
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Jul 14 10:53:25 2016 -0500

    Moved the Sontek processing support out of the Hidden Shortcuts
    and into a menu item. Also added the Sontek to KML support to the menu.
    Changed the name of a couple of the TDRI specific menu items to ensure
    clarity.

commit 9acc3f1719816592f5327d1c80e219161a8dc9da
Merge: ce96ab5 b800d38
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Mar 31 20:24:55 2016 -0500

    Resolvd merge conflicts.

commit b800d3829f662580b3c9f97e2b6708fe72234bd0 (tag: v4.08-rc6)
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Mar 24 09:45:20 2016 -0500

    This is v4.08rc6

commit 5933ab7b71b4f11a629edcafd47ea45d8647085b
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Mar 24 09:19:48 2016 -0500

    I think I have repaired the code to properly process the change in direction syntax

commit f5098aa0c2353d9ad25ab1a23c5ac0d80593b8ad
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Mar 23 16:00:47 2016 -0500

    Correcting flip station syntax. Some changes were not committed correctly, and were lost.

commit 94c6a953978a2bb39d19dd95246b13a62b5c574b
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Mar 23 10:02:53 2016 -0500

    Incremental change

commit ce96ab5cec49b02491eba22c550cb4096ee43d25 (tag: v4.08-rc5)
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Feb 16 14:33:55 2016 -0600

    This is v4.08rc5

commit 6342c055e99bf4d2aeac78cdbdb3d3990a122894
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Feb 16 14:27:21 2016 -0600

    Worked with KKJ to identify and fix Graphics Control bugs.
    This is an extension of the corrections I made for Liz Hittle.

commit 46a470aaf7ebc2bd80f68b5e5f19c7fe2db13569
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Feb 16 14:00:23 2016 -0600

    Minor bug fix in VMT_PlotPlanViewQuivers.m

commit 286bd2415534756cc2de6174c4a53e1c6b47e31a
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Fri Feb 5 08:14:01 2016 -0600

    Fixed small typo in log message. Modified the .gitignore.

commit 57234ac63cfce5ce83b1860ec84fa6215786704f
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Feb 2 11:57:21 2016 -0600

    This is v4.08rc4 for testing. I've added a PRJ file locally, and put its resources into the
    .gitignore.

commit 0edf5300c7a61d76cfbe436cfbfc024045db1fb3
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Feb 2 11:03:37 2016 -0600

    Fixed a couple of bugs in the Graphics Control GUI that came about from start bank feature.
    Should also migrate these into master.

commit a48ec3a933f8bfd130966b8df5ec057642094052
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Feb 2 08:44:30 2016 -0600

    Fixed syntax error if plotting MCS without vectors.

commit ddf8618a43eea563ddae303478131b00a368bd8d
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Feb 2 08:39:45 2016 -0600

    Figured out the flipping of the MCS. Had to add a second condition during plotting to ensure that XDir was only
    changed if the start bank was set to auto.

commit 5016302f4b883a55de070e24d4e3a6eaf89bd00f
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Feb 2 08:16:54 2016 -0600

    Fixed Graphics Control GUI. This changes was from fb-projectshiptrack.

commit 33ee44beb0a1235ce2549afc490bd2de5d5fd44b
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Fri Jan 22 15:53:02 2016 -0600

    End of day commit

commit 94167cfeb5be719065f3505fc78c5e80c0953802 (tag: v4.08-rc3)
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Jan 21 11:01:47 2016 -0600

    This is v4.08rc3. Still have some more features to add and test
    but this is ready to distribute as is.

commit 0077d19ae682f29dfd13875e8fee14798e244095
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Jan 21 10:44:21 2016 -0600

    Fixed this bug.
    VMT now looks at all loaded ASCII files and determines the min and max depth
    range of the entire dataset and uses that for creating the MCS grid.
    Also changed how PlotXSContQuiver builds the vector framing used to space
    vectors according to GUI inputs. This was actually an old issue that was left
    unresolved with SonTek and RR support, but it was related to this issue as well.

commit f8f58edb549a89f8b2409b7999811478594303c8
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Jan 21 09:34:29 2016 -0600

    The Advanced Settings GUI is functional. All features implemented currently also work.
    Other Changes:
    1. Moved Units to first option in the Settings Menu
    2. Fully depreciated the Display Shoreline feature
    3. Various processing tweaks to ensure that the manual XS flipping works as expected
    
    Still needed:
    1. Move Unit Q correction into Advanced Settings
    2. Move set endpoints into Adv. Settings and enable a select file box
    3. Move Add background tinto Adv. Settings and enable a select file box

commit 757176a81760fff83deced354f78455081d7347c
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Jan 21 08:09:33 2016 -0600

    The basic GUI functionality is working. MCS orientation code
    is implemented in the processing. Still need to apply to PlotQuivers.
    Also need to clean the main GUI up to remove redundant or replaced callbacks.

commit e3e225736e3cf6d15f47a5d2df57678dcaea8341
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Jan 20 16:20:26 2016 -0600

    Working on implementation of start bank functionality in procesing.

commit 4298c7c67171af4e728ed1f078adb53ba64da6e3
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Jan 20 14:45:15 2016 -0600

    The subgui works now. Still need to implement the start bank
    feature. But at least the framework for doing so exists.

commit 21d294cf9e26398d88fac7330e194400e7b3bb14
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Jan 19 16:01:45 2016 -0600

    1. Moved the subgui into the utils folder and updated VMT calls
    2. Completed the look of the subgui at least with initial options
    3. Am able to pass VMT guiparams to the subgui
    4. TODO need to figure out how to write results back to VMT

commit cbb53bf2ad47343fec08da2a8e01053e2478f1e4
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Fri Jan 15 16:03:58 2016 -0600

    End of day commit. Started the Advanced Settings sub GUI
    Also renamed Parameters menu to Settings.

commit 12452d54f65c8b512841ecbcd7d3ea7ba5c377ee
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Fri Jan 15 08:49:25 2016 -0600

    Added Mathworks suggested workaround 2 based on mathworks bug 1293244

commit 643235289f83acc437a8528e5d57c46d66f5a183 (tag: v4.08-rc2)
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Jan 14 15:33:27 2016 -0600

    Update documentation after MB345 fix. Prepare tag for v4.08-rc2

commit f00fc331c20ec146b4334cfd2ab1548c5da197de
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Jan 14 15:11:41 2016 -0600

    There was a syntax error in VMT_PlotPlanviewQuivers that caused it
    not to properly excluded data not in the first column of V.mcs
    quantities for use in the Layer averaging. I removed the error,
    and now the code is working properly.

commit fc048c653bd7dd95b84252cbc5f9c4b1937a7b03
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Jan 14 14:00:38 2016 -0600

    A couple more updates to Make_VMT.

commit 5c30e633a548ed49e3d2aefc6e3083bbc28b4ebe
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Dec 31 10:56:15 2015 -0600

    Fixed syntax error in Grphics Control GUI that caused print style
    formatted MCS plot to be rendered incorrectly.

commit f5fc51c8d5073295cd660e236897d146a6837509
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Fri Dec 11 08:23:57 2015 -0600

    Updated Make_VMT.m with some instructions on how to create
    compiled releases of VMT.

commit 05bd3a540ae92b9ee580bdcc641db55fcb317c80 (tag: v4.08-rc1)
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Dec 10 16:22:34 2015 -0600

    Updated Changelog. Ready to make v4.08-rc1

commit 692eaf49bffa22483b67641ceb63247486656bf6
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Dec 10 16:19:37 2015 -0600

    Updated HTML documentation

commit d2097d3c87680e3895b2b96be8ddd686094af0c3
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Dec 10 16:17:33 2015 -0600

     Updated the User Guide PDF

commit b7d7cd50599219e40c847497af2797dbeac26aa6
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Dec 10 13:47:10 2015 -0600

     Resolved the bug. See Mantis for full details. VMT will now
    ensure that the UTM zone of the data is correctly selected for KMZ export.

commit 4fdfc8ee2a56829044968b76f0de77bb7efd5fff
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Dec 10 13:17:18 2015 -0600

    Disabled the movegui call to center the window upon generation.

commit ca5fc0ae2922ad1c0359fea6ae14afdf0b92ff89
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Dec 10 13:05:24 2015 -0600

    Added a new checkbox to the main GUI to enable user selection
    of whether or not to flip a MCS contour plot when est. flux is negative (ie
     flowing upstream)

commit 3767157290eee74e960ee62b768c85189de0bf88
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Dec 10 11:34:18 2015 -0600

    Updated HTML documentation. Ready to merge and retest.

commit 4e8e4c842c3b8a5e3b9dde62a9af4733ceca75bf
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Dec 8 12:40:50 2015 -0600

     Incorporated JMDLs bug fix into hab-reference branch. This branch is the working copy of v4.08

commit 15e36f6556ffa7f0ceead41b049583c98f4ee64c
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Dec 8 12:35:50 2015 -0600

    Bring repo up to date

commit 1d7008301791deabe30c737ef580db8a536c189d
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Mon Sep 28 08:07:12 2015 -0600

    Fixed a miscaluculation for HAB ref in VMT_PlotXSCont and
    VMT_PlotXSContQuiver

commit 3c315fba4bb8a7ffdb94f648ccf0c7baf22d1f3e
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Fri Sep 25 14:42:45 2015 -0600

    Updated HTML documentation
    Also added HAB range to ASCII2GIS tool.

commit 09fd1354fcb8027fbc3263721df8cf31b880799f
Merge: 2adca05 a4cb573
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Sep 24 11:28:54 2015 -0600

    Merge branch 'fix-sontek-support' into hab-reference

commit a4cb573dba88f7a81fd08a53e54dcb6d0102e9d5
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Sep 22 15:22:58 2015 -0600

    End of day. Modified parseSonTekVMT.m  to read v3.8 RSL files

commit 2adca0533a70753ae01ddf66e473066046eab01c
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Sep 9 15:35:40 2015 -0600

    End of the day edits

commit 18d8e9abfc49d0fdc7fc54851ab9f0c882cfb460
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Sep 9 13:13:50 2015 -0600

    Fixed the MCS colorbar issue with not changing to the AxColor.

commit f40b65875cbafc839491fa3c1db617687b0e084b
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Sep 9 12:03:28 2015 -0600

    Fixed GEplot_3D overwrite error
    added offsets panel and associated tags and callbacks
    removed the KMZ offset from the menus
    several small tweaks to VMT_CompMeanXS to ensure that HAB referening is
    computed correctly and consistently. This will impact the feature-branch
    that deals with BRLD.

commit 2beeca6acfae85f025bc529478264a8f60a9bd2a
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Sep 8 15:07:52 2015 -0600

    End of the day commit.

commit ed66b3d025e54749e7b4f3093871cc73deb7c042
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Sep 8 14:49:56 2015 -0600

    rudimentary functionality is now up and running.
    Also fixed some of the logic to run faster, eliminating slow calls to
    FIND function, and instead doing direct logical indexing.
    Still need some refinements to plot titles, etc.

commit dc956464a1564f78a9f035fd6d3ea856a3e39195
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Sep 8 10:37:48 2015 -0600

    Update. First incremental change to add HAB as a planview ref.

commit 5246150a20a670cb045587fedf6628dfad8365a5
Merge: 52fb8f3 b76db2b
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Aug 25 15:41:05 2015 -0600

    Added timestamp and time averaging basic functionality to
    main processing. Can now export Excel with timestamp information.

commit b76db2b824c91efedf7857d5e8b80aac7ea37f86
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Mon Jul 6 12:18:13 2015 -0600

    Ensured that nandatestr function is consistently applied.

commit cc409aaab3cbee06ba53d2c9781be07eb9b0e277
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Mon Jul 6 09:37:30 2015 -0600

    Found that the excel output will crash if there are invalid ensembles
    due to datestr not handling NaNs. I found a FEX function that replaces NaNs
    with empty strings. This fixed the issue.

commit 5ef95491d596de0d55b1ed51c4183beb19d4c2c8
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Mon Jul 6 08:01:12 2015 -0600

    The planview vector scale callback was rounding to the nearest integer
    needlessly, making it difficult to adjust vector scale. I removed the call
    to round the GUI input.

commit 668951748140b5c225884b24c26bbc98348b9523
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Jul 2 09:18:48 2015 -0600

    Added the smoothed PV vector results to multiple-mat file
    excel output. Also modified PlotPlanviewQuivers to compute a few more
    variables in the PVdata output structure, including the FileName of
    each vectors source.

commit d81dc3597a8d6b05d637c7897764add0e7cfc024
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Jul 2 06:47:57 2015 -0600

    Added timestamp and file name to multiple MAT-file excel output.

commit 30388cbd6263501199a45ee530ed32c152506e4e
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Jul 1 13:08:53 2015 -0600

    Added some documentation about the timestamps.

commit 52fb8f36eac832fe6cb7172fee47621d4e58127a
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Jul 1 12:38:53 2015 -0600

    Revert "Added timestamps to the excel output."
    
    This reverts commit 2ef26eca514d565bbc6be0e9af386e454b02c2ca.

commit 2ef26eca514d565bbc6be0e9af386e454b02c2ca
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Jul 1 08:33:39 2015 -0600

    Added timestamps to the excel output.
    Still need to add some more documentation to VMT_Summary.

commit b6f362b607428a26c26e6c2f7b575a0bb77dc0a1 (tag: v4.07)
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Mon Jun 8 10:56:43 2015 -0500

    Made some adjustments to the Excel Output, then redeployed.

commit 61635b0116619a93ede18a1eba67c113b7158d8c
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Fri Jun 5 11:49:38 2015 -0500

    Changed Check for Updates to read https instead of http
    per enforcement from our IT group

commit 2dd1cf37ca29c359f8f14f703621d0b657a7f2ff
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Fri Jun 5 10:42:49 2015 -0500

    Updated changelog for v4.07 release

commit 596364875a16a47d3f611c65de2baadcb5124625
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Fri Jun 5 10:42:02 2015 -0500

    Removed v4.06 user guide from repo.

commit f7eac1eae8338ed02bec30a610c385680e4c90f1
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Fri Jun 5 10:37:03 2015 -0500

    This commit brings VMT up to v4.07 release.
    Official changes include:
    1. Addition of Vorticity to contour variables
    2. Expanded Excel output to include exactly what's on the figures (smoothing and spacing)
    3. Official release of the Figure customization tool (gear icon on figures)
    4. Additional information about spacing/smoothing ground distance included in the Log Window
    5. Added ability for Batch Tool to have different WSEs for each transect

commit 1f35c5561bde6b3b0542960a7ab2a2cc8525f737
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Jun 3 15:46:21 2015 -0500

    Modified the Excel output to include more info
    1. Added first and last timestamps
    2. Ground distance for vector spacing and smoothing
    3. Fixed a few typos

commit e161a3b5a1dbf5771297e444546032b8967df08d
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Jun 2 15:19:17 2015 -0600

    Fixed a small syntax error, and updated docs for compile.

commit 2c8b4551ff6c8dacc1c20dc64d83a92f32f257b3
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Sun May 24 21:53:42 2015 -0500

    Modified the Excel output functionality to address Mantis bug #330:
    1. Added 2 new worksheets to the output ("Smoothed_" Planview and MeanCrossSection)
       These new sheets include only the actual data shown in the plots. If the
       user does smoothing or changes vector spacing, that is reflected in the Excel
       outputs.
    2. For the Smoothed_MeanCrossSection sheet, I retain data for the v,w components
       from the actual vectors as produced with VMT_PlotContQuivers. I then use
       interp2 to compute a u component from whatever is curently plotted (i.e.
       contour variable.
    3. I updated a few things in the VMT_Summary worksheet. I may want to add more later.
    4. All original worksheets are still included

commit 6a77175387cc5cb65444041ba2657cfee325c1b3
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Mon May 11 09:19:34 2015 -0500

    Updated .gitignore

commit 3e8c3f522922a281c09cad6b5aeb29b9538a8368
Merge: 2308449 ea4bbfd
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Mar 26 12:58:27 2015 -0500

    Merge branch 'master' of github.com:frank-engel-usgs/VMT

commit ea4bbfd491e103ce4710a755758b78a6bc87c144
Author: Frank L. Engel <frank-engel-usgs@users.noreply.github.com>
Date:   Thu Mar 26 12:48:21 2015 -0500

    Added standard USGS disclaimer
    
    Text taken from USGS EGRET Github Wiki

commit 230844964d4339bac298aeebf4a24df660eb9923
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Fri Jan 16 10:45:20 2015 -0600

    Updated documentation, and corrected some issues with the Excel output.

commit f292068d4846ce8c5c0b30a765ddbd15ac99bb3b
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Fri Jan 9 10:59:44 2015 -0600

    Clean up and update documentation.

commit 4b252ea0f5cb8b0654c0b84a78c2fc0ac1a3c19d
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Fri Jan 9 10:42:21 2015 -0600

    This updates the source code to v4.07 r20150109. Many new features and bug fixes are included:
            - VMT can now process water surface elevation tide-files. Included in this new feature
              is a new variable, mcsTime (serial date number). This time represents the average time associated with the
          ensembles closest to each horizontal grid node (i.e., each vertical contained within the V struct).
              Thus, if the user selects TWO ASCII files, mcsTime will show the average (midpoint in the case of 2
              files) timestamp of the nearest raw ADCP ensembles. This is an important assumption in VMT. The software
              produces the spatio-temporal average velocities for a series of loaded ADCP data. In the case of steady
              or quasi-steady flows, the assumption that velocities are not changing dramatically in time is valid.
              This is NOT the case in unsteady flow cases.
            - VMT Batch Mode will now allow for multiple water surface elevation (1 per cross-section). The data are
              written to both the saved VMT mat files, and if selected, the varying WSEs are used in the Export
              Multibeam Bathymetry batch process.
            - VMT can now plot in two vertical references: Depth from surface (dfs, this is the default), and Height
              above bottom (HAB). Use HAB as a reference in cases where you have a flat-bed or artificial channel, or in
              cases of rapidly varied flow. When a user selects this reference, VMT prompts for a bottom elevation. In
              MCS plot, rather than plot the beam-avg depth to bed, VMT will plot the computed water surface (stippled
              line). This reference is specialized, however it may be of use in particularly challenging flow
              visualization cases. Use with discretion.
            - Several small bugs have been fixed, including problems with the GUI not retaining entered WSEs, improved
              file selection user interface in the ASCII2GIS tool, and minor plotting and syntax errors.
    
    As always, VMT is a work in progress. Bugs should be reported via the github or the OSW forums.

commit f2d07985942237175cc5f40f7341dc5181b360dd
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Jan 7 16:21:40 2015 -0600

    Fixed a few issues with syntax and consistently applied computations. NOTE currently VMT_Vorticity is writing uw vorticity to the zsd variable. This is a hack for brandon rd purposes only. Need to roll that back before merging.

commit 1498bb4cf787e6d6ea0b6163de52f1f88597f1e1
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Jan 7 10:32:22 2015 -0600

    This commit applys all relevant stashed changes. Turned on the vorticity functionality. Ready for testing and merging.

commit 9685c5ee4742ec91bacfdcb55423c3b33f6867a7
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Jan 7 10:11:20 2015 -0600

    Fixed a couple of bugs. Also removed hard coded eta. Now, when user chooses HAB reference, VMT prompts for eta. Eta is stored in guiparams to make it persistent each session.

commit 1e32b73f61904c0220dfe1a3a1ca96658f6155f3
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Jan 7 09:32:19 2015 -0600

    This enables custom plotting for Brandon Rd. HAB reference is working, and this feature can be merged into the main branches pending testing.

commit 10dd7269d283e5782f0959319a5a6cc776df010a
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Jan 6 11:25:39 2015 -0600

    I have added the ability to process the MCS using data from a tide-file. Currently, there is a switch-case statement in VMT_CompMeanXS that enables this approach on line 135. This new method requires the assumption that the depths are not changing dramatically over the sample time for a cross section. In essense, it is making explicit the assumption previously implicit in VMT. Velocities at each grid node are interpolated both spatially--that is, esembles occuring near a grid node are mapped--and temporally. The time over which ensembles are sampled is the domain over which we require the above assumption.
    
    For the case of rapidly varied flow, this assumption is in no way valid. I will branch VMT again and build a solution for this case that I can use to process and visualize data collected during a lock dump procedure.

commit 4a506ca3a86382d520a425d9bb19896a516dc178
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Mon Jan 5 15:44:33 2015 -0600

    I have added support for loading a tide file into the export multibeam bathy functionality. Also in this commit is a bug fix in the export MBB dialog. See issue 317 in Mantis. Remaining items
    - Still need to allow for processing tide file while mapping the cross section. Currently only taking first WSE.
    - Need to modify ability of VMT to plot in WSE or Depth
    - Via a new branch, need to customize VMT to plot with constant bed elevation, varied WSE.
    This commit gets me closer, but not ready for any merge yet.

commit ea5c098b2434fe265f04dda74e03b4f7beecb740
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Mon Jan 5 09:26:23 2015 -0600

    Updated changelog

commit 4bba392982e1bb44a8f7a9ba7c3f0364635d831e
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Mon Jan 5 09:25:41 2015 -0600

    Updated the ASCII2GIS tool file loading scripts. Revised release number.

commit 40e90a785e38b7fcfe5bf1c8c5e34e43cbacee12
Merge: 25f8b1b c3311a6
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Mon Dec 1 16:04:46 2014 -0600

    Merge branch 'moffat-testing'

commit c3311a6bc34e8b3cafbfee493e37cd2b9e336da4
Merge: b291410 c1bf4f8
Author: Carlos Moffat <carlos@moffat.cl>
Date:   Mon Dec 1 12:55:26 2014 -0800

    Merge branch 'testing' of https://github.com/moffat/VMT into testing

commit c1bf4f8775f36441a6ad70bc42fac791e378c905
Author: Carlos Moffat <carlos@moffat.cl>
Date:   Mon Dec 1 17:50:53 2014 -0300

    Revert "Revert "Changed reference to vmt_version to correctly open user guide. Change""
    
    This reverts commit a8df5a80cef64868f96188f37a8538bfab9e3a80.

commit a8df5a80cef64868f96188f37a8538bfab9e3a80
Author: Carlos Moffat <carlos@moffat.cl>
Date:   Mon Dec 1 17:48:10 2014 -0300

    Revert "Changed reference to vmt_version to correctly open user guide. Change"
    
    This reverts commit 84de8b522400b2d7dcf96cd59f6e18e4f22a2eb5.

commit b291410c0ad8cfed2648b554257e526198a3bfa2
Author: Carlos Moffat <carlos@moffat.cl>
Date:   Mon Dec 1 12:36:12 2014 -0800

    Updated Help menu callbacks
    
    - Change reference to vmt_version to correctly open user guide.
    - Change open command for library functions to work on OS X.

commit 84de8b522400b2d7dcf96cd59f6e18e4f22a2eb5
Author: Carlos Moffat <carlos@moffat.cl>
Date:   Mon Dec 1 12:36:12 2014 -0800

    Changed reference to vmt_version to correctly open user guide. Change
    open command for library functions to work on OS X.

commit d20e8482a652558610b38ee6edfb49df0f43d29b
Author: Carlos Moffat <carlos@moffat.cl>
Date:   Fri Nov 28 14:05:29 2014 -0800

    Added if statement to deal with future removal of DrawMode

commit 4dd2efec24f2a5bde2d6975667e9c9a1e6751e0b
Author: Carlos Moffat <carlos@moffat.cl>
Date:   Fri Nov 28 13:44:11 2014 -0800

    Removed declaration of filesep, not needed.

commit 25f8b1b9d98403783faf1ba3b71d505da6b66426
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Oct 2 09:43:37 2014 -0500

    Modified the Check for Update function. Added VMT.ico to repo. This version is good to distribute with InnoScript.

commit 5a5c2e307f9fe365b48ee9678cc18f80eaebb73c
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Sep 17 10:39:10 2014 -0500

    Commit to update CHANGELOG.md

commit 0e2c44e1aa6891617254b0bce14ce7bcdba5824d
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Sep 17 10:38:05 2014 -0500

    Modified the Set User Endpoints functionality, added a pref for it, and made the shiptrack and planview plots show the user set endpoints if spedified. Also PRJ caught a small buf in tfile. Finally, added a release data to the version tag. VMT now looks for when a particular version was release and compares it against the VMTversion.txt on the OSW HA Webpage.

commit ff8504e914476a0e5eb1eb4bfab173bebf1a07a2
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Aug 21 10:54:19 2014 -0500

    Fixed a bug in loading SonTek RSL v3.60 data. Updated docs, and changelog.

commit 883ce9065309f722c17c8a0d8cfceed827af04ed
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Fri Aug 1 10:44:33 2014 -0500

    Added an auto-update check feature, and updated documentation.

commit d24f8349a0f8be41e04530a9ff11ea514ac174c3 (tag: v4.06)
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Jul 30 14:14:55 2014 -0500

    1. Added the old SVN changelog to the repo; 2. Added the new changelog; 3. A couple of prerelease tweaks to v4.06

commit 0cb64c2f197d52214f5edca82a870bda00061b1e
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Jul 23 21:38:34 2014 -0400

    Making sure VMT repo is up to date prior to messing with Sontekfile reading.

commit ee10257a1322c31b3cc3bcef539cbc5551299bd3
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Wed Jul 9 13:22:24 2014 -0500

    Corrected syntax error in fileinfotxt graphic handling. Added Exit to the File menu.

commit 737342be2777b76b883170764b655e3bc97ba8cf
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Jul 8 15:32:41 2014 -0500

    Final tweaks to get master with editplot merge tied up.

commit 35c410e6204d4d75948ba0cbd56d4589d9b62af2
Merge: e949aa8 6de4b51
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Jul 8 15:03:10 2014 -0500

    Merge branch 'editplotmerge'

commit 6de4b51e0ad87598b89e74545b6535d8d845ed0a
Merge: cec128d e949aa8
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Jul 8 15:02:34 2014 -0500

    Resolving conflicts as part of the merge of branch editplot to master.

commit cec128d6c8a6ec209d2f99e04a142b8ea4e435be
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Jul 8 12:04:28 2014 -0500

    Editplot is working now. This is the commit before merging the branch back into master.

commit 345c15c4cd46a6868314a0cfc7e65cb739e96687
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Jul 8 09:46:58 2014 -0500

    Tweaked the disableMenuBar function to pass the correct handles on hEdit ClickedCallback. Modifed editFigureDialog to accept that handle.

commit e949aa8c25aaa1b752bcae5f9e2dfec8975320ab
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Jul 8 08:44:34 2014 -0500

    Updated documentation for distro

commit 863800a80956a3f39ea9c23d358c01f64a927c86
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Jul 8 08:41:43 2014 -0500

    Turned off the file info text object at the bottom of the figure. It is still there, just has visibility set to off. This makes v4.06 on master ready for distribution.

commit dfb08768fa7bf469337f1e95d86ff9ed01c69707
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Jul 8 08:16:15 2014 -0500

    Edits to editFigureDialog; things are pretty much working now when running as source. Still a couple of small tweaks to go.

commit 2813428276c0e3734c20f5414b31c978b81e3f9a
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Jul 3 11:09:41 2014 -0500

    Reverted master to stable v4.06, branch editplot has new feature in testing.

commit 78bf7ff907cae75b1ecc6847c16f7f13ed46904b
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Jul 3 10:57:22 2014 -0500

    Updated readme.

commit 86f91cc817f916606046d5f03e48e01ed340f3ea
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Jul 3 10:56:15 2014 -0500

    Updated documentation

commit 735319779d76cf692b2a4bf8d087c2bd796643fd
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Jul 3 10:26:37 2014 -0500

    A little cleanup before editplot branch is created

commit f45b8c39b36ec14ddb0be27041cf00629a95e5f2
Merge: d20786b 54b121e
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Jul 3 10:17:17 2014 -0500

    Merge branch 'master' of github.com:frank-engel-usgs/VMT

commit d20786bb8905f0c1850791847aaceefea0fb905f
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Thu Jul 3 10:11:23 2014 -0500

    Initial commit to repo

commit 54b121e11b961d6cb4f91ecd11e33bfc34a746e4
Author: Frank L. Engel <frank-engel-usgs@users.noreply.github.com>
Date:   Thu Jul 3 09:39:28 2014 -0500

    Initial commit
