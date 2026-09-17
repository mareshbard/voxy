//
//  FontRegistration.swift
//  Voxy
//
//  Created by Voxy Team on 31/08/26.
//

import CoreText
import Foundation

enum FontRegistration {

    static func registerFonts() {
        for ext in ["ttf", "otf"] {
            let urls = Bundle.main.urls(
                forResourcesWithExtension: ext,
                subdirectory: nil
            ) ?? []

            for url in urls {
                register(at: url)
            }
        }
    }

    private static func register(at url: URL) {
        var error: Unmanaged<CFError>?
        guard CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) else {
            let cfError = error?.takeUnretainedValue()
            let description = cfError
                .flatMap { CFErrorCopyDescription($0) as String? }
                ?? "erro desconhecido"
            print("Falha ao registrar fonte \(url.lastPathComponent): \(description)")
            return
        }
    }
}
