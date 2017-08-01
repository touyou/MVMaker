//
//  ConfirmViewController.swift
//  MVMaker
//
//  Created by 藤井陽介 on 2017/08/01.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit
import MediaPlayer

class ConfirmViewController: UIViewController {
    
    @IBOutlet weak var coverImageView: CircleImageView! {
        
        didSet {
            
            coverImageView.image = musicManager.music?.artwork?.image(at: coverImageView.bounds.size)
        }
    }

    let musicManager = MusicManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Button
    @IBAction func tappedOkButton() {
        
        performSegue(withIdentifier: "toRecordingViewController", sender: nil)
    }
    
    @IBAction func tappedCancelButton() {
        
        musicManager.music = nil
        dismiss(animated: true, completion: nil)
    }
}
