import Foundation

struct GameQuestion {
    let hiragana: String
    let choices: [HiraganaItem]
    let correctAnswer: HiraganaItem
}


class GameLogicService {
    private let hiraganaDataManager = HiraganaDataManager.shared
    private var userSettings: UserSettings?
    
    init(userSettings: UserSettings? = nil) {
        self.userSettings = userSettings
    }
    
    func isCorrectAnswer(hiragana: String, imageName: String) -> Bool {
        // そのひらがなに対応するすべての選択肢を取得
        let correctItems = hiraganaDataManager.getQuestionVariations(for: hiragana)
        
        // 選択されたimageNameがそのひらがなの正解選択肢の中にあるかチェック
        return correctItems.contains { $0.imageName == imageName }
    }
    
    func generateChoices(for hiragana: String, count: Int) -> [HiraganaItem] {
        return hiraganaDataManager.getRandomChoices(for: hiragana, count: count)
    }
    
    func generateChoicesWithCorrectAnswer(_ correctAnswer: HiraganaItem, count: Int) -> [HiraganaItem] {
        return hiraganaDataManager.getRandomChoicesWithCorrectAnswer(correctAnswer, count: count)
    }
    
    func generateQuestionsForLevel(_ level: Int, questionCount: Int) -> [GameQuestion] {
        let levelConfig = hiraganaDataManager.getLevelConfiguration()
        guard let charactersForLevel = levelConfig[level] else { return [] }
        
        var questions: [GameQuestion] = []
        
        // 難易度に応じて選択肢の数を調整
        let choiceCount = getChoiceCountForDifficulty()
        
        // 各文字を最低1回は出題するようにする
        var allCharacters = charactersForLevel.shuffled()
        var remainingQuestions = questionCount
        
        // 各文字を最低1回ずつ出題
        for character in allCharacters {
            if remainingQuestions <= 0 { break }
            
            guard let correctAnswer = hiraganaDataManager.getItem(for: character) else {
                continue
            }
            
            let choices = generateChoicesWithCorrectAnswer(correctAnswer, count: choiceCount)
            
            let question = GameQuestion(
                hiragana: character,
                choices: choices,
                correctAnswer: correctAnswer
            )
            questions.append(question)
            remainingQuestions -= 1
        }
        
        // 残りの問題数をランダムに埋める
        while remainingQuestions > 0 {
            let randomHiragana = charactersForLevel.randomElement() ?? ""
            
            guard let correctAnswer = hiraganaDataManager.getItem(for: randomHiragana) else {
                continue
            }
            
            let choices = generateChoicesWithCorrectAnswer(correctAnswer, count: choiceCount)
            
            let question = GameQuestion(
                hiragana: randomHiragana,
                choices: choices,
                correctAnswer: correctAnswer
            )
            questions.append(question)
            remainingQuestions -= 1
        }
        
        // 最終的にシャッフルして出題順をランダムにし、連続する同じ答えを回避
        return shuffleWithConsecutiveAvoidance(questions)
    }
    
    private func shuffleWithConsecutiveAvoidance(_ questions: [GameQuestion]) -> [GameQuestion] {
        guard questions.count > 1 else { return questions }
        
        var shuffled = questions.shuffled()
        let maxAttempts = 10
        
        for _ in 0..<maxAttempts {
            var hasConsecutiveDuplicates = false
            
            // 連続する同じ答えがあるかチェック
            for i in 0..<(shuffled.count - 1) {
                if shuffled[i].correctAnswer.imageName == shuffled[i + 1].correctAnswer.imageName {
                    hasConsecutiveDuplicates = true
                    break
                }
            }
            
            if !hasConsecutiveDuplicates {
                break
            }
            
            // 連続する同じ答えがある場合、再シャッフル
            shuffled = questions.shuffled()
        }
        
        return shuffled
    }
    
    private func getChoiceCountForDifficulty() -> Int {
        guard let settings = userSettings else { return 3 }
        
        switch settings.difficulty {
        case .easy:
            return 2  // 2択
        case .normal:
            return 3  // 3択
        case .hard:
            return 4  // 4択
        }
    }
    
    func calculateStars(correctAnswers: Int, totalQuestions: Int) -> Int {
        let accuracy = Double(correctAnswers) / Double(totalQuestions)
        
        // 難易度に応じて必要正解率を調整
        guard let settings = userSettings else {
            return calculateStarsForAccuracy(accuracy, difficulty: .normal)
        }
        
        return calculateStarsForAccuracy(accuracy, difficulty: settings.difficulty)
    }
    
    private func calculateStarsForAccuracy(_ accuracy: Double, difficulty: GameDifficulty) -> Int {
        switch difficulty {
        case .easy:
            // 簡単モード：より高い正解率が必要
            switch accuracy {
            case 1.0:
                return 3
            case 0.9...0.99:
                return 2
            case 0.8...0.89:
                return 1
            default:
                return 0
            }
        case .normal:
            // 普通モード：標準の基準
            switch accuracy {
            case 1.0:
                return 3
            case 0.8...0.99:
                return 2
            case 0.6...0.79:
                return 1
            default:
                return 0
            }
        case .hard:
            // 難しいモード：少し甘めの基準でボーナス
            switch accuracy {
            case 1.0:
                return 3
            case 0.75...0.99:
                return 2
            case 0.5...0.74:
                return 1
            default:
                return 0
            }
        }
    }
    
    
    func calculateGameStats(correctAnswers: Int, totalQuestions: Int, timeTaken: TimeInterval) -> GameStats {
        let accuracy = Double(correctAnswers) / Double(totalQuestions)
        let averageTime = timeTaken / Double(totalQuestions)
        
        return GameStats(
            accuracy: accuracy,
            timeElapsed: timeTaken,
            averageResponseTime: averageTime
        )
    }
    
    
    func validateAnswer(_ answer: String, for hiragana: String) -> Bool {
        return isCorrectAnswer(hiragana: hiragana, imageName: answer)
    }
    
    func generateHint(for hiragana: String) -> String {
        guard let item = hiraganaDataManager.getItem(for: hiragana) else {
            return "ヒントが見つかりません"
        }
        
        // より詳細で役立つヒントを生成
        let hints = getDetailedHints()
        return hints[hiragana] ?? "\(hiragana)は\(item.category)に関係するよ！正解の絵を探してみてね。"
    }
    
    private func getDetailedHints() -> [String: String] {
        return [
            // あ行
            "あ": "「あり」の「あ」だよ！小さくて働き者の虫の絵を探してね。",
            "い": "「いぬ」の「い」だよ！人間の一番の友達、しっぽを振る動物の絵を探してね。",
            "う": "「うさぎ」の「う」だよ！長い耳とぴょんぴょん跳ねる可愛い動物の絵を探してね。",
            "え": "「えび」の「え」だよ！海にいる曲がった背中の美味しい生き物の絵を探してね。",
            "お": "「おに」の「お」だよ！角が生えた怖そうな顔の妖怪の絵を探してね。",
            
            // か行
            "か": "「かに」の「か」だよ！大きなハサミを持った海の生き物の絵を探してね。",
            "き": "「きりん」の「き」だよ！首がとても長くて黄色い動物の絵を探してね。",
            "く": "「くま」の「く」だよ！大きくて毛がふわふわした動物の絵を探してね。",
            "け": "「けーき」の「け」だよ！甘くて美味しいお祝いの食べ物の絵を探してね。",
            "こ": "「こま」の「こ」だよ！くるくる回して遊ぶおもちゃの絵を探してね。",
            
            // さ行
            "さ": "「さる」の「さ」だよ！木登りが上手で尻尾の長い動物の絵を探してね。",
            "し": "「しか」の「し」だよ！立派な角を持った森の動物の絵を探してね。",
            "す": "「すいか」の「す」だよ！大きくて緑色の甘い果物の絵を探してね。",
            "せ": "「せみ」の「せ」だよ！夏に鳴く声の大きな虫の絵を探してね。",
            "そ": "「そら」の「そ」だよ！青くて広がっている空の絵を探してね。",
            
            // た行
            "た": "「たこ」の「た」だよ！8本の足を持った海の生き物の絵を探してね。",
            "ち": "「ちょう」の「ち」だよ！きれいな羽で花から花へ飛ぶ虫の絵を探してね。",
            "つ": "「つる」の「つ」だよ！首が長くて優雅に飛ぶ鳥の絵を探してね。",
            "て": "「て」だよ！物を掴んだり触ったりする体の部分の絵を探してね。",
            "と": "「とけい」の「と」だよ！時間を教えてくれる道具の絵を探してね。",
            
            // な行
            "な": "「なす」の「な」だよ！紫色の野菜の絵を探してね。",
            "に": "「にんじん」の「に」だよ！オレンジ色の細長い野菜の絵を探してね。",
            "ぬ": "「ぬいぐるみ」の「ぬ」だよ！柔らかくて可愛いおもちゃの絵を探してね。",
            "ね": "「ねこ」の「ね」だよ！にゃあと鳴く可愛い動物の絵を探してね。",
            "の": "「のはら」の「の」だよ！広い草原や野原の絵を探してね。",
            
            // は行
            "は": "「はな」の「は」だよ！きれいで良い匂いのする植物の絵を探してね。",
            "ひ": "「ひよこ」の「ひ」だよ！黄色くて小さな可愛い鳥の赤ちゃんの絵を探してね。",
            "ふ": "「ふね」の「ふ」だよ！水の上を進む乗り物の絵を探してね。",
            "へ": "「へび」の「へ」だよ！長くてくねくね動く爬虫類の絵を探してね。",
            "ほ": "「ほね」の「ほ」だよ！体の中にある白い硬いものの絵を探してね。",
            
            // ま行
            "ま": "「まめ」の「ま」だよ！小さくて丸い食べ物の絵を探してね。",
            "み": "「みみ」の「み」だよ！音を聞く体の部分の絵を探してね。",
            "む": "「むし」の「む」だよ！小さな生き物の絵を探してね。",
            "め": "「め」だよ！見るための体の部分の絵を探してね。",
            "も": "「もも」の「も」だよ！ピンク色の甘い果物の絵を探してね。",
            
            // や行
            "や": "「やじるし」の「や」だよ！方向を示す矢印の絵を探してね。",
            "ゆ": "「ゆ」だよ！温かいお風呂の湯気の絵を探してね。",
            "よ": "「よる」の「よ」だよ！暗くなった夜の絵を探してね。",
            
            // ら行
            "ら": "「らっぱ」の「ら」だよ！音楽を奏でる金色の楽器の絵を探してね。",
            "り": "「りんご」の「り」だよ！赤くて丸い美味しい果物の絵を探してね。",
            "る": "「るーぷ」の「る」だよ！輪っかの形をしたものの絵を探してね。",
            "れ": "「れいぞうこ」の「れ」だよ！食べ物を冷やす大きな家電の絵を探してね。",
            "ろ": "「ろうそく」の「ろ」だよ！火をつけて明かりにするものの絵を探してね。",
            
            // わ行
            "わ": "「わ」だよ！指にはめる丸い飾りの絵を探してね。",
            "を": "「をとこ」の「を」だよ！男性の人の絵を探してね。",
            "ん": "「あんてな」の「ん」だよ！電波をキャッチする細い棒の絵を探してね。"
        ]
    }
}