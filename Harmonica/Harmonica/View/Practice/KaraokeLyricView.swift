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
    @State private var isCountingDown = false
    
    @State private var nextLineIndex: Int = 1
    @State private var nextLine: LyricLine = LyricLine(text: "", timings: [])
    @State private var nextCharacterIndex: Int = 0
    @State private var nextCharacterProgress: CGFloat = 0.0
    @State private var nextCharDuration: Double = 0.0
    @State private var nextstartTime: Date = Date()
    
    // 음악 재생 관련 State
    let songInfo: SongInfo
    @State private var player: AVPlayer = AVPlayer()
    @State private var mode: PlayMode = .ar
    @State private var currentTime: Double = 0
    @State private var playbackTimer: Timer?
    @State private var autoProgressTimer: Timer?
    @State private var currentSegmentIndex = 0
    @State private var segments: [LyricSegment] = []
    @State private var lyricLines: [LyricLine] = []
    
    //View용 찌끄레기 State
    @State private var isBackPressed: Bool = false
    @State private var isRetryPressed: Bool = false
    @State private var isNextPressed: Bool = false
    
    
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect() // ~60fps
    
    var hasNextLine: Bool {
        guard nextLineIndex < lyricLines.count,
              nextLineIndex < segments.count,
              currentSegmentIndex < segments.count else { return false }
        return segments[currentSegmentIndex].index == segments[nextLineIndex].index
    }
    
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
        
        ZStack{
            Image("MetronomeField")
                .resizable()
                .scaledToFit()
                .frame(width: 1250, height: 279)
            VStack {
                HStack {
                    
                    Button(action: {
                        
                    }) {
                        Image("Power")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 76, height: 76)
                    }
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Image(mode == .ar ? "WhoChang" : "SeonChang")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 121, height: 67)
                        .padding(.trailing, 5)
                }
                .padding(.bottom, 3)
            }
            .frame(width: 1250, height: 279)
                
                HStack(spacing: 20) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(getMetronomeCircleColor(for: index))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                    }
            }
        }
        .padding(.bottom, 0)
        .padding(.top, 40)
        
        //MARK: ----------------------------------------------------------------------------------------------------------
        
        
        ZStack{
            RoundedRectangle(cornerRadius: 40)
                .fill(Color(Color(hex: "DDDDDD")))
                .frame(width: 1250, height: 421)
            
            //MARK: 여기야
            if let count = countdown {
                let circleColors: [Color] = [Color(hex:"00484A"), Color(hex:"007A7D"), Color(hex:"00ADB2"), Color(hex:"04D1D7")]
                VStack {
                    HStack(spacing: 20) {
                        ForEach(0..<4) { index in
                            if index <= count {
                                ZStack {
                                    Circle()
                                        .fill(circleColors[index])
                                        .frame(width: 50, height: 50)
                                    Text(["1", "2", "3", "4"][index])
                                        .font(.system(size: 40))
                                        .bold()
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .padding()
                .padding(.top, 20)
                .padding(.leading, 120)
            }
            VStack{
                
                ZStack(alignment: .leading) {
                    Text(fullText)
                        .foregroundColor(.gray)
                        .bold()
                    
                    HStack(spacing: 0) {
                        //이미 파란색으로 채워진 텍스트들
                        Text(highlightedText)
                            .foregroundColor(Color(hex: "00B6BA"))
                            .bold()
                        
                        //두개로 label을 나눠서 마스크 & 텍스트를 두개로 해버리는게 나을까?
                        //아니면 mask가 Text 위치를 따라갈 수 있는 방법이 있을까?
                        if !currentChar.isEmpty {
                            Text(currentChar)
                                .foregroundColor(Color(hex: "00B6BA"))
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
                .font(.system(size: 96))
                .padding(.bottom, 0)
                
                
                
                ZStack{
                    if hasNextLine {
                        ZStack(alignment: .leading) {
                            Text(nextfullText)
                                .foregroundColor(.gray)
                                .bold()
                            
                            HStack(spacing: 0) {
                                
                                //이미 파란색으로 채워진 텍스트들
                                Text(nexthighlightedtext)
                                    .foregroundColor(Color(hex: "00B6BA"))
                                    .bold()

                                if !nextcurrentChar.isEmpty {
                                    Text(nextcurrentChar)
                                        .foregroundColor(Color(hex: "00B6BA"))
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
                        .font(.system(size: 96))
                        .padding(.top, 0)
                    }
                }
            }
        }
        .padding(.bottom, 40)
        .padding(.top, 16)
            
        HStack(spacing: 45){
            Button(action: previous) {
                Image(isBackPressed ? "BackPressed" : "Back")
                    .resizable()
                    .frame(width: 172, height: 172)
                    .scaledToFit()
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                isBackPressed = true
                            }
                            .onEnded { _ in
                                isBackPressed = false
                                previous()
                            }
                    )
            }
            .disabled(currentSegmentIndex <= 0)
            
            Button(action: replay) {
                Image(isRetryPressed ? "Retry_Pressed" : "Retry")
                    .resizable()
                    .frame(width: 172, height: 172)
                    .scaledToFit()
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                isRetryPressed = true
                            }
                            .onEnded { _ in
                                isRetryPressed = false
                                replay()
                            }
                    )
            }
            
            Button(action: next) {
                Image(isNextPressed ? "Next_Pressed" : "Next")
                    .resizable()
                    .frame(width: 172, height: 172)
                    .scaledToFit()
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                isNextPressed = true
                            }
                            .onEnded { _ in
                                isNextPressed = false
                                next()
                            }
                    )
            }
            .disabled(currentSegmentIndex >= segments.count - 1)
        }
        .padding(.bottom, 40)
        
        .onAppear {
            setupAudio()
            loadLyrics()
            
            if !lyricLines.isEmpty {
                updateCurrentLines()
            }
        }
        .onDisappear {
            stopPlayback()
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
    
    func getMetronomeCircleColor(for index: Int) -> Color {
        // 더미 로직 - 수정 필요
        if let count = countdown {
            return index < count ? .blue : .clear
        }
        return .clear
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
    
    func updateCurrentLines() {
        guard currentLineIndex < lyricLines.count else { return }
        
        currentLine = lyricLines[currentLineIndex]
        nextLineIndex = currentLineIndex + 1
        if nextLineIndex < lyricLines.count && hasNextLine {
            nextLine = lyricLines[nextLineIndex]
        }
    }
    
    func resetCharacterStates() {
        currentCharacterIndex = 0
        nextCharacterIndex = 0
        currentCharacterProgress = 0
        nextCharacterProgress = 0
        countdown = 0
        startCountdown()
    }
    
    func resetCharacterStatesForMR() {
        currentCharacterIndex = 0
        nextCharacterIndex = 0
        currentCharacterProgress = 0
        nextCharacterProgress = 0
        countdown = 0
        startCountdownForMR()
    }
    
    func previous() {
        print("=== PREVIOUS")
        guard currentSegmentIndex > 0 else { return }
        
        // 재생 중지 및 모드 초기화
        stopPlayback()
        mode = .ar
        
        let currentIndex = segments[currentSegmentIndex].index
        var targetSegmentIndex = currentSegmentIndex - 1
        
        while targetSegmentIndex >= 0 && segments[targetSegmentIndex].index == currentIndex {
            targetSegmentIndex -= 1
        }
        
        if targetSegmentIndex >= 0 {
            let targetIndex = segments[targetSegmentIndex].index
            while targetSegmentIndex > 0 && segments[targetSegmentIndex - 1].index == targetIndex {
                targetSegmentIndex -= 1
            }
            
            currentSegmentIndex = targetSegmentIndex
            currentLineIndex = findLineIndexBySegmentIndex(targetSegmentIndex)
            updateCurrentLines()
            replay()
        }
    }
    
    func next() {
        print("=== NEXT")
        guard currentSegmentIndex < segments.count - 1 else { return }
        
        stopPlayback()
        mode = .ar
        
        let currentIndex = segments[currentSegmentIndex].index
        var targetSegmentIndex = currentSegmentIndex + 1
        
        while targetSegmentIndex < segments.count && segments[targetSegmentIndex].index == currentIndex {
            targetSegmentIndex += 1
        }
        
        if targetSegmentIndex < segments.count {
            currentSegmentIndex = targetSegmentIndex
            currentLineIndex = findLineIndexBySegmentIndex(targetSegmentIndex)
            updateCurrentLines()
            replay()
        }
    }
    
    // 세그먼트 인덱스에 해당하는 가사 라인 인덱스 찾는 함수
    func findLineIndexBySegmentIndex(_ segmentIndex: Int) -> Int {
        guard segmentIndex < segments.count else { return 0 }
        let targetIndex = segments[segmentIndex].index
        
        // 해당 index를 가진 첫 번째 라인 찾기
        for (lineIndex, segment) in segments.enumerated() {
            if segment.index == targetIndex {
                return lineIndex
            }
        }
        return segmentIndex // 찾지 못한 경우 segmentIndex 반환
    }
    
    func replay() {
        guard currentSegmentIndex < segments.count else { return }
        
        stopPlayback()
        mode = .ar
        
        let segment = segments[currentSegmentIndex]
        let fileName = songInfo.arFileName // 항상 AR부터 시작
        
        guard let url = Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".mp3", with: ""), withExtension: "mp3") else {
            print("오디오 파일을 찾을 수 없습니다: \(fileName)")
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        
        let startTime = CMTime(seconds: segment.startTime, preferredTimescale: 600)
        player.seek(to: startTime) { [self] _ in
            // 카운트다운이 끝나면 재생 시작
            resetCharacterStates()
        }
    }
    
    func startPlaybackTimer(segment: LyricSegment) {
        stopTimer()
        
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] timer in
            let currentTime = player.currentTime().seconds
            
            if currentTime >= segment.endTime {
                player.pause()
                timer.invalidate()
                
                if mode == .ar {
                    autoProgressTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                        mode = .mr
                        startMRPlayback(segment: segment)
                    }
                }
            }
            
            self.currentTime = currentTime
        }
    }
    
    func startMRPlayback(segment: LyricSegment) {
        let fileName = songInfo.mrFileName
        
        guard let url = Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".mp3", with: ""), withExtension: "mp3") else {
            print("MR 파일을 찾을 수 없습니다: \(fileName)")
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        
        let startTime = CMTime(seconds: segment.startTime, preferredTimescale: 600)
        player.seek(to: startTime) { [self] _ in
            // MR 재생 전에도 카운트다운 시작
            resetCharacterStatesForMR()
        }
    }
    
    func stopTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
        autoProgressTimer?.invalidate()
        autoProgressTimer = nil
    }
    
    func stopPlayback() {
        player.pause()
        stopTimer()
    }
    
    // 하나 둘 셋 넷 카운터 (AR용)
    private func startCountdown() {
        countdownTimer?.invalidate()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 0.37, repeats: true) { timer in
            guard let currentCount = countdown else { return }
            
            countdown = currentCount + 1
            
            if countdown! >= 4 {
                countdown = nil
                isCountingDown = false
                timer.invalidate()
                countdownTimer = nil
                
                // 카운트다운이 끝나면 음악 재생 시작
                guard currentSegmentIndex < segments.count else { return }
                let segment = segments[currentSegmentIndex]
                player.play()
                startPlaybackTimer(segment: segment)
                
                // 가사 타이밍 시작
                currentCharDuration = lyricsWithDuration.first?.1 ?? 0.0
                startTime = Date()
                if hasNextLine {
                    nextCharDuration = NextlyricsWithDuration.first?.1 ?? 0.0
                    nextstartTime = Date()
                }
            }
        }
    }
    
    // 하나 둘 셋 넷 카운터 (MR용)
    private func startCountdownForMR() {
        countdownTimer?.invalidate()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 0.37, repeats: true) { timer in
            guard let currentCount = countdown else { return }
            
            countdown = currentCount + 1
            
            if countdown! >= 4 {
                countdown = nil
                isCountingDown = false
                timer.invalidate()
                countdownTimer = nil
                
                // 카운트다운이 끝나면 MR 재생 시작
                guard currentSegmentIndex < segments.count else { return }
                let segment = segments[currentSegmentIndex]
                player.play()
                startPlaybackTimer(segment: segment)
                
                // 가사 타이밍 시작
                currentCharDuration = lyricsWithDuration.first?.1 ?? 0.0
                startTime = Date()
                if hasNextLine {
                    nextCharDuration = NextlyricsWithDuration.first?.1 ?? 0.0
                    nextstartTime = Date()
                }
            }
        }
    }
}

// MARK: - Data Models
struct LyricLine {
    let text: String
    let timings: [Double]
    
    var characterDurations: [(String, Double)] {
        let chars = Array(text).map { String($0) }
        guard timings.count > 1 else { return [] }
        
        let durations = zip(timings, timings.dropFirst()).map { $1 - $0 }
        let result = Array(zip(chars, durations))
        
        // 문자 수와 duration 수가 맞지 않으면 빈 배열 반환
        guard result.count <= chars.count else { return [] }
        
        return result
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
