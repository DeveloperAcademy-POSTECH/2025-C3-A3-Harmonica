import SwiftUI
import AVFoundation
import SwiftData

struct KaraokeLyricView: View {
    // MARK: - State
    @State private var currentLineIndex: Int = 0
    @State private var currentLine: LyricLine = LyricLine(text: "", timings: [])
    @State private var currentCharacterIndex: Int = 0
    @State private var currentCharacterProgress: CGFloat = 0.0
    @State private var currentCharDuration: Double = 0.0
    @State private var startTime: Date = Date()
    @State private var countdown: Int? = nil
    @State private var countdownTimer: Timer?
    
    @State private var nextLineIndex: Int = 1
    @State private var nextLine: LyricLine = LyricLine(text: "", timings: [])
    @State private var nextCharacterIndex: Int = 0
    @State private var nextCharacterProgress: CGFloat = 0.0
    @State private var nextCharDuration: Double = 0.0
    @State private var nextstartTime: Date = Date()
    
    // 음악 재생 관련 State
    let songInfo: SongInfo // 받아온 노래 정보
    @State private var player: AVPlayer = AVPlayer()
    @State private var mode: PlayMode = .ar
    @State private var currentTime: Double = 0
    @State private var playbackTimer: Timer?
    
    // 통합
    @State private var currentSegmentIndex = 0
    @State private var segments: [LyricSegment] = []
    @State private var lyricLines: [LyricLine] = []

    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect() // ~60fps
    
    var hasNextLine: Bool {
        nextLineIndex < lyricLines.count &&
        nextLineIndex < segments.count &&
        segments[currentSegmentIndex].index == segments[nextLineIndex].index
    }

    // MARK: - Derived property for current lyric line
    var lyricsWithDuration: [(String, Double)] {
        currentLine.characterDurations
    }
    var NextlyricsWithDuration: [(String, Double)] {
        nextLine.characterDurations
    }

    var body: some View {
        let fullText = lyricsWithDuration.map { $0.0 }.joined()
        let highlightedText = lyricsWithDuration.prefix(currentCharacterIndex).map { $0.0 }.joined()
        let currentChar = currentCharacterIndex < lyricsWithDuration.count ? lyricsWithDuration[currentCharacterIndex].0 : ""
        
        let nextfullText = NextlyricsWithDuration.map { $0.0 }.joined()
        let nexthighlightedtext = NextlyricsWithDuration.prefix(nextCharacterIndex).map { $0.0 }.joined()
        let nextcurrentChar = nextCharacterIndex < NextlyricsWithDuration.count ? NextlyricsWithDuration[nextCharacterIndex].0 : ""

        VStack {
            Picker("모드", selection: $mode) {
                Text("AR (원곡)").tag(PlayMode.ar)
                Text("MR (반주)").tag(PlayMode.mr)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .onChange(of: mode) { _, _ in
                replay()
            }
            
            Text(songInfo.title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(songInfo.artist)
                .font(.subheadline)
            
            if let count = countdown {
                Text(["4", "3", "2", "1"][count])
                    .font(.largeTitle)
                    .bold()
                    .transition(.opacity)
            }

            ZStack(alignment: .leading) {
                Text(fullText)
                    .foregroundColor(.gray)
                    .bold()

                HStack(spacing: 0) {
                    //이미 파란색으로 채워진 텍스트들
                    Text(highlightedText)
                        .foregroundColor(.blue)
                        .bold()

                    //두개로 label을 나눠서 마스크 & 텍스트를 두개로 해버리는게 나을까?
                    //아니면 mask가 Text 위치를 따라갈 수 있는 방법이 있을까?
                    if !currentChar.isEmpty {
                        Text(currentChar)
                            .foregroundColor(.blue)
                            .bold()
                            .mask(
                                GeometryReader { geo in
                                    Rectangle()
                                        .frame(width: geo.size.width * currentCharacterProgress)
                                }
                            )
                    }
                }
            }
            .font(.title)
            .padding()
            
            if hasNextLine {
                ZStack(alignment: .leading) {
                    Text(nextfullText)
                        .foregroundColor(.gray)
                        .bold()
                    
                    HStack(spacing: 0) {
                        
                        //이미 파란색으로 채워진 텍스트들
                        Text(nexthighlightedtext)
                            .foregroundColor(.blue)
                            .bold()
                        
                        //두개로 label을 나눠서 마스크 & 텍스트를 두개로 해버리는게 나을까?
                        //아니면 mask가 Text 위치를 따라갈 수 있는 방법이 있을까?
                        if !nextcurrentChar.isEmpty {
                            Text(nextcurrentChar)
                                .foregroundColor(.blue)
                                .bold()
                                .mask(
                                    GeometryReader { geo in
                                        Rectangle()
                                            .frame(width: geo.size.width * nextCharacterProgress)
                                    }
                                )
                        }
                    }
                }
                .font(.title)
                .padding()
            }

            HStack(spacing: 30){
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

        //가사 줄 배열 불러오고, 첫 글자 재생 타이밍 설정
        .onAppear {
            setupAudio()
            loadLyrics()
            
            if !lyricLines.isEmpty {
                currentLine = lyricLines[currentLineIndex]
                currentCharDuration = lyricsWithDuration.first?.1 ?? 0.0
                startTime = Date()
                
                if lyricLines.count > 1 && hasNextLine {
                    nextLine = lyricLines[nextLineIndex]
                    nextCharDuration = NextlyricsWithDuration.first?.1 ?? 0.0
                    nextstartTime = Date()
                }
            }
        }
        .onDisappear {
            stopPlayback()
        }
        
        // 1/60초 마다 실행됨. 카운트 다운 중이면 안하고 characterProgress = 지나간 시간 / 글자 총 지속시간 형태로 진행상태 확인하며 characterProgress가 1.0 이상이면 다음 글자로 이동
        .onReceive(timer) { _ in
            guard countdown == nil else { return }
            guard currentCharacterIndex < lyricsWithDuration.count else { return }

            let elapsed = Date().timeIntervalSince(startTime)
            let duration = lyricsWithDuration[currentCharacterIndex].1
            currentCharacterProgress = min(1.0, elapsed / duration)

            if currentCharacterProgress >= 1.0 {
                currentCharacterIndex += 1
                currentCharacterProgress = 0.0
                if currentCharacterIndex < lyricsWithDuration.count {
                    currentCharDuration = lyricsWithDuration[currentCharacterIndex].1
                    startTime = Date()
                }
            }
        }
        .onReceive(timer) { _ in
            guard countdown == nil else { return }
            guard hasNextLine else { return }
            guard nextCharacterIndex < NextlyricsWithDuration.count else { return }

            let elapsed = Date().timeIntervalSince(nextstartTime)
            let duration = NextlyricsWithDuration[nextCharacterIndex].1
            nextCharacterProgress = min(1.0, elapsed / duration)

            if nextCharacterProgress >= 1.0 {
                nextCharacterIndex += 1
                nextCharacterProgress = 0.0
                if nextCharacterIndex < NextlyricsWithDuration.count {
                    nextCharDuration = NextlyricsWithDuration[nextCharacterIndex].1
                    nextstartTime = Date()
                }
            }
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
        guard let path = Bundle.main.path(forResource: songInfo.lyricsFileName, ofType: "json") else {
            print("가사 파일을 찾을 수 없습니다: \(songInfo.lyricsFileName)")
            return
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let lyricDataArray = try JSONDecoder().decode([LyricData].self, from: data)
            
            segments = parseLyricsFromJSON(lyricDataArray: lyricDataArray)
            lyricLines = createLyricLines(from: lyricDataArray)
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
    
    func createLyricLines(from lyricDataArray: [LyricData]) -> [LyricLine] {
        return lyricDataArray
            .sorted(by: { $0.index < $1.index })
            .map { LyricLine(text: $0.Lyric, timings: $0.timingArray) }
    }
    
    func resetCharacterStates() {
        currentCharacterIndex = 0
        nextCharacterIndex = 0
        currentCharacterProgress = 0
        nextCharacterProgress = 0
        countdown = 0
        startCountdown()
    }
    
    func previous() {
        print("=== PREVIOUS")
        guard currentSegmentIndex > 0 else { return }
        currentSegmentIndex -= 2
        replay()
        
        if currentLineIndex > 1 {
            currentLineIndex -= 2
            currentLine = lyricLines[currentLineIndex]
            nextLineIndex = currentLineIndex + 1
            if nextLineIndex < lyricLines.count {
                nextLine = lyricLines[nextLineIndex]
            }
            resetCharacterStates()
        }
        
    }
    
    func next() {
        print("=== NEXT")
        guard currentSegmentIndex < segments.count - 1 else { return }
        currentSegmentIndex += 2
        replay()
        
        if currentLineIndex + 2 < lyricLines.count {
            currentLineIndex += 2
            currentLine = lyricLines[currentLineIndex]
            nextLineIndex = currentLineIndex + 1
            if nextLineIndex < lyricLines.count {
                nextLine = lyricLines[nextLineIndex]
            }
            resetCharacterStates()
        }
    }
    
    func replay() {
        guard currentSegmentIndex < segments.count else { return }
        
        let segment = segments[currentSegmentIndex]
        let fileName = mode == .ar ? songInfo.arFileName : songInfo.mrFileName
        
        guard let url = Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".mp3", with: ""), withExtension: "mp3") else {
            print("오디오 파일을 찾을 수 없습니다: \(fileName)")
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        
        let startTime = CMTime(seconds: segment.startTime, preferredTimescale: 600)
        player.seek(to: startTime) { [self] _ in
            player.play()
            startPlaybackTimer(segment: segment)
        }
        
        if currentLineIndex >= 0 && currentLineIndex < lyricLines.count {
            currentLine = lyricLines[currentLineIndex]
            nextLineIndex = currentLineIndex + 1
            if nextLineIndex < lyricLines.count {
                nextLine = lyricLines[nextLineIndex]
            }
            currentCharacterIndex = 0
            nextCharacterIndex = 0
            currentCharacterProgress = 0
            nextCharacterProgress = 0
            countdown = 0
            startCountdown()
        }
    }
        
    func startPlaybackTimer(segment: LyricSegment) {
        stopTimer()
        
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] timer in
            let currentTime = player.currentTime().seconds
            
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

    // 하나 둘 셋 넷 카운터
    private func startCountdown() {
        countdownTimer?.invalidate()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 0.37, repeats: true) { timer in
            countdown! += 1
            if countdown! >= 4 {
                countdown = nil
                currentCharDuration = lyricsWithDuration.first?.1 ?? 0.0
                startTime = Date()
                if hasNextLine {
                    nextCharDuration = NextlyricsWithDuration.first?.1 ?? 0.0
                    nextstartTime = Date()
                }
                timer.invalidate()
                countdownTimer = nil
                
            }
        }
    }
}

// MARK: - Data Models
struct LyricLine {
    let text: String
    let timings: [Double]
    
    /// 각 글자별 지속 시간을 계산해 반환
    var characterDurations: [(String, Double)] {
        let chars = Array(text).map { String($0) }
        let durations = zip(timings, timings.dropFirst()).map { $1 - $0 }
        return Array(zip(chars, durations))
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
    KaraokeLyricView(songInfo: .preview)
}
