//
//  CustomAVPlayerViewController.swift
//  MVMaker
//
//  Created by 藤井陽介 on 2017/08/03.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import AVKit

class CustomAVPlayerViewController: AVPlayerViewController {

    var completion: (() -> ())!
    
    override func viewDidDisappear(_ animated: Bool) {
        completion()
        super.viewDidDisappear(animated)
    }
}
