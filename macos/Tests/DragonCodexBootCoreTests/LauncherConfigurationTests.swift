import Foundation
import XCTest
@testable import DragonCodexBootCore

final class LauncherConfigurationTests: XCTestCase {
    func testExampleConfigurationDecodesAndValidates() throws {
        let json = #"{"DisplayName":"Codex 启动动画","Video":"media/welcome-glass-4k-12s.mp4","AppBundleIdentifier":"com.openai.codex","AppPath":"","HoldAt":6.2,"TransitionStart":10.6,"TransitionEnd":12.0,"MaxWaitSeconds":60,"Volume":1,"Fullscreen":true,"PlayerWidth":1920,"PlayerHeight":1080}"#
        let configuration = try LauncherConfiguration.decode(from: Data(json.utf8))
        XCTAssertEqual(configuration.displayName, "Codex 启动动画")
        XCTAssertEqual(configuration.video, "media/welcome-glass-4k-12s.mp4")
        XCTAssertEqual(configuration.appBundleIdentifier, "com.openai.codex")
        XCTAssertEqual(configuration.holdAt, 6.2, accuracy: 0.0001)
        XCTAssertEqual(configuration.transitionStart, 10.6, accuracy: 0.0001)
        XCTAssertEqual(configuration.transitionEnd, 12.0, accuracy: 0.0001)
        XCTAssertTrue(configuration.fullscreen)
    }

    func testPlayerFadesSmoothlyAcrossConfiguredTransition() {
        let configuration = LauncherConfiguration()
        XCTAssertEqual(configuration.playerOpacity(at: 10.0), 1, accuracy: 0.0001)
        XCTAssertEqual(configuration.playerOpacity(at: 10.6), 1, accuracy: 0.0001)
        XCTAssertEqual(configuration.playerOpacity(at: 11.3), 0.5, accuracy: 0.0001)
        XCTAssertEqual(configuration.playerOpacity(at: 12.0), 0, accuracy: 0.0001)
        XCTAssertEqual(configuration.playerOpacity(at: 15.0), 0, accuracy: 0.0001)
    }

    func testRelativeVideoPathIsResolvedAgainstApplicationSupportDirectory() {
        let root = URL(fileURLWithPath: "/tmp/DragonCodexBoot", isDirectory: true)
        XCTAssertEqual(
            LauncherConfiguration().videoURL(relativeTo: root).path,
            "/tmp/DragonCodexBoot/media/welcome-glass-4k-12s.mp4"
        )
    }

    func testInvalidTimingAndMissingAppAreRejected() {
        var invalidTiming = LauncherConfiguration()
        invalidTiming.transitionEnd = invalidTiming.transitionStart
        XCTAssertThrowsError(try invalidTiming.validate())

        var missingApp = LauncherConfiguration()
        missingApp.appBundleIdentifier = ""
        XCTAssertThrowsError(try missingApp.validate())
    }
}
