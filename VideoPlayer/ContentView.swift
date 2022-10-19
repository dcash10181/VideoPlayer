//
//  ContentView.swift
//  VideoPlayer
//
//  Created by Duane Cash on 10/19/22.
//

import SwiftUI
import AVKit
import AVFoundation

struct ContentView: View {
    
    private let videoPlayer = AVPlayer(url: URL(string:  "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8")!)
    
    private var videoPlayerItem: AVPlayerItem?
    @State var timeObserverToken: Any?
    
    var videoPlayEndPublisher = NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
    
    func addPeriodicTimeObserver() {
        // timer to notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        
        timeObserverToken = videoPlayer.addPeriodicTimeObserver(forInterval: time,
                                                                queue: .main) {
            time in
            // print playhead time to console
            print(time.string)
        }
    }
    
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            videoPlayer.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }

    var body: some View {
        VStack {
            VideoPlayer(player: videoPlayer)
                .onAppear() {
                    videoPlayer.play()
                    if videoPlayer.isPlaying {
                        print("Playback started")
                        addPeriodicTimeObserver()
                        
                    } else {
                        print("Playback stopped")
                    }
                }
                .onReceive(videoPlayEndPublisher) { (output) in
                    print("Playback stopped")
                }
                .onDisappear() {
                    removePeriodicTimeObserver()

                }
        }
        .padding()
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

extension CMTime {
    var seconds: Int {
        return Int(CMTimeGetSeconds(self))
    }
 
    var string: String {
        let value = self.seconds
        let hours = (value % 86400) / 3600
        let minutes = (value % 3600) / 60
        let seconds = (value % 3600) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
