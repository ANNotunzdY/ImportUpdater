//
//  ViewController.swift
//  ImportUpdater
//
//  Created by ANNotunzdY on 6/28/16.
//  Copyright © 2016 Kibousoft LLC. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let allSources = try! NSString(contentsOfFile: "/Users/annotunzdy/Desktop/sources.txt", encoding: String.Encoding.utf8.rawValue).components(separatedBy: "\n")
        let allHeaders = try! NSString(contentsOfFile: "/Users/annotunzdy/Desktop/headers.txt", encoding: String.Encoding.utf8.rawValue).components(separatedBy: "\n").map({ (fullPath) -> [String] in
            let components = NSString(string: fullPath).pathComponents
            var frameworkName = components[1]
            frameworkName = frameworkName.replacingOccurrences(of: "-", with: "_")
            frameworkName = frameworkName.replacingOccurrences(of: "+", with: "_")
            return [frameworkName, components[components.count - 1]]
        })
        
        for sourcePath in allSources {
            let fullPath = sourcePath
            NSLog("Search: %@", fullPath)
            var sourceCode = try! NSString(contentsOfFile: fullPath, encoding: String.Encoding.utf8.rawValue)
            var changed = false
            for headerInfo in allHeaders {
                NSLog("Check: %@/%@", headerInfo[0], headerInfo[1])
                let oldImport1 = NSString(format: "#import \"%@\"", headerInfo[1]) as String
                let oldImport2 = NSString(format: "#import <%@/%@>", headerInfo[0], headerInfo[1]) as String
                let newImport = NSString(format: "#import \"%@/%@\"", headerInfo[0], headerInfo[1]) as String
                var newSourceCode = sourceCode.replacingOccurrences(of: oldImport1, with: newImport)
                newSourceCode = newSourceCode.replacingOccurrences(of: oldImport2, with: newImport)
                if (sourceCode as String != newSourceCode) {
                    changed = true
                    sourceCode = newSourceCode as NSString
                }
            }
            if (changed) {
                let data = sourceCode.data(using: String.Encoding.utf8.rawValue)
                try! FileManager.default.removeItem(atPath: fullPath)
                FileManager.default.createFile(atPath: fullPath, contents: data, attributes: nil)
                NSLog("Changed")
            } else {
                NSLog("Unchanged")
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

