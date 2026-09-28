// Copyright 2026 Andreas Kupper
// SPDX-License-Identifier: Apache-2.0

/// Custom glass surfaces need a compositor capture. The snapshot renderer turns
/// these off when it must draw in-process; native sliders remain system controls.
enum GlassSettings {
    nonisolated(unsafe) static var isEnabled = true
}
