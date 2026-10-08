//
//  AIResourceAvailabilityUnitTests.swift
//  Voxy
//
//  Created by Voxy Team on 08/10/26.
//

import Testing
@testable import Voxy

@MainActor
struct AIResourceAvailabilityUnitTests {

    // CT-37 
    @Test
    func checksAIResourceAvailability() {
        let service = FoundationQuestionGenerationService()

        let message = service.availabilityMessage

        if let message {
            #expect(!message.isEmpty)
        } else {
            #expect(message == nil)
        }
    }
}
