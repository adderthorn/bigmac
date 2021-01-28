//
//  InProgressTasks.swift
//  bigmac2
//
//  Created by starplayrx on 1/14/21.
//

import Foundation

//MARK: In Progess Flow
extension ViewController {
    
    func cancelTask() -> Bool {
        guard globalDispatch == nil && globalWorkItem == nil else {
            
            DispatchQueue.main.async { [self] in
                performSegue(withIdentifier: "namedTask", sender: self)
            }
            
            return true
        }
        
        return false
    }

    
    func que(label: String, function: () ) {
        
        globalWorkItem = DispatchWorkItem { function }
        globalDispatch = DispatchQueue(label: label)
        
        if let d = globalDispatch, let w = globalWorkItem {
            d.async(execute: w)
        }
    }
   
    
    func dosDude1inProgressTask(label: String, dmg: String) {
        if cancelTask() { return }
        
        if let r = Bundle.main.resourceURL?.path, let p = Optional(r + "/" + dmg), checkIfFileExists(path: p) {
            _ = mountDiskImage(arg: ["mount", "\(p)", "-noverify", "-noautofsck", "-autoopen"])
        } else {
            let function: () = downloadDMG(diskImage: dmg, webSite: globalWebsite).self
            que(label: label, function: function)
        }
    }
    
    
    func bigMacDataPatchDMG(label: String = "BigData Patches", dmg: String = bigDataDMG) {
        if cancelTask() { return }
        
        if NSUserName() == "root", let r = Bundle.main.resourceURL?.path, let p = Optional(r + "/" + bigDataDMG), checkIfFileExists(path: p) {
            mountBigData()
        } else if NSUserName() == "root" {
            let function: () = downloadDMG(diskImage: bigDataDMG, webSite: globalWebsite).self
            que(label: label, function: function)
        }
    }
    

    func downloadMacOSTask(label: String = "Downloading macOS", urlString: String = "http://swcdn.apple.com/content/downloads/00/55/001-86606-A_9SF1TL01U7/5duug9lar1gypwunjfl96dza0upa854qgg/InstallAssistant.pkg") {
        if cancelTask() { return }
        
        let function: () = downloadPkg(pkgString : urlString).self
        que(label: label, function: function)
    }
    
    @objc func EraseDmgBootDisk(_ notification:Notification) {
       volumeInfo = notification.object as? myVolumeInfo ?? myVolumeInfo(diskSlice: "", disk: "", displayName: "", volumeName: "", path: "", uuid: "", external: false, root: false, capacity: 0)
     
       DispatchQueue.main.async { [self] in
           spinnerAnimation(start: true, hide: false)
       }
       
       let path = "/Users/shared/\(bigmacDMG)"
       
       if !checkIfFileExists(path: path) {
           
           if cancelTask() { return }

           let function: () =  downloadBigMac2(dmg:"\(http)://\(domain)/\(bigmac2)/\(bigmacDMG)")
           que(label: "DMG Boot disk", function: function)
           
       } else {
            dmgBootMedia()
       }
    }
    
    
     @objc func EraseDisk(_ notification:Notification) {
        volumeInfo = notification.object as? myVolumeInfo ?? myVolumeInfo(diskSlice: "", disk: "", displayName: "", volumeName: "", path: "", uuid: "", external: false, root: false, capacity: 0)
      
        DispatchQueue.main.async { [self] in
            spinnerAnimation(start: true, hide: false)
        }
        
        let path = "/Users/shared/\(bigmacDMG)"

        if !checkIfFileExists(path: path) {
            
            if cancelTask() { return }

            let function: () =  downloadBigMac2(dmg:"\(http)://\(domain)/\(bigmac2)/\(bigmacDMG)")
            que(label: "DMG Boot disk", function: function)
            
        } else {
            isoBootMedia()
        }
     }
    
    @objc func EraseInstallDisk(_ notification:Notification) {
       volumeInfo = notification.object as? myVolumeInfo ?? myVolumeInfo(diskSlice: "", disk: "", displayName: "", volumeName: "", path: "", uuid: "", external: false, root: false, capacity: 0)
     
       DispatchQueue.main.async { [self] in
           spinnerAnimation(start: true, hide: false)
       }
       
       var downloadDisk = true
        
       let path = "/Users/shared/\(globalDownloadMacOSdmgName)"
       let path2 = "/\(globalDownloadMacOSdmgName)"
       
       if checkIfFileExists(path: path) || checkIfFileExists(path: path2) {
            downloadDisk = false
       }
        
       if downloadDisk {
           if cancelTask() { return }

           let function: () =  downloadBigMac2(dmg:"\(http)://\(domain)/\(bigmac2)/\(globalDownloadMacOSdmgName)")
           que(label: "Downloading Install disk", function: function)
           
       } else {
            installDmgMedia()
       }
    }
    
    func installDmgMedia() {
        if cancelTask() { return }

        DispatchQueue.main.async { [self] in
            isBaseSingleUser = singleUserCheckbox.state == .on
            isBaseVerbose = verboseUserCheckbox.state == .on
            spinnerAnimation(start: true, hide: false)
        }
     
        let function: () = installMacOSdiskImageX(diskInfo: volumeInfo, isVerbose: isBaseVerbose, isSingleUser: isBaseSingleUser).self

        que(label: "Installing macOS DMG", function: function)
        
    }
    
    func dmgBootMedia() {
        if cancelTask() { return }

        DispatchQueue.main.async { [self] in
            isBaseSingleUser = singleUserCheckbox.state == .on
            isBaseVerbose = verboseUserCheckbox.state == .on
            spinnerAnimation(start: true, hide: false)
        }
     
        let function: () = installDmgBootDisk(diskInfo: volumeInfo, isVerbose: isBaseVerbose, isSingleUser: isBaseSingleUser).self //not fulldisk is for internal testing

        que(label: "DMG Boot Media", function: function)

    }
    
    func isoBootMedia() {
        if cancelTask() { return }

        DispatchQueue.main.async { [self] in
            isBaseSingleUser = singleUserCheckbox.state == .on
            isBaseVerbose = verboseUserCheckbox.state == .on
            spinnerAnimation(start: true, hide: false)
        }
     
        let function: () = installIsoBootDisk(diskInfo: volumeInfo, isVerbose: isBaseVerbose, isSingleUser: isBaseSingleUser).self

        que(label: "Install Boot Media", function: function)
        
    }
    
     @objc func CreateDisk(_ notification:Notification){
        if globalInstall == install.bootDmg {
            dmgBootMedia()
        } else if globalInstall == install.bootIso {
            isoBootMedia()
        }
     }
    
    
    func currentWorkflowEnded() {
        if let _ = globalDispatch, let _ = globalWorkItem {
            globalDispatch = nil
            globalWorkItem = nil
        }
    }
}
