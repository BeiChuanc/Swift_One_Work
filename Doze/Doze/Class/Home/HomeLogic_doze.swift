import Foundation
import UIKit

// MARK: 首页业务逻辑

/// 首页业务逻辑类
/// 职责：集中处理首页所有数据获取、状态计算、问候语生成、相册分组、睡眠成长曲线等逻辑
/// 与 UI 层完全解耦，Home_Doze 只负责展示，逻辑由本类提供
class HomeLogic_Doze {

    // MARK: - 单例

    static let shared_Doze = HomeLogic_Doze()
    private init() {}

    // MARK: - 问候语与时段

    /// 根据当前时间返回问候语
    func getGreeting_Doze() -> String {
        let hour_doze = Calendar.current.component(.hour, from: Date())
        switch hour_doze {
        case 5..<12:  return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default:      return "Good Night"
        }
    }

    /// 根据当前时间返回对应的 SF Symbol 图标名
    func getTimeIcon_Doze() -> String {
        let hour_doze = Calendar.current.component(.hour, from: Date())
        switch hour_doze {
        case 5..<12:  return "sun.horizon.fill"
        case 12..<17: return "sun.max.fill"
        case 17..<21: return "sunset.fill"
        default:      return "moon.stars.fill"
        }
    }

    /// 返回当前时间的格式化字符串（如 "Tuesday, March 10"）
    func getFormattedDate_Doze() -> String {
        let formatter_doze = DateFormatter()
        formatter_doze.dateFormat = "EEEE, MMMM d"
        return formatter_doze.string(from: Date())
    }

    // MARK: - 睡眠状态枚举

    /// 宠物睡眠状态枚举
    enum SleepStatus_Doze {
        case deepSleep_doze
        case lightSleep_doze
        case awake_doze
        case napping_doze

        var title_Doze: String {
            switch self {
            case .deepSleep_doze:  return "Deep Sleep"
            case .lightSleep_doze: return "Light Sleep"
            case .awake_doze:      return "Awake"
            case .napping_doze:    return "Napping"
            }
        }

        /// 状态简短标识（用于芯片，防止溢出）
        var shortTitle_Doze: String {
            switch self {
            case .deepSleep_doze:  return "Deep"
            case .lightSleep_doze: return "Light"
            case .awake_doze:      return "Active"
            case .napping_doze:    return "Nap"
            }
        }

        var description_Doze: String {
            switch self {
            case .deepSleep_doze:  return "Your pet is in a deep, restful slumber"
            case .lightSleep_doze: return "Drifting in and out of gentle sleep"
            case .awake_doze:      return "Alert and active right now"
            case .napping_doze:    return "Enjoying a cozy little catnap"
            }
        }

        var color_Doze: UIColor {
            switch self {
            case .deepSleep_doze:  return UIColor(hexstring_Doze: "#B794F6")
            case .lightSleep_doze: return UIColor(hexstring_Doze: "#90CDF4")
            case .awake_doze:      return UIColor(hexstring_Doze: "#F6AD55")
            case .napping_doze:    return UIColor(hexstring_Doze: "#FBB6CE")
            }
        }

        var iconName_Doze: String {
            switch self {
            case .deepSleep_doze:  return "moon.zzz.fill"
            case .lightSleep_doze: return "moon.fill"
            case .awake_doze:      return "eye.fill"
            case .napping_doze:    return "zzz"
            }
        }
    }

    /// 获取当前宠物睡眠状态（根据时段模拟）
    func getCurrentSleepStatus_Doze() -> SleepStatus_Doze {
        let hour_doze = Calendar.current.component(.hour, from: Date())
        let statuses_doze: [SleepStatus_Doze]
        switch hour_doze {
        case 22...23, 0..<6:
            statuses_doze = [.deepSleep_doze, .deepSleep_doze, .lightSleep_doze]
        case 6..<9:
            statuses_doze = [.lightSleep_doze, .awake_doze, .napping_doze]
        case 12..<15:
            statuses_doze = [.napping_doze, .napping_doze, .awake_doze]
        default:
            statuses_doze = [.awake_doze, .napping_doze, .lightSleep_doze]
        }
        return statuses_doze[Int.random(in: 0..<statuses_doze.count)]
    }

    /// 获取睡眠质量分值 (0.0 ~ 1.0)
    func getSleepQuality_Doze() -> CGFloat {
        let hour_doze = Calendar.current.component(.hour, from: Date())
        let base_doze: CGFloat
        switch hour_doze {
        case 22...23, 0..<6: base_doze = 0.75
        case 6..<9:          base_doze = 0.55
        case 12..<15:        base_doze = 0.65
        default:             base_doze = 0.40
        }
        let noise_doze = CGFloat.random(in: -0.1...0.15)
        return min(1.0, max(0.1, base_doze + noise_doze))
    }

    /// 获取今日总睡眠时长字符串（如 "7h 23m"）
    func getTodaySleepDuration_Doze() -> String {
        let hours_doze = Int.random(in: 6...10)
        let minutes_doze = Int.random(in: 0...59)
        return "\(hours_doze)h \(minutes_doze)m"
    }

    /// 获取今日活跃宠物数（模拟）
    func getActivePetsCount_Doze() -> Int {
        return Int.random(in: 12...48)
    }

    // MARK: - 帖子数据

    /// 获取热门帖子（按点赞数降序，取前5条）
    func getFeaturedPosts_Doze() -> [TitleModel_Doze] {
        let allPosts_doze = TitleViewModel_Doze.shared_Doze.getPosts_Doze()
        return Array(allPosts_doze.sorted { $0.likes_Doze > $1.likes_Doze }.prefix(5))
    }

    /// 获取最新日志（全部）
    func getLatestPosts_Doze() -> [TitleModel_Doze] {
        return TitleViewModel_Doze.shared_Doze.getPosts_Doze()
    }

    // MARK: - 睡眠相册数据

    /// 用户自建相册（内存存储，支持新增）
    private(set) var customAlbums_Doze: [SleepAlbumGroup_Doze] = []

    /// 添加自定义相册
    /// - Parameter album_doze: 用户创建的相册分组
    func addCustomAlbum_Doze(_ album_doze: SleepAlbumGroup_Doze) {
        customAlbums_Doze.append(album_doze)
    }

    /// 删除指定 ID 的自定义相册
    /// - Parameter id_doze: 相册 ID
    func removeCustomAlbum_Doze(id_doze: Int) {
        customAlbums_Doze.removeAll { $0.id == id_doze }
    }

    /// 获取所有相册分组（预置 + 用户自建）
    /// 预置分组按成长阶段/季节/纪念日归类现有日志
    /// - Returns: [SleepAlbumGroup_Doze] 数组
    func getAlbumGroups_Doze() -> [SleepAlbumGroup_Doze] {
        let posts_doze = TitleViewModel_Doze.shared_Doze.getPosts_Doze()

        // 预置分组定义（标题、副标题、图标、颜色、关联类别）
        let definitions_doze: [(String, String, String, String, PetCategory_Doze)] = [
            ("1 Month Mark",   "First sleepy milestone",    "moon.zzz.fill",    "#B794F6", .cat_doze),
            ("Summer Naps",    "Long afternoon siestas",    "sun.max.fill",      "#F6AD55", .dog_doze),
            ("Winter Dreams",  "Deep seasonal slumber",     "snowflake",         "#90CDF4", .rabbit_doze),
            ("Anniversary",    "One year of sweet dreams",  "sparkles",          "#FBB6CE", .cat_doze),
            ("Growth Moments", "Milestones & memories",     "pawprint.circle.fill", "#68D391", .bird_doze),
        ]

        var groups_doze: [SleepAlbumGroup_Doze] = []
        for (i, (title, sub, icon, color, category)) in definitions_doze.enumerated() {
            let related_doze = posts_doze.filter { $0.petCategory_Doze == category }
            let sliced_doze = Array(related_doze.prefix(3))
            let covers_doze = sliced_doze.compactMap { $0.titleMeidas_Doze.first }

            groups_doze.append(SleepAlbumGroup_Doze(
                id: i + 1,
                groupTitle_Doze: title,
                groupSubtitle_Doze: sub,
                groupIcon_Doze: icon,
                coverMediaPaths_Doze: Array(covers_doze.prefix(2)),
                posts_Doze: sliced_doze,
                accentColor_Doze: color,
                isCustom_Doze: false,
                imageOffsets_Doze: [CGPoint(x: 10, y: 10), CGPoint(x: 26, y: 22)],
                customNote_Doze: ""
            ))
        }

        // 预置分组始终全部显示（无帖子也展示图标/标题，不过滤）

        // 追加用户自建相册（无论是否有帖子都保留）
        groups_doze.append(contentsOf: customAlbums_Doze)
        return groups_doze
    }

    // MARK: - 相册统计聚合

    /// 从相册分组聚合用户睡眠统计数据
    /// 数据来源严格限于用户自建相册（isCustom_Doze = true），无数据则全返回 0 / "0h 0m"
    /// - Parameter groups_doze: 相册分组数组
    /// - Returns: (自定义相册数量, 日志总数, 最新相册质量百分比0~100, 最新相册总时长字符串)
    func computeAlbumStats_Doze(groups_doze: [SleepAlbumGroup_Doze])
        -> (albumCount: Int, totalLogs: Int, avgQualityPct: Int, totalDuration: String) {

        // 只统计用户自建相册，预置分组不计入
        let customAlbums_doze = groups_doze.filter { $0.isCustom_Doze }
        let albumCount_doze = customAlbums_doze.count

        // 日志数：自建相册关联的帖子总数（目前用户建的相册 posts 为空，以 sleepDurationMinutes > 0 的数量代替）
        let totalLogs_doze = customAlbums_doze.filter { $0.sleepDurationMinutes_Doze > 0 }.count

        // 质量：取最新一条带质量数据的自建相册，无则为 0
        let customWithQuality_doze = customAlbums_doze.filter { $0.sleepQualityPct_Doze > 0 }
        let qualityPct_doze = customWithQuality_doze.last?.sleepQualityPct_Doze ?? 0

        // 时长：自建相册睡眠时长总和，无则为 "0h 0m"
        let customWithTime_doze = customAlbums_doze.filter { $0.sleepDurationMinutes_Doze > 0 }
        let totalMinutes_doze = customWithTime_doze.reduce(0) { $0 + $1.sleepDurationMinutes_Doze }
        let durationStr_doze = totalMinutes_doze > 0
            ? "\(totalMinutes_doze / 60)h \(totalMinutes_doze % 60)m"
            : "0h 0m"

        return (albumCount_doze, totalLogs_doze, qualityPct_doze, durationStr_doze)
    }

    /// 根据睡眠质量百分比推导睡眠状态（用于替代随机模拟状态）
    /// - Parameter qualityPct_doze: 睡眠质量（0~100），0 表示无数据
    /// - Returns: SleepStatus_Doze
    func getSleepStatusFromQuality_Doze(qualityPct_doze: Int) -> SleepStatus_Doze {
        switch qualityPct_doze {
        case 28...: return .deepSleep_doze
        case 18...: return .lightSleep_doze
        case 8...:  return .napping_doze
        default:    return .awake_doze
        }
    }

    /// 从相册生成月度睡眠成长数据（最近 6 个月，按 createdAt 真实分组）
    /// 有数据的月份展示实际质量均值，无数据的月份值为 0；不混入任何模拟基线
    /// - Parameter groups_doze: 相册分组列表
    /// - Returns: [SleepGrowthPoint_Doze]（共 6 个点，当月在最右）
    func getMonthlyDataFromAlbums_Doze(groups_doze: [SleepAlbumGroup_Doze]) -> [SleepGrowthPoint_Doze] {
        let calendar_doze = Calendar.current
        let fmt_doze = DateFormatter()
        fmt_doze.dateFormat = "MMM"
        let now_doze = Date()

        // 生成最近 6 个月的 (Date起始, 标签) 元组，当月排在最后
        let monthMeta_doze: [(Date, String)] = (0..<6).reversed().map { offset in
            let anchor = calendar_doze.date(byAdding: .month, value: -offset, to: now_doze)!
            return (anchor, fmt_doze.string(from: anchor))
        }

        // 仅使用用户自建相册
        let customAlbums_doze = groups_doze.filter { $0.isCustom_Doze }

        return monthMeta_doze.map { (anchor, label) in
            // 找出 createdAt 属于同年同月的相册
            let inMonth_doze = customAlbums_doze.filter {
                calendar_doze.isDate($0.createdAt_Doze, equalTo: anchor, toGranularity: .month)
            }
            let quality_doze: CGFloat
            let duration_doze: Int
            if inMonth_doze.isEmpty {
                quality_doze = 0
                duration_doze = 0
            } else {
                let validQuality_doze = inMonth_doze.filter { $0.sleepQualityPct_Doze > 0 }
                let sumQuality_doze = validQuality_doze.reduce(0) { $0 + $1.sleepQualityPct_Doze }
                quality_doze = validQuality_doze.isEmpty
                    ? 0
                    : CGFloat(sumQuality_doze) / CGFloat(validQuality_doze.count) / 100.0
                duration_doze = inMonth_doze.reduce(0) { $0 + $1.sleepDurationMinutes_Doze }
            }
            return SleepGrowthPoint_Doze(
                label_Doze: label,
                avgQuality_Doze: quality_doze,
                totalDuration_Doze: duration_doze,
                logCount_Doze: inMonth_doze.count
            )
        }
    }

    /// 从相册生成季度睡眠成长数据（4 个季度，按 createdAt 真实分组，当前季在最右）
    /// 有数据的季度展示实际质量均值，无数据的季度值为 0；不混入任何模拟基线
    /// - Parameter groups_doze: 相册分组列表
    /// - Returns: [SleepGrowthPoint_Doze]（共 4 个点）
    func getSeasonalDataFromAlbums_Doze(groups_doze: [SleepAlbumGroup_Doze]) -> [SleepGrowthPoint_Doze] {
        let month_doze = Calendar.current.component(.month, from: Date())
        // 当前季度 index（0=Spring 3-5, 1=Summer 6-8, 2=Autumn 9-11, 3=Winter 12/1/2）
        let currentIdx_doze: Int
        switch month_doze {
        case 3...5:  currentIdx_doze = 0
        case 6...8:  currentIdx_doze = 1
        case 9...11: currentIdx_doze = 2
        default:     currentIdx_doze = 3
        }
        // 各季度覆盖的月份范围
        let seasonMonths_doze: [[Int]] = [
            [3, 4, 5], [6, 7, 8], [9, 10, 11], [12, 1, 2]
        ]
        let seasonNames_doze = ["Spring", "Summer", "Autumn", "Winter"]
        // 以当前季度结尾，排列最近 4 个季度
        let orderedIdx_doze = (0..<4).map { offset in (currentIdx_doze - 3 + offset + 4) % 4 }

        let calendar_doze = Calendar.current
        let customAlbums_doze = groups_doze.filter { $0.isCustom_Doze }

        return orderedIdx_doze.map { idx in
            let months_doze = seasonMonths_doze[idx]
            let label_doze = seasonNames_doze[idx]
            // 找出 createdAt 月份属于该季度的相册
            let inSeason_doze = customAlbums_doze.filter {
                months_doze.contains(calendar_doze.component(.month, from: $0.createdAt_Doze))
            }
            let quality_doze: CGFloat
            let duration_doze: Int
            if inSeason_doze.isEmpty {
                quality_doze = 0
                duration_doze = 0
            } else {
                let validQuality_doze = inSeason_doze.filter { $0.sleepQualityPct_Doze > 0 }
                let sumQuality_doze = validQuality_doze.reduce(0) { $0 + $1.sleepQualityPct_Doze }
                quality_doze = validQuality_doze.isEmpty
                    ? 0
                    : CGFloat(sumQuality_doze) / CGFloat(validQuality_doze.count) / 100.0
                duration_doze = inSeason_doze.reduce(0) { $0 + $1.sleepDurationMinutes_Doze }
            }
            return SleepGrowthPoint_Doze(
                label_Doze: label_doze,
                avgQuality_Doze: quality_doze,
                totalDuration_Doze: duration_doze,
                logCount_Doze: inSeason_doze.count
            )
        }
    }

    // MARK: - 睡眠成长曲线数据

    /// 获取月度睡眠数据（最近6个月，基于帖子分布模拟）
    /// - Returns: [SleepGrowthPoint_Doze] 按月度聚合
    func getMonthlySleepData_Doze() -> [SleepGrowthPoint_Doze] {
        let months_doze = ["Aug", "Sep", "Oct", "Nov", "Dec", "Jan"]
        let baseLine_doze: [CGFloat] = [0.52, 0.61, 0.57, 0.72, 0.68, 0.79]
        let posts_doze = TitleViewModel_Doze.shared_Doze.getPosts_Doze()

        // 帖子为空时直接用基线模拟，避免负数下标崩溃
        guard !posts_doze.isEmpty else {
            return months_doze.enumerated().map { (i, label) in
                SleepGrowthPoint_Doze(
                    label_Doze: label,
                    avgQuality_Doze: baseLine_doze[i],
                    totalDuration_Doze: 360 + i * 20,
                    logCount_Doze: 1
                )
            }
        }

        let chunkSize_doze = max(1, posts_doze.count / months_doze.count)

        return months_doze.enumerated().map { (i, label) in
            let start_doze = min(i * chunkSize_doze, posts_doze.count - 1)
            let end_doze   = min(start_doze + chunkSize_doze, posts_doze.count)
            let safeEnd_doze = max(start_doze + 1, end_doze)
            let chunk_doze = Array(posts_doze[start_doze..<min(safeEnd_doze, posts_doze.count)])
            let quality_doze = baseLine_doze[i] + CGFloat.random(in: -0.05...0.05)
            let duration_doze = 360 + i * 20 + Int.random(in: -20...30)
            return SleepGrowthPoint_Doze(
                label_Doze: label,
                avgQuality_Doze: min(1.0, max(0.1, quality_doze)),
                totalDuration_Doze: duration_doze,
                logCount_Doze: max(1, chunk_doze.count)
            )
        }
    }

    /// 获取季度睡眠数据（4 个季度模拟）
    /// - Returns: [SleepGrowthPoint_Doze] 按季度聚合
    func getSeasonalSleepData_Doze() -> [SleepGrowthPoint_Doze] {
        return [
            SleepGrowthPoint_Doze(label_Doze: "Spring", avgQuality_Doze: 0.62, totalDuration_Doze: 450, logCount_Doze: 24),
            SleepGrowthPoint_Doze(label_Doze: "Summer", avgQuality_Doze: 0.55, totalDuration_Doze: 395, logCount_Doze: 31),
            SleepGrowthPoint_Doze(label_Doze: "Autumn", avgQuality_Doze: 0.74, totalDuration_Doze: 490, logCount_Doze: 28),
            SleepGrowthPoint_Doze(label_Doze: "Winter", avgQuality_Doze: 0.82, totalDuration_Doze: 540, logCount_Doze: 35),
        ]
    }
}
