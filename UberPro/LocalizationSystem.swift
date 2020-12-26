//
//  LocalizationSystem.swift
//  3000
//
//  Created by Asliddin Rasulov on 23.09.2020.
//  Copyright © 2020 Asliddin Rasulov. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: LocalizationSystem.shared.bundle, comment: "")
    }
}

final class LocalizationSystem {
    static let shared = LocalizationSystem()
    
    private var _bundle: Bundle = .main
    private var _locale = Locale(identifier: "ru")

    var locale: Locale {
        get {
            _locale
        } set {
            guard Bundle.main.localizations.contains(newValue.identifier) else { return }
            _locale = newValue
            updateUI()
        }
    }

    var bundle: Bundle {
        _bundle
    }

    private func updateUI() {
        guard
            let path = Bundle.main.path(forResource: _locale.identifier, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else { fatalError() }
        _bundle = bundle
        UserDefaults.standard.setValue(_locale.identifier, forKey: "AppleLanguage")
    }
}
