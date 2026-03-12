import UIKit
import Foundation

// MARK: 睡眠相册创建逻辑

/// 睡眠相册创建页逻辑层
/// 职责：校验输入、保存图片到磁盘、构建 SleepAlbumGroup_Doze 并写入 HomeLogic
/// 与 SleepAlbumCreate_Doze UI 层完全解耦
class SleepAlbumCreateLogic_Doze {

    // MARK: - 单例

    static let shared_Doze = SleepAlbumCreateLogic_Doze()
    private init() {}

    // MARK: - 图标预设

    /// 用户可选的相册图标（SF Symbol）
    let albumIcons_Doze: [String] = [
        "moon.zzz.fill",
        "pawprint.fill",
        "sparkles",
        "heart.fill",
        "star.fill",
        "camera.fill",
        "photo.on.rectangle",
        "cloud.moon.fill",
    ]

    // MARK: - 输入校验

    /// 校验相册输入是否合法
    /// - Parameters:
    ///   - title_doze: 相册标题
    ///   - image_doze: 封面图（可选，nil 表示未上传）
    /// - Returns: (是否合法, 错误提示)
    func validateAlbumInput_Doze(
        title_doze: String,
        image_doze: UIImage?
    ) -> (Bool, String) {
        let trimmed_doze = title_doze.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed_doze.isEmpty {
            return (false, "Please enter an album title.")
        }
        if trimmed_doze.count < 2 {
            return (false, "Title must be at least 2 characters.")
        }
        if trimmed_doze.count > 40 {
            return (false, "Title cannot exceed 40 characters.")
        }
        if image_doze == nil {
            return (false, "Please add a cover photo.")
        }
        return (true, "")
    }

    // MARK: - 保存图片

    /// 将封面图保存到 Documents 目录，返回文件路径；失败返回 nil
    /// - Parameter image_doze: 要保存的图片
    /// - Returns: 文件绝对路径字符串（供 MediaDisplayView 加载）
    func saveImageToDocuments_Doze(image_doze: UIImage) -> String? {
        guard let data = image_doze.jpegData(compressionQuality: 0.82) else { return nil }
        let name = "album_\(Date().timeIntervalSince1970).jpg"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(name)
        do {
            try data.write(to: url)
            print("✅ 相册封面已保存: \(url.path)")
            return url.path
        } catch {
            print("❌ 保存相册封面失败: \(error)")
            return nil
        }
    }

    // MARK: - 创建相册

    /// 构建并保存自定义相册到 HomeLogic
    /// - Parameters:
    ///   - title_doze: 相册标题
    ///   - note_doze: 用户描述
    ///   - image_doze: 封面图
    ///   - selectedIcon_doze: 图标 SF Symbol 名
    ///   - bedTime_doze: 就寝时间字符串（如 "22:30"）
    ///   - wakeTime_doze: 起床时间字符串（如 "07:00"）
    ///   - sleepQualityPct_doze: 自动计算的睡眠质量百分比（0~100）
    ///   - sleepDurationMinutes_doze: 睡眠时长（分钟）
    func createAndSaveAlbum_Doze(
        title_doze: String,
        note_doze: String,
        image_doze: UIImage?,
        selectedIcon_doze: String,
        bedTime_doze: String,
        wakeTime_doze: String,
        sleepQualityPct_doze: Int,
        sleepDurationMinutes_doze: Int
    ) {
        // 保存封面图到磁盘
        var paths_doze: [String] = []
        if let img_doze = image_doze,
           let path_doze = saveImageToDocuments_Doze(image_doze: img_doze) {
            paths_doze.append(path_doze)
        }

        let nextId_doze = HomeLogic_Doze.shared_Doze.customAlbums_Doze.count + 100

        // 根据睡眠质量选择强调色
        let accentColor_doze: String
        switch sleepQualityPct_doze {
        case 30...: accentColor_doze = "#B794F6"  // 良好 → 薰衣草紫
        case 20...: accentColor_doze = "#90CDF4"  // 一般 → 天空蓝
        default:    accentColor_doze = "#FBB6CE"  // 较短 → 玫瑰粉
        }

        let album_doze = SleepAlbumGroup_Doze(
            id: nextId_doze,
            groupTitle_Doze: title_doze.trimmingCharacters(in: .whitespacesAndNewlines),
            groupSubtitle_Doze: note_doze.isEmpty ? "My custom album" : note_doze,
            groupIcon_Doze: selectedIcon_doze,
            coverMediaPaths_Doze: paths_doze,
            posts_Doze: [],
            accentColor_Doze: accentColor_doze,
            isCustom_Doze: true,
            imageOffsets_Doze: [CGPoint(x: 0, y: 0)],
            customNote_Doze: note_doze,
            bedTime_Doze: bedTime_doze,
            wakeTime_Doze: wakeTime_doze,
            sleepQualityPct_Doze: sleepQualityPct_doze,
            sleepDurationMinutes_Doze: sleepDurationMinutes_doze,
            createdAt_Doze: Date()
        )

        HomeLogic_Doze.shared_Doze.addCustomAlbum_Doze(album_doze)
        print("✅ 自定义相册已创建: \(title_doze)，睡眠质量: \(sleepQualityPct_doze)%，时长: \(sleepDurationMinutes_doze) 分钟")
    }
}
