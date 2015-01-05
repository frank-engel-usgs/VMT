commit 4bba392982e1bb44a8f7a9ba7c3f0364635d831e (HEAD, master)
Author: Frank L. Engel <fengel@usgs.gov>
Date:   Mon Jan 5 09:25:41 2015 -0600

    Updated the ASCII2GIS tool file loading scripts. Revised release number.

commit 40e90a785e38b7fcfe5bf1c8c5e34e43cbacee12 (origin/master)
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
