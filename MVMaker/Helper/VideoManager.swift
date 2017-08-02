//
//  VideoManager.swift
//  MVMaker
//
//  Created by 藤井陽介 on 2017/08/02.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit
import AVFoundation

protocol VideoManagerDelegate: class {
    
    func change(recordingTime time: Int64)
    func finish(fileUrl: URL, completion: @escaping () -> Void)
}

class VideoManager: NSObject {
    
    weak var delegate: VideoManagerDelegate?
    fileprivate var recordingTime: Int64 = 0
    
    fileprivate var videoWriter: VideoWriter?
    
    var height: Int = 1980
    var width: Int = 1080
    let sessionPreset = AVCaptureSessionPresetHigh
    
    func setup(previewView: UIImageView, recordingTime: Int64) {
        
        self.recordingTime = recordingTime
        
        let captureSession = AVCaptureSession()
        
        let videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        // framerate = 1/30
        videoDevice?.activeVideoMinFrameDuration = CMTimeMake(1, 30)
        let videoInput = try! AVCaptureDeviceInput(device: videoDevice)
        captureSession.addInput(videoInput)
        
        let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        let audioInput = try! AVCaptureDeviceInput(device: audioDevice)
        captureSession.addInput(audioInput)
        
        captureSession.sessionPreset = sessionPreset
        
        if let videoLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            
            videoLayer.frame = previewView.bounds
            videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewView.layer.addSublayer(videoLayer)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            captureSession.startRunning()
        }
    }
    
    func start() -> Bool {
        
        guard let videoWriter = videoWriter else {
            
            return false
        }
        
        videoWriter.start()
        return true
    }
    
    func pause() {
        
        videoWriter?.pause()
    }
    
    func stop() {
        
        videoWriter?.stop()
    }
}

// MARK: - Sample Buffer Delegate
extension VideoManager: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        let isVideo = captureOutput is AVCaptureVideoDataOutput
        
        if videoWriter != nil {
            
            if !isVideo,
                let fmt = CMSampleBufferGetFormatDescription(sampleBuffer),
                let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fmt) {
                
                let channels = Int(asbd.pointee.mChannelsPerFrame)
                let samples = asbd.pointee.mSampleRate
                self.videoWriter = VideoWriter(height: height, width: width, channels: channels, samples: samples, recordingTime: recordingTime)
                self.videoWriter?.delegate = self
            }
        }
        
        // 音は音楽が再生されている間は保存しない
        guard isVideo || !MusicManager.shared.status else {
            
            return
        }
        
        videoWriter?.write(sampleBuffer: sampleBuffer, isVideo: isVideo)
    }
}

// MARK: - Video Writer Delegate
extension VideoManager: VideoWriterDelegate {
    
    func change(recordingTime time: Int64) {
        
        delegate?.change(recordingTime: time)
    }
    
    func finish(fileUrl: URL) {
        
        delegate?.finish(fileUrl: fileUrl, completion: { [weak self] in
            
            self?.videoWriter = nil
        })
    }
}
