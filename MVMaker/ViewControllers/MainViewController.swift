//
//  MainViewController.swift
//  MVMaker
//
//  Created by 藤井陽介 on 2017/07/28.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit
import MediaPlayer

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Button
    @IBAction func tappedStartButton() {
        
        let picker = MPMediaPickerController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func finish(_ segue: UIStoryboardSegue) {
        
        MusicManager.shared.music = nil
    }
}

extension MainViewController: MPMediaPickerControllerDelegate {
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        guard let media = mediaItemCollection.items.first else {
            return
        }
        
        dismiss(animated: true, completion: {
            
            MusicManager.shared.music = media
            self.performSegue(withIdentifier: "toConfirmViewController", sender: nil)
        })
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        
        dismiss(animated: true, completion: nil)
    }
}
