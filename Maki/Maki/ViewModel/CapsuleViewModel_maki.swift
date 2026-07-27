import Foundation
import UIKit

// MARK: 手作成长与时光胶囊ViewModel

/// 手作技艺等级枚举
/// 功能：依据用户已发布作品数量，划分手作技艺成长阶段，作为"成长阶梯"可视化的数据基础
enum CraftLevel_Maki: Int, CaseIterable {
    /// 新手入门
    case beginner_maki = 0
    /// 进阶创作者
    case intermediate_maki = 1
    /// 造物大师
    case advanced_maki = 2

    /// 等级标题
    var title_Maki: String {
        switch self {
        case .beginner_maki:     return "Beginner Maker"
        case .intermediate_maki: return "Skilled Crafter"
        case .advanced_maki:     return "Master Artisan"
        }
    }

    /// 等级副标题（描述该阶段特征）
    var subtitle_Maki: String {
        switch self {
        case .beginner_maki:     return "Small items, big beginnings"
        case .intermediate_maki: return "Complex builds, growing skill"
        case .advanced_maki:     return "Large custom creations"
        }
    }

    /// 等级图标（SF Symbol）
    var icon_Maki: String {
        switch self {
        case .beginner_maki:     return "leaf.fill"
        case .intermediate_maki: return "hammer.fill"
        case .advanced_maki:     return "crown.fill"
        }
    }

    /// 达到该等级所需的最少作品数
    var threshold_Maki: Int {
        switch self {
        case .beginner_maki:     return 0
        case .intermediate_maki: return 3
        case .advanced_maki:     return 8
        }
    }
}

/// 手作成长与时光胶囊状态管理类
/// 功能：管理"手作时光胶囊"的封存/开启、"旧料改造"推荐方案获取、"成长阶梯"等级计算
/// 设计：单例 + 通知驱动状态更新；胶囊数据存储于内存，随应用生命周期存在（与其他 ViewModel 保持一致）
@MainActor
class CapsuleViewModel_Maki {

    /// 单例
    static let shared_Maki = CapsuleViewModel_Maki()

    // MARK: - 通知名称

    /// 胶囊状态更新通知
    static let capsuleStateDidChangeNotification_Maki = Notification.Name("CapsuleStateDidChange_Maki")

    // MARK: - 私有属性

    /// 全部用户的时光胶囊列表
    private var capsules_Maki: [TimeCapsuleModel_Maki] = []

    /// 下一个胶囊自增ID
    private var nextCapsuleId_Maki: Int = 1

    private init() {}

    // MARK: - 公共方法 - 时光胶囊

    /// 获取当前登录用户的全部胶囊（按开启日期升序排列）
    func getCapsules_Maki() -> [TimeCapsuleModel_Maki] {
        let userId_maki = UserViewModel_Maki.shared_Maki.getCurrentUser_Maki().userId_Maki ?? 0
        return capsules_Maki
            .filter { $0.ownerId_Maki == userId_maki }
            .sorted { $0.openDate_Maki < $1.openDate_Maki }
    }

    /// 获取已到开启时间但尚未被查看的胶囊（用于首页弹窗提醒回看）
    func getReadyToOpenCapsule_Maki() -> TimeCapsuleModel_Maki? {
        getCapsules_Maki().first { $0.isUnlocked_Maki && !$0.isOpened_Maki }
    }

    /// 获取最近一个尚未解锁的胶囊（用于首页倒计时展示）
    func getNextLockedCapsule_Maki() -> TimeCapsuleModel_Maki? {
        getCapsules_Maki().first { !$0.isUnlocked_Maki }
    }

    /// 封存新的手作时光胶囊
    /// 参数：
    /// - coverMedia_maki: 成品实拍封面路径
    /// - videoPath_maki: 制作步骤视频路径（可选）
    /// - materials_maki: 材料清单
    /// - mood_maki: 制作当天心情（emoji）
    /// - giftTo_maki: 赠送对象
    /// - story_maki: 背后小故事
    /// - openDate_maki: 开启日期
    func createCapsule_Maki(
        coverMedia_maki: String,
        videoPath_maki: String?,
        materials_maki: [String],
        mood_maki: String,
        giftTo_maki: String,
        story_maki: String,
        openDate_maki: Date
    ) {
        guard UserViewModel_Maki.shared_Maki.isLoggedIn_Maki else {
            showLoginPrompt_Maki()
            return
        }

        let userId_maki = UserViewModel_Maki.shared_Maki.getCurrentUser_Maki().userId_Maki ?? 0
        let capsule_maki = TimeCapsuleModel_Maki(
            capsuleId_Maki: nextCapsuleId_Maki,
            ownerId_Maki: userId_maki,
            coverMedia_Maki: coverMedia_maki,
            videoPath_Maki: videoPath_maki,
            materials_Maki: materials_maki,
            mood_Maki: mood_maki,
            giftTo_Maki: giftTo_maki,
            story_Maki: story_maki,
            createDate_Maki: Date(),
            openDate_Maki: openDate_maki
        )
        nextCapsuleId_Maki += 1
        capsules_Maki.append(capsule_maki)

        Load_Maki.showSuccess_Maki(
            message_Maki: "Time capsule sealed!",
            image_Maki: UIImage(systemName: "shippingbox.fill")
        )
        notifyStateChange_Maki()
    }

    /// 标记胶囊为已开启查看
    /// 参数：
    /// - capsule_maki: 目标胶囊
    func markOpened_Maki(capsule_maki: TimeCapsuleModel_Maki) {
        guard let index_maki = capsules_Maki.firstIndex(where: { $0.capsuleId_Maki == capsule_maki.capsuleId_Maki }) else { return }
        capsules_Maki[index_maki].isOpened_Maki = true
        notifyStateChange_Maki()
    }

    // MARK: - 公共方法 - 旧料改造推荐

    /// 获取系统推荐的旧料改造方案列表
    func getReuseIdeas_Maki() -> [MaterialReuseIdeaModel_Maki] {
        ReuseIdeaSource_Maki.ideas_Maki
    }

    // MARK: - 公共方法 - 成长阶梯

    /// 当前登录用户已发布作品数量
    func postsCount_Maki() -> Int {
        UserViewModel_Maki.shared_Maki.getCurrentUser_Maki().userPosts_Maki.count
    }

    /// 根据作品数量计算当前手作等级
    func currentLevel_Maki() -> CraftLevel_Maki {
        let count_maki = postsCount_Maki()
        if count_maki >= CraftLevel_Maki.advanced_maki.threshold_Maki { return .advanced_maki }
        if count_maki >= CraftLevel_Maki.intermediate_maki.threshold_Maki { return .intermediate_maki }
        return .beginner_maki
    }

    /// 距离下一等级所需的作品数量（已是最高等级时返回 0）
    func postsToNextLevel_Maki() -> Int {
        let level_maki = currentLevel_Maki()
        guard let next_maki = CraftLevel_Maki(rawValue: level_maki.rawValue + 1) else { return 0 }
        return max(0, next_maki.threshold_Maki - postsCount_Maki())
    }

    // MARK: - 私有方法

    /// 发送状态更新通知
    private func notifyStateChange_Maki() {
        NotificationCenter.default.post(
            name: CapsuleViewModel_Maki.capsuleStateDidChangeNotification_Maki,
            object: nil
        )
    }

    /// 显示登录引导（延迟 0.5 秒后跳转登录页）
    private func showLoginPrompt_Maki() {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            Navigation_Maki.toLogin_Maki(style_maki: .present_maki)
        }
    }
}

// MARK: - 静态数据源

/// 旧料改造灵感静态数据源（系统预置推荐方案，仅供 CapsuleViewModel_Maki 内部使用）
private enum ReuseIdeaSource_Maki {

    static let ideas_Maki: [MaterialReuseIdeaModel_Maki] = [
        MaterialReuseIdeaModel_Maki(
            ideaId_Maki: 1,
            beforeMaterial_Maki: "Childhood building blocks",
            afterCreation_Maki: "Desk skyline ornament",
            coverImage_Maki: "title5",
            description_Maki: "Glue leftover blocks into a tiny skyline sculpture — a nostalgic keepsake for your desk.",
            difficulty_Maki: 1
        ),
        MaterialReuseIdeaModel_Maki(
            ideaId_Maki: 2,
            beforeMaterial_Maki: "Old denim & worn shirts",
            afterCreation_Maki: "Patchwork fabric tote",
            coverImage_Maki: "title9",
            description_Maki: "Cut squares from old clothes and stitch them into a sturdy, one-of-a-kind tote bag.",
            difficulty_Maki: 2
        ),
        MaterialReuseIdeaModel_Maki(
            ideaId_Maki: 3,
            beforeMaterial_Maki: "Empty glass jars",
            afterCreation_Maki: "Soy candle holders",
            coverImage_Maki: "title7",
            description_Maki: "Clean out jam jars and repour soy wax for a zero-waste candle set.",
            difficulty_Maki: 1
        ),
        MaterialReuseIdeaModel_Maki(
            ideaId_Maki: 4,
            beforeMaterial_Maki: "Wine corks",
            afterCreation_Maki: "Woven coaster set",
            coverImage_Maki: "title3",
            description_Maki: "Slice corks into discs and bind them with waxed thread for rustic coasters.",
            difficulty_Maki: 2
        ),
        MaterialReuseIdeaModel_Maki(
            ideaId_Maki: 5,
            beforeMaterial_Maki: "Scrap leather offcuts",
            afterCreation_Maki: "Mini card wallet",
            coverImage_Maki: "title3",
            description_Maki: "Piece together small leather scraps into a compact hand-stitched card holder.",
            difficulty_Maki: 3
        ),
        MaterialReuseIdeaModel_Maki(
            ideaId_Maki: 6,
            beforeMaterial_Maki: "Leftover clay trimmings",
            afterCreation_Maki: "Tiny stamp set",
            coverImage_Maki: "title10",
            description_Maki: "Roll dry trimmings back into small stamps — nothing goes to waste in the studio.",
            difficulty_Maki: 1
        )
    ]
}
