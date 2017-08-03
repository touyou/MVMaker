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
    
    @IBOutlet weak var coverImageView: CircleImageView!
    @IBOutlet weak var titleLabel: UILabel! {
        
        didSet {
            
            titleLabel.text = musicManager.music?.title
        }
    }
    @IBOutlet weak var artistLabel: UILabel! {
        
        didSet {
            
            let artist = musicManager.music?.artist ?? "Unknown"
            artistLabel.text = "Artist: \(artist)"
        }
    }
    @IBOutlet weak var albumLabel: UILabel! {
        
        didSet {
            
            let albumTitle = musicManager.music?.albumTitle ?? "Unknown"
            albumLabel.text = "Album: \(albumTitle)"
        }
    }
    let musicManager = MusicManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        coverImageView.image = musicManager.music?.artwork?.image(at: coverImageView.bounds.size)
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
