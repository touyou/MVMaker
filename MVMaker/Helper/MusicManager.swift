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
}
