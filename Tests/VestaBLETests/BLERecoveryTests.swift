// Copyright 2026 Andreas Kupper
// SPDX-License-Identifier: Apache-2.0

import Testing
import CoreBluetooth
@testable import VestaBLE

@Suite("Bluetooth permission recovery")
struct BLERecoveryTests {
    @Test("Granting access recovers a manager stuck at unauthorized or unsupported")
    func permissionGranted() {
        for state in [CBManagerState.unauthorized, .unsupported] {
            var policy = BLERecoveryPolicy(authorization: .notDetermined)
            let result1 = policy.shouldRestart(state: state, authorization: .notDetermined)
            #expect(!result1)
            let result2 = policy.shouldRestart(state: state, authorization: .allowedAlways)
            #expect(result2)
            let result3 = policy.shouldRestart(state: state, authorization: .allowedAlways)
            #expect(!result3)
        }
    }

    @Test("A persistently unsupported adapter gets one automatic attempt, plus explicit retries")
    func boundedRetries() {
        var policy = BLERecoveryPolicy(authorization: .allowedAlways)
        let result4 = policy.shouldRestart(state: .unsupported, authorization: .allowedAlways)
        #expect(result4)
        for _ in 0..<10 {
            let result5 = policy.shouldRestart(state: .unsupported, authorization: .allowedAlways)
            #expect(!result5)
        }
        let result6 = policy.shouldRestart(state: .unsupported, authorization: .allowedAlways, explicit: true)
        #expect(result6)
    }

    @Test("Denied permission, a powered-off radio and a healthy connection are not restarted")
    func leavesStableStatesAlone() {
        var policy = BLERecoveryPolicy(authorization: .denied)
        let result7 = policy.shouldRestart(state: .unauthorized, authorization: .denied, explicit: true)
        #expect(!result7)
        let result8 = policy.shouldRestart(state: .unsupported, authorization: .restricted, explicit: true)
        #expect(!result8)
        let result9 = policy.shouldRestart(state: .poweredOff, authorization: .allowedAlways, explicit: true)
        #expect(!result9)
        let result10 = policy.shouldRestart(state: .poweredOn, authorization: .allowedAlways, explicit: true)
        #expect(!result10)
    }

    @Test("A new permission transition can recover again")
    func permissionChangesAgain() {
        var policy = BLERecoveryPolicy(authorization: .allowedAlways)
        let result11 = policy.shouldRestart(state: .unsupported, authorization: .allowedAlways)
        #expect(result11)
        let result12 = policy.shouldRestart(state: .unauthorized, authorization: .denied)
        #expect(!result12)
        let result13 = policy.shouldRestart(state: .unauthorized, authorization: .allowedAlways)
        #expect(result13)
    }

    @Test("Transient startup and resetting states wait for callbacks unless explicitly retried")
    func transientStates() {
        for state in [CBManagerState.unknown, .resetting] {
            var policy = BLERecoveryPolicy(authorization: .allowedAlways)
            let result14 = policy.shouldRestart(state: state, authorization: .allowedAlways)
            #expect(!result14)
            let result15 = policy.shouldRestart(state: state, authorization: .allowedAlways, explicit: true)
            #expect(result15)
        }
    }
}
