//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Shawn Burlew on 2/2/16.
//  Copyright © 2016 Shawn Burlew. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController {
  
  let stopRecordingIdentifier = "stopRecording"
  
  let audioSession = AVAudioSession.sharedInstance()
  var audioRecorder: AVAudioRecorder!
  var recordedAudio: RecordedAudio!

  @IBOutlet weak var recordingInProgress: UILabel!
  @IBOutlet weak var recordButton: UIButton!
  @IBOutlet weak var pauseResumeButton: UIButton!
  @IBOutlet weak var stopButton: UIButton!
  
  var audioIsPaused = false
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.pauseResumeButton.hidden = true
    self.stopButton.hidden = true
    self.recordButton.enabled = true
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard segue.identifier == self.stopRecordingIdentifier else {
      return
    }
    
    let playSoundsVC = segue.destinationViewController as! PlaySoundsViewController
    playSoundsVC.receivedAudio = sender as! RecordedAudio
  }

  @IBAction func recordAudio(sender: AnyObject) {
    self.recordButton.enabled = false
    self.stopButton.hidden = false
    self.pauseResumeButton.hidden = false
    
    self.recordingInProgress.hidden = false
    self.recordingInProgress.text = "Recording in progress."
    
    let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    let recordingName = "my_audio.wav"
    
    let pathArray = [dirPath, recordingName]
    let filePath = NSURL.fileURLWithPathComponents(pathArray)
    
    try! self.audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
    
    try! audioRecorder = AVAudioRecorder(URL: filePath!, settings: [:])
    self.audioRecorder.delegate = self
    self.audioRecorder.meteringEnabled = true
    self.audioRecorder.prepareToRecord()
    self.audioRecorder.record()
  }
  
  @IBAction func pauseResumeAudio(sender: AnyObject) {
    if self.audioIsPaused {
      // Resume audio recording
      dispatch_async(dispatch_get_main_queue()) {
        self.pauseResumeButton.imageView!.image = UIImage(named: "pause")
        self.recordingInProgress.text = "Recording in progress."
      }
      self.audioRecorder.record()
      self.audioIsPaused = false
    } else {
      // Pause audio recording
      
      dispatch_async(dispatch_get_main_queue()) {
        self.pauseResumeButton.imageView!.image = UIImage(named: "resume")
        self.recordingInProgress.text = "Recording paused."
      }
      self.audioRecorder.pause()
      self.audioIsPaused = true
    }
  }
  
  @IBAction func stopRecordingAudio(sender: AnyObject) {
    self.audioRecorder.stop()
    try! self.audioSession.setActive(false)
    self.recordButton.enabled = true
    self.recordingInProgress.hidden = true
    self.stopButton.hidden = true
    self.pauseResumeButton.hidden = true
  }
}

extension RecordSoundsViewController: AVAudioRecorderDelegate {
  func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
    guard flag else {
      print("Experienced an error while recording.")
      return
    }
    
    self.recordedAudio = RecordedAudio(filePathURL: recorder.url, title: recorder.url.lastPathComponent!)
    self.performSegueWithIdentifier(self.stopRecordingIdentifier, sender: recordedAudio)
  }
}