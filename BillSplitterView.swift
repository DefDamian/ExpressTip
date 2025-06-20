import SwiftUI

struct BillSplitterView: View {
    @Binding var splitCount: Int
    var body: some View {
        HStack {
            Text("Split")
                .font(.title3)
            Spacer()
            Stepper("\(splitCount) \(splitCount == 1 ? "person" : "people")", value: $splitCount, in: 1...20)
                .frame(width: 180)
        }
        .padding(.vertical, 8)
    }
}
