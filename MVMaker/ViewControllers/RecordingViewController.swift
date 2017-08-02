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
    
    @IBOutlet weak var videoView: UIImageView!
    
    let musicManager = MusicManager.shared
    var videoManager: VideoManager?
    
    fileprivate var recordingTime: Int64 = 100000000

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
    
    @IBAction func touchDownRecordButton() {
        
        _ = videoManager?.start()
        musicManager.play()
    }
    
    @IBAction func touchUpRecordButton() {
        
        videoManager?.pause()
        musicManager.pause()
    }
    
    @IBAction func tappedEndButton() {
        
        videoManager?.stop()
        musicManager.stop()
    }
    
    // MARK: Setup Video
    fileprivate func setupVideo() {
        
        videoManager = VideoManager()
        videoManager?.delegate = self
        videoManager?.setup(previewView: videoView, recordingTime: recordingTime)
        view.sendSubview(toBack: videoView)
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
        let audioTrack = asset.tracks(withMediaType: AVMediaTypeAudio).first!
        try? compositionVideoTrack.insertTimeRange(range, of: videoTrack, at: kCMTimeZero)
        try? compositionAudioTrack.insertTimeRange(range, of: audioTrack, at: kCMTimeZero)
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = range
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        
        // 音楽部分
        if let soundUrl = musicManager.music?.assetURL {
            
            let soundAsset = AVURLAsset(url: soundUrl)
            let soundTrack = soundAsset.tracks(withMediaType: AVMediaTypeAudio).first!
            let compositionSoundTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
            // 音楽の早さは変えずに動画を基準にするため
            if range.duration > soundAsset.duration {
                
                let soundRange = CMTimeRange(start: kCMTimeZero, duration: soundAsset.duration)
                try? compositionSoundTrack.insertTimeRange(soundRange, of: soundTrack, at: kCMTimeZero)
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
            // ここで遷移する
        }
    }
}
