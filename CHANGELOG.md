commit 596364875a16a47d3f611c65de2baadcb5124625 (HEAD, master)
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

commit 1f35c5561bde6b3b0542960a7ab2a2cc8525f737 (origin/master)
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

commit f2d07985942237175cc5f40f7341dc5181b360dd (origin/private/brandonrdcustom)
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

commit 10dd7269d283e5782f0959319a5a6cc776df010a (origin/variable_wse)
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

commit c3311a6bc34e8b3cafbfee493e37cd2b9e336da4 (moffat-testing)
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

commit d24f8349a0f8be41e04530a9ff11ea514ac174c3
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

commit 6de4b51e0ad87598b89e74545b6535d8d845ed0a (editplotmerge)
Merge: cec128d e949aa8
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Tue Jul 8 15:02:34 2014 -0500

    Resolving conflicts as part of the merge of branch editplot to master.

commit cec128d6c8a6ec209d2f99e04a142b8ea4e435be (origin/editplot, editplot)
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
