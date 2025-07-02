import SwiftUI

struct SimplePreviewTest: View {
    var body: some View {
        VStack {
            Text("Preview Test")
                .font(.largeTitle)
                .padding()
            
            Text("If you can see this, previews are working!")
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.yellow.opacity(0.3))
    }
}

#Preview {
    SimplePreviewTest()
}