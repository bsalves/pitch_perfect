//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Bruno Alves on 01/10/18.
//  Copyright © 2018 Bruno Alves. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    
    //MARK: - Properties
    
    var audioRecorder: AVAudioRecorder!
    var recording = false
    var defaultTapToRecordLabel: String!
    
    //MARK: - Lyfecicle/Segue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultTapToRecordLabel = recordingLabel.text
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recording = false
        configureUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
    //MARK: - UI Methods
    
    func configureUI() {
        if recording {
            recordButton.setImage(UIImage(named: "Stop"), for: .normal)
            recordingLabel.text = "Gravando..."
        } else {
            recordButton.setImage(UIImage(named: "Record"), for: .normal)
            recordingLabel.text = defaultTapToRecordLabel
        }
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Erro!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    //MARK: - IBActions
    
    @IBAction func record(_ sender: Any) {
        recording = !recording
        if recording {
            startRecording()
        } else {
            stopRecording()
        }
        configureUI()
    }
    
    //MARK: - Internal methods
    
    func startRecording() {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        guard let filePath = URL(string: pathArray.joined(separator: "/")) else {
            showError(message: "Erro ao criar um diretório para o audio.")
            return
        }
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath, settings: [:])
        audioRecorder.delegate = self
        
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    func stopRecording() {
        configureUI()
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
}

extension RecordSoundsViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            showError(message: "Erro ao gravar o audio.")
        }
    }
    
}
