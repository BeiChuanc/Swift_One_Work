import Foundation
import UIKit

// MARK: 发现页 ViewModel

/// 发现页状态管理类
/// 功能：负责发现页数据供给，包括搜索、标签筛选、花卉百科、热门帖子、推荐用户
/// 设计：@MainActor 单例，不重复实现用户关注、帖子点赞等已有逻辑
@MainActor
class DiscoverViewModel_Sprig {
    
    /// 单例
    static let shared_Sprig = DiscoverViewModel_Sprig()
    
    private init() {}
    
    // MARK: - 花卉百科
    
    /// 获取全部花卉百科列表
    /// 返回值：[FlowerModel_Sprig] 全部15种花卉
    func getAllFlowers_Sprig() -> [FlowerModel_Sprig] {
        return LocalData_Sprig.shared_Sprig.flowerList_Sprig
    }
    
    /// 根据月份获取当季花卉
    /// 参数：month_sprig - 月份（1-12），默认当前月
    /// 返回值：[FlowerModel_Sprig]
    func getFlowersByMonth_Sprig(month_sprig: Int? = nil) -> [FlowerModel_Sprig] {
        let targetMonth_sprig = month_sprig ?? Calendar.current.component(.month, from: Date())
        return LocalData_Sprig.shared_Sprig.flowerList_Sprig.filter {
            $0.bloomMonths_Sprig.contains(targetMonth_sprig)
        }
    }
    
    // MARK: - 标签
    
    /// 获取全部标签列表
    /// 返回值：[FlowerTagModel_Sprig] 8个分类标签
    func getAllTags_Sprig() -> [FlowerTagModel_Sprig] {
        return LocalData_Sprig.shared_Sprig.tagList_Sprig
    }
    
    // MARK: - 帖子筛选
    
    /// 实时搜索帖子
    /// 功能：在帖子标题和内容中进行不区分大小写的关键词匹配
    /// 参数：keyword_sprig - 搜索关键词（空字符串返回全部）
    /// 返回值：[TitleModel_Sprig]
    func searchPosts_Sprig(keyword_sprig: String) -> [TitleModel_Sprig] {
        let trimmed_sprig = keyword_sprig.trimmingCharacters(in: .whitespaces)
        guard !trimmed_sprig.isEmpty else {
            return TitleViewModel_Sprig.shared_Sprig.getPosts_Sprig()
        }
        let lower_sprig = trimmed_sprig.lowercased()
        return TitleViewModel_Sprig.shared_Sprig.getPosts_Sprig().filter {
            $0.title_Sprig.lowercased().contains(lower_sprig) ||
            $0.titleContent_Sprig.lowercased().contains(lower_sprig) ||
            $0.titleUserName_Sprig.lowercased().contains(lower_sprig) ||
            $0.titleTags_Sprig.contains(where: { $0.lowercased().contains(lower_sprig) })
        }
    }
    
    /// 根据标签筛选帖子
    /// 功能：通过标签关联关键词在帖子标签和内容中匹配
    /// 参数：tag_sprig - 标签模型，nil 返回热门帖子（点赞降序）
    /// 返回值：[TitleModel_Sprig]
    func getPostsByTag_Sprig(tag_sprig: FlowerTagModel_Sprig?) -> [TitleModel_Sprig] {
        guard let tag_sprig = tag_sprig else {
            return getHotPosts_Sprig()
        }
        let allPosts_sprig = TitleViewModel_Sprig.shared_Sprig.getPosts_Sprig()
        let keywords_sprig = tag_sprig.relatedKeywords_Sprig.map { $0.lowercased() }
        return allPosts_sprig.filter { post_sprig in
            // 先匹配帖子标签
            let tagMatch_sprig = post_sprig.titleTags_Sprig.contains { postTag_sprig in
                keywords_sprig.contains(postTag_sprig.lowercased())
            }
            if tagMatch_sprig { return true }
            // 再匹配内容关键词
            let contentLower_sprig = post_sprig.titleContent_Sprig.lowercased()
            let titleLower_sprig = post_sprig.title_Sprig.lowercased()
            return keywords_sprig.contains { kw_sprig in
                contentLower_sprig.contains(kw_sprig) || titleLower_sprig.contains(kw_sprig)
            }
        }
    }
    
    /// 获取热门帖子（点赞数降序）
    /// 返回值：[TitleModel_Sprig]
    func getHotPosts_Sprig() -> [TitleModel_Sprig] {
        return TitleViewModel_Sprig.shared_Sprig.getPosts_Sprig()
            .sorted { $0.likes_Sprig > $1.likes_Sprig }
    }
    
    // MARK: - 推荐用户
    
    /// 获取推荐关注的用户列表
    /// 功能：返回除当前登录用户以外、按粉丝数降序排列的用户
    /// 返回值：[PrewUserModel_Sprig] 最多返回8个
    func getRecommendedUsers_Sprig() -> [PrewUserModel_Sprig] {
        let currentId_sprig = UserViewModel_Sprig.shared_Sprig.getCurrentUser_Sprig().userId_Sprig ?? 0
        let users_sprig = LocalData_Sprig.shared_Sprig.userList_Sprig
            .filter { ($0.userId_Sprig ?? 0) != currentId_sprig }
            .sorted { ($0.userFans_Sprig ?? 0) > ($1.userFans_Sprig ?? 0) }
        return Array(users_sprig.prefix(8))
    }
    
    // MARK: - 花卉详情辅助
    
    /// 生成花期月份描述字符串
    /// 功能：将月份数组转换为可读文字，如 [3,4,5] → "Mar – May"
    /// 参数：months_sprig - 月份数组（1-12）
    /// 返回值：String 花期描述
    func bloomMonthsDescription_Sprig(months_sprig: [Int]) -> String {
        guard !months_sprig.isEmpty else { return "Year-round" }
        if months_sprig.count >= 10 { return "Year-round" }
        let shortMonths_sprig = ["Jan","Feb","Mar","Apr","May","Jun",
                                 "Jul","Aug","Sep","Oct","Nov","Dec"]
        let sorted_sprig = months_sprig.sorted()
        if let first_sprig = sorted_sprig.first, let last_sprig = sorted_sprig.last {
            if first_sprig == last_sprig {
                return shortMonths_sprig[first_sprig - 1]
            }
            return "\(shortMonths_sprig[first_sprig - 1]) – \(shortMonths_sprig[last_sprig - 1])"
        }
        return "Year-round"
    }
    
    /// 生成难度描述
    /// 参数：level_sprig - 难度等级（1-3）
    /// 返回值：String
    func careLevelDescription_Sprig(level_sprig: Int) -> String {
        switch level_sprig {
        case 1: return "Easy"
        case 2: return "Moderate"
        case 3: return "Expert"
        default: return "Easy"
        }
    }
}
