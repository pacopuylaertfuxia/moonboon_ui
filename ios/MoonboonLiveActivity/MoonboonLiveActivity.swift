import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Monitor Widget

struct MonitorLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MoonboonActivityAttributes.self) { context in
            switch context.attributes.designVariant {
            case 2:  MonitorBLockScreen(attrs: context.attributes, state: context.state)
            case 8:  V8LockScreen(attrs: context.attributes, state: context.state)
            case 9:  V9LockScreen(attrs: context.attributes, state: context.state)
            case 10: V10LockScreen(attrs: context.attributes, state: context.state)
            case 11: V11LockScreen(attrs: context.attributes, state: context.state)
            default: MonitorLockScreen(attrs: context.attributes, state: context.state)
            }
        } dynamicIsland: { context in
            let v = context.attributes.designVariant
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    if v == 2 {
                        MonitorBExpandedLeading(state: context.state)
                    } else if v == 8 {
                        V8ExpandedLeading(state: context.state)
                    } else if v == 9 {
                        V9ExpandedLeading(attrs: context.attributes, state: context.state)
                    } else if v == 10 {
                        V10ExpandedLeading(attrs: context.attributes, state: context.state)
                    } else if v == 11 {
                        V11ExpandedLeading(attrs: context.attributes, state: context.state)
                    } else {
                        MonitorExpandedLeading(attrs: context.attributes, state: context.state)
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    if v == 10 {
                        V10ExpandedCenter(state: context.state)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if v == 2 {
                        MonitorBExpandedTrailing(state: context.state)
                    } else if v == 8 {
                        V8ExpandedTrailing(state: context.state)
                    } else if v == 9 {
                        V9ExpandedTrailing(state: context.state)
                    } else if v == 10 {
                        V10ExpandedTrailing(state: context.state)
                    } else if v == 11 {
                        V11ExpandedTrailing(state: context.state)
                    } else {
                        MonitorExpandedTrailing(state: context.state)
                    }
                }
            } compactLeading: {
                if v == 2 {
                    MonitorBCompactLeading(state: context.state)
                } else if v == 8 {
                    V8CompactLeading(state: context.state)
                } else if v == 9 {
                    V9CompactLeading(state: context.state)
                } else if v == 10 {
                    V10CompactLeading(state: context.state)
                } else if v == 11 {
                    V11CompactLeading(state: context.state)
                } else {
                    MonitorCompactLeading(state: context.state)
                }
            } compactTrailing: {
                if v == 2 {
                    MonitorBCompactTrailing(state: context.state)
                } else if v == 8 {
                    V8CompactTrailing(state: context.state)
                } else if v == 9 {
                    V9CompactTrailing(state: context.state)
                } else if v == 10 {
                    V10CompactTrailing(state: context.state)
                } else if v == 11 {
                    V11CompactTrailing(state: context.state)
                } else {
                    MonitorCompactTrailing(state: context.state)
                }
            } minimal: {
                if v == 2 {
                    MonitorBMinimal(state: context.state)
                } else if v == 8 {
                    V8Minimal(state: context.state)
                } else if v == 9 {
                    V9Minimal(state: context.state)
                } else if v == 10 {
                    V10Minimal(state: context.state)
                } else if v == 11 {
                    V11Minimal(state: context.state)
                } else {
                    MonitorMinimal(state: context.state)
                }
            }
        }
    }
}

// MARK: - Motor Widget

struct MotorLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MotorActivityAttributes.self) { context in
            MotorLockScreen(attrs: context.attributes, state: context.state)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    MotorExpanded(attrs: context.attributes, state: context.state)
                }
            } compactLeading: {
                MotorCompactLeading(state: context.state)
            } compactTrailing: {
                MotorCompactTrailing(state: context.state)
            } minimal: {
                MotorMinimal(state: context.state)
            }
        }
    }
}

// MARK: - Bundle

@main
struct MoonboonLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        MonitorLiveActivityWidget()
        MotorLiveActivityWidget()
    }
}
