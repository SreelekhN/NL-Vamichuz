import XCTest
@testable import NL

final class DeviceIntegrityTests: XCTestCase {

    override func tearDown() {
        NLConfig.shared.securityCheckEnabled = true
        NLConfig.shared.debuggerCheckEnabled = false
        NLConfig.shared.deviceIntegrityProvider = nil
        DeviceIntegrityEvaluator.overrideForTesting = nil
        super.tearDown()
    }

    func testJailbreakDetectorFlagsWhenAnySignalPositive() {
        let signals: [(name: String, check: () -> Bool)] = [
            ("clean", { false }),
            ("compromised", { true })
        ]
        XCTAssertTrue(JailbreakDetector().isJailbroken(signals: signals))
    }

    func testJailbreakDetectorCleanWhenAllSignalsNegative() {
        let signals: [(name: String, check: () -> Bool)] = [
            ("clean1", { false }),
            ("clean2", { false })
        ]
        XCTAssertFalse(JailbreakDetector().isJailbroken(signals: signals))
    }

    func testTamperDetectorFlagsSuspiciousDyldImage() {
        let detector = TamperDetector()
        XCTAssertTrue(detector.isTampered(scanner: { _ in ["FridaGadget"] }, hookChecks: []))
        XCTAssertFalse(detector.isTampered(scanner: { _ in [] }, hookChecks: []))
    }

    func testTamperDetectorFlagsHookedFunction() {
        let detector = TamperDetector()
        XCTAssertTrue(detector.isTampered(scanner: { _ in [] }, hookChecks: [{ true }]))
        XCTAssertFalse(detector.isTampered(scanner: { _ in [] }, hookChecks: [{ false }]))
    }

    func testRequestBlockedWhenSecurityCheckEnabledAndDeviceCompromised() async {
        NLConfig.shared.securityCheckEnabled = true
        DeviceIntegrityEvaluator.overrideForTesting = true

        let client = FakeIntegrityClient()
        let response = await client.call()

        switch response {
        case .failure(let message, _):
            XCTAssertEqual(message, ErrorMessage.deviceIntegrityCompromised.rawValue)
        default:
            XCTFail("Expected request to be blocked")
        }
    }

    func testSecurityCheckEnabledByDefault() {
        XCTAssertTrue(NLConfig.shared.securityCheckEnabled)
    }

    func testDebuggerCheckDisabledByDefault() {
        // Off by default: a debugger is attached to every Xcode debug run (lldb), so this
        // must never be part of the always-on aggregate or local development breaks.
        XCTAssertFalse(NLConfig.shared.debuggerCheckEnabled)
    }

    func testHookDetectorFlagsAddressOutsideSystemImage() {
        // A function local to this test binary can never resolve into /System/Library or
        // /usr/lib, so this deterministically exercises the "hooked" branch regardless of
        // ambient test-harness instrumentation (e.g. Xcode's Main Thread Checker, which itself
        // injects a dylib and would make any "known clean address" assertion environment-dependent).
        let pointer = unsafeBitCast(fakeHookedImplementation, to: UnsafeRawPointer.self)
        XCTAssertTrue(HookDetector.isPointerOutsideSystemImage(pointer))
    }
}

private let fakeHookedImplementation: @convention(c) () -> Void = {}

private struct FakeIntegrityClient: HTTPClient {
    func call() async -> FinalResponse<ExchangeDecorder> {
        let compose = ConvertCompose()
        return await self.serverRequest(compose: compose, decoder: ExchangeDecorder.self)
    }
}
