// Copyright 2026 Andreas Kupper
// SPDX-License-Identifier: Apache-2.0

import CoreBluetooth

/// A stale manager gets one automatic retry per permission transition. A real
/// unsupported adapter must not cause an endless manager/prompt creation loop.
struct BLERecoveryPolicy {
    private var authorization: CBManagerAuthorization
    private var hasRetried = false

    init(authorization: CBManagerAuthorization) {
        self.authorization = authorization
    }

    mutating func shouldRestart(state: CBManagerState,
                                authorization current: CBManagerAuthorization,
                                explicit: Bool = false) -> Bool {
        if current != authorization {
            authorization = current
            hasRetried = false
        }
        guard current == .allowedAlways else { return false }
        switch state {
        case .unsupported, .unauthorized:
            guard explicit || !hasRetried else { return false }
        case .unknown, .resetting:
            guard explicit else { return false }
        default:
            return false
        }
        hasRetried = true
        return true
    }
}
