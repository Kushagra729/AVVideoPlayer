//
//  VideoVC.swift
//  AVVideoPlayer
//
//  Created by Kushagra Chandra
//

import UIKit
import AVKit
protocol VideoVCDelegate {
    func sendThumbNil(thumNil: UIImage)
}
import UIKit

class VideoVC: UIViewController {
    @IBOutlet weak var videoView: UIView!
    var setUrl = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"
    var player: AVPlayer?
    var playerController: AVPlayerViewController?
    var isPlaying = false
    var playerItem:AVPlayerItem?
    let playBtn:UIButton = UIButton()
    let viewControl = UIView()
    var timer = Timer()
    var number = 0
    var delegate:VideoVCDelegate?
    var _isPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setVideo(url: setUrl)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player?.pause()
    }
    
    func setVideo(url: String) {
//        let videoURL = URL(string: url)!
        let videoURL = URL(string: url)!

        let playerItem:AVPlayerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)
        let playerLayer=AVPlayerLayer(player: player!)
        playerLayer.frame=CGRect(x: -35, y: 0, width: 420, height: 230)
        self.videoView.layer.addSublayer(playerLayer)
        try! AVAudioSession.sharedInstance().setCategory(.playback)
        player?.play()
        
        //MARK:- Skip Button
        let button:UIButton = UIButton()
        button.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 11)
        button.titleLabel?.textAlignment = .left
        button.backgroundColor = .blue
        button.setTitle("Skip >>", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)
        self.videoView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal, toItem: self.videoView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: self.videoView, attribute: .bottom, multiplier: 1, constant: -35).isActive = true
        NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 70).isActive = true
        NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 25).isActive = true
        
        //MARK:- Controller
        let bottomSide = CGFloat(-3)
        viewControl.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.videoView.addSubview(viewControl)
        viewControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: viewControl, attribute: .trailing, relatedBy: .equal, toItem: self.videoView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: viewControl, attribute: .bottom, relatedBy: .equal, toItem: self.videoView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: viewControl, attribute: .leading, relatedBy: .equal, toItem: self.videoView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: viewControl, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 30).isActive = true
        
        //MARK:- Slider
        let playbackSlider = UISlider()
        playbackSlider.minimumValue = 0
        playbackSlider.setThumbImage(UIImage(named: "icon_slider_thumb"), for: .normal)
        let duration : CMTime = playerItem.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        playbackSlider.maximumValue = Float(seconds)
        playbackSlider.isContinuous = true
        playbackSlider.tintColor = .white
        playbackSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
        
        viewControl.addSubview(playbackSlider)
        playbackSlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: playbackSlider, attribute: .leading, relatedBy: .equal, toItem: self.videoView, attribute: .leading, multiplier: 1, constant: 70).isActive = true
        NSLayoutConstraint(item: playbackSlider, attribute: .trailing, relatedBy: .equal, toItem: self.videoView, attribute: .trailing, multiplier: 1, constant: -60).isActive = true
        NSLayoutConstraint(item: playbackSlider, attribute: .bottom, relatedBy: .equal, toItem: self.videoView, attribute: .bottom, multiplier: 1, constant: bottomSide).isActive = true
        NSLayoutConstraint(item: playbackSlider, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 25).isActive = true
        
        //MARK:- Play Button
        playBtn.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 13)
        playBtn.titleLabel?.textAlignment = .center
        playBtn.setImage(UIImage(named: "icon_pause" ), for: .normal)
        playBtn.setTitleColor(.black, for: .normal)
        playBtn.addTarget(self, action:#selector(self.playPauseBtn), for: .touchUpInside)
        viewControl.addSubview(playBtn)
        playBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: playBtn, attribute: .leading, relatedBy: .equal, toItem: self.videoView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: playBtn, attribute: .bottom, relatedBy: .equal, toItem: self.videoView, attribute: .bottom, multiplier: 1, constant: bottomSide).isActive = true
        NSLayoutConstraint(item: playBtn, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 25).isActive = true
        NSLayoutConstraint(item: playBtn, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 25).isActive = true
        
        //MARK:- Starting Time Button
        let startTimeBtn:UIButton = UIButton()
        startTimeBtn.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 13)
        startTimeBtn.titleLabel?.textAlignment = .center
        startTimeBtn.setTitle("00:00", for: .normal)
        startTimeBtn.setTitleColor(.white, for: .normal)
        viewControl.addSubview(startTimeBtn)
        startTimeBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: startTimeBtn, attribute: .leading, relatedBy: .equal, toItem: self.videoView, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: startTimeBtn, attribute: .bottom, relatedBy: .equal, toItem: self.videoView, attribute: .bottom, multiplier: 1, constant: bottomSide).isActive = true
        NSLayoutConstraint(item: startTimeBtn, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 50).isActive = true
        NSLayoutConstraint(item: startTimeBtn, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 25).isActive = true
        
        //MARK:- End Time Button
        let endTimeBtn:UIButton = UIButton()
        endTimeBtn.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 13)
        endTimeBtn.titleLabel?.textAlignment = .center
        endTimeBtn.setTitle("00:00", for: .normal)
        endTimeBtn.setTitleColor(.white, for: .normal)
        viewControl.addSubview(endTimeBtn)
        endTimeBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: endTimeBtn, attribute: .trailing, relatedBy: .equal, toItem: self.videoView, attribute: .trailing, multiplier: 1, constant: -8).isActive = true
        NSLayoutConstraint(item: endTimeBtn, attribute: .bottom, relatedBy: .equal, toItem: self.videoView, attribute: .bottom, multiplier: 1, constant: bottomSide).isActive = true
        NSLayoutConstraint(item: endTimeBtn, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 50).isActive = true
        NSLayoutConstraint(item: endTimeBtn, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 25).isActive = true
        
        
        player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main, using: { (time) in
            if self.player!.currentItem?.status == .readyToPlay {
                self._isPlaying = true
                let currentTime = CMTimeGetSeconds(self.player!.currentTime())
                let secs = Int(currentTime)
                let time = NSString(format: "%02d:%02d", secs/60, secs%60) as String
                startTimeBtn.setTitle(time, for: .normal)
                
                let duration : CMTime = playerItem.asset.duration
                let seconds : Float64 = CMTimeGetSeconds(duration)
                playbackSlider.value = Float(currentTime)
                playbackSlider.maximumValue = Float(seconds)
                
                let fullTime = NSString(format: "%02d:%02d", Int(seconds)/60, Int(seconds)%60) as String
                endTimeBtn.setTitle(fullTime, for: .normal)
                
                DispatchQueue.main.async {
                    if startTimeBtn.titleLabel?.text == endTimeBtn.titleLabel?.text{
                        print("\(time)")
                        self.dismiss(animated: false, completion: nil)
                    }
                }
            }else {
            }
            
        }
        )
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.videoView.addGestureRecognizer(tap)
        resetTime()
    }
    
    func resetTime(){
        number = 0
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fire), userInfo: nil, repeats: true)
    }
    
    @objc func fire()
    {
        number += 1
        if number == 10{
            if _isPlaying == false{
                
            }
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if viewControl.isHidden{
            self.viewControl.fadeIn()
        }else{
            self.viewControl.fadeOut()
        }
        resetTime()
    }
    
    @objc func playPauseBtn(){
        isPlaying = !isPlaying
        if isPlaying{
            player?.pause()
            playBtn.setImage(UIImage(named: "icon_play" ), for: .normal)
        }else{
            player?.play()
            playBtn.setImage(UIImage(named: "icon_pause" ), for: .normal)
        }
        resetTime()
    }
    
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider){
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        player!.seek(to: targetTime)
        
        if isPlaying{
            player?.pause()
            playBtn.setImage(UIImage(named: "icon_play" ), for: .normal)
        }else{
            player?.play()
            playBtn.setImage(UIImage(named: "icon_pause" ), for: .normal)
        }
        resetTime()
    }
    
    @objc func buttonClicked() {
        self.player?.pause()
        self.dismiss(animated: false, completion: nil)
        
    }
    
    @objc func finishVideo(){
        self.dismiss(animated: false, completion: nil)
    }
}

extension UIView {
    func fadeIn(duration: TimeInterval = 0.4, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in }) {
        self.alpha = 0.0
        
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
            self.isHidden = false
            self.alpha = 1.0
        }, completion: completion)
    }
    
    func fadeOut(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in }) {
        self.alpha = 1.0
        
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
            self.alpha = 0.0
        }) { (completed) in
            self.isHidden = true
            completion(true)
        }
    }
}


