--
--  AppDelegate.applescript
--  KitchenSync
--
--  Created by tom on 19/07/2015.
--  Copyright (c) 2015 tom. All rights reserved.
--

script AppDelegate
	property parent : class "NSObject"
	
	-- IBOutlets
	property theWindow : missing value
	
	on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened 
	end applicationWillFinishLaunching_
	
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits 
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
    on buttonClicked_(sender)
        #set myPath to POSIX path of (path to me) as string
        set scriptPath to POSIX path of (path to resource "KitchenSync.sh")
        do shell script quoted form of scriptPath
    end buttonClicked_

end script

