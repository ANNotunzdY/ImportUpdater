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
        let allSources = try! NSString(contentsOfFile: "/Users/annotunzdy/Desktop/sources.txt", encoding: NSUTF8StringEncoding).componentsSeparatedByString("\n")
        let allHeaders = try! NSString(contentsOfFile: "/Users/annotunzdy/Desktop/headers.txt", encoding: NSUTF8StringEncoding).componentsSeparatedByString("\n").map({ (fullPath) -> [String] in
            let components = NSString(string: fullPath).pathComponents
            var frameworkName = components[1]
            frameworkName = frameworkName.stringByReplacingOccurrencesOfString("-", withString: "_")
            frameworkName = frameworkName.stringByReplacingOccurrencesOfString("+", withString: "_")
            return [frameworkName, components[components.count - 1]]
        })
        
        for sourcePath in allSources {
            let fullPath = NSString(string: "/Users/annotunzdy/Documents/Proj").stringByAppendingPathComponent(sourcePath)
            NSLog("Search: %@", fullPath)
            var sourceCode = try! NSString(contentsOfFile: fullPath, encoding: NSUTF8StringEncoding)
            var changed = false
            for headerInfo in allHeaders {
                let oldImport1 = NSString(format: "#import \"%@\"", headerInfo[1]) as String
                let oldImport2 = NSString(format: "#import <%@/%@>", headerInfo[0], headerInfo[1]) as String
                let newImport = NSString(format: "#import \"%@/%@\"", headerInfo[0], headerInfo[1]) as String
                var newSourceCode = sourceCode.stringByReplacingOccurrencesOfString(oldImport1, withString: newImport)
                newSourceCode = sourceCode.stringByReplacingOccurrencesOfString(oldImport2, withString: newImport)
                if (sourceCode != newSourceCode) {
                    changed = true
                    sourceCode = newSourceCode
                }
            }
            if (changed) {
                let data = sourceCode.dataUsingEncoding(NSUTF8StringEncoding)
                try! NSFileManager.defaultManager().removeItemAtPath(fullPath)
                NSFileManager.defaultManager().createFileAtPath(fullPath, contents: data, attributes: nil)
                NSLog("Changed")
            } else {
                NSLog("Unchanged")
            }
        }
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

