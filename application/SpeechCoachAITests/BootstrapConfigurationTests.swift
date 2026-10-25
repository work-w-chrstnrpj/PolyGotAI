import Foundation
import Testing
@testable import SpeechCoachAI

struct BootstrapConfigurationTests {
    @Test func builtAppSupportsBothDeviceClassesAndMinimumOS() throws {
        let bundle = Bundle.main
        let families = try #require(bundle.object(forInfoDictionaryKey: "UIDeviceFamily") as? [Int])
        #expect(Set(families) == [1, 2])
        #expect(bundle.object(forInfoDictionaryKey: "MinimumOSVersion") as? String == "17.0")
    }

    @Test func speechFeaturesDeclareOnlyMicrophoneAndSpeechRecognition() {
        let bundle = Bundle.main
        #expect((bundle.object(forInfoDictionaryKey: "NSMicrophoneUsageDescription") as? String)?.contains("replay and practice, and dictate text") == true)
        #expect((bundle.object(forInfoDictionaryKey: "NSSpeechRecognitionUsageDescription") as? String)?.contains("on this device") == true)
        #expect(bundle.object(forInfoDictionaryKey: "UIBackgroundModes") == nil)
        #expect(bundle.object(forInfoDictionaryKey: "NSAppTransportSecurity") == nil)
    }
}
