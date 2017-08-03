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
    
//    fileprivate var lastTime: CMTime!
//    fileprivate var offsetTime = kCMTimeZero
//    
//    fileprivate var _recordingTime: Int64 = 0
//    var recordingTime: CMTime {
//        
//        get {
//            
//            return CMTimeSubtract(lastTime, offsetTime)
//        }
//    }
//    
//    
//    fileprivate enum Status {
//        case start
//        case write
//        case pause
//        case restart
//        case end
//    }
//    fileprivate var status: Status = .start
    
    init(height: Int, width: Int, channels: Int, samples: Float64, recordingTime: Int64) {
//        self._recordingTime = recordingTime
        
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
            
            if writer.status == AVAssetWriterStatus.unknown {
                
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

    
//    func write(sampleBuffer buff: CMSampleBuffer, isVideo: Bool) {
//        
//        if status == .start || status == .end || status == .pause {
//            
//            return
//        }
//        
//        if status == .restart {
//            
//            let timeStamp = CMSampleBufferGetPresentationTimeStamp(buff)
//            let spanTime = CMTimeSubtract(timeStamp, lastTime)
//            offsetTime = CMTimeAdd(offsetTime, spanTime)
//            status = .write
//        }
//        
//        if CMSampleBufferDataIsReady(buff) {
//            
//            if isVideo && writer.status == .unknown {
//                
//                offsetTime = CMSampleBufferGetPresentationTimeStamp(buff)
//                writer.startWriting()
//                writer.startSession(atSourceTime: kCMTimeZero)
//            }
//            
//            if writer.status == .writing {
//                
//                // Offset分だけ調整
//                var copyBuffer: CMSampleBuffer?
//                var count: CMItemCount = 1
//                var info = CMSampleTimingInfo()
//                CMSampleBufferGetSampleTimingInfoArray(buff, count, &info, &count)
//                info.presentationTimeStamp = CMTimeSubtract(info.presentationTimeStamp, offsetTime)
//                CMSampleBufferCreateCopyWithNewTiming(kCFAllocatorDefault, buff, 1, &info, &copyBuffer)
//                // 最後のデータの時間を保存
//                lastTime = CMSampleBufferGetPresentationTimeStamp(buff)
//                let duration = CMSampleBufferGetDuration(buff)
//                if duration.value > 0 {
//                    
//                    lastTime = CMTimeAdd(lastTime, duration)
//                }
//                
//                if recordingTime > CMTimeMake(Int64(_recordingTime), 1) {
//                    
//                    writer.finishWriting {
//                        
//                        DispatchQueue.main.async {
//                            
//                            self.delegate?.finish(fileUrl: self.writer.outputURL)
//                        }
//                    }
//                    status = .end
//                    return
//                }
//                
//                if isVideo {
//                    
//                    if videoInput.isReadyForMoreMediaData {
//                        
//                        videoInput.append(copyBuffer!)
//                    }
//                } else {
//                    
//                    if audioInput.isReadyForMoreMediaData {
//                        
//                        audioInput.append(copyBuffer!)
//                    }
//                }
//            }
//        }
//    }
    
    func finish() {
        
        writer.finishWriting {
            
            DispatchQueue.main.async {
                
                self.delegate?.finish(fileUrl: self.writer.outputURL)
            }
        }
    }
    
//    func stop() {
//        
//        writer.finishWriting {
//            
//            DispatchQueue.main.async {
//                
//                self.delegate?.finish(fileUrl: self.writer.outputURL)
//            }
//        }
//        status = .end
//    }
//    
//    func pause() {
//        
//        if status == .write {
//            
//            status = .pause
//        }
//    }
//    
//    func start() {
//        
//        if status == .start {
//            
//            status = .write
//        } else if status == .pause {
//            
//            status = .restart
//        }
//    }
}
