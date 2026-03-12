import Foundation
import UIKit

// MARK: 发现页业务逻辑

/// 发现页业务逻辑类
/// 职责：封装帖子全量获取、关键词搜索、宠物类别筛选
/// 分页/推荐用户/关注等功能已移除，UI 与逻辑完全解耦
class DiscoverLogic_Doze {

    // MARK: - 单例

    static let shared_Doze = DiscoverLogic_Doze()
    private init() {}

    // MARK: - 私有属性

    /// 当前激活的宠物类别（默认全部）
    private var currentCategory_Doze: PetCategory_Doze = .all_doze

    // MARK: - 公共方法 - 获取全量帖子

    /// 获取当前类别筛选下的全量帖子
    /// 无搜索词时调用，返回按类别过滤后所有帖子
    /// - Returns: [TitleModel_Doze]
    func getAllFilteredPosts_Doze() -> [TitleModel_Doze] {
        return getFilteredSource_Doze()
    }

    // MARK: - 公共方法 - 搜索

    /// 按关键词全文搜索帖子（标题 / 内容 / 用户名，不区分大小写）
    /// - Parameter keyword_doze: 搜索关键词，空字符串则返回当前类别全量帖子
    /// - Returns: [TitleModel_Doze]
    func searchPosts_Doze(keyword_doze: String) -> [TitleModel_Doze] {
        let trimmed_doze = keyword_doze.trimmingCharacters(in: .whitespaces)
        guard !trimmed_doze.isEmpty else { return getFilteredSource_Doze() }
        let lower_doze = trimmed_doze.lowercased()
        return getFilteredSource_Doze().filter {
            $0.title_Doze.lowercased().contains(lower_doze) ||
            $0.titleContent_Doze.lowercased().contains(lower_doze) ||
            $0.titleUserName_Doze.lowercased().contains(lower_doze)
        }
    }

    // MARK: - 公共方法 - 分类筛选

    /// 按宠物类别切换帖子列表
    /// - Parameter category_doze: 目标类别，.all_doze 返回全部
    /// - Returns: [TitleModel_Doze]
    func filterByCategory_Doze(category_doze: PetCategory_Doze) -> [TitleModel_Doze] {
        currentCategory_Doze = category_doze
        return getFilteredSource_Doze()
    }

    // MARK: - 私有工具

    /// 根据 currentCategory_Doze 过滤全量帖子
    private func getFilteredSource_Doze() -> [TitleModel_Doze] {
        let all_doze = TitleViewModel_Doze.shared_Doze.getPosts_Doze()
        guard currentCategory_Doze != .all_doze else { return all_doze }
        return all_doze.filter { $0.petCategory_Doze == currentCategory_Doze }
    }
}
