import FirebaseAI
import Foundation

final class QueryGenerateManager {
  private var model: GenerativeModel?
  
  init() {
    let firebaseService = FirebaseAI.firebaseAI(backend: .googleAI())
    model = firebaseService.generativeModel(modelName: "gemini-2.0-flash")
  }
}

extension QueryGenerateManager {
  func generate(inputText: String) async throws -> String {
    guard let model else { return "" }
    
    var result = ""
    
    let outputContentStream = try model.generateContentStream(
      """
      다음 사용자 입력 텍스트에서 노래 검색에 필요한 '가수'와 '노래 제목'을 추출하여 **가장 적절한 검색어 문자열**을 만들어줘.
      **불필요한 단어나 문장은 제거하고, 오직 가수와 노래 제목을 공백으로 연결한 형태의 핵심 검색어만 반환해야 해.**
      만약 가수나 노래 제목을 특정할 수 없다면, **빈 문자열("")**을 반환해줘.
      **다른 추가적인 설명이나 정보, 마크다운(예: ```json)은 일체 포함하지 말고, 오직 검색어 문자열만 반환해줘.**

      [예시 시작]
      사용자 입력: "싸이의 강남스타일 찾아줘"
      출력: "싸이 강남스타일"

      사용자 입력: "싸이의 강남스타일 틀어줘"
      출력: "싸이 강남스타일"

      사용자 입력: "그 싸이 노래 있잖아, 강남스타일 인가?, 그거 들려줘"
      출력: "싸이 강남스타일"

      사용자 입력: "강남스타일 싸이 재생해 줘"
      출력: "싸이 강남스타일"

      사용자 입력: "아이유의 좋은 날 들려줘"
      출력: "아이유 좋은 날"

      사용자 입력: "아이유의 좋은 날 재생해줘"
      출력: "아이유 좋은 날"

      사용자 입력: "BTS Dynamite 찾아줘"
      출력: "BTS Dynamite"

      사용자 입력: "BTS Dynamite 틀어줘"
      출력: "BTS Dynamite"

      사용자 입력: "옛날 노래 중에 아무노래 그거 찾아줘"
      출력: "아무노래"

      사용자 입력: "아무노래 틀어줘"
      출력: "아무노래"

      사용자 입력: "블랙핑크 노래 틀어줘"
      출력: "블랙핑크"

      사용자 입력: "최신 팝송 찾아줘"
      출력: ""

      사용자 입력: "그 윤하 노래, 비밀번호 486인가? 재생해줘"
      출력: "윤하 비밀번호 486"

      사용자 입력: "버스커버스커 정류장 틀어줘"
      출력: "버스커버스커 정류장"

      사용자 입력: "진성의 나그네 고향 틀어줘"
      출력: "진성 나그네 고향"

      사용자 입력: "나그네 고향 진성 노래 찾아줘"
      출력: "진성 나그네 고향"

      사용자 입력: "진성의 나그네 고향 들려줘"
      출력: "진성 나그네 고향"

      사용자 입력: "진성 나그네 고향 재생해 줘"
      출력: "진성 나그네 고향"

      사용자 입력: "나그네 고향 진성 나와?"
      출력: "진성 나그네 고향"

      사용자 입력: "내여자 내남자 배금성 노래 틀어줘"
      출력: "배금성 내여자 내남자"

      사용자 입력: "배금성의 내여자 내남자 찾아주세요"
      출력: "배금성 내여자 내남자"

      사용자 입력: "가시 강문경 틀어줘"
      출력: "강문경 가시"

      사용자 입력: "강문경의 가시 좀 들려줘"
      출력: "강문경 가시"

      사용자 입력: "강문경 가시 재생해 줘"
      출력: "강문경 가시"

      사용자 입력: "윤정아 인생대로 60번길 틀어줘"
      출력: "윤정아 인생대로 60번길"

      사용자 입력: "인생대로 60번길 윤정아 노래 찾아줘"
      출력: "윤정아 인생대로 60번길"

      사용자 입력: "윤정아 인생대로 60번길 좀 들려줘"
      출력: "윤정아 인생대로 60번길"

      사용자 입력: "나훈아 테스형! 틀어줘"
      출력: "나훈아 테스형!"

      사용자 입력: "김광석 사랑했지만 찾아줘"
      출력: "김광석 사랑했지만"

      사용자 입력: "악동뮤지션 어떻게 이별까지 사랑하겠어 널 사랑하는 거지 틀어줘"
      출력: "악동뮤지션 어떻게 이별까지 사랑하겠어 널 사랑하는 거지"

      사용자 입력: "비비 밤양갱 들려줘"
      출력: "비비 밤양갱"

      사용자 입력: "아이브 러브 다이브 재생해 줘"
      출력: "IVE LOVE DIVE"

      사용자 입력: "르세라핌 이지 찾아줘"
      출력: "LE SSERAFIM EASY"

      사용자 입력: "엔시티 드림 츄잉껌 틀어줘"
      출력: "NCT DREAM Chewing Gum"
      
      사용자 입력: "밝은 성의 내여자 내남자 틀어줘"
      출력: "배금성 내여자 내남자"

      사용자 입력: "배은정의 내여자 내남자 재생"
      출력: "배금성 내여자 내남자"

      사용자 입력: "100 음성의 내여자 내남자 틀어줘"
      출력: "배금성 내여자 내남자"

      사용자 입력: "백금성의 내 여자 내 남자 노래 틀어줘"
      출력: "배금성 내여자 내남자"

      사용자 입력: "배 음성에 내여자 내남자"
      출력: "배금성 내여자 내남자"

      사용자 입력: "최금성의 내 여자 내 남자 노래"
      출력: "배금성 내여자 내남자"

      사용자 입력: "백암성 내 여자 내 남자"
      출력: "배금성 내여자 내남자"

      사용자 입력: "내 여자 내 남자 배 음성"
      출력: "배금성 내여자 내남자"
      
      [예시 끝]

      사용자 입력: \(inputText)
      출력:
      """
    )
    
    for try await outputContent in outputContentStream {
      if let line = outputContent.text {
        result = result + line
      }
    }
    
    return result
  }
}
