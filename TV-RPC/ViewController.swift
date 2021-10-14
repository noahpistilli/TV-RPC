//
//  ViewController.swift
//  TV RPC
//
//  Created by Noah Pistilli on 2021-10-13.
//

import Cocoa
import ScriptingBridge
import SwordRPC

@objc enum TVEPlS: NSInteger {
    case playing = 0x6b505350
    case paused = 0x6b505370
}

@objc protocol TVVideo {
    @objc optional var show: String {get}
    @objc optional var objectDescription: String {get}
    @objc optional var duration: CDouble {get}
    @objc optional var episodeNumber: Int {get}
    @objc optional var name: String {get}
    @objc optional var playerState: TVEPlS {get}
    @objc optional var seasonNumber: Int {get}
}

@objc protocol TVApplication {
    @objc optional var currentTrack: TVVideo {get}
    @objc optional var playerPosition: CDouble {get}
}

class ViewController: NSViewController {
    // This is the TV RPC App ID
    let rpc = SwordRPC(appId: "896880510381457452")
    
    // Apple TV's bundle identifier
    var appName = "com.apple.TV"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Callback for when RPC connects.
        rpc.onConnect { _ in
            print("Connected to Discord.")
            
            DispatchQueue.main.async {
                self.view.window?.close()
            }
            
            // Populate information initially.
            self.updateEmbed()
        }
        
        // Same with Music, Apple TV sends an NSNotification during every player event.
        DistributedNotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "\(self.appName).playerInfo"), object: nil, queue: nil, using: { _ in
            self.updateEmbed()
        })
        
        rpc.connect()
    }
    
    func updateEmbed() {
        var presence = RichPresence()
        
        // By default, show a lack of state.
        presence.details = "Stopped"
        presence.state = "Nothing is currently playing"
        presence.assets.largeText = "There's nothing here!"
        presence.assets.largeImage = "tv"
        presence.assets.smallText = "Currently stopped"
        
        let tv: AnyObject = SBApplication(bundleIdentifier: appName)!

        // Apple TV+ videos will always return nil for name. As Apple TV+ videos also return nil for pretty much everything else, we will not handle them.
        if tv.currentTrack!.name != nil {
            let track = tv.currentTrack!
            
            switch tv.playerState! {
            case .playing:
                // If show is nil, the user is watching a movie.
                if track.show == "" {
                    presence.details = track.name!
                    presence.state = "Watching a Movie"
                } else {
                    // The user is watching a TV show.
                    presence.details = track.show!
                    presence.state = track.name!
                    presence.assets.largeText = "Season \(track.seasonNumber!) Episode \(track.episodeNumber!)"
                }
                
                // The following needs to be in milliseconds.
                let trackDuration = Double(round(track.duration!))
                let trackPosition = Double(round(tv.playerPosition!))
                let currentTimestamp = Date()
                let trackSecondsRemaining = trackDuration - trackPosition
                
                let startTimestamp = currentTimestamp - trackPosition
                let endTimestamp = currentTimestamp + trackSecondsRemaining
                
                // Go back (position amount)
                presence.timestamps.start = Date(timeIntervalSince1970: startTimestamp.timeIntervalSince1970 * 1000)
                
                // Add time remaining
                presence.timestamps.end = Date(timeIntervalSince1970: endTimestamp.timeIntervalSince1970 * 1000)
                
            case .paused:
                if track.show != nil {
                    presence.details = "Paused - \(track.show!)"
                    presence.state = "\(track.name!)"
                } else {
                    presence.details = "Paused - \(track.name!)"
                    presence.state = "Watching a Movie"
                }
                break
            default:
                break
            }
        }
        
 
        rpc.setPresence(presence)
        
    }
}
