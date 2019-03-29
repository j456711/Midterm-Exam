//
//  ViewController.swift
//  Midterm-Exam
//
//  Created by 渡邊君 on 2019/3/29.
//  Copyright © 2019 Yu-Hsin Yeh. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var controlButtonsView: UIView!
    
    @IBOutlet weak var blackView: UIView!
    
    @IBOutlet weak var emptyLabel: UILabel!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var playTimeLabel: UILabel!
    
    @IBOutlet weak var endTimeLabel: UILabel!
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var volumeButton: UIButton!
    
    @IBOutlet weak var rewindButton: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var forwardButton: UIButton!
    
    @IBOutlet weak var landscapeButton: UIButton!
    
    @IBAction func sliderMoved(_ sender: UISlider) {
        
        let seconds = Int64(slider.value)
        
        let targetTime = CMTimeMake(value: seconds, timescale: 1)
        
        player?.seek(to: targetTime)
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
    
        if textField.text == "https://s3-ap-northeast-1.amazonaws.com/mid-exam/Video/taeyeon.mp4" {
            
            loadVideo()
            
            playButton.setImage(UIImage(named: "stop"), for: .normal)
            
        } else {
            
            playerLayer?.removeFromSuperlayer()
        }
    }
    
    @IBAction func volumeButtonPressed(_ sender: UIButton) {
        
        if volumeButton.imageView?.image == UIImage(named: "volume_up") {
            
            player?.isMuted = true
            
            volumeButton.setImage(UIImage(named: "volume_off"), for: .normal)
            
        } else {
            
            player?.isMuted = false
            
            volumeButton.setImage(UIImage(named: "volume_up"), for: .normal)
            
        }
    }
    
    @IBAction func rewindButtonPressed(_ sender: UIButton) {
        
        let playerCurrentTime = CMTimeGetSeconds(player!.currentTime())
        
        var newTime = playerCurrentTime - seekDuration
        
        if newTime < 0 {
            
            newTime = 0
        }
        
        let newTime2 = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        
        player?.seek(to: newTime2, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        
        detectIfVideoIsPlaying()
    }
    
    @IBAction func forwardButtonPressed(_ sender: UIButton) {
    
        guard let duration = player?.currentItem?.duration else { return }
        
        let playerCurrentTime = CMTimeGetSeconds(player!.currentTime())
        
        let newTime = playerCurrentTime + seekDuration
        
        if newTime < (CMTimeGetSeconds(duration) - seekDuration) {
            
            let newTime2 = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            
            player?.seek(to: newTime2, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        }
    }
    
    @IBAction func landscapeButtonPressed(_ sender: UIButton) {
        
        navigationController?.isNavigationBarHidden = true
        
        
        textField.isHidden = true
        
        
        blackView.backgroundColor = .black
        
        
        emptyLabel.textColor = .white
        
        emptyLabel.transform = CGAffineTransform(rotationAngle: .pi / 2)
        
        
        self.view.bringSubviewToFront(controlButtonsView)
        
        
        playerLayer?.setAffineTransform(CGAffineTransform(rotationAngle: .pi / 2))
        
        playerLayer?.frame = self.view.bounds
        
        playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        rotateControlButtonsView()
        
        renderItems()
    }
    
    var player: AVPlayer?
    
    var playerItem: AVPlayerItem?
    
    var playerLayer: AVPlayerLayer?
    
    var seekDuration: Float64 = 10
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        slider.value = 0
    }
    
    
    func loadVideo() {
        
        guard let videoUrl = URL(string: "https://s3-ap-northeast-1.amazonaws.com/mid-exam/Video/taeyeon.mp4") else { return }
        
        player = AVPlayer(url: videoUrl)
        
        playerLayer = AVPlayerLayer(player: player)
        
        setUpPlayerLayer()
        
        fetchDuration()
        
        fetchCurrentDuration()
        
        player!.play()
    }
    
    func setUpPlayerLayer() {
        
        playerLayer?.frame = self.view.bounds
        
        self.view.layer.addSublayer(playerLayer!)
    }
    
    func fetchDuration() {
        
        guard let duration = player!.currentItem?.asset.duration else { return }
        
        let seconds = CMTimeGetSeconds(duration)
        
        endTimeLabel.text = formatConversion(time: seconds)
        
        slider.maximumValue = Float(seconds)
        
        slider.isContinuous = true
    }
    
    func fetchCurrentDuration() {
        
        player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { (CMTime) in
            
            if self.player?.currentItem?.status == .readyToPlay {
                
                let currentTime = CMTimeGetSeconds(self.player!.currentTime())
                
                self.slider.value = Float(currentTime)
                
                self.playTimeLabel.text = self.formatConversion(time: currentTime)
            }
        })
    }
    
    func detectIfVideoIsPlaying() {
        
        if player?.rate == 0 {
            
            playButton.setImage(UIImage(named: "stop"), for: .normal)
            
            player!.play()
            
        } else {
            
            playButton.setImage(UIImage(named: "play_button"), for: .normal)
            
            player!.pause()
        }
    }
    
    func rotateControlButtonsView() {
                
        controlButtonsView.transform = CGAffineTransform(rotationAngle: .pi / 2)
    }
}

extension ViewController {
    
    // Helper Method
    func formatConversion(time:Float64) -> String {
        
        let songLength = Int(time)
        
        let minutes = Int(songLength / 60) // 求 songLength 的商，為分鐘數
        
        let seconds = Int(songLength % 60) // 求 songLength 的餘數，為秒數
        
        var time = ""
        
        if minutes < 10 {
            
            time = "0\(minutes):"
            
        } else {
            
            time = "\(minutes)"
            
        }
        
        if seconds < 10 {
            
            time += "0\(seconds)"
            
        } else {
            
            time += "\(seconds)"
            
        }
        
        return time
    }
    
    func renderItems() {
        
        let buttons = [ volumeButton,
                        rewindButton,
                        playButton,
                        forwardButton,
                        landscapeButton ]
        
        let images = [ UIImage(named: "fast_forward"),
                       UIImage(named: "full_screen_exit"),
                       UIImage(named: "play_button"),
                       UIImage(named: "rewind") ,
                       UIImage(named: "stop"),
                       UIImage(named: "volume_off"),
                       UIImage(named: "volume_up") ]
        
        for image in images {
            
            image?.withRenderingMode(.alwaysTemplate)
        }
        
        buttons[0]?.setImage(images[6], for: .normal)
        
        buttons[0]?.tintColor = .white
    }
}
