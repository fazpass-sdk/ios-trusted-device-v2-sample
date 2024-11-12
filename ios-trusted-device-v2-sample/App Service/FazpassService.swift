//
//  FazpassService.swift
//  ios-trusted-device-v2-sample
//
//  Created by Andri nova riswanto on 11/11/24.
//

import Foundation
import Fazpass

class FazpassService {
    
    private let ACCOUNT_INDEX = 0
    private let fazpass = Fazpass.shared
    
    var meta = ""
    
    func generateMeta(onError: @escaping (Error) -> Void, onFinished: @escaping() -> Void) {
        fazpass.generateMeta(accountIndex: ACCOUNT_INDEX) { meta, fazpassException in
            self.meta = meta

            guard let exception = fazpassException else {
                onFinished()
                return
            }
            onError(exception)
        }
    }
}
