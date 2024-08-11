import SwiftUI
import AVKit

struct LoadingScreenView: View {
    @State private var player: AVPlayer?
    @State private var isLoadingComplete = false
    
    var body: some View {
        VStack {
            if let player = player {
                VideoPlayerView(player: player)
                    .frame(width: 250, height: 250) // Adjust the size as needed
                    .background(Color.clear)
                    .onAppear {
                        player.play()
                    }
            }
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(2) // Adjust the size of the loading circle
                .padding(.top, 50)
            
            if isLoadingComplete {
                NavigationLink(destination: NextView(), isActive: $isLoadingComplete) {
                    EmptyView()
                }
            }
        }
        .padding()
        .onAppear {
            setupPlayer()
        }
    }
    
    private func setupPlayer() {
        if let url = Bundle.main.url(forResource: "logo", withExtension: "mp4") {
            player = AVPlayer(url: url)
            player?.isMuted = true // Mute the video if needed
            player?.actionAtItemEnd = .none
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player?.currentItem,
                queue: .main
            ) { _ in
                player?.seek(to: .zero)
                player?.play()
            }
            // Start playing the video and set the timer for 5 seconds
            player?.play()
            DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                isLoadingComplete = true
            }
        } else {
            print("Error: Video file not found")
        }
    }
}

struct NextView: View {
    var body: some View {
        Text("Next View")
    }
}

struct LoadingScreenView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LoadingScreenView()
        }
    }
}
