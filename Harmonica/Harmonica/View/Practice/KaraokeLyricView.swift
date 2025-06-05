import SwiftUI
import AVFoundation
import SwiftData

struct KaraokeLyricView: View {
    // MARK: LyricProvider에서 json 파일 입력해서 가져오기
    let lyricProvider = LyricProvider(jsonFileName: "내 여자 내 남자 가삭")

    // MARK: - State
    @State private var currentLineIndex: Int = 0
    @State private var currentLine: LyricLine = LyricLine(text: "내 여자 내 남자 - 배금성", timings: [0.00, 1.03, 1.3, 1.43, 1.65, 2.27, 2.57, 2.85, 3.07, 4.1, 4.4, 4.7, 5.0, 5.3, 5.7, 6.0])
    @State private var currentCharacterIndex: Int = 0
    @State private var currentCharacterProgress: CGFloat = 0.0
    @State private var currentCharDuration: Double = 0.0
    @State private var startTime: Date = Date()
    @State private var countdown: Int? = nil
    @State private var countdownTimer: Timer?
    
    @State private var nextLineIndex: Int = 1
    @State private var nextLine: LyricLine = LyricLine(text: "배금성", timings: [0.00, 1.03, 1.3, 1.43])
    @State private var nextCharacterIndex: Int = 0
    @State private var nextCharacterProgress: CGFloat = 0.0
    @State private var nextCharDuration: Double = 0.0
    @State private var nextstartTime: Date = Date()
    
    // 음악 재생 관련 State
    let song: Song // 받아온 노래 정보
    @State private var player: AVPlayer = AVPlayer()
    @State private var mode: PlayMode = .ar
    @State private var currentTime: Double = 0
    @State private var playbackTimer: Timer?
    // 통합?
    @State private var currentSegmentIndex = 0
    @State private var segments: [LyricSegment] = []

    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect() // ~60fps

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
            
            Text(song.title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(song.artist)
                .font(.subheadline)
            
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
            
            if let count = countdown {
                Text(["하나", "둘", "셋", "넷"][count])
                    .font(.largeTitle)
                    .bold()
                    .transition(.opacity)
            }
            
            Text("\(currentLineIndex)")

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
            
            let lines = lyricProvider.lyricLines
            if !lines.isEmpty {
                currentLine = lines[currentLineIndex]
                currentCharDuration = lyricsWithDuration.first?.1 ?? 0.0
                startTime = Date()
            }
            
            if !lines.isEmpty {
                nextLine = lines[nextLineIndex]
                nextCharDuration = NextlyricsWithDuration.first?.1 ?? 0.0
                nextstartTime = Date()
            }
        }
        .onDisappear {
            stopPlayback()
        }
        
        //1/60초 마다 (개빨리) 실행됨. 카운트 다운 중이면 안하고 characterProgress = 지나간 시간 / 글자 총 지속시간 형태로 진행상태 확인하며 characterProgress가 1.0 이상이면 다음 글자로 이동
        .onReceive(timer) { _ in
            guard countdown == nil else { return }
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
        print("=== PREVIOUS")
        guard currentSegmentIndex > 0 else { return }
        currentSegmentIndex -= 1
        print(currentSegmentIndex)
        replay()
        
        
        let lines = lyricProvider.lyricLines
        if currentLineIndex > 1 {
            currentLineIndex -= 2
            currentLine = lines[currentLineIndex]
            nextLineIndex = currentLineIndex + 1
            nextLine = lines[nextLineIndex]
            currentCharacterIndex = 0
            nextCharacterIndex = 0
            currentCharacterProgress = 0
            nextCharacterProgress = 0
            countdown = 0
            startCountdown()
        }
        
    }
    
    func next() {
        print("=== NEXT!")
        guard currentSegmentIndex < segments.count - 1 else { return }
        currentSegmentIndex += 1
        print(currentSegmentIndex)
        replay()
        
        let lines = lyricProvider.lyricLines
        if currentLineIndex + 2 < lines.count {
            currentLineIndex += 2
            currentLine = lines[currentLineIndex]
            nextLineIndex = currentLineIndex + 1
            nextLine = lines[nextLineIndex]
            currentCharacterIndex = 0
            nextCharacterIndex = 0
            currentCharacterProgress = 0
            nextCharacterProgress = 0
            countdown = 0
            startCountdown()
        }
    }
    
    func replay() {
        guard currentSegmentIndex < segments.count else { return }
        print(currentSegmentIndex)
        
        let segment = segments[currentSegmentIndex]
        let fileName = mode == .ar ? song.arFileName : song.mrFileName
        
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
        
        let lines = lyricProvider.lyricLines
        if currentLineIndex >= 0 {
            currentLine = lines[currentLineIndex]
            nextLineIndex = currentLineIndex + 1
            nextLine = lines[nextLineIndex]
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

    // 이건 그냥 하나 둘 셋 넷 카운터 딱히 필요는 없슴
    private func startCountdown() {
        countdownTimer?.invalidate()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 0.37, repeats: true) { timer in
            if let currentCount = countdown {
                countdown! += 1
                if countdown! >= 4 {
                    countdown = nil
                    currentCharDuration = lyricsWithDuration.first?.1 ?? 0.0
                    startTime = Date()
                    nextCharDuration = NextlyricsWithDuration.first?.1 ?? 0.0
                    nextstartTime = Date()
                    timer.invalidate()
                    countdownTimer = nil
                }
            } else {
                print("=== startCountdown ERROR")
            }
        }
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

#Preview{
    KaraokeLyricView(song: .preview)
}
