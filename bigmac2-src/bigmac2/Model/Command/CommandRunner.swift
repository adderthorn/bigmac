//
//  CommandRunner.swift
//  bigmac2
//
//  Created by starplayrx on 12/19/20.
//

// #!/usr/bin/env xcrun swift

import Foundation

func runCommandReturnString(binary: String, arguments: [String]) -> String? {
    
    let task = Process()
    if #available(OSX 10.13, *) {
        task.executableURL = URL(string: "file://" + binary)
    } else {
        // Fallback on earlier versions
        task.launchPath = binary
        
    }
    task.arguments = arguments
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.launch()
    task.waitUntilExit()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    
    if let output = String(data: data, encoding: String.Encoding.utf8), !output.isEmpty {
        print(output)
        return output
    }
    
    return ""
}


/* May remove AppleScript, or keep if for non-root mode*/
func performAppleScript (script: String) -> (text: String?, error: NSDictionary?) {
    
    var text : String?
    var error : NSDictionary?
    
    if let script = NSAppleScript(source: script) {
        let result = script.executeAndReturnError(&error) as NSAppleEventDescriptor
        text = result.stringValue
    }
    
    return (text: text, error: error)
}


extension ViewController {
    
    /* Run command in the background */
    func runProcess(binary: String, arguments: [String], title: String) {
        
        DispatchQueue.main.async { [self] in
            incrementInstallGauge(resetGauge: false, incremment: true, setToFull: false, cylon: false, title: title)
            sharedSupportGbLabel.stringValue = ""
            sharedSupportProgressBar.doubleValue = 0
            sharedSupportPercentage.stringValue = "0%"
        }
        
        //DispatchQueue.global(qos: .background).async {
        let process = Process()
        process.launchPath = binary
        process.arguments = arguments
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        pipe.fileHandleForReading.readabilityHandler = { pipe in
            if let io = String(data: pipe.availableData, encoding: .utf8) {
                let t = io.components(separatedBy: "\t")
                
                if t.count >= 4 && t.count <= 5 {
                    
                    if let x = Int(t[1]) {
                        if x >= 0 && x <= 100 {
                            DispatchQueue.main.async { [self] in
                                
                                sharedSupportProgressBar.doubleValue = Double(x)
                                sharedSupportPercentage.stringValue = "\(x)%"
                            }
                        }
                    }
                }
            }
        }
        
        //Finish the Job
        process.terminationHandler = { (task: Process?) -> () in
            pipe.fileHandleForReading.readabilityHandler = nil
        }
        
        process.launch()
        process.waitUntilExit()
    }
    
    /* Run command in the background */
    func runIndeterminateProcess(binary: String, arguments: [String], title: String) {
        
        DispatchQueue.main.async { [self] in
            postInstallTask_label.stringValue = title
            postInstallDetails_label.stringValue = ""
        }
        
        //DispatchQueue.global(qos: .background).async {
        let process = Process()
        process.launchPath = binary
        process.arguments = arguments
        
        let pipe = Pipe()
        
        process.standardOutput = pipe
        process.standardError = pipe
        
        pipe.fileHandleForReading.readabilityHandler = { pipe in
            if var io = String(data: pipe.availableData, encoding: .utf8) {
                if io.contains("ting") {
                    io = io.stringAfter(":")
                    io = io.stringAfter(":")
                    io = io.stringAfter(":")
                    io = io.stringAfter(" ")
                    io = io.capitalizingFirstLetter()
                    
                    if (!io.isEmpty) {
                        DispatchQueue.main.async { [self] in
                            self.postInstallDetails_label.stringValue = io as String
                            
                            if io.starts(with: "Writing") {
                                postInstallProgressIndicator.doubleValue += 1
                            }
                        }
                    }
                }
            }
        }
        
        //Finish the Job
        process.terminationHandler = { (task: Process?) -> () in
            pipe.fileHandleForReading.readabilityHandler = nil
        }
        
        process.qualityOfService = .default
        process.launch()
        process.waitUntilExit()
    }
}


