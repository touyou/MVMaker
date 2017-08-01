//
//  RecordingViewController.swift
//  MVMaker
//
//  Created by 藤井陽介 on 2017/08/01.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class RecordingViewController: UIViewController {
    
    @IBOutlet weak var videoView: UIView!
    
    let musicManager = MusicManager.shared
    fileprivate var input: AVCaptureDeviceInput!
    fileprivate var output: AVCaptureVideoDataOutput!
    fileprivate var session: AVCaptureSession!
    fileprivate var camera: AVCaptureDevice!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        setupVideo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tappedRecordButton() {
        
        
    }
    
    fileprivate func setupVideo() {
        
        // MARK: Setup Video
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetHigh
        
        camera = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)
        do {
            
            input = try AVCaptureDeviceInput(device: camera) as AVCaptureDeviceInput
        } catch let error {
            
            print(error.localizedDescription)
        }
        if session.canAddInput(input) {
            
            session.addInput(input)
        }
        
        output = AVCaptureVideoDataOutput()
        if session.canAddOutput(output) {
            
            session.addOutput(output)
        }
        
        let videoLayer = AVCaptureVideoPreviewLayer(session: session)
        videoLayer?.frame = view.bounds
        videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoView.layer.addSublayer(videoLayer!)
        view.sendSubview(toBack: videoView)
        
        session.startRunning()
    }
    
}

extension RecordingViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
}
