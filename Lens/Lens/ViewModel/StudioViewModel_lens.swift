import Foundation
import UIKit

// MARK: - 调制画盘 ViewModel

/// StudioViewModel_Lens
/// 功能：管理作品集、亚克力分层与光源环境的业务逻辑
/// 设计思路：单例 + UserDefaults 持久化 + 通知驱动 UI 刷新
@MainActor
class StudioViewModel_Lens {

    static let shared_Lens = StudioViewModel_Lens()

    /// 工作室状态更新通知
    static let studioStateDidChangeNotification_Lens = Notification.Name("StudioStateDidChange_Lens")

    private let artworksKey_Lens = "studio_artworks_lens"
    private let layersKey_Lens = "studio_layers_lens"
    private let lightKey_Lens = "studio_light_lens"
    private let snapshotsKey_Lens = "studio_color_snapshots_lens"
    private let danmakuKey_Lens = "studio_danmaku_lens"
    private let removedPresetDanmakuKey_Lens = "studio_removed_preset_danmaku_lens"
    private let activeArtworkKey_Lens = "studio_active_artwork_lens"

    private var artworks_Lens: [ArtworkModel_Lens] = []
    private var layers_Lens: [AcrylicLayerModel_Lens] = []
    private var colorSnapshots_Lens: [ColorTestSnapshot_Lens] = []
    /// 用户发布的弹幕（不含预制弹幕）
    private var danmakus_Lens: [DanmakuModel_Lens] = []
    /// 已举报/删除的预制弹幕 ID
    private var removedPresetDanmakuIds_Lens = Set<Int>()
    private var activeArtworkId_Lens: Int?
    private var lightEnv_Lens = LightEnvironmentModel_Lens(
        modeRaw_Lens: LightModeType_Lens.morningSun_Lens.rawValue,
        angle_Lens: 45,
        intensity_Lens: 0.72,
        referencePhotoPath_Lens: nil,
        extractedTintHex_Lens: nil
    )

    private init() {}

    // MARK: - 初始化

    /// 初始化工作室数据（优先读取本地缓存，过滤预制作品）
    func initStudio_Lens() {
        if let savedArtworks_Lens = loadArtworksFromDisk_Lens() {
            let userOnly_Lens = savedArtworks_Lens.filter { $0.isUserCreated_Lens != false }
            artworks_Lens = userOnly_Lens
            if userOnly_Lens.count != savedArtworks_Lens.count {
                saveArtworksToDisk_Lens()
            }
        } else {
            artworks_Lens = []
            saveArtworksToDisk_Lens()
        }

        if let savedLayers_Lens = loadLayersFromDisk_Lens() {
            layers_Lens = savedLayers_Lens
        } else {
            layers_Lens = LocalData_Lens.shared_Lens.defaultLayers_Lens
            saveLayersToDisk_Lens()
        }

        if let savedLight_Lens = loadLightFromDisk_Lens() {
            lightEnv_Lens = savedLight_Lens
        }

        if let savedSnapshots_Lens = loadSnapshotsFromDisk_Lens() {
            colorSnapshots_Lens = savedSnapshots_Lens
        } else {
            colorSnapshots_Lens = []
        }

        if let savedDanmaku_Lens = loadDanmakuFromDisk_Lens() {
            let presetIds_Lens = Set(LocalData_Lens.shared_Lens.defaultDanmakus_Lens.map { $0.danmakuId_Lens })
            danmakus_Lens = savedDanmaku_Lens.filter { !presetIds_Lens.contains($0.danmakuId_Lens) }
            if danmakus_Lens.count != savedDanmaku_Lens.count {
                saveDanmakuToDisk_Lens()
            }
        } else {
            danmakus_Lens = []
            saveDanmakuToDisk_Lens()
        }
        removedPresetDanmakuIds_Lens = loadRemovedPresetDanmakuIds_Lens()

        activeArtworkId_Lens = UserDefaults.standard.object(forKey: activeArtworkKey_Lens) as? Int

        syncUserStudioStats_Lens()
        notifyStateChange_Lens()
    }

    // MARK: - 登录校验

    /// 校验是否已登录，未登录时提示并跳转登录页
    /// - Returns: 已登录返回 true，否则 false
    func requireLogin_Lens() -> Bool {
        guard UserViewModel_Lens.shared_Lens.isLoggedIn_Lens else {
            Load_Lens.showWarning_Lens(message_Lens: "Please log in first")
            Navigation_Lens.toLogin_Lens()
            return false
        }
        return true
    }

    // MARK: - 作品集

    /// 获取全部作品列表
    func getArtworks_Lens() -> [ArtworkModel_Lens] {
        artworks_Lens
    }

    /// 根据 ID 获取单个作品
    /// - Parameter artworkId_Lens: 作品 ID
    func getArtwork_Lens(artworkId_Lens: Int) -> ArtworkModel_Lens? {
        artworks_Lens.first { $0.artworkId_Lens == artworkId_Lens }
    }

    /// 获取作品创作事件时间线（按事件 ID 排序）
    /// - Parameter artworkId_Lens: 作品 ID
    func getCreationTimeline_Lens(artworkId_Lens: Int) -> [CreationEvent_Lens] {
        guard let artwork_Lens = getArtwork_Lens(artworkId_Lens: artworkId_Lens) else { return [] }
        return artwork_Lens.events_Lens.sorted { $0.eventId_Lens < $1.eventId_Lens }
    }

    /// 获取用户自定义作品列表
    func getUserArtworks_Lens() -> [ArtworkModel_Lens] {
        let userId_Lens = UserViewModel_Lens.shared_Lens.getCurrentUser_Lens().userId_Lens ?? 0
        return artworks_Lens.filter {
            $0.isUserCreated_Lens == true && ($0.userId_Lens == userId_Lens || $0.userId_Lens == 0)
        }
    }

    /// 获取指定日期的用户作品（yyyy-MM-dd）
    func getArtworksOnDay_Lens(dateKey_Lens: String) -> [ArtworkModel_Lens] {
        getUserArtworks_Lens().filter { artworkDateKey_Lens(for: $0) == dateKey_Lens }
    }

    /// 获取指定月份内有创作活动的日期集合
    func getActiveDaysInMonth_Lens(year_Lens: Int, month_Lens: Int) -> Set<String> {
        var days_Lens = Set<String>()
        let prefix_Lens = String(format: "%04d-%02d", year_Lens, month_Lens)
        for artwork_Lens in getUserArtworks_Lens() {
            let key_Lens = artworkDateKey_Lens(for: artwork_Lens)
            if key_Lens.hasPrefix(prefix_Lens) {
                days_Lens.insert(key_Lens)
            }
            for event_Lens in artwork_Lens.events_Lens {
                if let eventDate_Lens = event_Lens.eventDate_Lens, eventDate_Lens.hasPrefix(prefix_Lens) {
                    days_Lens.insert(eventDate_Lens)
                }
            }
        }
        return days_Lens
    }

    /// 获取当前活跃录制作品 ID
    func getActiveArtworkId_Lens() -> Int? {
        activeArtworkId_Lens
    }

    /// 自定义创建新作品（需登录）
    /// - Parameters:
    ///   - title_Lens: 作品标题
    ///   - coverImage_Lens: 用户上传的封面图
    /// - Returns: 新作品 ID，失败返回 nil
    @discardableResult
    func createArtwork_Lens(title_Lens: String, coverImage_Lens: UIImage) -> Int? {
        guard requireLogin_Lens() else { return nil }
        let trimmed_Lens = title_Lens.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed_Lens.isEmpty else { return nil }
        guard let coverPath_Lens = saveArtworkCoverToDisk_Lens(image_Lens: coverImage_Lens) else { return nil }

        let newId_Lens = (artworks_Lens.map { $0.artworkId_Lens }.max() ?? 999) + 1
        let user_Lens = UserViewModel_Lens.shared_Lens.getCurrentUser_Lens()
        let userId_Lens = user_Lens.userId_Lens ?? 0
        let formatter_Lens = DateFormatter()
        formatter_Lens.dateFormat = "yyyy-MM-dd HH:mm"
        let now_Lens = Date()
        let artwork_Lens = ArtworkModel_Lens(
            artworkId_Lens: newId_Lens,
            userId_Lens: userId_Lens,
            title_Lens: trimmed_Lens,
            coverMedia_Lens: coverPath_Lens,
            createdAt_Lens: formatter_Lens.string(from: now_Lens),
            totalStrokes_Lens: 0,
            totalLayers_Lens: 0,
            events_Lens: [],
            isUserCreated_Lens: true
        )
        artworks_Lens.insert(artwork_Lens, at: 0)
        activeArtworkId_Lens = newId_Lens
        UserDefaults.standard.set(newId_Lens, forKey: activeArtworkKey_Lens)
        saveArtworksToDisk_Lens()
        syncUserStudioStats_Lens()
        notifyStateChange_Lens()
        return newId_Lens
    }

    /// 为作品添加自定义创作步骤（需登录）
    @discardableResult
    func addCreationStep_Lens(
        artworkId_Lens: Int,
        type_Lens: CreationEventType_Lens,
        detail_Lens: String,
        fromColorHex_Lens: String? = nil,
        toColorHex_Lens: String? = nil,
        layerName_Lens: String? = nil
    ) -> Bool {
        guard requireLogin_Lens() else { return false }
        guard let index_Lens = artworks_Lens.firstIndex(where: { $0.artworkId_Lens == artworkId_Lens }) else { return false }

        let timeFormatter_Lens = DateFormatter()
        timeFormatter_Lens.dateFormat = "HH:mm:ss"
        let dateFormatter_Lens = DateFormatter()
        dateFormatter_Lens.dateFormat = "yyyy-MM-dd"
        let now_Lens = Date()
        let eventId_Lens = (artworks_Lens[index_Lens].events_Lens.map { $0.eventId_Lens }.max() ?? 0) + 1
        let event_Lens = CreationEvent_Lens(
            eventId_Lens: eventId_Lens,
            type_Lens: type_Lens,
            timestamp_Lens: timeFormatter_Lens.string(from: now_Lens),
            eventDate_Lens: dateFormatter_Lens.string(from: now_Lens),
            detail_Lens: detail_Lens,
            brushPoints_Lens: nil,
            fromColorHex_Lens: fromColorHex_Lens,
            toColorHex_Lens: toColorHex_Lens,
            layerName_Lens: layerName_Lens
        )
        artworks_Lens[index_Lens].events_Lens.append(event_Lens)
        refreshArtworkStats_Lens(at: index_Lens)
        activeArtworkId_Lens = artworkId_Lens
        UserDefaults.standard.set(artworkId_Lens, forKey: activeArtworkKey_Lens)
        saveArtworksToDisk_Lens()
        syncUserStudioStats_Lens()
        notifyStateChange_Lens()
        return true
    }

    /// 将亚克力色彩测试记录到创作时间线
    @discardableResult
    func recordAcrylicTestToTimeline_Lens(artworkId_Lens: Int? = nil) -> Bool {
        guard requireLogin_Lens() else { return false }
        guard let targetId_Lens = resolveRecordingArtworkId_Lens(preferredId_Lens: artworkId_Lens) else {
            Load_Lens.showWarning_Lens(message_Lens: "Create an artwork first")
            return false
        }
        let blend_Lens = getCurrentRefractionColor_Lens()
        var r_Lens: CGFloat = 0, g_Lens: CGFloat = 0, b_Lens: CGFloat = 0, a_Lens: CGFloat = 0
        blend_Lens.getRed(&r_Lens, green: &g_Lens, blue: &b_Lens, alpha: &a_Lens)
        let hex_Lens = String(format: "#%02X%02X%02X", Int(r_Lens * 255), Int(g_Lens * 255), Int(b_Lens * 255))
        let layerCount_Lens = getLayers_Lens().count
        return addCreationStep_Lens(
            artworkId_Lens: targetId_Lens,
            type_Lens: .acrylicTest_Lens,
            detail_Lens: "Acrylic refraction test with \(layerCount_Lens) layers",
            toColorHex_Lens: hex_Lens
        )
    }

    /// 将光源调整记录到创作时间线
    @discardableResult
    func recordLightSessionToTimeline_Lens(artworkId_Lens: Int? = nil) -> Bool {
        guard requireLogin_Lens() else { return false }
        guard let targetId_Lens = resolveRecordingArtworkId_Lens(preferredId_Lens: artworkId_Lens) else {
            Load_Lens.showWarning_Lens(message_Lens: "Create an artwork first")
            return false
        }
        let light_Lens = getCurrentLight_Lens()
        let detail_Lens = "\(light_Lens.mode_Lens.displayTitle_Lens) · \(Int(light_Lens.angle_Lens))° · \(Int(light_Lens.intensity_Lens * 100))%"
        return addCreationStep_Lens(
            artworkId_Lens: targetId_Lens,
            type_Lens: .lightAdjust_Lens,
            detail_Lens: detail_Lens,
            toColorHex_Lens: light_Lens.extractedTintHex_Lens ?? light_Lens.mode_Lens.defaultTintHex_Lens
        )
    }

    /// 保存当前色彩测试快照（需登录）
    @discardableResult
    func saveColorTestSnapshot_Lens() -> Bool {
        guard requireLogin_Lens() else { return false }
        guard let layer_Lens = getLayers_Lens().last else { return false }
        let blend_Lens = getCurrentRefractionColor_Lens()
        var r_Lens: CGFloat = 0, g_Lens: CGFloat = 0, b_Lens: CGFloat = 0, a_Lens: CGFloat = 0
        blend_Lens.getRed(&r_Lens, green: &g_Lens, blue: &b_Lens, alpha: &a_Lens)
        let hex_Lens = String(format: "#%02X%02X%02X", Int(r_Lens * 255), Int(g_Lens * 255), Int(b_Lens * 255))

        let formatter_Lens = DateFormatter()
        formatter_Lens.dateFormat = "MM/dd HH:mm"
        let snap_Lens = ColorTestSnapshot_Lens(
            snapshotId_Lens: (colorSnapshots_Lens.map { $0.snapshotId_Lens }.max() ?? 0) + 1,
            tintHex_Lens: layer_Lens.tintHex_Lens,
            opacity_Lens: layer_Lens.opacity_Lens,
            saturation_Lens: layer_Lens.saturation_Lens,
            refractionHex_Lens: hex_Lens,
            savedAt_Lens: formatter_Lens.string(from: Date())
        )
        colorSnapshots_Lens.insert(snap_Lens, at: 0)
        saveSnapshotsToDisk_Lens()
        notifyStateChange_Lens()
        return true
    }

    /// 获取已保存的色彩测试快照
    func getColorSnapshots_Lens() -> [ColorTestSnapshot_Lens] {
        colorSnapshots_Lens
    }

    /// 获取周期汇总数据
    func getPeriodSummary_Lens() -> StudioPeriodSummary_Lens {
        let calendar_Lens = Calendar.current
        let weekAgo_Lens = calendar_Lens.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        var weekEvents_Lens = 0
        var weekLayerTests_Lens = 0
        var weekLightSessions_Lens = 0
        var weekArtworks_Lens = 0

        let userArtworks_Lens = getUserArtworks_Lens()

        for artwork_Lens in userArtworks_Lens {
            if let date_Lens = parseArtworkDate_Lens(artwork_Lens.createdAt_Lens), date_Lens >= weekAgo_Lens {
                weekArtworks_Lens += 1
            }
            for event_Lens in artwork_Lens.events_Lens {
                weekEvents_Lens += 1
                if event_Lens.type_Lens == .acrylicTest_Lens { weekLayerTests_Lens += 1 }
                if event_Lens.type_Lens == .lightAdjust_Lens { weekLightSessions_Lens += 1 }
            }
        }

        return StudioPeriodSummary_Lens(
            weekArtworks_Lens: weekArtworks_Lens,
            weekEvents_Lens: weekEvents_Lens,
            weekLayerTests_Lens: weekLayerTests_Lens,
            weekLightSessions_Lens: weekLightSessions_Lens,
            totalArtworks_Lens: userArtworks_Lens.count
        )
    }

    /// 获取近 7 天有创作活动的日期（yyyy-MM-dd，仅用户作品）
    func getRecentActiveDays_Lens() -> Set<String> {
        var days_Lens = Set<String>()
        for artwork_Lens in getUserArtworks_Lens() {
            days_Lens.insert(artworkDateKey_Lens(for: artwork_Lens))
            for event_Lens in artwork_Lens.events_Lens {
                if let eventDate_Lens = event_Lens.eventDate_Lens {
                    days_Lens.insert(eventDate_Lens)
                }
            }
        }
        return days_Lens
    }

    /// 提取作品创建日期键 yyyy-MM-dd
    func artworkDateKey_Lens(for artwork_Lens: ArtworkModel_Lens) -> String {
        if let date_Lens = parseArtworkDate_Lens(artwork_Lens.createdAt_Lens) {
            let formatter_Lens = DateFormatter()
            formatter_Lens.dateFormat = "yyyy-MM-dd"
            return formatter_Lens.string(from: date_Lens)
        }
        return String(artwork_Lens.createdAt_Lens.prefix(10))
    }

    /// 同步登录用户工作室统计字段
    private func syncUserStudioStats_Lens() {
        let userArtworks_Lens = getUserArtworks_Lens()
        let dateFormatter_Lens = DateFormatter()
        dateFormatter_Lens.dateFormat = "yyyy-MM-dd"
        var lastDate_Lens: String?
        for artwork_Lens in userArtworks_Lens {
            let key_Lens = artworkDateKey_Lens(for: artwork_Lens)
            if lastDate_Lens == nil || key_Lens > (lastDate_Lens ?? "") {
                lastDate_Lens = key_Lens
            }
        }
        let cover_Lens = userArtworks_Lens.first?.coverMedia_Lens
        UserViewModel_Lens.shared_Lens.syncStudioStats_Lens(
            artworkCount_Lens: userArtworks_Lens.count,
            lastActiveDate_Lens: lastDate_Lens,
            coverMedia_Lens: cover_Lens
        )
    }

    // MARK: - 弹幕池

    /// 获取弹幕列表（预制其他用户弹幕 + 用户自己发布的弹幕）
    func getDanmakus_Lens() -> [DanmakuModel_Lens] {
        mergedDanmakus_Lens()
    }

    /// 合并预制弹幕与用户弹幕
    private func mergedDanmakus_Lens() -> [DanmakuModel_Lens] {
        let presets_Lens = LocalData_Lens.shared_Lens.defaultDanmakus_Lens.filter {
            !removedPresetDanmakuIds_Lens.contains($0.danmakuId_Lens)
        }
        return presets_Lens + danmakus_Lens
    }

    /// 判断是否为预制弹幕
    private func isPresetDanmaku_Lens(danmakuId_Lens: Int) -> Bool {
        LocalData_Lens.shared_Lens.defaultDanmakus_Lens.contains { $0.danmakuId_Lens == danmakuId_Lens }
    }

    /// 当前弹幕池最大 ID（用于用户新发弹幕）
    private func nextDanmakuId_Lens() -> Int {
        let allIds_Lens = mergedDanmakus_Lens().map { $0.danmakuId_Lens }
        return (allIds_Lens.max() ?? 100) + 1
    }

    /// 发布弹幕（需登录）
    @discardableResult
    func postDanmaku_Lens(content_Lens: String) -> Bool {
        guard requireLogin_Lens() else { return false }
        let trimmed_Lens = content_Lens.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed_Lens.isEmpty else { return false }

        let colors_Lens = ["#FF6B6B", "#4D96FF", "#C77DFF", "#FFD93D", "#6BCB77"]
        let user_Lens = UserViewModel_Lens.shared_Lens.getCurrentUser_Lens()
        let formatter_Lens = DateFormatter()
        formatter_Lens.dateFormat = "HH:mm"
        let item_Lens = DanmakuModel_Lens(
            danmakuId_Lens: nextDanmakuId_Lens(),
            userId_Lens: user_Lens.userId_Lens ?? 0,
            userName_Lens: user_Lens.userName_Lens ?? "Artist",
            content_Lens: trimmed_Lens,
            colorHex_Lens: colors_Lens.randomElement() ?? "#4D96FF",
            time_Lens: formatter_Lens.string(from: Date())
        )
        danmakus_Lens.insert(item_Lens, at: 0)
        if danmakus_Lens.count > 50 { danmakus_Lens = Array(danmakus_Lens.prefix(50)) }
        saveDanmakuToDisk_Lens()
        notifyStateChange_Lens()
        return true
    }

    /// 举报弹幕（预制弹幕仅隐藏，用户弹幕从列表移除）
    func reportDanmaku_Lens(danmakuId_Lens: Int) {
        if isPresetDanmaku_Lens(danmakuId_Lens: danmakuId_Lens) {
            removedPresetDanmakuIds_Lens.insert(danmakuId_Lens)
            saveRemovedPresetDanmakuIds_Lens()
        } else {
            danmakus_Lens.removeAll { $0.danmakuId_Lens == danmakuId_Lens }
            saveDanmakuToDisk_Lens()
        }
        notifyStateChange_Lens()
    }

    /// 删除自己的弹幕
    @discardableResult
    func deleteDanmaku_Lens(danmakuId_Lens: Int) -> Bool {
        if isPresetDanmaku_Lens(danmakuId_Lens: danmakuId_Lens) {
            removedPresetDanmakuIds_Lens.insert(danmakuId_Lens)
            saveRemovedPresetDanmakuIds_Lens()
            notifyStateChange_Lens()
            return true
        }
        guard let index_Lens = danmakus_Lens.firstIndex(where: { $0.danmakuId_Lens == danmakuId_Lens }),
              UserViewModel_Lens.shared_Lens.isCurrentUser_Lens(userId_lens: danmakus_Lens[index_Lens].userId_Lens) else {
            return false
        }
        danmakus_Lens.remove(at: index_Lens)
        saveDanmakuToDisk_Lens()
        notifyStateChange_Lens()
        return true
    }

    /// 解析录制目标作品 ID
    private func resolveRecordingArtworkId_Lens(preferredId_Lens: Int?) -> Int? {
        if let preferredId_Lens,
           artworks_Lens.contains(where: { $0.artworkId_Lens == preferredId_Lens && $0.isUserCreated_Lens == true }) {
            return preferredId_Lens
        }
        if let active_Lens = activeArtworkId_Lens,
           artworks_Lens.contains(where: { $0.artworkId_Lens == active_Lens && $0.isUserCreated_Lens == true }) {
            return active_Lens
        }
        return getUserArtworks_Lens().first?.artworkId_Lens
    }

    /// 刷新作品统计数据
    private func refreshArtworkStats_Lens(at index_Lens: Int) {
        let events_Lens = artworks_Lens[index_Lens].events_Lens
        artworks_Lens[index_Lens].totalStrokes_Lens = events_Lens.filter {
            $0.type_Lens == .brushStroke_Lens
        }.count
        artworks_Lens[index_Lens].totalLayers_Lens = events_Lens.filter {
            $0.type_Lens == .layerAdd_Lens || $0.type_Lens == .acrylicTest_Lens
        }.count
    }

    /// 解析作品创建时间
    private func parseArtworkDate_Lens(_ text_Lens: String) -> Date? {
        let formatter_Lens = DateFormatter()
        formatter_Lens.dateFormat = "yyyy-MM-dd HH:mm"
        if let date_Lens = formatter_Lens.date(from: text_Lens) { return date_Lens }
        formatter_Lens.dateFormat = "yyyy-MM-dd"
        return formatter_Lens.date(from: String(text_Lens.prefix(10)))
    }

    // MARK: - 亚克力分层

    /// 获取当前全部亚克力层（按堆叠顺序排序）
    func getLayers_Lens() -> [AcrylicLayerModel_Lens] {
        layers_Lens.sorted { $0.stackOrder_Lens < $1.stackOrder_Lens }
    }

    /// 更新指定亚克力层参数
    /// - Parameters:
    ///   - layerId_Lens: 层 ID
    ///   - opacity_Lens: 透明度 0~1
    ///   - saturation_Lens: 饱和度 0~1
    ///   - brushThickness_Lens: 笔触厚度 0.5~8
    ///   - edgeGloss_Lens: 边缘光泽 0~1
    func updateLayer_Lens(
        layerId_Lens: Int,
        opacity_Lens: Double? = nil,
        saturation_Lens: Double? = nil,
        brushThickness_Lens: Double? = nil,
        edgeGloss_Lens: Double? = nil
    ) {
        guard let index_Lens = layers_Lens.firstIndex(where: { $0.layerId_Lens == layerId_Lens }) else { return }
        if let opacity_Lens { layers_Lens[index_Lens].opacity_Lens = opacity_Lens }
        if let saturation_Lens { layers_Lens[index_Lens].saturation_Lens = saturation_Lens }
        if let brushThickness_Lens { layers_Lens[index_Lens].brushThickness_Lens = brushThickness_Lens }
        if let edgeGloss_Lens { layers_Lens[index_Lens].edgeGloss_Lens = edgeGloss_Lens }
        saveLayersToDisk_Lens()
        notifyStateChange_Lens()
    }

    /// 添加新的亚克力透明层
    /// - Parameter name_Lens: 层名称
    func addLayer_Lens(name_Lens: String) {
        let nextOrder_Lens = (layers_Lens.map { $0.stackOrder_Lens }.max() ?? -1) + 1
        let newId_Lens = (layers_Lens.map { $0.layerId_Lens }.max() ?? 200) + 1
        let palette_Lens = ["#4D96FF", "#FF6B6B", "#6BCB77", "#C77DFF", "#FFD93D"]
        let tint_Lens = palette_Lens[nextOrder_Lens % palette_Lens.count]

        let layer_Lens = AcrylicLayerModel_Lens(
            layerId_Lens: newId_Lens,
            layerName_Lens: name_Lens,
            tintHex_Lens: tint_Lens,
            opacity_Lens: 0.4,
            saturation_Lens: 0.8,
            brushThickness_Lens: 2.5,
            edgeGloss_Lens: 0.3,
            stackOrder_Lens: nextOrder_Lens
        )
        layers_Lens.append(layer_Lens)
        saveLayersToDisk_Lens()
        notifyStateChange_Lens()
    }

    /// 智能计算多层色彩叠加后的折射混合色
    /// - Parameter layers_Lens: 亚克力层数组
    /// - Returns: 叠加后的 UIColor
    func computeRefractionColor_Lens(layers_Lens: [AcrylicLayerModel_Lens]) -> UIColor {
        var r_Lens: CGFloat = 1.0
        var g_Lens: CGFloat = 1.0
        var b_Lens: CGFloat = 1.0

        for layer_Lens in layers_Lens.sorted(by: { $0.stackOrder_Lens < $1.stackOrder_Lens }) {
            let base_Lens = UIColor(hexstring_Lens: layer_Lens.tintHex_Lens)
            var lr_Lens: CGFloat = 0, lg_Lens: CGFloat = 0, lb_Lens: CGFloat = 0, la_Lens: CGFloat = 0
            base_Lens.getRed(&lr_Lens, green: &lg_Lens, blue: &lb_Lens, alpha: &la_Lens)

            let sat_Lens = CGFloat(layer_Lens.saturation_Lens)
            let gray_Lens = 0.299 * lr_Lens + 0.587 * lg_Lens + 0.114 * lb_Lens
            lr_Lens = gray_Lens + sat_Lens * (lr_Lens - gray_Lens)
            lg_Lens = gray_Lens + sat_Lens * (lg_Lens - gray_Lens)
            lb_Lens = gray_Lens + sat_Lens * (lb_Lens - gray_Lens)

            let alpha_Lens = CGFloat(layer_Lens.opacity_Lens)
            let gloss_Lens = CGFloat(layer_Lens.edgeGloss_Lens)
            let refract_Lens = 1.0 + gloss_Lens * 0.12

            r_Lens = r_Lens * (1 - alpha_Lens) + min(lr_Lens * refract_Lens, 1.0) * alpha_Lens
            g_Lens = g_Lens * (1 - alpha_Lens) + min(lg_Lens * refract_Lens, 1.0) * alpha_Lens
            b_Lens = b_Lens * (1 - alpha_Lens) + min(lb_Lens * refract_Lens, 1.0) * alpha_Lens
        }

        return UIColor(red: r_Lens, green: g_Lens, blue: b_Lens, alpha: 1.0)
    }

    /// 获取当前折射预览色
    func getCurrentRefractionColor_Lens() -> UIColor {
        computeRefractionColor_Lens(layers_Lens: getLayers_Lens())
    }

    // MARK: - 光源环境

    /// 获取全部 12 种光源模式
    func getAllLightModes_Lens() -> [LightModeType_Lens] {
        LightModeType_Lens.allCases
    }

    /// 获取当前光源环境配置
    func getCurrentLight_Lens() -> LightEnvironmentModel_Lens {
        lightEnv_Lens
    }

    /// 设置光源模式
    /// - Parameter mode_Lens: 光源模式
    func setLightMode_Lens(mode_Lens: LightModeType_Lens) {
        lightEnv_Lens.modeRaw_Lens = mode_Lens.rawValue
        if mode_Lens != .exclusiveLight_Lens {
            lightEnv_Lens.extractedTintHex_Lens = mode_Lens.defaultTintHex_Lens
        }
        saveLightToDisk_Lens()
        notifyStateChange_Lens()
    }

    /// 调整光源角度与强度
    /// - Parameters:
    ///   - angle_Lens: 角度 0~360
    ///   - intensity_Lens: 强度 0~1
    ///   - persist_Lens: 是否持久化并广播通知（拖动预览时可设为 false）
    func updateLightParams_Lens(
        angle_Lens: Double,
        intensity_Lens: Double,
        persist_Lens: Bool = true
    ) {
        lightEnv_Lens.angle_Lens = max(0, min(360, angle_Lens))
        lightEnv_Lens.intensity_Lens = max(0, min(1, intensity_Lens))
        guard persist_Lens else { return }
        saveLightToDisk_Lens()
        notifyStateChange_Lens()
    }

    /// 专属光影：从照片中提取光线环境并应用到作品
    /// - Parameter image_Lens: 用户上传的参考照片
    func applyExclusiveLightFromPhoto_Lens(image_Lens: UIImage) {
        let extracted_Lens = extractLightFromImage_Lens(image_Lens: image_Lens)
        let photoPath_Lens = saveReferencePhoto_Lens(image_Lens: image_Lens)

        lightEnv_Lens.modeRaw_Lens = LightModeType_Lens.exclusiveLight_Lens.rawValue
        lightEnv_Lens.extractedTintHex_Lens = extracted_Lens.tintHex_Lens
        lightEnv_Lens.angle_Lens = extracted_Lens.angle_Lens
        lightEnv_Lens.intensity_Lens = extracted_Lens.intensity_Lens
        lightEnv_Lens.referencePhotoPath_Lens = photoPath_Lens

        saveLightToDisk_Lens()
        notifyStateChange_Lens()
    }

    /// 根据当前光源配置生成预览渐变色组
    func buildLightPreviewColors_Lens() -> [CGColor] {
        let tintHex_Lens = lightEnv_Lens.extractedTintHex_Lens
            ?? lightEnv_Lens.mode_Lens.defaultTintHex_Lens
        let base_Lens = UIColor(hexstring_Lens: tintHex_Lens)
        let intensity_Lens = CGFloat(lightEnv_Lens.intensity_Lens)

        var hr_Lens: CGFloat = 0, hg_Lens: CGFloat = 0, hb_Lens: CGFloat = 0, ha_Lens: CGFloat = 0
        base_Lens.getRed(&hr_Lens, green: &hg_Lens, blue: &hb_Lens, alpha: &ha_Lens)

        let highlight_Lens = UIColor(
            red: min(hr_Lens + 0.25 * intensity_Lens, 1),
            green: min(hg_Lens + 0.2 * intensity_Lens, 1),
            blue: min(hb_Lens + 0.15 * intensity_Lens, 1),
            alpha: 1
        )
        let shadow_Lens = UIColor(
            red: hr_Lens * (1 - 0.35 * intensity_Lens),
            green: hg_Lens * (1 - 0.35 * intensity_Lens),
            blue: hb_Lens * (1 - 0.3 * intensity_Lens),
            alpha: 1
        )

        return [highlight_Lens.cgColor, base_Lens.cgColor, shadow_Lens.cgColor]
    }

    // MARK: - 私有：光线提取

    /// 从图片采样平均色与亮度，推算光源色调、角度和强度
    private func extractLightFromImage_Lens(image_Lens: UIImage) -> (tintHex_Lens: String, angle_Lens: Double, intensity_Lens: Double) {
        let size_Lens = CGSize(width: 40, height: 40)
        let renderer_Lens = UIGraphicsImageRenderer(size: size_Lens)
        let thumb_Lens = renderer_Lens.image { _ in
            image_Lens.draw(in: CGRect(origin: .zero, size: size_Lens))
        }

        guard let cgImage_Lens = thumb_Lens.cgImage,
              let data_Lens = cgImage_Lens.dataProvider?.data,
              let ptr_Lens = CFDataGetBytePtr(data_Lens) else {
            return ("#E8D5FF", 120, 0.65)
        }

        let bytesPerPixel_Lens = 4
        let width_Lens = cgImage_Lens.width
        let height_Lens = cgImage_Lens.height
        var totalR_Lens: Int = 0, totalG_Lens: Int = 0, totalB_Lens: Int = 0
        var warmBias_Lens: Double = 0
        let count_Lens = width_Lens * height_Lens

        for y_Lens in 0..<height_Lens {
            for x_Lens in 0..<width_Lens {
                let offset_Lens = (y_Lens * width_Lens + x_Lens) * bytesPerPixel_Lens
                let r_Lens = Int(ptr_Lens[offset_Lens])
                let g_Lens = Int(ptr_Lens[offset_Lens + 1])
                let b_Lens = Int(ptr_Lens[offset_Lens + 2])
                totalR_Lens += r_Lens
                totalG_Lens += g_Lens
                totalB_Lens += b_Lens
                warmBias_Lens += Double(r_Lens - b_Lens)
            }
        }

        let avgR_Lens = totalR_Lens / count_Lens
        let avgG_Lens = totalG_Lens / count_Lens
        let avgB_Lens = totalB_Lens / count_Lens
        let brightness_Lens = Double(avgR_Lens + avgG_Lens + avgB_Lens) / (255.0 * 3.0)
        let angle_Lens = max(0, min(360, 90 + warmBias_Lens / Double(count_Lens) * 0.5))
        let hex_Lens = String(format: "#%02X%02X%02X", avgR_Lens, avgG_Lens, avgB_Lens)

        return (hex_Lens, angle_Lens, max(0.25, min(1.0, brightness_Lens * 1.4)))
    }

    /// 保存参考照片到 Documents 目录
    private func saveReferencePhoto_Lens(image_Lens: UIImage) -> String? {
        guard let data_Lens = image_Lens.jpegData(compressionQuality: 0.85) else { return nil }
        let fileName_Lens = "exclusive_light_\(Int(Date().timeIntervalSince1970)).jpg"
        let url_Lens = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName_Lens)
        try? data_Lens.write(to: url_Lens)
        return fileName_Lens
    }

    /// 保存作品封面到 Documents 目录
    /// - Parameter image_Lens: 用户上传封面
    /// - Returns: 文件名（供 MediaDisplayView 加载），失败返回 nil
    private func saveArtworkCoverToDisk_Lens(image_Lens: UIImage) -> String? {
        guard let data_Lens = image_Lens.jpegData(compressionQuality: 0.85) else { return nil }
        let fileName_Lens = "artwork_cover_\(Int(Date().timeIntervalSince1970)).jpg"
        let url_Lens = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName_Lens)
        do {
            try data_Lens.write(to: url_Lens)
            return fileName_Lens
        } catch {
            print("⚠️ 作品封面保存失败: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - 私有：持久化

    private func loadArtworksFromDisk_Lens() -> [ArtworkModel_Lens]? {
        guard let data_Lens = UserDefaults.standard.data(forKey: artworksKey_Lens) else { return nil }
        return try? JSONDecoder().decode([ArtworkModel_Lens].self, from: data_Lens)
    }

    private func saveArtworksToDisk_Lens() {
        guard let data_Lens = try? JSONEncoder().encode(artworks_Lens) else { return }
        UserDefaults.standard.set(data_Lens, forKey: artworksKey_Lens)
    }

    private func loadLayersFromDisk_Lens() -> [AcrylicLayerModel_Lens]? {
        guard let data_Lens = UserDefaults.standard.data(forKey: layersKey_Lens) else { return nil }
        return try? JSONDecoder().decode([AcrylicLayerModel_Lens].self, from: data_Lens)
    }

    private func saveLayersToDisk_Lens() {
        guard let data_Lens = try? JSONEncoder().encode(layers_Lens) else { return }
        UserDefaults.standard.set(data_Lens, forKey: layersKey_Lens)
    }

    private func loadLightFromDisk_Lens() -> LightEnvironmentModel_Lens? {
        guard let data_Lens = UserDefaults.standard.data(forKey: lightKey_Lens) else { return nil }
        return try? JSONDecoder().decode(LightEnvironmentModel_Lens.self, from: data_Lens)
    }

    private func saveLightToDisk_Lens() {
        guard let data_Lens = try? JSONEncoder().encode(lightEnv_Lens) else { return }
        UserDefaults.standard.set(data_Lens, forKey: lightKey_Lens)
    }

    private func loadSnapshotsFromDisk_Lens() -> [ColorTestSnapshot_Lens]? {
        guard let data_Lens = UserDefaults.standard.data(forKey: snapshotsKey_Lens) else { return nil }
        return try? JSONDecoder().decode([ColorTestSnapshot_Lens].self, from: data_Lens)
    }

    private func saveSnapshotsToDisk_Lens() {
        guard let data_Lens = try? JSONEncoder().encode(colorSnapshots_Lens) else { return }
        UserDefaults.standard.set(data_Lens, forKey: snapshotsKey_Lens)
    }

    private func loadDanmakuFromDisk_Lens() -> [DanmakuModel_Lens]? {
        guard let data_Lens = UserDefaults.standard.data(forKey: danmakuKey_Lens) else { return nil }
        return try? JSONDecoder().decode([DanmakuModel_Lens].self, from: data_Lens)
    }

    private func saveDanmakuToDisk_Lens() {
        guard let data_Lens = try? JSONEncoder().encode(danmakus_Lens) else { return }
        UserDefaults.standard.set(data_Lens, forKey: danmakuKey_Lens)
    }

    /// 读取已移除的预制弹幕 ID
    private func loadRemovedPresetDanmakuIds_Lens() -> Set<Int> {
        let ids_Lens = UserDefaults.standard.array(forKey: removedPresetDanmakuKey_Lens) as? [Int] ?? []
        return Set(ids_Lens)
    }

    /// 持久化已移除的预制弹幕 ID
    private func saveRemovedPresetDanmakuIds_Lens() {
        UserDefaults.standard.set(Array(removedPresetDanmakuIds_Lens), forKey: removedPresetDanmakuKey_Lens)
    }

    private func notifyStateChange_Lens() {
        NotificationCenter.default.post(name: Self.studioStateDidChangeNotification_Lens, object: nil)
    }
}
