//
//  MusicManager.swift
//  MVMaker
//
//  Created by 藤井陽介 on 2017/08/01.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit
import MediaPlayer

class MusicManager: NSObject {
    
    static let shared = MusicManager()
    var music: MPMediaItem?
    private var mediaPlayer: AVAudioPlayer?
    
    var status: Bool {
        
        get {
            
            return mediaPlayer?.isPlaying ?? false
        }
    }
    
    let musicQueue = DispatchQueue(label: "com.dev.touyou.MusicQueue")
    
    func play() {
        
        musicQueue.sync {
            
            if let mediaPlayer = mediaPlayer {
                
                mediaPlayer.play()
            } else if let url = music?.assetURL {
                
                mediaPlayer = try? AVAudioPlayer(contentsOf: url)
                mediaPlayer?.numberOfLoops = 0
                mediaPlayer?.play()
            }
        }
    }
    
    func pause() {
        
        musicQueue.sync {
            
            mediaPlayer?.pause()
        }
    }
    
    func stop() {
        
        musicQueue.sync {
            
            mediaPlayer?.stop()
        }
    }
}
