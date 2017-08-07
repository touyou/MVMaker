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
    
    let indicator = UIActivityIndicatorView()
    let cached = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Viewのヒエラルキーに追加されるのを待つ
        let popTime = DispatchTime(uptimeNanoseconds: 10)
        DispatchQueue.main.asyncAfter(deadline: popTime, execute: {
            
            #if DEBUG
                self.performSegue(withIdentifier: "toTutorialViewController", sender: nil)
            #else
                if (self.cached.object(forKey: "isFirst") as? Bool) != nil {
                    
                    self.cached.set(true, forKey: "isFirst")
                    self.performSegue(withIdentifier: "toTutorialViewController", sender: nil)
                }
            #endif
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Button
    @IBAction func tappedStartButton() {
        
        let picker = MPMediaPickerController()
        picker.delegate = self
        
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        indicator.color = UIColor.white
        view.addSubview(indicator)
        view.bringSubview(toFront: indicator)
        indicator.startAnimating()
        
        present(picker, animated: true, completion: {
            
            self.indicator.stopAnimating()
        })
    }
    
    @IBAction func tappedTutorialButton() {
        
        performSegue(withIdentifier: "toTutorialViewController", sender: nil)
    }
    
    @IBAction func finish(_ segue: UIStoryboardSegue) {
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
