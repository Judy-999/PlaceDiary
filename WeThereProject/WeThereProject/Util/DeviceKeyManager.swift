//
//  KeyChainManager.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/03/22.
//

import UIKit

final class DeviceKeyManager {
    static let shared = DeviceKeyManager()
    private let account = "PlaceDiaryKey"
    
    private init() { }
    
    private func add(item: String = UIDevice.current.identifierForVendor!.uuidString) {
        guard let data = item.data(using: .utf8) else { return }
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                      kSecAttrAccount: account,
                                      kSecValueData: data]
        
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func read() -> String {
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                      kSecAttrAccount: account,
                                      kSecReturnAttributes: true,
                                      kSecReturnData: true]
        var item: CFTypeRef?
        SecItemCopyMatching(query as CFDictionary, &item)
        
        guard let existingItem = item as? [String: Any],
              let data = existingItem[kSecValueData as String] as? Data,
              let key = String(data: data, encoding: .utf8) else { return "" }
        
        return key
    }
    
    func checkAppFirstRun(key: String = "PlaceDiaryKey") {
        if UserDefaults.standard.bool(forKey: key) == false {
            if read().isEmpty {
                add()
            }
            
            UserDefaults.standard.set(true, forKey: key)
        }
    }
}
