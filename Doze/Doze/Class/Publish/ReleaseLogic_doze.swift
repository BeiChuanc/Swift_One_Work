import UIKit
import Foundation

// MARK: 发布页业务逻辑

/// 发布页逻辑类
/// 职责：校验输入、保存媒体文件、调用 TitleViewModel 发布帖子
/// 严格与 UI 解耦，Release_Doze 只负责展示与回调
class ReleaseLogic_Doze {

    // MARK: - 单例

    static let shared_Doze = ReleaseLogic_Doze()
    private init() {}

    // MARK: - 快速标签数据源

    /// 睡眠状态快速标签（用于快速补充内容描述）
    let quickTags_Doze: [(label: String, icon: String)] = [
        ("Deep Sleep",   "moon.zzz.fill"),
        ("Light Sleep",  "moon.fill"),
        ("Napping",      "zzz"),
        ("Restless",     "arrow.triangle.2.circlepath"),
        ("Awake",        "eye.fill"),
        ("Snoring",      "waveform"),
        ("Dreaming",     "sparkles"),
        ("Cozy",         "pawprint.fill"),
    ]

    // MARK: - 登录校验

    /// 校验当前用户是否已登录
    /// - Returns: true 表示已登录，false 表示游客状态
    func isLoggedIn_Doze() -> Bool {
        return UserViewModel_Doze.shared_Doze.isLoggedIn_Doze
    }

    // MARK: - 输入校验

    /// 校验发布输入是否合法
    /// - Parameters:
    ///   - title_doze: 帖子标题
    ///   - content_doze: 帖子内容
    /// - Returns: (是否合法, 错误提示)
    func validateInputs_Doze(title_doze: String, content_doze: String) -> (Bool, String) {
        let trimmedTitle_doze = title_doze.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent_doze = content_doze.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedTitle_doze.isEmpty {
            return (false, "Please enter a title for your sleep log.")
        }
        if trimmedTitle_doze.count < 3 {
            return (false, "Title must be at least 3 characters.")
        }
        if trimmedTitle_doze.count > 60 {
            return (false, "Title cannot exceed 60 characters.")
        }
        if trimmedContent_doze.isEmpty {
            return (false, "Please add some notes about this sleep observation.")
        }
        if trimmedContent_doze.count < 10 {
            return (false, "Notes must be at least 10 characters.")
        }
        return (true, "")
    }

    // MARK: - 媒体保存

    /// 将选中的图片保存到 Documents 目录，返回文件路径
    /// - Parameter image_doze: 选中的 UIImage
    /// - Returns: 保存成功返回文件路径字符串，失败返回 nil
    func saveImageToDocuments_Doze(image_doze: UIImage) -> String? {
        guard let data_doze = image_doze.jpegData(compressionQuality: 0.82) else {
            print("⚠️ 图片转 JPEG 失败")
            return nil
        }

        let fileName_doze = "sleep_log_\(Int(Date().timeIntervalSince1970)).jpg"
        let docsURL_doze = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL_doze = docsURL_doze.appendingPathComponent(fileName_doze)

        do {
            try data_doze.write(to: fileURL_doze)
            print("✅ 图片已保存: \(fileURL_doze.path)")
            return fileURL_doze.path
        } catch {
            print("❌ 保存图片失败: \(error)")
            return nil
        }
    }

    // MARK: - 发布

    /// 发布睡眠日志帖子
    /// - Parameters:
    ///   - title_doze: 帖子标题
    ///   - content_doze: 帖子正文
    ///   - mediaPath_doze: 媒体路径（可为空，使用默认宠物图标路径）
    ///   - category_doze: 宠物类别
    func publishPost_Doze(
        title_doze: String,
        content_doze: String,
        mediaPath_doze: String?,
        category_doze: PetCategory_Doze
    ) {
        let finalMedia_doze = mediaPath_doze ?? category_doze.iconName_Doze
        TitleViewModel_Doze.shared_Doze.releasePost_Doze(
            title_doze: title_doze,
            content_doze: content_doze,
            media_doze: finalMedia_doze
        )
    }

    // MARK: - 字数统计辅助

    /// 获取内容字数剩余提示颜色
    /// - Parameters:
    ///   - current_doze: 当前字数
    ///   - max_doze: 最大字数
    /// - Returns: 对应颜色
    func counterColor_Doze(current_doze: Int, max_doze: Int) -> UIColor {
        let ratio_doze = Double(current_doze) / Double(max_doze)
        if ratio_doze < 0.7 { return UIColor(hexstring_Doze: "#90CDF4") }
        if ratio_doze < 0.9 { return UIColor(hexstring_Doze: "#F6AD55") }
        return UIColor(hexstring_Doze: "#FC8181")
    }
}
