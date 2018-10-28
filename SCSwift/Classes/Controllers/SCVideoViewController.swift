//
//  SCVideoViewController.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 28/10/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

public enum VideoAspect: Int {
    case resizeAspectFill = 1
    case resizeAspect = 2
    case resize = 3
}

public protocol SCVideoViewControllerDelegate : class {
    func videoReadyToPlay()
    func videoDidPlay()
    func videoDidPause()
    func videoDidStop()
    func videoDidFinishPlay()
    func videoDidFailLoad()
    func videoDidUpdateProgress(currentTime: TimeInterval, duration: TimeInterval)
}

open class SCVideoViewController: SCMediaViewController, SCMediaPlayerViewControllerDelegate {
    
    // MARK: - Xibs
    
    private var videoView: UIView!
    private var imgPlaceholder: UIImageView!
    private var spinner: UIActivityIndicatorView!
    
    // MARK: - Constants & Variables
    
    internal var player: AVPlayer?
    internal var playerLayer: AVPlayerLayer?
    
    private var videoAspect: VideoAspect = .resizeAspectFill
    
    private var didFirstLoad: Bool = false
    public var autoPlay: Bool = false
    public var loop: Bool = false
    
    public weak var videoDelegate: SCVideoViewControllerDelegate?
    
    private var timeObserver: Any?
    
    // MARK: - Initialization
    
    public convenience init(media: SCMedia, autoPlay: Bool, loop: Bool, delegate: SCVideoViewControllerDelegate?) {
        self.init()
        
        self.media = media
        self.autoPlay = autoPlay
        self.loop = loop
        self.videoDelegate = delegate
    }
    
    // MARK: - UIViewController Methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        videoView = UIView(frame: view.frame)
        view.addSubview(videoView)
        
        imgPlaceholder = UIImageView(frame: videoView.frame)
        videoView.addSubview(imgPlaceholder)
        
        spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.color = .lightGray
        spinner.center = videoView.center
        spinner.startAnimating()
        videoView.addSubview(imgPlaceholder)
        
        spinner.hidesWhenStopped = true
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        videoDelegate?.videoDidUpdateProgress(currentTime: currentTime, duration: duration)
        if !didFirstLoad {
            self.initialize()
        } else {
            if player?.currentItem != nil {
                self.addObservers()
            }
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.pause()
        self.removeObservers()
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        videoView.frame = view.frame
        imgPlaceholder.frame = videoView.frame
        spinner.center = videoView.center
        playerLayer?.frame = videoView.frame
        /*
         if UIDevice.isPortrait {
         videoAspect = .resizeAspect
         } else {
         videoAspect = .resizeAspectFill
         }*/
        videoAspect = .resizeAspect
        
        switch(videoAspect){
        case .resizeAspectFill: playerLayer?.videoGravity = .resizeAspectFill
        case .resizeAspect: playerLayer?.videoGravity = .resizeAspect
        case .resize: playerLayer?.videoGravity = .resize
        }
    }
    
    // MARK: - Player Methods
    
    func addObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlay(notification:)),
                                               name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        player?.addObserver(self, forKeyPath: "status", options: [], context: nil)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 2), queue: DispatchQueue.main) { (time) in
            self.videoDelegate?.videoDidUpdateProgress(currentTime: time.seconds, duration: self.duration)
        }
    }
    
    func removeObservers() {
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        player?.removeObserver(self, forKeyPath: "status")
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
    public var isReadyToPlay : Bool {
        return player?.status == .readyToPlay
    }
    
    public var isPlaying : Bool {
        return player?.rate != 0
    }
    
    public var duration : TimeInterval {
        if let item = player?.currentItem {
            let seconds = item.duration.seconds
            return seconds.isNaN ? 0.0 : seconds
        }
        return 0.0
    }
    
    public var currentTime : TimeInterval {
        if let item = player?.currentItem {
            let seconds = item.currentTime().seconds
            return seconds.isNaN ? 0.0 : seconds
        }
        return 0.0
    }
    
    public var remainingTime : TimeInterval {
        return (self.duration - self.currentTime)
    }
    
    public func initialize() {
        
        guard let url = media.url else {
            return
        }
        
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = videoView.frame
        videoView.layer.addSublayer(playerLayer!)
        
        self.addObservers()
        self.loadThumbnail()
    }
    
    public func loadThumbnail() {
        
        guard let asset = player?.currentItem?.asset else {
            imgPlaceholder.image = nil
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            
            let assetImgGenerate = AVAssetImageGenerator(asset: asset)
            assetImgGenerate.appliesPreferredTrackTransform = true
            let time = CMTimeMakeWithSeconds(Float64(self.media.videoThumbnailSecond), preferredTimescale: 100)
            var thumbnail: UIImage?
            
            do {
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                thumbnail = UIImage(cgImage: img)
            } catch {
                
            }
            
            DispatchQueue.main.sync {
                self.imgPlaceholder.image = thumbnail
            }
        }
    }
    
    public func play() {
        player?.play()
        videoDelegate?.videoDidPlay()
    }
    
    public func play(from seconds: TimeInterval) {
        player?.seek(to: CMTime(seconds: seconds, preferredTimescale: 1000), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        self.play()
        videoDelegate?.videoDidPlay()
    }
    
    public func pause() {
        player?.pause()
        videoDelegate?.videoDidPause()
    }
    
    public func stop() {
        player?.pause()
        player?.seek(to: CMTime.zero)
        videoDelegate?.videoDidStop()
    }
    
    @objc public func playerDidFinishPlay(notification: Notification) {
        self.stop()
        videoDelegate?.videoDidFinishPlay()
        if loop {
            play()
        }
    }
    
    // MARK: - SCMediaPlayerViewController Delegate
    
    public func mediaPlayerDidTapPlay() {
        
        if isPlaying {
            self.pause()
        } else {
            self.play()
        }
    }
    
    public func mediaPlayerDidTapPause() {
        self.pause()
    }
    
    public func mediaPlayerDidTapStop() {
        self.stop()
    }
    
    public func mediaPlayerDidChangeTime(seconds: TimeInterval) {
        self.play(from: seconds)
    }
    
    // MARK: - Other Methods
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (object as? AVPlayer) == player {
            
            if keyPath == "status" {
                if player?.status == .readyToPlay {
                    let playable = player?.currentItem?.asset.isPlayable
                    if playable == true {
                        spinner.stopAnimating()
                        imgPlaceholder.isHidden = true
                        videoDelegate?.videoReadyToPlay()
                        if autoPlay && !didFirstLoad {
                            self.play()
                            didFirstLoad = true
                        }
                    } else {
                        videoDelegate?.videoDidFailLoad()
                        self.delegate?.mediaDidFailLoad(media: self.media)
                    }
                }
            }
        }
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
