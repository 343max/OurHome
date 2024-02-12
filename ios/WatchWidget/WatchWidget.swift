import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry()
  }
  
  func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
    let entry = SimpleEntry()
    completion(entry)
  }
  
  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    let timeline = Timeline(entries: [SimpleEntry()], policy: .atEnd)
    completion(timeline)
  }
}

struct SimpleEntry: TimelineEntry {
  let date: Date = Date()
}

struct WatchWidgetEntryView : View {
  var entry: Provider.Entry
  
  let roundAspectRatio = 0.9
  
  var body: some View {
    Image(systemName: "key.fill")
      .containerBackground(for: .widget) {
        Color.orange
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
    .supportedFamilies([.accessoryCircular])
  }
}

#Preview(as: .accessoryCircular) {
  WatchWidget()
} timeline: {
  SimpleEntry()
}
