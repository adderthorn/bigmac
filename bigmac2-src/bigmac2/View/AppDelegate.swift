//
//  AppDelegate.swift
//  bigmac2
//
//  Created by starplayrx on 12/18/20.
//

import AppKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag == false {

            for window in sender.windows {

                if (window.delegate?.isKind(of: ViewController.self)) == true {
                    window.orderFront(self)
                } else {
                    window.makeKeyAndOrderFront(self)
                }
            }
        }
        return true
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
        if NSUserName() == root {
            unmountBigData() //dmg for the app
        }
        
        func save() {
            //ToDo Switch to an array and loop over or a dictionary, could even use a Struct
            let defaults = UserDefaults.standard
            defaults.set(isBaseVerbose, forKey: "isBaseVerbose")
            defaults.set(isBaseSingleUser, forKey: "isBaseSingleUser")
            defaults.set(enableUSB, forKey: "enableUSB")
            defaults.set(disableBT2, forKey: "disableBT2")
            defaults.set(teleTrap, forKey: "teleTrap")
            defaults.set(VerboseBoot, forKey: "VerboseBoot")
            defaults.set(superDrive, forKey: "superDrive")
            defaults.set(appStoreMacOS, forKey: "appStoreMacOS")
            defaults.set(appleHDA, forKey: "appleHDA")
            defaults.set(hdmiAudio, forKey: "hdmiAudio")
            defaults.set(legacyWiFi, forKey: "legacyWiFi")
            defaults.set(installKCs, forKey: "installKCs")
            defaults.set(blessSystem, forKey: "blessSystem")
            defaults.set(deleteSnaphots, forKey: "deleteSnaphots")
            defaults.set(singleUser, forKey: "singleUser")
            defaults.set(amdMouSSE, forKey: "amdMouSSE")
        }
        
        save()
    }
}

    
  

