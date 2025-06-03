import SwiftUI
import AVFoundation
import SwiftData

struct SongPracticeView: View {
    @State private var player: AVPlayer = AVPlayer() // 음악 재생
    @State private var mode: PlayMode = .ar // 현재 재생 모드(시작은 AR)
    @State private var currentSegmentIndex = 0 // 지금 재생 중인 소절
    @State private var segments: [LyricSegment] = [] // 가사 정보
    @State private var isPlaying = false // 재생 여부
    @State private var currentTime: Double = 0 // 현재 재생 시간
    @State private var playbackTimer: Timer? // 시간 체크용 타이머
    
    let song: Song // 받아온 노래 정보

    var body: some View {
        VStack(spacing: 20) {
            Text(song.title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(song.artist)
                .font(.subheadline)
            
            // 가사가 있고, 현재 인덱스가 유효할 때
            if !segments.isEmpty && currentSegmentIndex < segments.count {
                VStack(spacing: 10) {
                    Text("소절 \(currentSegmentIndex + 1) / \(segments.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(segments[currentSegmentIndex].lyric)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
            }
            
            // 재생 모드 선택
            Picker("모드", selection: $mode) {
                Text("AR (원곡)").tag(PlayMode.ar)
                Text("MR (반주)").tag(PlayMode.mr)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .onChange(of: mode) { _, _ in
                replay() // 모드가 바뀌면 다시 재생
            }
            
            // 컨트롤 버튼들
            HStack(spacing: 30) {
                Button(action: previous) {
                    Image(systemName: "backward.fill")
                }
                .disabled(currentSegmentIndex <= 0)
                
                Button(action: replay) {
                    Image(systemName: "gobackward")
                }
                
                Button(action: next) {
                    Image(systemName: "forward.fill")
                }
                .disabled(currentSegmentIndex >= segments.count - 1)
            }
        }
        .padding()
        .onAppear {
            setupAudio()
            loadLyrics()
        }
        .onDisappear {
            stopPlayback()
        }
    }
    
    // MARK: - Functions
    
    func setupAudio() {
        // 음악을 재생 중임을 iOS에게 알려주기
        // 다른 앱 소리 중단
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("오디오 세션 설정 실패: \(error)")
        }
    }
    
    func loadLyrics() {
        guard let path = Bundle.main.path(forResource: song.lyricsFileName, ofType: "json") else {
            print("가사 파일을 찾을 수 없습니다: \(song.lyricsFileName)")
            return
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let lyricDataArray = try JSONDecoder().decode([LyricData].self, from: data)
            segments = parseLyricsFromJSON(lyricDataArray: lyricDataArray)
        } catch {
            print("가사 파일 읽기 실패: \(error)")
        }
    }
    
    func parseLyricsFromJSON(lyricDataArray: [LyricData]) -> [LyricSegment] {
        var segments: [LyricSegment] = []
        
        for lyricData in lyricDataArray {
            let startTime = lyricData.mp3Start
            let endTime: Double
            
            // duration이 null이면 기본값 3초 사용
            if let duration = lyricData.duration {
                endTime = startTime + duration
            } else {
                endTime = startTime + 3.0
            }
            
            let segment = LyricSegment(
                startTime: startTime,
                endTime: endTime,
                lyric: lyricData.Lyric,
                timingArray: lyricData.timingArray,
                index: lyricData.index
            )
            
            segments.append(segment)
        }
        
        return segments
    }
    
    func previous() {
        guard currentSegmentIndex > 0 else { return }
        currentSegmentIndex -= 1
        replay()
    }
    
    func next() {
        guard currentSegmentIndex < segments.count - 1 else { return }
        currentSegmentIndex += 1
        replay()
    }
    
    func replay() {
        guard currentSegmentIndex < segments.count else { return }
        
        let segment = segments[currentSegmentIndex]
        let fileName = mode == .ar ? song.arFileName : song.mrFileName
        
        guard let url = Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".mp3", with: ""), withExtension: "mp3") else {
            print("오디오 파일을 찾을 수 없습니다: \(fileName)")
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        
        // 시작 시간으로 이동
        let startTime = CMTime(seconds: segment.startTime, preferredTimescale: 600)
        player.seek(to: startTime) { [self] _ in
            player.play()
            startPlaybackTimer(segment: segment)
        }
    }
    
    func startPlaybackTimer(segment: LyricSegment) {
        stopTimer()
        
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] timer in
            let currentTime = player.currentTime().seconds
            
            // 세그먼트 끝에 도달하면 재생 중지
            if currentTime >= segment.endTime {
                player.pause()
                timer.invalidate()
            }
            
            self.currentTime = currentTime
        }
    }
    
    func stopTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    func stopPlayback() {
        player.pause()
        stopTimer()
    }
    
    func calculateProgress(segment: LyricSegment) -> Double {
        let duration = segment.endTime - segment.startTime
        let elapsed = max(0, currentTime - segment.startTime)
        return min(1.0, elapsed / duration)
    }
}

struct LyricSegment {
    let startTime: Double
    var endTime: Double = 0
    let lyric: String
    let timingArray: [Double]
    let index: Int
}

struct LyricData: Codable {
    let index: Int
    let Lyric: String // mp3Start + duration
    let timingArray: [Double]
    let mp3Start: Double
    let duration: Double?
}

enum PlayMode {
    case ar
    case mr
}

#Preview {
    SongPracticeView(song: .preview)
}
