//
//  VideoWriter.swift
//  MVMaker
//
//  Created by 藤井陽介 on 2017/08/02.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit
import AVFoundation

protocol VideoWriterDelegate: class {
    
    func change(recordingTime time: Int64)
    func finish(fileUrl: URL)
}

class VideoWriter: NSObject {
    
    weak var delegate: VideoWriterDelegate?
    
    fileprivate var writer: AVAssetWriter!
    fileprivate var videoInput: AVAssetWriterInput!
    fileprivate var audioInput: AVAssetWriterInput!
    
    init(height: Int, width: Int, channels: Int, samples: Float64) {
        
        // temporary files
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as String
        let filePath = "\(documentsDirectory)/temp.mov"
        if FileManager.default.fileExists(atPath: filePath) {
            
            try? FileManager.default.removeItem(atPath: filePath)
        }
        
        // Initialize Writer
        writer = try? AVAssetWriter(outputURL: URL(fileURLWithPath: filePath), fileType: AVFileTypeQuickTimeMovie)
        
        // Video Input
        let videoOutputSettings = [
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height
            ] as [String : Any]
        videoInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoOutputSettings)
        videoInput.expectsMediaDataInRealTime = true
        writer.add(videoInput)
        
        // Audio Input
        let audioOutputSettings = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVNumberOfChannelsKey: channels,
            AVSampleRateKey: samples,
            AVEncoderBitRateKey: 128000
            ] as [String : Any]
        audioInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: audioOutputSettings)
        audioInput.expectsMediaDataInRealTime = true
        writer.add(audioInput)
    }
    
    func write(_ sample: CMSampleBuffer, isVideo: Bool){
        
        if CMSampleBufferDataIsReady(sample) {
            
            if isVideo && writer.status == AVAssetWriterStatus.unknown {
                
                let startTime = CMSampleBufferGetPresentationTimeStamp(sample)
                writer.startWriting()
                writer.startSession(atSourceTime: startTime)
            }
            
            if writer.status == AVAssetWriterStatus.failed {
                
                return
            }
            
            if isVideo {
                
                if videoInput.isReadyForMoreMediaData {
                    
                    videoInput.append(sample)
                }
            }else{
                
                if audioInput.isReadyForMoreMediaData {
                    
                    audioInput.append(sample)
                }
            }
        }
    }

    func finish() {
        
        writer.finishWriting {
            
            DispatchQueue.main.async {
                
                self.delegate?.finish(fileUrl: self.writer.outputURL)
            }
        }
    }
}
