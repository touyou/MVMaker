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
    
    func play() {
        
        if let url = music?.assetURL {
            
            mediaPlayer = try? AVAudioPlayer(contentsOf: url)
            mediaPlayer?.numberOfLoops = 0
            mediaPlayer?.play()
        }
    }
    
    func pause() {
        
        mediaPlayer?.pause()
    }
    
    func stop() {
        
        mediaPlayer?.stop()
    }
}
