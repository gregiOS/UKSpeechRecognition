//
//  SpeechAudioRecognizer.swift
//  UKSpeechRecognition
//
//  Created by Grzegorz Przybyła on 01/03/2018.
//  Copyright © 2018 Grzegorz Przybyła. All rights reserved.
//

import Foundation
import Speech

class SpeechAudioRecognizer {
    
    enum RecognizerError: Error {
        case notPermited
        case recognitionInProgress
    }
    
    typealias RecognizerResult = (Result<SFSpeechRecognitionResult>) -> Void
    
    static let shared = SpeechAudioRecognizer()
    
    // MARK: Properties
    let completionQueue: DispatchQueue = .main
    let audioEngin = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer()!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private init() {
        let inputNode = audioEngin.inputNode
        let bus = 0
        let format = inputNode.inputFormat(forBus: bus)
        inputNode.installTap(onBus: bus, bufferSize: 1024, format: format) { [weak self] (buffer, _) in
            self?.recognitionRequest?.append(buffer)
            
        }
        audioEngin.prepare()
    }
    
    // MARK: SFSpeechRecognizerAuthorization
    
    func startRecording(_ completion: @escaping RecognizerResult) {
        if SFSpeechRecognizer.authorizationStatus() == .authorized {
            performRecording(completion: completion)
            return
        }
        SFSpeechRecognizer.requestAuthorization { [weak self] (result) in
            switch result {
            case .authorized:
                self?.performRecording(completion: completion)
            default:
                self?.finishRecording(completion, result: .failure(RecognizerError.notPermited))
            }
        }
    }
    
    func finishRecording() {
        audioEngin.stop()
        recognitionRequest?.endAudio()
    }
    
    func cancelRecording() {
        audioEngin.stop()
        recognitionTask?.cancel()
    }
    
    // MARK: - Private
    
    private func performRecording(completion: @escaping RecognizerResult) {
        if audioEngin.isRunning {
            finishRecording(completion, result: .failure(RecognizerError.recognitionInProgress))
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        try? audioEngin.start()
        recognitionTask = speechRecognizer
            .recognitionTask(with: recognitionRequest!, resultHandler: { [weak self] (result, error) in
                guard let result = result else {
                    self?.finishRecording(completion, result: .failure(error!))
                    print("Recognition finished with error: \(error!)")
                    return
                }
                if result.isFinal {
                    self?.finishRecording(completion, result: .success(result))
                    print("Finished with translation: \(result.bestTranscription.formattedString)")
                } else {
                    print("Not finial result")
                }
            })
    }
    
    private func finishRecording(_ completion: @escaping RecognizerResult, result: Result<SFSpeechRecognitionResult>) {
        completionQueue.async {
            completion(result)
        }
    }
    
}
