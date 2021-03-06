//
//  RecordingViewController.swift
//  MVMaker
//
//  Created by 藤井陽介 on 2017/08/01.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer
import Photos

class RecordingViewController: UIViewController {
    
    @IBOutlet weak var videoView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    let indicator = UIActivityIndicatorView()
    var timer: Timer!
    var time = 0
    
    let musicManager = MusicManager.shared
    var videoManager: VideoManager?
    
    var flag = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        indicator.color = UIColor.white
        view.addSubview(indicator)
        view.bringSubview(toFront: indicator)
        indicator.startAnimating()
    }

    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        setupVideo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func touchDownRecordButton() {
        
        if flag {
            
            videoManager?.start()
            flag = false
        } else {
            
            videoManager?.resume()
        }
        musicManager.play()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    @IBAction func touchUpRecordButton() {
        
        videoManager?.pause()
        musicManager.pause()
        timer.invalidate()
    }
    
    @IBAction func tappedEndButton() {
        
        // MARK: indicator
        indicator.startAnimating()
        timer.invalidate()
        
        videoManager?.stop()
        musicManager.stop()
    }
    
    // MARK: Setup Video
    fileprivate func setupVideo() {
        
        videoManager = VideoManager()
        videoManager?.delegate = self
        videoManager?.setup(previewView: videoView, completion: {
            
            self.indicator.stopAnimating()
        })
        view.sendSubview(toBack: videoView)
    }
    
    @objc fileprivate func update() {
        
        time += 1
        let sec = time % 60
        let min = time / 60
        timeLabel.text = String(format: "%02d:%02d ", min, sec) + (musicManager.count == 0 ? "♪" : " ")
    }
}

extension RecordingViewController: VideoManagerDelegate {
    
    func change(recordingTime time: Int64) {
    }
    
    func finish(fileUrl: URL, completion: @escaping () -> Void) {
        
        // MARK: 動画と音楽を合成する
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as String
        let outputPath = "\(documentsDirectory)/result.mov"
        
        let composition = AVMutableComposition()
        let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        // 動画部分をCompositionに追加
        let asset = AVURLAsset(url: fileUrl)
        let range = CMTimeRange(start: kCMTimeZero, duration: asset.duration)
        let videoTrack = asset.tracks(withMediaType: AVMediaTypeVideo).first!
        try? compositionVideoTrack.insertTimeRange(range, of: videoTrack, at: kCMTimeZero)
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = range
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        
        // 音楽部分
        if let soundUrl = musicManager.music?.assetURL {
            
            let soundAsset = AVURLAsset(url: soundUrl)
            let soundTrack = soundAsset.tracks(withMediaType: AVMediaTypeAudio).first!
            let compositionSoundTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
            // 音楽の早さは変えずに動画を基準にするため
            // 加えてここで最後の部分の音は保存する
            if range.duration > soundAsset.duration {
                
                let soundRange = CMTimeRange(start: kCMTimeZero, duration: soundAsset.duration)
                try? compositionSoundTrack.insertTimeRange(soundRange, of: soundTrack, at: kCMTimeZero)
                let audioRange = CMTimeRange(start: kCMTimeZero + soundAsset.duration, end: range.end)
                let audioTrack = asset.tracks(withMediaType: AVMediaTypeAudio).first!
                try? compositionAudioTrack.insertTimeRange(audioRange, of: audioTrack, at: kCMTimeZero + soundAsset.duration)
            } else {
                
                try? compositionSoundTrack.insertTimeRange(range, of: soundTrack, at: kCMTimeZero)
            }
        }
        
        // iOSの仕様により動画が回転してしまっている可能性があるから
        var videoSize = videoTrack.naturalSize
        let transform = videoTrack.preferredTransform
        if transform.a == 0 && transform.d == 0 && (transform.b == 1.0 || transform.b == -1.0) && (transform.c == 1.0 || transform.c == -1.0) {
            
            videoSize = CGSize(width: videoSize.height, height: videoSize.width)
        }
        layerInstruction.setTransform(transform, at: kCMTimeZero)
        instruction.layerInstructions = [layerInstruction]
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = videoSize
        videoComposition.instructions = [instruction]
        videoComposition.frameDuration = CMTimeMake(1, 30)
        
        if FileManager.default.fileExists(atPath: outputPath) {
            
            try? FileManager.default.removeItem(atPath: outputPath)
        }
        
        let session = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        session?.outputURL = URL(fileURLWithPath: outputPath)
        session?.outputFileType = AVFileTypeQuickTimeMovie
        session?.videoComposition = videoComposition
        
        session?.exportAsynchronously { [weak self] in
            
            guard session?.status == .completed else {
                
                return
            }

            self?.indicator.stopAnimating()
            let playerController = CustomAVPlayerViewController()
            let url = URL(fileURLWithPath: outputPath)
            let videoPlayer = AVPlayer(url: url)
            playerController.player = videoPlayer
            playerController.completion = { [weak self] in
                
                let alert = UIAlertController(title: "アルバムに保存しますか？", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
                    
                    MusicManager.shared.clear()
                    self?.performSegue(withIdentifier: "toMainViewController", sender: nil)
                }))
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self] _ in
                    
                    PHPhotoLibrary.shared().performChanges({
                        
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                    }) { [weak self] _, _ in
                        
                        let alert = UIAlertController(title: "保存が完了しました。", message: "", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {[weak self] _ in
                            
                            MusicManager.shared.clear()
                            self?.performSegue(withIdentifier: "toMainViewController", sender: nil)
                        }))
                        self?.present(alert, animated: true, completion: nil)
                    }
                }))
                
                self?.present(alert, animated: true, completion: nil)
            }
            self?.present(playerController, animated: true, completion: nil)
        }
    }
}

