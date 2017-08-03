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
    
    var height: Int = 1080
    var width: Int = 1980
    let sessionPreset = AVCaptureSessionPresetHigh
    
    let lockQueue = DispatchQueue(label: "com.dev.touyou.LockQueue")
    let recordingQueue = DispatchQueue(label: "com.dev.touyou.RecordingQueue")
    var isCapturing = false
    var isPaused = false
    var isDiscontinue = false
    var timeOffset = CMTimeMake(0, 0)
    var lastAudioPts: CMTime?
    let captureSession = AVCaptureSession()
    
    func setup(previewView: UIImageView, recordingTime: Int64, completion: @escaping () -> Void) {
        
        self.recordingTime = recordingTime
        
        let videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        // framerate = 1/30
        videoDevice?.activeVideoMinFrameDuration = CMTimeMake(1, 30)
        let videoInput = try! AVCaptureDeviceInput(device: videoDevice)
        captureSession.addInput(videoInput)
        
        let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        let audioInput = try! AVCaptureDeviceInput(device: audioDevice)
        captureSession.addInput(audioInput)
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: recordingQueue)
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        captureSession.addOutput(videoDataOutput)
        let videoConnection = videoDataOutput.connection(withMediaType: AVMediaTypeVideo)!
        videoConnection.videoOrientation = .landscapeRight
        
        let audioDataOutput = AVCaptureAudioDataOutput()
        audioDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        captureSession.addOutput(audioDataOutput)
        
        captureSession.sessionPreset = sessionPreset
        
        if let videoLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            
            videoLayer.frame = previewView.bounds
            videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoLayer.connection.videoOrientation = .landscapeRight
            previewView.layer.addSublayer(videoLayer)
        }
        
        completion()
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.captureSession.startRunning()
        }
    }
    
    func shutdown() {
        
        captureSession.stopRunning()
    }
    
    func start() {
        
        lockQueue.sync {
            
            if !self.isCapturing {
                
                self.isPaused = false
                self.isDiscontinue = false
                self.isCapturing = true
                self.timeOffset = CMTimeMake(0, 0)
            }
        }
    }
    
    func stop() {
        
        lockQueue.sync {
            
            if self.isCapturing {
                
                self.isCapturing = false
                self.videoWriter?.finish()
            }
        }
    }
    
    func pause() {
        
        lockQueue.sync {
            
            self.isPaused = true
            self.isDiscontinue = true
        }
    }
    
    func resume() {
        
        lockQueue.sync {
            
            if self.isCapturing {
                
                self.isPaused = false
            }
        }
    }
    
    func ajustTimeStamp(_ sample: CMSampleBuffer, offset: CMTime) -> CMSampleBuffer {
        
        var count: CMItemCount = 0
        CMSampleBufferGetSampleTimingInfoArray(sample, 0, nil, &count);
        var info = [CMSampleTimingInfo](repeating: CMSampleTimingInfo(duration: CMTimeMake(0, 0), presentationTimeStamp: CMTimeMake(0, 0), decodeTimeStamp: CMTimeMake(0, 0)), count: count)
        CMSampleBufferGetSampleTimingInfoArray(sample, count, &info, &count);
        
        for i in 0..<count {
            
            info[i].decodeTimeStamp = CMTimeSubtract(info[i].decodeTimeStamp, offset);
            info[i].presentationTimeStamp = CMTimeSubtract(info[i].presentationTimeStamp, offset);
        }
        
        var out: CMSampleBuffer?
        CMSampleBufferCreateCopyWithNewTiming(nil, sample, count, &info, &out);
        return out!
    }
    
    //    func start() -> Bool {
    //
    //        guard let videoWriter = videoWriter else {
    //
    //            return false
    //        }
    //
    //        videoWriter.start()
    //        return true
    //    }
    //
    //    func pause() {
    //
    //        videoWriter?.pause()
    //    }
    //
    //    func stop() {
    //
    //        videoWriter?.stop()
    //    }
}

// MARK: - Sample Buffer Delegate
extension VideoManager: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        lockQueue.sync {
            
            if !self.isCapturing || self.isPaused {
                return
            }
            
            let isVideo = captureOutput is AVCaptureVideoDataOutput
            
            if self.videoWriter == nil && !isVideo {
                
                let fmt = CMSampleBufferGetFormatDescription(sampleBuffer)
                let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fmt!)
                
                let channels = Int((asbd?.pointee.mChannelsPerFrame)!)
                let samples = asbd?.pointee.mSampleRate
                self.videoWriter = VideoWriter(height: height, width: width, channels: channels, samples: samples!, recordingTime: recordingTime)
                self.videoWriter?.delegate = self
            }
            
            if self.isDiscontinue {
                
                if isVideo {
                    
                    return
                }
                
                var pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                
                let isAudioPtsValid = self.lastAudioPts!.flags.intersection(CMTimeFlags.valid)
                if isAudioPtsValid.rawValue != 0 {
                    
                    let isTimeOffsetPtsValid = self.timeOffset.flags.intersection(CMTimeFlags.valid)
                    if isTimeOffsetPtsValid.rawValue != 0 {
                        
                        pts = CMTimeSubtract(pts, self.timeOffset);
                    }
                    let offset = CMTimeSubtract(pts, self.lastAudioPts!);
                    
                    if self.timeOffset.value == 0 {
                        
                        self.timeOffset = offset;
                    } else {
                        
                        self.timeOffset = CMTimeAdd(self.timeOffset, offset);
                    }
                }
                self.lastAudioPts!.flags = CMTimeFlags()
                self.isDiscontinue = false
            }
            
            var buffer = sampleBuffer
            if self.timeOffset.value > 0 {
                buffer = self.ajustTimeStamp(sampleBuffer, offset: self.timeOffset)
            }
            
            if !isVideo {
                var pts = CMSampleBufferGetPresentationTimeStamp(buffer!)
                let dur = CMSampleBufferGetDuration(buffer!)
                if (dur.value > 0)
                {
                    pts = CMTimeAdd(pts, dur)
                }
                self.lastAudioPts = pts
            }
            
            self.videoWriter?.write(buffer!, isVideo: isVideo)
        }
        
        //        let isVideo = captureOutput is AVCaptureVideoDataOutput
        //
        //        if videoWriter == nil {
        //
        //            if !isVideo,
        //                let fmt = CMSampleBufferGetFormatDescription(sampleBuffer),
        //                let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fmt) {
        //
        //                let channels = Int(asbd.pointee.mChannelsPerFrame)
        //                let samples = asbd.pointee.mSampleRate
        //                self.videoWriter = VideoWriter(height: height, width: width, channels: channels, samples: samples, recordingTime: recordingTime)
        //                self.videoWriter?.delegate = self
        //            }
        //        }
        //
        //        videoWriter?.write(sampleBuffer, isVideo: isVideo)
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
