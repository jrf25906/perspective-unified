import SwiftUI
import AVKit

struct VideoBackgroundView: UIViewRepresentable {
    let videoName: String
    let videoType: String

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false // Don't intercept touch events
        
        // Add fallback gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemBlue.withAlphaComponent(0.3).cgColor,
            UIColor.systemPurple.withAlphaComponent(0.3).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(gradientLayer)
        
        // Try to load video with proper error handling
        print("🎥 Looking for video: \(videoName).\(videoType)")
        print("🎥 Bundle main path: \(Bundle.main.bundlePath)")
        
        if let bundleURL = Bundle.main.url(forResource: videoName, withExtension: videoType) {
            print("✅ Found video at: \(bundleURL.path)")
        } else {
            print("❌ Video file '\(videoName).\(videoType)' not found in bundle")
            // List all mp4 files in bundle for debugging
            if let bundlePath = Bundle.main.resourcePath {
                let fileManager = FileManager.default
                do {
                    let files = try fileManager.contentsOfDirectory(atPath: bundlePath)
                    let mp4Files = files.filter { $0.hasSuffix(".mp4") }
                    print("📁 Available MP4 files in bundle: \(mp4Files)")
                } catch {
                    print("Error listing bundle contents: \(error)")
                }
            }
            return view
        }
        
        guard let videoURL = Bundle.main.url(forResource: videoName, withExtension: videoType) else {
            print("⚠️ Video file '\(videoName).\(videoType)' not found in bundle. Using fallback background.")
            return view
        }
        
        let player = AVPlayer(playerItem: AVPlayerItem(asset: AVAsset(url: videoURL)))
        player.isMuted = true
        player.actionAtItemEnd = .none

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = UIScreen.main.bounds
        view.layer.insertSublayer(playerLayer, at: 0) // Insert below gradient

        player.play()

        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: .zero)
            player.play()
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
