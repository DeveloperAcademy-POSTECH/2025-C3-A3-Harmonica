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
    @State private var isPlaying = false // 재생 상태 추가
    
    // 메트로놈 관련 State
    @State private var metronomeStartTime: Date?
    @State private var currentBeat: Int = 0
    @State private var beatProgress: CGFloat = 0.0
    @State private var isMetronomeActive = false
    @State private var lastBeatTime: Date = Date()
    @State private var metronomePlayer: AVAudioPlayer?
    
    private var beatsPerMeasure: Int {
        songInfo.timeSignatureTop
    }
    
    private var beatDuration: Double {
        60.0 / Double(songInfo.bpm)
    }

    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
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

        VStack {
            Button(action: {
                // 연습 종료 더미 버튼 - 기능 추가 필요
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            .padding()
            
            Text(mode == .ar ? "선창 (원곡)" : "후창 (반주)")
                .font(.headline)
                .foregroundColor(mode == .ar ? .red : .blue)
                .padding(.horizontal)
            
            Text(songInfo.title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(songInfo.artist)
                .font(.subheadline)
            
            if isPlaying || countdown != nil {
                HStack(spacing: 20) {
                    ForEach(0..<beatsPerMeasure, id: \.self) { index in
                        Circle()
                            .fill(getMetronomeCircleColor(for: index))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                            .overlay(
                                index == currentBeat && isMetronomeActive ?
                                Circle()
                                    .trim(from: 0, to: beatProgress)
                                    .stroke(Color.blue, lineWidth: 4)
                                    .rotationEffect(.degrees(-90))
                                : nil
                            )
                            .scaleEffect(index == currentBeat && isMetronomeActive ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: currentBeat)
                    }
                }
                .transition(.opacity)
            }
            
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
                        Text(nexthighlightedtext)
                            .foregroundColor(.blue)
                            .bold()
                        
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

        .onAppear {
            setupAudio()
            setupMetronomeSound()
            loadLyrics()
            
            if !lyricLines.isEmpty {
                updateCurrentLines()
            }
        }
        .onDisappear {
            stopPlayback()
            stopMetronome()
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
        .onReceive(timer) { _ in
            updateMetronome()
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
    
    func setupMetronomeSound() {
        guard let soundURL = Bundle.main.url(forResource: "metronome_click", withExtension: "wav") else {
            print("No metronome sound file: use system sound")
            return
        }
        
        do {
            metronomePlayer = try AVAudioPlayer(contentsOf: soundURL)
            metronomePlayer?.prepareToPlay()
            metronomePlayer?.volume = 0.5
        } catch {
            print("FAIL metronome sound setting: \(error)")
        }
    }
    
    func playMetronomeSound() {
        guard isPlaying || countdown != nil else { return }
        
        if let player = metronomePlayer {
            player.stop()
            player.currentTime = 0
            player.play()
        } else {
            AudioServicesPlaySystemSound(1103)
        }
    }
    
    func startMetronome() {
        metronomeStartTime = Date()
        lastBeatTime = Date()
        currentBeat = 0
        beatProgress = 0.0
        isMetronomeActive = true
        playMetronomeSound()
    }
    
    func stopMetronome() {
        isMetronomeActive = false
        metronomeStartTime = nil
        currentBeat = 0
        beatProgress = 0.0
    }
    
    func updateMetronome() {
        guard (isPlaying || countdown != nil) && isMetronomeActive, let startTime = metronomeStartTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let totalBeats = elapsed / beatDuration
        
        let newBeat = Int(totalBeats) % beatsPerMeasure
        
        if newBeat != currentBeat {
            currentBeat = newBeat
            playMetronomeSound()
            lastBeatTime = Date()
        }
        
        let beatElapsed = totalBeats - floor(totalBeats)
        beatProgress = CGFloat(beatElapsed)
    }
    
    func getMetronomeCircleColor(for index: Int) -> Color {
        if let count = countdown {
            return index < count ? .blue : .clear
        }
        
        if isMetronomeActive {
            if index == currentBeat {
                return .blue
            } else if index < currentBeat {
                return .blue.opacity(0.3)
            } else {
                return .clear
            }
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
            resetCharacterStates()
        }
    }
        
    func startPlaybackTimer(segment: LyricSegment) {
        stopTimer()
        isPlaying = true // 재생 상태 업데이트
        
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
                } else {
                    // MR 재생 완료 후 재생 상태 업데이트
                    isPlaying = false
                    stopMetronome()
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
        isPlaying = false
        stopTimer()
        stopMetronome()
    }

    // 하나 둘 셋 넷 카운터 (AR용)
    private func startCountdown() {
        countdownTimer?.invalidate()
        
        startMetronome()
        
        let countdownInterval = beatDuration
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: countdownInterval, repeats: true) { timer in
            guard let currentCount = countdown else { return }
            
            countdown = currentCount + 1
            
            if countdown! >= 4 {
                countdown = nil
                isCountingDown = false
                timer.invalidate()
                countdownTimer = nil
                
                guard currentSegmentIndex < segments.count else { return }
                let segment = segments[currentSegmentIndex]
                player.play()
                startPlaybackTimer(segment: segment)
                
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
        
        startMetronome()
        
        let countdownInterval = beatDuration
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: countdownInterval, repeats: true) { timer in
            guard let currentCount = countdown else { return }
            
            countdown = currentCount + 1
            
            if countdown! >= 4 {
                countdown = nil
                isCountingDown = false
                timer.invalidate()
                countdownTimer = nil
                
                guard currentSegmentIndex < segments.count else { return }
                let segment = segments[currentSegmentIndex]
                player.play()
                startPlaybackTimer(segment: segment)
                
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
