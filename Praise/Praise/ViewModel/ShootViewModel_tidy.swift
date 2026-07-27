import Foundation
import UIKit

// MARK: 拍摄工具箱 ViewModel

/// 拍摄工具箱状态管理类
/// 核心作用：管理"拍摄参数记忆"预设的本地持久化读写、离线教学图库与曝光推荐的查询入口
/// 设计思路：
///   与 UserViewModel_Tidy 的打卡持久化方式保持一致，使用 UserDefaults 存储 JSON 编码数据；
///   预设变更后广播通知，供 UI 层（预设列表弹窗等）监听刷新。
/// 关键属性/方法：
///   - shootPresetsDidChangeNotification_Tidy：预设数据变更通知
///   - savePreset_Tidy / deletePreset_Tidy / getAllPresets_Tidy：预设 CRUD
///   - getExposureRecommendation_Tidy：场景曝光参数查询
///   - getFilmFilterPresets_Tidy / getLightingReferences_Tidy：胶片滤镜与教学图库查询
@MainActor
class ShootViewModel_Tidy {

    /// 单例
    static let shared_Tidy = ShootViewModel_Tidy()

    /// 拍摄预设数据变更通知
    static let shootPresetsDidChangeNotification_Tidy = Notification.Name("ShootPresetsDidChange_Tidy")

    /// UserDefaults 预设存储 Key
    private let kShootPresets_Tidy = "Tidy_ShootPresets_v1"

    private init() {}

    // MARK: - 预设 CRUD

    /// 获取全部已保存的拍摄预设（按创建时间从新到旧排序）
    /// - Returns: 拍摄预设数组
    func getAllPresets_Tidy() -> [ShootPreset_Tidy] {
        guard let data_tidy = UserDefaults.standard.data(forKey: kShootPresets_Tidy),
              let presets_tidy = try? JSONDecoder().decode([ShootPreset_Tidy].self, from: data_tidy) else {
            return []
        }
        return presets_tidy.sorted { $0.createdAt_Tidy > $1.createdAt_Tidy }
    }

    /// 保存一套新的拍摄参数预设（构图网格 + 透明度 + 胶片滤镜 + 渐变滤镜 + 拍摄用照片）
    /// 参数：
    /// - name_tidy: 预设名称
    /// - gridType_tidy: 构图网格类型
    /// - gridOpacity_tidy: 构图网格透明度
    /// - filterPresetId_tidy: 关联胶片滤镜预设 ID（可为空）
    /// - gradientConfig_tidy: 关联渐变滤镜配置（可为空）
    /// - image_tidy: 保存预设时正在使用的照片，会被压缩写入本地文件，还原预设时一并带回
    func savePreset_Tidy(
        name_tidy: String,
        gridType_tidy: GridTemplateType_Tidy,
        gridOpacity_tidy: Float,
        filterPresetId_tidy: String?,
        gradientConfig_tidy: GradientFilterConfig_Tidy?,
        image_tidy: UIImage?
    ) {
        var presets_tidy = getAllPresets_Tidy()
        let imageFileName_tidy = saveImageToDisk_Tidy(image_tidy: image_tidy)
        let newPreset_tidy = ShootPreset_Tidy(
            id_Tidy: UUID().uuidString,
            name_Tidy: name_tidy,
            gridType_Tidy: gridType_tidy,
            gridOpacity_Tidy: gridOpacity_tidy,
            filterPresetId_Tidy: filterPresetId_tidy,
            gradientConfig_Tidy: gradientConfig_tidy,
            imageFileName_Tidy: imageFileName_tidy,
            createdAt_Tidy: Date()
        )
        presets_tidy.append(newPreset_tidy)
        persistPresets_Tidy(presets_tidy)
        Utils_Tidy.showSuccess_Tidy(message_Tidy: "Preset saved! Ready for next shoot 🎬")
        notifyPresetsChange_Tidy()
    }

    /// 删除指定预设（同时清理其关联的本地照片文件，避免留下孤立文件）
    /// 参数：
    /// - id_tidy: 预设唯一标识
    func deletePreset_Tidy(id_tidy: String) {
        var presets_tidy = getAllPresets_Tidy()
        if let target_tidy = presets_tidy.first(where: { $0.id_Tidy == id_tidy }),
           let imageFileName_tidy = target_tidy.imageFileName_Tidy {
            try? FileManager.default.removeItem(at: presetImageURL_Tidy(fileName_tidy: imageFileName_tidy))
        }
        presets_tidy.removeAll { $0.id_Tidy == id_tidy }
        persistPresets_Tidy(presets_tidy)
        notifyPresetsChange_Tidy()
    }

    /// 将预设数组编码后写入 UserDefaults
    private func persistPresets_Tidy(_ presets_tidy: [ShootPreset_Tidy]) {
        guard let data_tidy = try? JSONEncoder().encode(presets_tidy) else { return }
        UserDefaults.standard.set(data_tidy, forKey: kShootPresets_Tidy)
    }

    // MARK: - 预设关联照片本地存取

    /// 拍摄预设照片在 Documents 目录中的完整路径
    /// 参数：
    /// - fileName_tidy: 文件名
    private func presetImageURL_Tidy(fileName_tidy: String) -> URL {
        let docsURL_tidy = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docsURL_tidy.appendingPathComponent(fileName_tidy)
    }

    /// 将照片压缩为 JPEG 并写入本地，返回生成的文件名（写入失败或未传图片时返回 nil）
    /// 参数：
    /// - image_tidy: 待保存的照片
    private func saveImageToDisk_Tidy(image_tidy: UIImage?) -> String? {
        guard let image_tidy = image_tidy,
              let data_tidy = image_tidy.jpegData(compressionQuality: 0.7) else { return nil }
        let fileName_tidy = "shoot_preset_\(UUID().uuidString).jpg"
        do {
            try data_tidy.write(to: presetImageURL_Tidy(fileName_tidy: fileName_tidy))
            return fileName_tidy
        } catch {
            print("拍摄预设照片保存失败: \(error)")
            return nil
        }
    }

    /// 根据文件名读取预设关联的照片
    /// 参数：
    /// - fileName_tidy: 文件名
    /// 返回值：读取到的 UIImage，文件不存在或读取失败时返回 nil
    func loadPresetImage_Tidy(fileName_tidy: String) -> UIImage? {
        UIImage(contentsOfFile: presetImageURL_Tidy(fileName_tidy: fileName_tidy).path)
    }

    /// 广播预设数据变更通知
    private func notifyPresetsChange_Tidy() {
        NotificationCenter.default.post(
            name: ShootViewModel_Tidy.shootPresetsDidChangeNotification_Tidy, object: nil
        )
    }

    // MARK: - 曝光参数模拟

    /// 根据拍摄场景获取推荐的 ISO / 快门 / 光圈参数（快门模拟模拟器）
    /// 参数：
    /// - scene_tidy: 拍摄场景类型
    /// 返回值：曝光参数推荐结果
    func getExposureRecommendation_Tidy(scene_tidy: SceneType_Tidy) -> ExposureRecommendation_Tidy {
        ShootDataSource_Tidy.exposureRecommendationTable_Tidy[scene_tidy]
            ?? ExposureRecommendation_Tidy(iso_Tidy: "-", shutterSpeed_Tidy: "-", aperture_Tidy: "-", tip_Tidy: "")
    }

    // MARK: - 胶片滤镜 & 教学图库查询

    /// 获取胶片滤镜预设列表，可按分组过滤
    /// 参数：
    /// - group_tidy: 指定分组，传 nil 返回全部
    func getFilmFilterPresets_Tidy(group_tidy: FilmFilterGroup_Tidy? = nil) -> [FilmFilterPreset_Tidy] {
        guard let group_tidy = group_tidy else { return ShootDataSource_Tidy.filmFilterPresets_Tidy }
        return ShootDataSource_Tidy.filmFilterPresets_Tidy.filter { $0.group_Tidy == group_tidy }
    }

    /// 根据 ID 查找胶片滤镜预设
    /// 参数：
    /// - id_tidy: 预设唯一标识
    func getFilmFilterPreset_Tidy(id_tidy: String) -> FilmFilterPreset_Tidy? {
        ShootDataSource_Tidy.filmFilterPresets_Tidy.first { $0.id_Tidy == id_tidy }
    }

    /// 获取离线光影教学参考卡片列表，可按构图分类过滤
    /// 参数：
    /// - category_tidy: 指定构图分类，传 nil 返回全部
    func getLightingReferences_Tidy(category_tidy: GridTemplateType_Tidy? = nil) -> [LightingReference_Tidy] {
        guard let category_tidy = category_tidy else { return ShootDataSource_Tidy.lightingReferences_Tidy }
        return ShootDataSource_Tidy.lightingReferences_Tidy.filter { $0.category_Tidy == category_tidy }
    }
}
