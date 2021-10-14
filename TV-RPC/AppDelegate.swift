//
//  AppDelegate.swift
//  TV RPC
//
//  Created by Noah Pistilli on 2021-10-13.
//

import Cocoa

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var menu: NSMenu?
    @IBOutlet weak var firstMenuItem: NSMenuItem?
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.image = NSImage(named: "status_icon")
        if let menu = menu {
            statusItem.menu = menu
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}


