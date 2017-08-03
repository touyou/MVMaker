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
    var count = 0
    
    var status: Bool {
        
        get {
            
            return mediaPlayer?.isPlaying ?? false
        }
    }
    
    let musicQueue = DispatchQueue(label: "com.dev.touyou.MusicQueue")
    
    func play() {
        
        musicQueue.sync {
            
            if let mediaPlayer = mediaPlayer {
                
                if count == 0 {
                    
                    mediaPlayer.play()
                }
            } else if let url = music?.assetURL {
                
                mediaPlayer = try? AVAudioPlayer(contentsOf: url)
                mediaPlayer?.numberOfLoops = 0
                mediaPlayer?.delegate = self
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
    
    func clear() {
        
        mediaPlayer = nil
        music = nil
        count = 0
    }
}

extension MusicManager: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        count += 1
    }
}
