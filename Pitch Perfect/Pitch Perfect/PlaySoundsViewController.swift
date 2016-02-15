//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Shawn Burlew on 2/2/16.
//  Copyright © 2016 Shawn Burlew. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
  
  // Outlets
  @IBOutlet weak var slowButton: UIButton!
  @IBOutlet weak var fastButton: UIButton!
  @IBOutlet weak var chipmunkButton: UIButton!
  @IBOutlet weak var vaderButton: UIButton!
  @IBOutlet weak var echoButton: UIButton!
  @IBOutlet weak var reverbButton: UIButton!
  @IBOutlet weak var stopButton: UIButton!
  
  // Audio handlers
  var audioEngine: AVAudioEngine!
  var audioPlayer: AVAudioPlayer!
  var audioPlayerEchoReverb: AVAudioPlayer!
  var audioFile: AVAudioFile!
  
  var receivedAudio: RecordedAudio!
  let navBarTitle = "Sound Effects"
  var alreadyInstantiated = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = navBarTitle
    instantiateAudioObjects()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.instantiateAudioObjects()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    self.alreadyInstantiated = false
  }
  
  func instantiateAudioObjects() {
    // Only run this method once each time PlaySoundsViewController appears. The
    // first time the app runs, it will be invoked by viewDidLoad. After that,
    // it will be invoked by viewWillAppear.
    guard !alreadyInstantiated else {
      return
    }
    alreadyInstantiated = true
    
    let allButtons: [UIButton] = [
      self.slowButton,
      self.fastButton,
      self.chipmunkButton,
      self.vaderButton,
      self.echoButton,
      self.reverbButton
    ]
    
    self.navigationController!.navigationItem.title = self.navBarTitle
    self.audioEngine = AVAudioEngine()
    
    // If receivedAudio doesn't exist or has a nil filePathURL, then prevent the
    // user from using any sound effects.
    guard self.receivedAudio != nil && self.receivedAudio.filePathURL != nil else {
      self.disableButtons(allButtons)
      return
    }
    
    // If primary audio player isn't properly instantiated, then prevent user
    // from using any sound effects.
    do {
      self.audioPlayer = try AVAudioPlayer(contentsOfURL: self.receivedAudio.filePathURL)
    } catch {
      self.disableButtons(allButtons)
      return
    }
    self.audioPlayer.enableRate = true
    
    // If audio file isn't properly instantiated, then prevent user from using
    // effects that use it (chipmunk, vader, echo, or reverb).
    do {
      self.audioFile = try AVAudioFile(forReading: self.receivedAudio.filePathURL)
    } catch {
      self.disableButtons([
        self.chipmunkButton,
        self.vaderButton,
        self.echoButton,
        self.reverbButton
        ])
    }
    
    // If secondary audio player isn't properly instantiated, then prevent user
    // from using echo or reverb effects.
    do {
      self.audioPlayerEchoReverb = try AVAudioPlayer(contentsOfURL: self.receivedAudio.filePathURL)
    } catch {
      self.disableButtons([
        self.echoButton,
        self.reverbButton
        ])
    }
  }

  @IBAction func playSoundSlow(sender: AnyObject) {
    self.playAudio(withRate: 0.5)
  }
  
  @IBAction func playSoundFast(sender: AnyObject) {
    self.playAudio(withRate: 1.5)
  }
  
  @IBAction func playSoundChipmunk(sender: AnyObject) {
    self.playAudioWithPitch(1000.0)
  }
  
  @IBAction func playSoundVader(sender: AnyObject) {
    self.playAudioWithPitch(-700.0)
  }
  
  @IBAction func playSoundEcho(sender: AnyObject) {
    self.audioPlayer.stop()
    self.audioPlayer.currentTime = 0.0
    
    // Configure secondary audio player with half the volume of the primary
    // audio player.
    self.audioPlayerEchoReverb.stop()
    self.audioPlayerEchoReverb.currentTime = 0.0
    self.audioPlayerEchoReverb.volume = self.audioPlayer.volume * 0.5
    
    // Play secondary audio player at a specific time interval after the primary
    // audio player.
    self.audioPlayer.play()
    self.audioPlayerEchoReverb.playAtTime(self.audioPlayerEchoReverb.deviceCurrentTime + 0.1)
  }
  
  @IBAction func playSoundReverb(sender: AnyObject) {
  }
  
  func playAudioWithPitch(pitch: Float) {
    self.audioPlayer.stop()
    self.audioEngine.stop()
    self.audioEngine.reset()
    
    let audioPlayerNode = AVAudioPlayerNode()
    self.audioEngine.attachNode(audioPlayerNode)
    
    let changePitchEffect = AVAudioUnitTimePitch()
    changePitchEffect.pitch = pitch
    self.audioEngine.attachNode(changePitchEffect)
    
    self.audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
    self.audioEngine.connect(changePitchEffect, to: self.audioEngine.outputNode, format: nil)
    
    audioPlayerNode.scheduleFile(self.audioFile, atTime: nil, completionHandler: nil)
    try! self.audioEngine.start()
    
    audioPlayerNode.play()
  }
  
  func playAudio(withRate rate: Float) {
    self.audioPlayer.currentTime = 0.0
    self.audioPlayer.rate = rate
    self.audioPlayer.play()
    self.audioPlayer.updateMeters()
  }
  
  @IBAction func stopSound(sender: AnyObject) {
    self.audioEngine.stop()
    self.audioPlayer.stop()
    self.audioPlayer.currentTime = 0.0
    self.audioPlayerEchoReverb.stop()
    self.audioPlayerEchoReverb.currentTime = 0.0
  }
  
  func disableButtons(buttons: [UIButton]) {
    for button in buttons {
      button.enabled = false
    }
  }
  
  func enableButtons(buttons: [UIButton]) {
    for button in buttons {
      button.enabled = true
    }
  }
}
