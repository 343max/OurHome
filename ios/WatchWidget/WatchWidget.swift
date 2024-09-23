import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(family: context.family)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(family: context.family)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let timeline = Timeline(entries: [SimpleEntry(family: context.family)], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date = .init()
    let family: WidgetFamily
}

struct WatchWidgetEntryView: View {
    var entry: Provider.Entry

    let roundAspectRatio = 0.9

    var body: some View {
        HStack {
            if entry.family == .accessoryInline {
                Text("Our Home")
            }
            Image(systemName: "key.fill")
                .containerBackground(for: .widget) {
                    Color.orange
                }
        }
    }
}

@main
struct WatchWidget: Widget {
    let kind: String = "WatchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WatchWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Our Home")
        .description("Tür auf, Tür zu")
        .supportedFamilies([
            .accessoryCircular, .accessoryCorner, .accessoryInline, .accessoryRectangular,
        ])
    }
}

#Preview("Circular", as: .accessoryCircular) {
    WatchWidget()
} timeline: {
    SimpleEntry(family: .accessoryCircular)
}

#Preview("Corner", as: .accessoryCorner) {
    WatchWidget()
} timeline: {
    SimpleEntry(family: .accessoryCorner)
}

#Preview("Inline", as: .accessoryInline) {
    WatchWidget()
} timeline: {
    SimpleEntry(family: .accessoryInline)
}

#Preview("Rectangular", as: .accessoryRectangular) {
    WatchWidget()
} timeline: {
    SimpleEntry(family: .accessoryRectangular)
}
