//
//  ViewController.swift
//  UKSpeechRecognition
//
//  Created by Grzegorz Przybyła on 28/02/2018.
//  Copyright © 2018 Grzegorz Przybyła. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    var speechAudioRecognizer: SpeechAudioRecognizer = SpeechAudioRecognizer.shared
    
    @IBAction func didTapStartRecording(_ sender: UIButton) {
        statusLabel.text = "Recording..."
        speechAudioRecognizer.startRecording { [weak self] (result) in
            self?.statusLabel.text = "Recorded finished"
            switch result {
            case .failure(let error):
                print("Recognition finished with error: \(error)")
                self?.showPermisionsNotGrandedAlert()
            case .success(let value):
                print("Recognition succeed: \(value.bestTranscription.formattedString)")
                self?.showResult(value.bestTranscription.formattedString)
            }
        }
    }
    
    @IBAction func didTapFinishRecording(_ sender: UIButton) {
        speechAudioRecognizer.finishRecording()
    }
    
    private func showResult(_ result: String) {
        let alert = UIAlertController(title: "Success", message: "Speech recognition finished with result\n: \(result)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alert, sender: self)
    }
    
    private func showPermisionsNotGrandedAlert() {
        let alert = UIAlertController(title: "Error", message: "Permisions not granded", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alert, sender: self)
    }
    
}
