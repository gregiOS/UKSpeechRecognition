//
//  Result.swift
//  UKSpeechRecognition
//
//  Created by Grzegorz Przybyła on 01/03/2018.
//  Copyright © 2018 Grzegorz Przybyła. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(Error)
}
