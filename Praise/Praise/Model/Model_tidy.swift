import Foundation
import UIKit

// MARK: 数据模型定义

// MARK: - 家居分类模型

/// 家居物品分类模型
/// 功能：定义首页分类入口与发现页筛选 tab 所用的分类数据结构
/// 关键属性：
///   - id_Tidy: 分类唯一标识（与 TitleModel 的 titleCategory_Tidy 对应）
///   - name_Tidy: 展示名称（英文 UI）
///   - iconName_Tidy: SF Symbol 图标名
///   - colorHex_Tidy: 分类主题色十六进制值
struct HomeCategory_Tidy {
    
    /// 分类唯一标识（"all" 表示全部）
    let id_Tidy: String
    
    /// 分类展示名称
    let name_Tidy: String
    
    /// SF Symbol 图标名
    let iconName_Tidy: String
    
    /// 分类主题色十六进制值
    let colorHex_Tidy: String
}

/// 用户数据模型
class PrewUserModel_Tidy: NSObject, Codable {
    
    /// 用户ID
    var userId_Tidy: Int?
    
    /// 用户名字
    var userName_Tidy: String?
    
    /// 用户简介
    var userIntroduce_Tidy: String?
    
    /// 用户头像
    var userHead_Tidy: String?
    
    /// 用户媒体
    var userMedia_Tidy: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Tidy: [TitleModel_Tidy] = []

    /// 用户关注数
    var userFollow_Tidy: Int?

    /// 用户粉丝数
    var userFans_Tidy: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Tidy: Int? = nil,
         userName_Tidy: String? = nil,
         userIntroduce_Tidy: String? = nil,
         userHead_Tidy: String? = nil,
         userMedia_Tidy: [String]? = nil,
         userLike_Tidy: [TitleModel_Tidy] = [],
         userFollow_Tidy: Int? = nil,
         userFans_Tidy: Int? = nil) {
        self.userId_Tidy = userId_Tidy
        self.userName_Tidy = userName_Tidy
        self.userIntroduce_Tidy = userIntroduce_Tidy
        self.userHead_Tidy = userHead_Tidy
        self.userMedia_Tidy = userMedia_Tidy
        self.userLike_Tidy = userLike_Tidy
        self.userFollow_Tidy = userFollow_Tidy
        self.userFans_Tidy = userFans_Tidy
        super.init()
    }
}

/// 帖子数据模型
/// 功能：社区帖子的完整数据结构，包含分类标识用于首页/发现页筛选
class TitleModel_Tidy: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Tidy: Int
    
    /// 拥有者ID
    var titleUserId_Tidy: Int
    
    /// 拥有者昵称
    var titleUserName_Tidy: String
    
    /// 帖子媒体
    var titleMeidas_Tidy: [String]
    
    /// 帖子标题
    var title_Tidy: String
    
    /// 帖子内容
    var titleContent_Tidy: String
    
    /// 帖子评论列表
    var reviews_Tidy: [Comment_Tidy]
    
    /// 喜欢个数
    var likes_Tidy: Int
    
    /// 帖子所属家居分类标识（与 HomeCategory_Tidy.id_Tidy 对应）
    var titleCategory_Tidy: String
    
    init(titleId_Tidy: Int,
         titleUserId_Tidy: Int,
         titleUserName_Tidy: String,
         titleMeidas_Tidy: [String],
         title_Tidy: String,
         titleContent_Tidy: String,
         reviews_Tidy: [Comment_Tidy],
         likes_Tidy: Int,
         titleCategory_Tidy: String = "all") {
        self.titleId_Tidy = titleId_Tidy
        self.titleUserId_Tidy = titleUserId_Tidy
        self.titleUserName_Tidy = titleUserName_Tidy
        self.titleMeidas_Tidy = titleMeidas_Tidy
        self.title_Tidy = title_Tidy
        self.titleContent_Tidy = titleContent_Tidy
        self.reviews_Tidy = reviews_Tidy
        self.likes_Tidy = likes_Tidy
        self.titleCategory_Tidy = titleCategory_Tidy
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Tidy: NSObject, Codable {
    
    /// 用户ID
    var userId_Tidy: Int?
    
    /// 用户密码
    var userPwd_Tidy: String?
    
    /// 用户名称
    var userName_Tidy: String?
    
    /// 用户头像
    var userHead_Tidy: String?
    
    /// 用户简介
    var userIntroduce_Tidy: String?
    
    /// 用户发布帖子列表
    var userPosts_Tidy: [TitleModel_Tidy]
    
    /// 用户喜欢帖子列表
    var userLike_Tidy: [TitleModel_Tidy]

    /// 用户关注列表
    var userFollow_Tidy: [PrewUserModel_Tidy]
    
    /// 初始化
    init(userId_Tidy: Int? = nil,
         userPwd_Tidy: String? = nil,
         userName_Tidy: String? = nil,
         userHead_Tidy: String? = nil,
         userIntroduce_Tidy: String? = nil,
         userPosts_Tidy: [TitleModel_Tidy],
         userLike_Tidy: [TitleModel_Tidy],
         userFollow_Tidy: [PrewUserModel_Tidy]) {
        self.userId_Tidy = userId_Tidy
        self.userPwd_Tidy = userPwd_Tidy
        self.userName_Tidy = userName_Tidy
        self.userHead_Tidy = userHead_Tidy
        self.userIntroduce_Tidy = userIntroduce_Tidy
        self.userPosts_Tidy = userPosts_Tidy
        self.userLike_Tidy = userLike_Tidy
        self.userFollow_Tidy = userFollow_Tidy
    }
}

/// 消息数据模型
class MessageModel_Tidy: Codable {
    
    /// 消息ID
    var messageId_Tidy: Int?
    
    /// 消息内容
    var content_Tidy: String?
    
    /// 用户头像
    var userHead_Tidy: String?
    
    /// 是否是我发送的
    var isMine_Tidy: Bool?
    
    /// 消息时间
    var time_Tidy: String?
    
    /// 初始化
    init(messageId_tidy: Int? = nil,
         content_tidy: String? = nil,
         userHead_tidy: String? = nil,
         isMine_tidy: Bool? = nil,
         time_tidy: String? = nil) {
        self.messageId_Tidy = messageId_tidy
        self.content_Tidy = content_tidy
        self.userHead_Tidy = userHead_tidy
        self.isMine_Tidy = isMine_tidy
        self.time_Tidy = time_tidy
    }
}

/// 评论模型
class Comment_Tidy: NSObject, Codable {
    
    /// 评论ID
    var commentId_Tidy: Int
    
    /// 评论用户uid
    var commentUserId_Tidy: Int
    
    /// 评论用户昵称
    var commentUserName_Tidy: String
    
    /// 评论内容
    var commentContent_Tidy: String
    
    /// 初始化
    init(commentId_Tidy: Int,
         commentUserId_Tidy: Int,
         commentUserName_Tidy: String,
         commentContent_Tidy: String) {
        self.commentId_Tidy = commentId_Tidy
        self.commentUserId_Tidy = commentUserId_Tidy
        self.commentUserName_Tidy = commentUserName_Tidy
        self.commentContent_Tidy = commentContent_Tidy
    }
}

/// 商店模型
class StoreModel_Tidy: NSObject {
    
    /// ID编号
    var id_Tidy: Int?
    
    /// 商品ID
    var goodsId_Tidy: String?
    
    /// 商品名字
    var goodsName_Tidy: String?
    
    /// 商品价格
    var goodsPrice_Tidy: String?
    
    /// 是否顶部商品
    var goodIsTop_Tidy: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Tidy: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Tidy: Bool?
    
    init(id_Tidy: Int? = nil,
         goodsId_Tidy: String? = nil,
         goodsName_Tidy: String? = nil,
         goodsPrice_Tidy: String? = nil,
         goodIsTop_Tidy: Bool? = false,
         goodIsLimit_Tidy: Bool? = false,
         goodIsVIP_Tidy: Bool? = false) {
        self.id_Tidy = id_Tidy
        self.goodsId_Tidy = goodsId_Tidy
        self.goodsName_Tidy = goodsName_Tidy
        self.goodsPrice_Tidy = goodsPrice_Tidy
        self.goodIsTop_Tidy = goodIsTop_Tidy
        self.goodIsSpecial_Tidy = goodIsLimit_Tidy
        self.goodIsVIP_Tidy = goodIsVIP_Tidy
        super.init()
    }
}

// MARK: - 拍摄工具箱数据模型

/// 构图网格模板类型枚举
/// 功能：定义拍摄工具箱中可供选择的构图辅助线类型，每种类型对应不同的画面分割规则
enum GridTemplateType_Tidy: String, CaseIterable, Codable, Hashable {
    /// 三分线（九宫格）
    case ruleOfThirds_tidy
    /// 黄金螺旋
    case goldenSpiral_tidy
    /// 对称构图
    case symmetry_tidy
    /// 对角线构图
    case diagonal_tidy
    /// 电影 2.39:1 遮幅
    case cinemaScope_tidy
    /// 证件照比例
    case idPhoto_tidy
    /// 方形构图（1:1）
    case square_tidy
    /// 人像裁割参考线
    case portraitCrop_tidy

    /// 展示名称（英文 UI 文案）
    var displayName_Tidy: String {
        switch self {
        case .ruleOfThirds_tidy:  return "Rule of Thirds"
        case .goldenSpiral_tidy:  return "Golden Spiral"
        case .symmetry_tidy:      return "Symmetry"
        case .diagonal_tidy:      return "Diagonal"
        case .cinemaScope_tidy:   return "Cinema 2.39:1"
        case .idPhoto_tidy:       return "ID Photo Ratio"
        case .square_tidy:        return "Square"
        case .portraitCrop_tidy:  return "Portrait Crop"
        }
    }

    /// SF Symbol 图标名（用于选择器与占位图标）
    var iconName_Tidy: String {
        switch self {
        case .ruleOfThirds_tidy:  return "grid"
        case .goldenSpiral_tidy:  return "tornado"
        case .symmetry_tidy:      return "arrow.left.and.right.righttriangle.left.righttriangle.right"
        case .diagonal_tidy:      return "line.diagonal"
        case .cinemaScope_tidy:   return "rectangle.compress.vertical"
        case .idPhoto_tidy:       return "person.crop.rectangle"
        case .square_tidy:        return "square"
        case .portraitCrop_tidy:  return "person.crop.square"
        }
    }

    /// 图库/入口卡片主题色（复用 ColorConfig 现有配色，区分不同构图分类视觉）
    var themeColor_Tidy: UIColor {
        switch self {
        case .ruleOfThirds_tidy:  return ColorConfig_Tidy.categoryKitchen_Tidy
        case .goldenSpiral_tidy:  return ColorConfig_Tidy.tidyGold_Tidy
        case .symmetry_tidy:      return ColorConfig_Tidy.categoryBedroom_Tidy
        case .diagonal_tidy:      return ColorConfig_Tidy.categoryGarden_Tidy
        case .cinemaScope_tidy:   return ColorConfig_Tidy.tidyMintDeep_Tidy
        case .idPhoto_tidy:       return ColorConfig_Tidy.categoryBathroom_Tidy
        case .square_tidy:        return ColorConfig_Tidy.categoryStudy_Tidy
        case .portraitCrop_tidy:  return ColorConfig_Tidy.categoryStorage_Tidy
        }
    }
}

/// 胶片滤镜分组枚举
/// 功能：定义可自定义胶片滤镜组的六大分类，对应不同胶片厂商/风格调性
enum FilmFilterGroup_Tidy: String, CaseIterable, Codable, Hashable {
    /// 富士胶片风格（清冷通透、绿蓝更纯）
    case fujifilm_tidy
    /// 柯达胶片风格（暖调高饱和、红润明快）
    case kodak_tidy
    /// 伊尔福黑白胶片风格（高反差黑白）
    case ilford_tidy
    /// 复古港风（青红分离、颗粒暗角）
    case hkRetro_tidy
    /// 日系清透风格（低对比高曝光柔雾感）
    case japaneseClean_tidy
    /// 电影感 LUT（青橙调、宽银幕氛围）
    case cinematic_tidy

    /// 展示名称
    var displayName_Tidy: String {
        switch self {
        case .fujifilm_tidy:      return "Fujifilm"
        case .kodak_tidy:         return "Kodak"
        case .ilford_tidy:        return "Ilford"
        case .hkRetro_tidy:       return "HK Retro"
        case .japaneseClean_tidy: return "Japanese Clean"
        case .cinematic_tidy:     return "Cinematic LUT"
        }
    }

    /// 分组主题色（复用 ColorConfig 现有配色，用于滤镜 Chip 个性化配色）
    var themeColor_Tidy: UIColor {
        switch self {
        case .fujifilm_tidy:      return ColorConfig_Tidy.categoryStudy_Tidy
        case .kodak_tidy:         return ColorConfig_Tidy.tidyWarm_Tidy
        case .ilford_tidy:        return ColorConfig_Tidy.textSecondary_Tidy
        case .hkRetro_tidy:       return ColorConfig_Tidy.categoryBathroom_Tidy
        case .japaneseClean_tidy: return ColorConfig_Tidy.tidyGold_Tidy
        case .cinematic_tidy:     return ColorConfig_Tidy.primaryGradientStart_Tidy
        }
    }
}

/// 胶片滤镜预设模型
/// 功能：承载单个胶片滤镜的 CIFilter 调色参数，用于对预览图施加胶片风格模拟效果
/// 关键属性：
///   - exposure_Tidy/saturation_Tidy/contrast_Tidy：对应 CIColorControls 参数
///   - temperature_Tidy/tint_Tidy：对应 CITemperatureAndTint 参数
///   - vignette_Tidy：暗角强度，对应 CIVignette intensity
///   - lutFileName_Tidy：预留的真实 .cube LUT 文件名，当前为空，接入后由 FilmFilterEngine 优先使用
struct FilmFilterPreset_Tidy: Codable, Equatable {
    /// 预设唯一标识
    let id_Tidy: String
    /// 预设名称（英文 UI 展示）
    let name_Tidy: String
    /// 所属胶片分组
    let group_Tidy: FilmFilterGroup_Tidy
    /// 曝光调整（近似映射到 CIColorControls.brightness）
    let exposure_Tidy: Float
    /// 饱和度（0...2，1 为原始饱和度）
    let saturation_Tidy: Float
    /// 对比度（0...2，1 为原始对比度）
    let contrast_Tidy: Float
    /// 色温偏移（开尔文，正值偏暖，负值偏冷）
    let temperature_Tidy: Float
    /// 色调偏移（正值偏品红，负值偏绿）
    let tint_Tidy: Float
    /// 暗角强度（0...1）
    let vignette_Tidy: Float
    /// 预留真实 LUT 文件名（Documents 或 Bundle 内的 .cube 文件），当前为空
    let lutFileName_Tidy: String?
}

/// 渐变滤镜类型枚举（渐变形状）
enum GradientFilterType_Tidy: String, Codable, CaseIterable, Hashable {
    /// 径向渐变
    case radial_tidy
    /// 线性渐变
    case linear_tidy

    /// 展示名称
    var displayName_Tidy: String { self == .radial_tidy ? "Radial" : "Linear" }
}

/// 渐变滤镜作用模式枚举
enum GradientFilterMode_Tidy: String, Codable, CaseIterable, Hashable {
    /// 压暗天空（作用于画面上半部分）
    case darkenSky_tidy
    /// 提亮前景（作用于画面下半部分）
    case brightenForeground_tidy

    /// 展示名称
    var displayName_Tidy: String { self == .darkenSky_tidy ? "Darken Sky" : "Brighten Foreground" }
}

/// 渐变滤镜配置模型
/// 功能：描述一次渐变滤镜处理所需的形状、作用模式与强度参数
struct GradientFilterConfig_Tidy: Codable, Equatable {
    /// 渐变形状类型
    var type_Tidy: GradientFilterType_Tidy
    /// 作用模式
    var mode_Tidy: GradientFilterMode_Tidy
    /// 渐变强度（0...1，越大压暗/提亮效果越强）
    var intensity_Tidy: Float
}

/// 拍摄参数预设模型
/// 功能：记录一次"构图网格 + 透明度 + 胶片滤镜 + 渐变滤镜 + 拍摄用照片"的完整组合配置，
///       支持保存到本地并在下次拍片时一键调用（对应"拍摄参数记忆"需求）
/// 关键属性：
///   - imageFileName_Tidy：保存预设时所用照片在 Documents 目录中的文件名，还原预设时据此
///     重新读取并展示原图，而不仅仅是还原网格/滤镜/渐变等参数配置
struct ShootPreset_Tidy: Codable, Equatable {
    /// 预设唯一标识（UUID 字符串）
    var id_Tidy: String
    /// 预设名称（用户自定义命名）
    var name_Tidy: String
    /// 构图网格类型
    var gridType_Tidy: GridTemplateType_Tidy
    /// 构图网格透明度（0...1）
    var gridOpacity_Tidy: Float
    /// 关联的胶片滤镜预设 ID（可为空，表示未应用滤镜）
    var filterPresetId_Tidy: String?
    /// 关联的渐变滤镜配置（可为空，表示未应用渐变）
    var gradientConfig_Tidy: GradientFilterConfig_Tidy?
    /// 保存预设时所用照片的本地文件名（可为空，兼容旧版无图片的预设）
    var imageFileName_Tidy: String?
    /// 创建时间戳
    var createdAt_Tidy: Date
}

/// 拍摄场景类型枚举（用于快门参数模拟器）
enum SceneType_Tidy: String, CaseIterable, Codable, Hashable {
    /// 人像场景
    case portrait_tidy
    /// 夜景场景
    case night_tidy
    /// 风光场景
    case landscape_tidy

    /// 展示名称
    var displayName_Tidy: String {
        switch self {
        case .portrait_tidy:  return "Portrait"
        case .night_tidy:     return "Night"
        case .landscape_tidy: return "Landscape"
        }
    }

    /// SF Symbol 图标名
    var iconName_Tidy: String {
        switch self {
        case .portrait_tidy:  return "person.crop.circle"
        case .night_tidy:     return "moon.stars.fill"
        case .landscape_tidy: return "mountain.2.fill"
        }
    }
}

/// 曝光参数推荐结果模型
/// 功能：根据拍摄场景给出推荐的 ISO / 快门速度 / 光圈组合及简要提示文案
/// 说明：数值为经验性摄影建议，不读取真实相机硬件参数
struct ExposureRecommendation_Tidy {
    /// 推荐 ISO 值展示文案
    let iso_Tidy: String
    /// 推荐快门速度展示文案
    let shutterSpeed_Tidy: String
    /// 推荐光圈展示文案
    let aperture_Tidy: String
    /// 拍摄提示文案
    let tip_Tidy: String
}

// MARK: - 每日任务数据模型

/// 每日任务类型枚举
/// 功能：定义首页"每日任务"区块的 5 种任务类型，按难度从低到高分配对应目标完成次数——
///       难度越低（越容易完成）分配的目标次数越多，难度越高分配的目标次数越少：
///         打卡（入门，1 次）→ 浏览帖子（简单，5 次）→ 点赞帖子（普通，3 次）→
///         查看用户资料（进阶，2 次）→ 发布帖子（较难，1 次）
enum DailyTaskType_Tidy: String, CaseIterable, Codable, Hashable {
    /// 打卡（难度：入门，日常习惯动作，目标 1 次）
    case checkin_tidy
    /// 浏览帖子（难度：简单，目标 5 次）
    case browsePosts_tidy
    /// 点赞帖子（难度：普通，目标 3 次）
    case likePosts_tidy
    /// 查看用户资料（难度：进阶，目标 2 次）
    case viewProfile_tidy
    /// 发布帖子（难度：较难，需选图+填写内容+提交，目标 1 次）
    case publishPost_tidy

    /// 展示标题
    var title_Tidy: String {
        switch self {
        case .checkin_tidy:     return "Daily Check-in"
        case .browsePosts_tidy: return "Browse Posts"
        case .likePosts_tidy:   return "Like Posts"
        case .viewProfile_tidy: return "View Profiles"
        case .publishPost_tidy: return "Publish a Post"
        }
    }

    /// 任务说明文案
    var subtitle_Tidy: String {
        switch self {
        case .checkin_tidy:     return "Log today's shot streak"
        case .browsePosts_tidy: return "Open post details to explore ideas"
        case .likePosts_tidy:   return "Show love for shots you admire"
        case .viewProfile_tidy: return "Check out other creators"
        case .publishPost_tidy: return "Share one frame with the community"
        }
    }

    /// SF Symbol 图标名
    var iconName_Tidy: String {
        switch self {
        case .checkin_tidy:     return "flame.fill"
        case .browsePosts_tidy: return "square.stack.3d.up.fill"
        case .likePosts_tidy:   return "heart.fill"
        case .viewProfile_tidy: return "person.crop.circle.fill"
        case .publishPost_tidy: return "square.and.arrow.up.fill"
        }
    }

    /// 难度文案（从低到高）
    var difficultyLabel_Tidy: String {
        switch self {
        case .checkin_tidy:     return "Starter"
        case .browsePosts_tidy: return "Easy"
        case .likePosts_tidy:   return "Normal"
        case .viewProfile_tidy: return "Advanced"
        case .publishPost_tidy: return "Hard"
        }
    }

    /// 目标完成次数：难度越低次数越多，难度越高次数越少
    var targetCount_Tidy: Int {
        switch self {
        case .checkin_tidy:     return 1
        case .browsePosts_tidy: return 5
        case .likePosts_tidy:   return 3
        case .viewProfile_tidy: return 2
        case .publishPost_tidy: return 1
        }
    }

    /// 主题色（复用 ColorConfig 现有配色，用于图标底色与进度展示）
    var themeColor_Tidy: UIColor {
        switch self {
        case .checkin_tidy:     return ColorConfig_Tidy.tidyWarm_Tidy
        case .browsePosts_tidy: return ColorConfig_Tidy.tidyMint_Tidy
        case .likePosts_tidy:   return ColorConfig_Tidy.categoryBathroom_Tidy
        case .viewProfile_tidy: return ColorConfig_Tidy.categoryStudy_Tidy
        case .publishPost_tidy: return ColorConfig_Tidy.primaryGradientStart_Tidy
        }
    }
}

/// 每日任务展示项模型
/// 功能：承载单个任务类型在"今天"的完成进度，供首页任务区块渲染
struct DailyTaskItem_Tidy {
    /// 任务类型
    let type_Tidy: DailyTaskType_Tidy
    /// 今日已完成次数
    let progress_Tidy: Int
    /// 是否已达标完成
    var isCompleted_Tidy: Bool { progress_Tidy >= type_Tidy.targetCount_Tidy }
}

/// 离线光影教学参考卡片模型
/// 功能：承载"离线光影教学参考"图库中单条构图/光影示例，占位图标+文案，供分类浏览学习
struct LightingReference_Tidy {
    /// 唯一标识
    let id_Tidy: Int
    /// 所属构图分类
    let category_Tidy: GridTemplateType_Tidy
    /// 标题
    let title_Tidy: String
    /// 详细教学说明
    let description_Tidy: String
    /// 占位 SF Symbol 图标名（后续可替换为真实成片素材图）
    let iconName_Tidy: String
}
