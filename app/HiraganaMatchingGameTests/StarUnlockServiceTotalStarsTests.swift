@testable import HiraganaMatchingGame
import Testing

// #19: 実績/コレクション画面はゲーム画面を経由せずに StarUnlockService を作る。
// そのときでも合計スターが LevelProgressionService の値になることを保証する。
// provider はシングルトン上で「最後に生成したものが有効」（#36）。並列ストレステストが他のテストの provider を
// 上書きしないよう、このスイートは直列にする。
@Suite("StarUnlockService の合計スター供給 (#19)", .serialized)
struct StarUnlockServiceTotalStarsTests {
    @Test("ゲーム画面を経由しなくても合計スターは LevelProgressionService の値になる")
    func totalStarsComeFromInjectedLevelProgressionService() {
        let progression = LevelProgressionService(forTesting: true)
        progression.completeLevel(1, earnedStars: 3)
        #expect(progression.getTotalStars() == 3)

        // GameViewModel を作らずに、画面が行うのと同じ方法で生成する
        let service = StarUnlockService(levelProgressionService: progression)

        #expect(service.getStarStatistics().totalStars == 3)
    }

    @Test("次の解放条件も注入された合計スターから計算される")
    func nextUnlockInfoUsesInjectedTotalStars() {
        let progression = LevelProgressionService(forTesting: true)
        progression.completeLevel(1, earnedStars: 3)

        let service = StarUnlockService(levelProgressionService: progression)
        let next = service.getNextUnlockInfo()

        // か行（2 スター）は満たし、さ行（4 スター）まであと 1
        #expect(next?.groupName == "さ行")
        #expect(next?.requiredStars == 1)
    }

    // CI（GitHub Actions）で並列テストが StarUnlockService を同時に生成し、
    // シングルトンの provider closure の二重解放で SIGSEGV になった（run 36296260372）。
    // 失敗するときは #expect ではなくプロセスのクラッシュになる。
    @Test("StarUnlockService を並列に大量生成してもクラッシュしない")
    func concurrentInitializationDoesNotCrash() async {
        let progression = LevelProgressionService(forTesting: true)
        await withTaskGroup(of: Void.self) { group in
            for _ in 0 ..< 500 {
                group.addTask {
                    let service = StarUnlockService(levelProgressionService: progression)
                    _ = service.getStarStatistics().totalStars
                }
            }
        }
        #expect(StarUnlockService(levelProgressionService: progression).getStarStatistics().totalStars == 0)
    }
}
