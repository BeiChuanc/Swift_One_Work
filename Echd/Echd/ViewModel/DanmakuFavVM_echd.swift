import Foundation

// MARK: 弹幕数据模型

/// Live Sparks 专用弹幕数据模型（独立于帖子系统）
struct DanmakuModel_Echd: Codable {

    /// 弹幕唯一 ID（预制数据从 5000 起，用户发布从毫秒时间戳生成）
    let danmakuId_Echd: Int

    /// 弹幕文本
    let content_Echd: String

    /// 发布者昵称
    let authorName_Echd: String

    /// 发布者用户 ID（0 = 预制数据）
    let authorId_Echd: Int

    /// 发布时间戳
    let timestamp_Echd: TimeInterval
}

// MARK: 弹幕 ViewModel
// 职责：
//   1. Live Sparks 弹幕池：LocalData 预制 + 用户自发布，已举报/删除的过滤掉
//   2. 弹幕发布（用户）、删除（我发布的）、举报移除（任意条目）
//   3. 弹幕收藏（独立于帖子收藏，用单独的 UserDefaults key）
//   4. 帖子收藏（保持原有接口，供 MyMoments 已收藏帖子使用）

class DanmakuFavVM_Echd {

    // MARK: - 单例

    static let shared_Echd = DanmakuFavVM_Echd()
    private init() {}

    // MARK: - 通知名

    /// 弹幕数据变化（新增/删除/举报）通知
    static let danmakuChangedNotification_Echd = Notification.Name("DanmakuDataChanged_Echd")

    /// 弹幕收藏状态变化通知
    static let favChangedNotification_Echd = Notification.Name("DanmakuFavoritesChanged_Echd")

    // MARK: - UserDefaults Keys

    private let publishedKey_Echd     = "danmaku_published_echd"       // 用户自发布
    private let removedKey_Echd       = "danmaku_removed_ids_echd"     // 已举报/删除 ID 集合
    private let danmakuFavKey_Echd    = "danmaku_fav_danmaku_ids_echd" // 弹幕收藏 IDs
    private let postFavKey_Echd       = "danmaku_fav_ids_echd"         // 帖子收藏 IDs（保持兼容）

    // MARK: - 弹幕池（Live Sparks 数据源）

    /// 获取弹幕流（LocalData 预制 + 用户发布，已移除的过滤掉）
    func getAllDanmaku_Echd() -> [DanmakuModel_Echd] {
        let removed_Echd = removedIds_Echd
        let preset_Echd  = LocalData_Echd.shared_Echd.danmakuList_Echd
        let published_Echd = getStoredPublished_Echd()
        return (preset_Echd + published_Echd)
            .filter { !removed_Echd.contains($0.danmakuId_Echd) }
            .sorted { $0.timestamp_Echd > $1.timestamp_Echd }
    }

    // MARK: - 用户发布弹幕

    /// 发布一条新弹幕并持久化
    /// - Parameters:
    ///   - content_echd: 文本内容
    ///   - authorName_echd: 发布者昵称
    ///   - authorId_echd: 发布者 ID
    ///   - themeIndex_echd: 所属主题下标（0-3）。传入时确保 danmakuId % 4 == themeIndex，
    ///                       使该弹幕能正确出现在对应主题详情页；-1 表示不关联特定主题。
    func publishDanmaku_Echd(content_echd: String,
                             authorName_echd: String,
                             authorId_echd: Int,
                             themeIndex_echd: Int = -1) {
        var list_Echd = getStoredPublished_Echd()

        let rawId_Echd = abs(Int(Date().timeIntervalSince1970 * 1000) % Int.max)
        let themeCount_Echd = 4  // DanmakuTheme_Echd.all_Echd.count
        // 若指定主题，调整 ID 使 id % themeCount == themeIndex，确保过滤能命中
        let finalId_Echd: Int
        if themeIndex_echd >= 0 && themeIndex_echd < themeCount_Echd {
            let base_Echd = (rawId_Echd / themeCount_Echd) * themeCount_Echd
            finalId_Echd = base_Echd + themeIndex_echd
        } else {
            finalId_Echd = rawId_Echd
        }

        let item_Echd = DanmakuModel_Echd(
            danmakuId_Echd: finalId_Echd,
            content_Echd: content_echd.trimmingCharacters(in: .whitespaces),
            authorName_Echd: authorName_echd.isEmpty ? "Anonymous" : authorName_echd,
            authorId_Echd: authorId_echd,
            timestamp_Echd: Date().timeIntervalSince1970
        )
        list_Echd.insert(item_Echd, at: 0)
        savePublished_Echd(list_Echd)
        NotificationCenter.default.post(name: DanmakuFavVM_Echd.danmakuChangedNotification_Echd, object: nil)
    }

    /// 获取当前用户发布的弹幕列表（用于 My Moments > Published）
    /// - Returns: 当前用户发布的弹幕，按时间倒序
    func getMyPublishedDanmaku_Echd() -> [DanmakuModel_Echd] {
        let uid_Echd = UserViewModel_Echd.shared_Echd.getCurrentUser_Echd().userId_Echd ?? -1
        let removed_Echd = removedIds_Echd
        return getStoredPublished_Echd()
            .filter { $0.authorId_Echd == uid_Echd && !removed_Echd.contains($0.danmakuId_Echd) }
    }

    /// 删除自己发布的弹幕（My Moments > Published 右上角删除按钮）
    /// 同步将该 ID 加入 removed 池，使其从 Live Sparks 消失
    func deleteMyDanmaku_Echd(danmakuId_echd: Int) {
        var list_Echd = getStoredPublished_Echd()
        list_Echd.removeAll { $0.danmakuId_Echd == danmakuId_echd }
        savePublished_Echd(list_Echd)
        addToRemoved_Echd(danmakuId_echd)
        NotificationCenter.default.post(name: DanmakuFavVM_Echd.danmakuChangedNotification_Echd, object: nil)
    }

    /// 举报弹幕后从弹幕池中移除（同时取消该条的收藏）
    func removeDanmaku_Echd(danmakuId_echd: Int) {
        addToRemoved_Echd(danmakuId_echd)
        // 同步取消收藏
        var favs_Echd = danmakuFavIds_Echd
        favs_Echd.removeAll { $0 == danmakuId_echd }
        UserDefaults.standard.set(favs_Echd, forKey: danmakuFavKey_Echd)
        NotificationCenter.default.post(name: DanmakuFavVM_Echd.danmakuChangedNotification_Echd, object: nil)
    }

    // MARK: - 弹幕收藏

    /// 已收藏的弹幕 ID 列表
    var danmakuFavIds_Echd: [Int] {
        UserDefaults.standard.array(forKey: danmakuFavKey_Echd) as? [Int] ?? []
    }

    /// 查询弹幕是否已收藏
    func isDanmakuFavorited_Echd(danmakuId_echd: Int) -> Bool {
        danmakuFavIds_Echd.contains(danmakuId_echd)
    }

    /// 切换弹幕收藏状态
    func toggleDanmakuFavorite_Echd(danmakuId_echd: Int) {
        var ids_Echd = danmakuFavIds_Echd
        if let idx_Echd = ids_Echd.firstIndex(of: danmakuId_echd) {
            ids_Echd.remove(at: idx_Echd)
        } else {
            ids_Echd.append(danmakuId_echd)
        }
        UserDefaults.standard.set(ids_Echd, forKey: danmakuFavKey_Echd)
        NotificationCenter.default.post(name: DanmakuFavVM_Echd.favChangedNotification_Echd, object: nil)
    }

    /// 获取已收藏的弹幕数据（用于 My Moments > Favorites）
    func getFavoritedDanmaku_Echd() -> [DanmakuModel_Echd] {
        let ids_Echd     = danmakuFavIds_Echd
        let removed_Echd = removedIds_Echd
        return getAllDanmaku_Echd()
            .filter { ids_Echd.contains($0.danmakuId_Echd) && !removed_Echd.contains($0.danmakuId_Echd) }
    }

    // MARK: - 时光轨迹数据

    /// 获取时光轨迹数据：我发布的弹幕 + 我收藏的弹幕，合并去重后按时间倒序
    /// 返回值：(DanmakuModel, isPublished: true=我发布, false=我收藏)
    func getTimelineData_Echd() -> [(DanmakuModel_Echd, Bool)] {
        let published_Echd = getMyPublishedDanmaku_Echd().map { ($0, true) }
        let favIds_Echd    = danmakuFavIds_Echd
        let favorited_Echd = getAllDanmaku_Echd()
            .filter { favIds_Echd.contains($0.danmakuId_Echd) }
            .map { ($0, false) }

        // 合并并按时间排序，去重（发布的同时也被收藏时，显示为"发布"类型）
        var seen_Echd  = Set<Int>()
        var result_Echd: [(DanmakuModel_Echd, Bool)] = []
        for item_Echd in (published_Echd + favorited_Echd).sorted(by: { $0.0.timestamp_Echd > $1.0.timestamp_Echd }) {
            if !seen_Echd.contains(item_Echd.0.danmakuId_Echd) {
                seen_Echd.insert(item_Echd.0.danmakuId_Echd)
                result_Echd.append(item_Echd)
            }
        }
        return result_Echd
    }

    // MARK: - 帖子收藏（兼容原有接口）

    var favoritedIds_Echd: [Int] {
        UserDefaults.standard.array(forKey: postFavKey_Echd) as? [Int] ?? []
    }

    func isFavorited_Echd(postId_echd: Int) -> Bool {
        favoritedIds_Echd.contains(postId_echd)
    }

    func toggleFavorite_Echd(postId_echd: Int) {
        var ids_Echd = favoritedIds_Echd
        if let idx_Echd = ids_Echd.firstIndex(of: postId_echd) {
            ids_Echd.remove(at: idx_Echd)
        } else {
            ids_Echd.append(postId_echd)
        }
        UserDefaults.standard.set(ids_Echd, forKey: postFavKey_Echd)
        NotificationCenter.default.post(name: DanmakuFavVM_Echd.favChangedNotification_Echd, object: nil)
    }

    func getFavoritedPosts_Echd() -> [TitleModel_Echd] {
        let ids_Echd = favoritedIds_Echd
        return TitleViewModel_Echd.shared_Echd.getPosts_Echd().filter { ids_Echd.contains($0.titleId_Echd) }
    }

    // MARK: - 私有辅助

    private var removedIds_Echd: Set<Int> {
        Set(UserDefaults.standard.array(forKey: removedKey_Echd) as? [Int] ?? [])
    }

    private func addToRemoved_Echd(_ id: Int) {
        var set_Echd = Array(removedIds_Echd)
        if !set_Echd.contains(id) { set_Echd.append(id) }
        UserDefaults.standard.set(set_Echd, forKey: removedKey_Echd)
    }

    private func getStoredPublished_Echd() -> [DanmakuModel_Echd] {
        guard let data_Echd = UserDefaults.standard.data(forKey: publishedKey_Echd),
              let items_Echd = try? JSONDecoder().decode([DanmakuModel_Echd].self, from: data_Echd) else {
            return []
        }
        return items_Echd
    }

    private func savePublished_Echd(_ items: [DanmakuModel_Echd]) {
        if let data_Echd = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data_Echd, forKey: publishedKey_Echd)
        }
    }
}
