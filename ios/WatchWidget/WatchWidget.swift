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
  var date: Date = Date()
}

struct WatchWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
      HStack(alignment: .center) {
        Button(action: {
          print("öffne Haustür")
        }, label: {
          Image(systemName: "house")
        })
        .tint(.orange)
        .aspectRatio(0.8, contentMode: .fit)
        Spacer()
        Button {
          print("klingle um die Wohnungstür zu öffnen")
        } label: {
          Image(systemName: "door.left.hand.open")
        }
        .tint(.teal)
        .aspectRatio(0.8, contentMode: .fit)
      }
    }
}

@main
struct WatchWidget: Widget {
    let kind: String = "watchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(watchOS 10.0, *) {
                WatchWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WatchWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Our Home")
        .description("Tür auf, Tür zu")
    }
}

#Preview(as: .accessoryRectangular) {
    WatchWidget()
} timeline: {
    SimpleEntry()
}
