import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Widget

struct MoonboonLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MoonboonActivityAttributes.self) { context in
            switch context.attributes.designVariant {
            case 2:  V2LockScreen(attrs: context.attributes, state: context.state)
            case 3:  V3LockScreen(attrs: context.attributes, state: context.state)
            case 4:  V4LockScreen(attrs: context.attributes, state: context.state)
            case 5:  V5LockScreen(attrs: context.attributes, state: context.state)
            case 6:  V6LockScreen(attrs: context.attributes, state: context.state)
            case 7:  V7LockScreen(attrs: context.attributes, state: context.state)
            default: V1LockScreen(attrs: context.attributes, state: context.state)
            }
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    switch context.attributes.designVariant {
                    case 2:  V2Expanded(attrs: context.attributes, state: context.state)
                    case 3:  V3Expanded(attrs: context.attributes, state: context.state)
                    case 4:  V4Expanded(attrs: context.attributes, state: context.state)
                    case 5:  V5Expanded(attrs: context.attributes, state: context.state)
                    case 6:  V6Expanded(attrs: context.attributes, state: context.state)
                    case 7:  V7Expanded(attrs: context.attributes, state: context.state)
                    default: V1Expanded(attrs: context.attributes, state: context.state)
                    }
                }
            } compactLeading: {
                switch context.attributes.designVariant {
                case 2:  V2CompactLeading(state: context.state)
                case 3:  V3CompactLeading(state: context.state)
                case 4:  V4CompactLeading(state: context.state)
                case 5:  V5CompactLeading(state: context.state)
                case 6:  V6CompactLeading(state: context.state)
                case 7:  V7CompactLeading(state: context.state)
                default: V1CompactLeading(attrs: context.attributes, state: context.state)
                }
            } compactTrailing: {
                switch context.attributes.designVariant {
                case 2:  V2CompactTrailing(state: context.state)
                case 3:  V3CompactTrailing(state: context.state)
                case 4:  V4CompactTrailing(state: context.state)
                case 5:  V5CompactTrailing(state: context.state)
                case 6:  V6CompactTrailing(state: context.state)
                case 7:  V7CompactTrailing(state: context.state)
                default: V1CompactTrailing(state: context.state)
                }
            } minimal: {
                switch context.attributes.designVariant {
                case 2:  V2Minimal(state: context.state)
                case 3:  V3Minimal(state: context.state)
                case 4:  V4Minimal(state: context.state)
                case 5:  V5Minimal(state: context.state)
                case 6:  V6Minimal(state: context.state)
                case 7:  V7Minimal(state: context.state)
                default: V1Minimal(state: context.state)
                }
            }
        }
    }
}

// MARK: - Bundle

@main
struct MoonboonLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        MoonboonLiveActivityWidget()
    }
}
