import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Lumia: NSObject, Codable {
    
    /// 用户ID
    var userId_Lumia: Int?
    
    /// 用户名字
    var userName_Lumia: String?
    
    /// 用户简介
    var userIntroduce_Lumia: String?
    
    /// 用户头像
    var userHead_Lumia: String?
    
    /// 用户媒体
    var userMedia_Lumia: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Lumia: [TitleModel_Lumia] = []

    /// 用户关注数
    var userFollow_Lumia: Int?

    /// 用户粉丝数
    var userFans_Lumia: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Lumia: Int? = nil,
         userName_Lumia: String? = nil,
         userIntroduce_Lumia: String? = nil,
         userHead_Lumia: String? = nil,
         userMedia_Lumia: [String]? = nil,
         userLike_Lumia: [TitleModel_Lumia] = [],
         userFollow_Lumia: Int? = nil,
         userFans_Lumia: Int? = nil) {
        self.userId_Lumia = userId_Lumia
        self.userName_Lumia = userName_Lumia
        self.userIntroduce_Lumia = userIntroduce_Lumia
        self.userHead_Lumia = userHead_Lumia
        self.userMedia_Lumia = userMedia_Lumia
        self.userLike_Lumia = userLike_Lumia
        self.userFollow_Lumia = userFollow_Lumia
        self.userFans_Lumia = userFans_Lumia
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Lumia: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Lumia: Int
    
    /// 拥有者ID
    var titleUserId_Lumia: Int
    
    /// 拥有者昵称
    var titleUserName_Lumia: String
    
    /// 帖子媒体
    var titleMeidas_Lumia: [String]
    
    /// 帖子标题
    var title_Lumia: String
    
    /// 帖子内容
    var titleContent_Lumia: String
    
    /// 帖子评论列表
    var reviews_Lumia: [Comment_Lumia]
    
    /// 喜欢个数
    var likes_Lumia: Int
    
    init(titleId_Lumia: Int,
         titleUserId_Lumia: Int,
         titleUserName_Lumia: String,
         titleMeidas_Lumia: [String],
         title_Lumia: String,
         titleContent_Lumia: String,
         reviews_Lumia: [Comment_Lumia],
         likes_Lumia: Int) {
        self.titleId_Lumia = titleId_Lumia
        self.titleUserId_Lumia = titleUserId_Lumia
        self.titleUserName_Lumia = titleUserName_Lumia
        self.titleMeidas_Lumia = titleMeidas_Lumia
        self.title_Lumia = title_Lumia
        self.titleContent_Lumia = titleContent_Lumia
        self.reviews_Lumia = reviews_Lumia
        self.likes_Lumia = likes_Lumia
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Lumia: NSObject, Codable {
    
    /// 用户ID
    var userId_Lumia: Int?
    
    /// 用户密码
    var userPwd_Lumia: String?
    
    /// 用户名称
    var userName_Lumia: String?
    
    /// 用户头像
    var userHead_Lumia: String?

    /// 用户个人简介
    var userIntroduce_Lumia: String?
    
    /// 用户发布帖子列表
    var userPosts_Lumia: [TitleModel_Lumia]
    
    /// 用户喜欢帖子列表
    var userLike_Lumia: [TitleModel_Lumia]

    /// 用户关注列表
    var userFollow_Lumia: [PrewUserModel_Lumia]

    /// 胶片卷列表（包含今日进行中的卷和历史已冲洗的卷）
    var filmRolls_Lumia: [FilmRoll_Lumia]

    /// 主题征集提交列表
    var themeSubmissions_Lumia: [ThemeSubmission_Lumia]
    
    /// 初始化
    init(userId_Lumia: Int? = nil,
         userPwd_Lumia: String? = nil,
         userName_Lumia: String? = nil,
         userHead_Lumia: String? = nil,
         userIntroduce_Lumia: String? = nil,
         userPosts_Lumia: [TitleModel_Lumia],
         userLike_Lumia: [TitleModel_Lumia],
         userFollow_Lumia: [PrewUserModel_Lumia],
         filmRolls_Lumia: [FilmRoll_Lumia] = [],
         themeSubmissions_Lumia: [ThemeSubmission_Lumia] = []) {
        self.userId_Lumia = userId_Lumia
        self.userPwd_Lumia = userPwd_Lumia
        self.userName_Lumia = userName_Lumia
        self.userHead_Lumia = userHead_Lumia
        self.userIntroduce_Lumia = userIntroduce_Lumia
        self.userPosts_Lumia = userPosts_Lumia
        self.userLike_Lumia = userLike_Lumia
        self.userFollow_Lumia = userFollow_Lumia
        self.filmRolls_Lumia = filmRolls_Lumia
        self.themeSubmissions_Lumia = themeSubmissions_Lumia
    }
}

/// 消息数据模型
class MessageModel_Lumia: Codable {
    
    /// 消息ID
    var messageId_Lumia: Int?
    
    /// 消息内容
    var content_Lumia: String?
    
    /// 用户头像
    var userHead_Lumia: String?
    
    /// 是否是我发送的
    var isMine_Lumia: Bool?
    
    /// 消息时间
    var time_Lumia: String?
    
    /// 初始化
    init(messageId_lumia: Int? = nil,
         content_lumia: String? = nil,
         userHead_lumia: String? = nil,
         isMine_lumia: Bool? = nil,
         time_lumia: String? = nil) {
        self.messageId_Lumia = messageId_lumia
        self.content_Lumia = content_lumia
        self.userHead_Lumia = userHead_lumia
        self.isMine_Lumia = isMine_lumia
        self.time_Lumia = time_lumia
    }
}

/// 评论模型
class Comment_Lumia: NSObject, Codable {
    
    /// 评论ID
    var commentId_Lumia: Int
    
    /// 评论用户uid
    var commentUserId_Lumia: Int
    
    /// 评论用户昵称
    var commentUserName_Lumia: String
    
    /// 评论内容
    var commentContent_Lumia: String
    
    /// 初始化
    init(commentId_Lumia: Int,
         commentUserId_Lumia: Int,
         commentUserName_Lumia: String,
         commentContent_Lumia: String) {
        self.commentId_Lumia = commentId_Lumia
        self.commentUserId_Lumia = commentUserId_Lumia
        self.commentUserName_Lumia = commentUserName_Lumia
        self.commentContent_Lumia = commentContent_Lumia
    }
}

/// 商店模型
class StoreModel_Lumia: NSObject {
    
    /// ID编号
    var id_Lumia: Int?
    
    /// 商品ID
    var goodsId_Lumia: String?
    
    /// 商品名字
    var goodsName_Lumia: String?
    
    /// 商品价格
    var goodsPrice_Lumia: String?
    
    /// 是否顶部商品
    var goodIsTop_Lumia: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Lumia: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Lumia: Bool?
    
    init(id_Lumia: Int? = nil,
         goodsId_Lumia: String? = nil,
         goodsName_Lumia: String? = nil,
         goodsPrice_Lumia: String? = nil,
         goodIsTop_Lumia: Bool? = false,
         goodIsLimit_Lumia: Bool? = false,
         goodIsVIP_Lumia: Bool? = false) {
        self.id_Lumia = id_Lumia
        self.goodsId_Lumia = goodsId_Lumia
        self.goodsName_Lumia = goodsName_Lumia
        self.goodsPrice_Lumia = goodsPrice_Lumia
        self.goodIsTop_Lumia = goodIsTop_Lumia
        self.goodIsSpecial_Lumia = goodIsLimit_Lumia
        self.goodIsVIP_Lumia = goodIsVIP_Lumia
        super.init()
    }
}

// MARK: - 胶片功能模型

/// 胶片单帧（代表一张照片，24帧构成一卷）
class FilmFrame_Lumia: NSObject, Codable {
    var frameIndex_Lumia: Int
    var imagePath_Lumia: String?
    var note_Lumia: String?
    var takenAt_Lumia: String

    var isExposed_Lumia: Bool { imagePath_Lumia != nil }

    init(frameIndex_Lumia: Int, imagePath_Lumia: String? = nil, note_Lumia: String? = nil) {
        self.frameIndex_Lumia = frameIndex_Lumia
        self.imagePath_Lumia = imagePath_Lumia
        self.note_Lumia = note_Lumia
        let f_Lumia = DateFormatter()
        f_Lumia.dateFormat = "HH:mm"
        self.takenAt_Lumia = f_Lumia.string(from: Date())
    }
}

/// 胶片卷日记（24帧/卷，代表一天或一个主题的拍摄记录）
class FilmRoll_Lumia: NSObject, Codable {
    var rollId_Lumia: Int
    var rollName_Lumia: String
    var dateString_Lumia: String
    var frames_Lumia: [FilmFrame_Lumia]
    var maxFrames_Lumia: Int
    var isDeveloped_Lumia: Bool

    var exposedCount_Lumia: Int { frames_Lumia.filter { $0.isExposed_Lumia }.count }
    var isFull_Lumia: Bool { exposedCount_Lumia >= maxFrames_Lumia }

    init(rollId_Lumia: Int, rollName_Lumia: String, dateString_Lumia: String, maxFrames_Lumia: Int = 24) {
        self.rollId_Lumia = rollId_Lumia
        self.rollName_Lumia = rollName_Lumia
        self.dateString_Lumia = dateString_Lumia
        self.maxFrames_Lumia = maxFrames_Lumia
        self.frames_Lumia = (1...maxFrames_Lumia).map { FilmFrame_Lumia(frameIndex_Lumia: $0) }
        self.isDeveloped_Lumia = false
    }
}

/// 时光胶囊（设定解锁时间后才可查看的照片+留言，用于发现页「Capsules」标签的预制展示数据）
class TimeCapsule_Lumia: NSObject, Codable {
    var capsuleId_Lumia: Int
    /// 作者用户ID（用于举报/删除按钮判断是否为当前用户本人所属）
    var authorUserId_Lumia: Int
    /// 作者用户名（展示用）
    var authorUserName_Lumia: String
    var imagePath_Lumia: String?
    var message_Lumia: String
    var unlockDateString_Lumia: String
    var createdAt_Lumia: String
    var isRevealed_Lumia: Bool

    var canReveal_Lumia: Bool {
        let f_Lumia = DateFormatter()
        f_Lumia.dateFormat = "yyyy-MM-dd"
        guard let unlockDate_Lumia = f_Lumia.date(from: unlockDateString_Lumia) else { return false }
        return Date() >= unlockDate_Lumia
    }

    init(
        capsuleId_Lumia: Int,
        authorUserId_Lumia: Int,
        authorUserName_Lumia: String,
        imagePath_Lumia: String? = nil,
        message_Lumia: String,
        unlockDateString_Lumia: String
    ) {
        self.capsuleId_Lumia = capsuleId_Lumia
        self.authorUserId_Lumia = authorUserId_Lumia
        self.authorUserName_Lumia = authorUserName_Lumia
        self.imagePath_Lumia = imagePath_Lumia
        self.message_Lumia = message_Lumia
        self.unlockDateString_Lumia = unlockDateString_Lumia
        let f_Lumia = DateFormatter()
        f_Lumia.dateFormat = "yyyy-MM-dd"
        self.createdAt_Lumia = f_Lumia.string(from: Date())
        self.isRevealed_Lumia = false
    }
}

/// 主题征集提交
class ThemeSubmission_Lumia: NSObject, Codable {
    var submissionId_Lumia: Int
    var themeId_Lumia: Int
    var imagePath_Lumia: String?
    var descText_Lumia: String
    var submittedAt_Lumia: String

    init(submissionId_Lumia: Int, themeId_Lumia: Int, imagePath_Lumia: String? = nil, descText_Lumia: String) {
        self.submissionId_Lumia = submissionId_Lumia
        self.themeId_Lumia = themeId_Lumia
        self.imagePath_Lumia = imagePath_Lumia
        self.descText_Lumia = descText_Lumia
        let f_Lumia = DateFormatter()
        f_Lumia.dateFormat = "yyyy-MM-dd HH:mm"
        self.submittedAt_Lumia = f_Lumia.string(from: Date())
    }
}

/// 主题胶片展（每周一个征集主题）
struct FilmTheme_Lumia: Codable {
    var themeId_Lumia: Int
    var themeTitle_Lumia: String
    var themeDesc_Lumia: String
    var weekLabel_Lumia: String
    var accentColor_Lumia: String
}

/// 主题讨论区评论（用户在主题下发布的评论）
class ThemeDiscussionComment_Lumia: NSObject, Codable {
    var commentId_Lumia: Int
    var userId_Lumia: Int
    var userName_Lumia: String
    var userHead_Lumia: String?
    var content_Lumia: String
    /// 发布时间（"HH:mm"）
    var createdAt_Lumia: String

    init(commentId_Lumia: Int, userId_Lumia: Int, userName_Lumia: String,
         userHead_Lumia: String? = nil, content_Lumia: String) {
        self.commentId_Lumia = commentId_Lumia
        self.userId_Lumia = userId_Lumia
        self.userName_Lumia = userName_Lumia
        self.userHead_Lumia = userHead_Lumia
        self.content_Lumia = content_Lumia
        let f_Lumia = DateFormatter()
        f_Lumia.dateFormat = "HH:mm"
        self.createdAt_Lumia = f_Lumia.string(from: Date())
    }
}

// MARK: - 胶片工作室工具模型（预设/手动调节/硬件特效/曝光计算/冲洗计算共用）

/// 胶片调节参数集合
/// 核心作用：手动调节面板与胶片预设共用的渲染参数，供 FilmEffectsEngine_Lumia 统一渲染
/// 关键属性：除色温/分色偏移取值范围为 -1...1（0 为中性）外，其余强度类参数取值范围为 0...1
struct FilmAdjustmentParams_Lumia: Codable {
    /// 颗粒强度
    var grain_Lumia: Double = 0
    /// 灰雾强度（提亮暗部、降低对比的老胶片雾感）
    var fog_Lumia: Double = 0
    /// 对比度（0.5 为中性，越大对比越强）
    var contrast_Lumia: Double = 0.5
    /// 色温偏移（负值偏冷蓝，正值偏暖黄）
    var tempShift_Lumia: Double = 0
    /// 饱和度（0.5 为中性）
    var saturation_Lumia: Double = 0.5
    /// 红通道分色偏移
    var channelR_Lumia: Double = 0
    /// 绿通道分色偏移
    var channelG_Lumia: Double = 0
    /// 蓝通道分色偏移
    var channelB_Lumia: Double = 0
    /// 暗角强度
    var vignette_Lumia: Double = 0
    /// 漏光强度
    var lightLeak_Lumia: Double = 0
    /// 划痕脏点密度
    var dustScratch_Lumia: Double = 0

    /// 中性（无任何调节）参数
    static let neutral_Lumia = FilmAdjustmentParams_Lumia()
}

/// 胶片类型（彩负 / 反转 / 黑白）
enum FilmStockType_Lumia: String, Codable, CaseIterable {
    case colorNegative_Lumia = "Color Negative"
    case slide_Lumia = "Slide (E-6)"
    case blackWhite_Lumia = "Black & White"
}

/// 胶片预设分类（拍摄场景/风格标签）
enum FilmPresetCategory_Lumia: String, Codable, CaseIterable {
    case daylight_Lumia = "Daylight"
    case indoor_Lumia = "Indoor"
    case portrait_Lumia = "Portrait"
    case landscape_Lumia = "Landscape"
    case retroHK_Lumia = "Retro HK"
    case japanese_Lumia = "Japanese"
    case grainy_Lumia = "Grainy"
}

/// 胶片预设模型（品牌胶卷 + 分类标签 + 渲染参数）
/// 核心作用：既承载预制的品牌胶卷预设（海量胶片预设离线库），也承载用户自制保存的配方
class FilmPresetModel_Lumia: NSObject, Codable {
    var presetId_Lumia: Int
    /// 品牌（如 Kodak / Fujifilm / Ilford / Agfa / Polaroid / Lucky），自制配方固定为 "Custom"
    var brand_Lumia: String
    /// 胶卷名称（如 Portra 400）
    var filmName_Lumia: String
    var stockType_Lumia: FilmStockType_Lumia
    var category_Lumia: FilmPresetCategory_Lumia
    var params_Lumia: FilmAdjustmentParams_Lumia
    /// 是否为用户自制配方
    var isCustom_Lumia: Bool
    /// 是否已"离线缓存"完整滤镜参数（本地存储、无需联网，可手动切换标记状态）
    var isCached_Lumia: Bool

    init(
        presetId_Lumia: Int,
        brand_Lumia: String,
        filmName_Lumia: String,
        stockType_Lumia: FilmStockType_Lumia,
        category_Lumia: FilmPresetCategory_Lumia,
        params_Lumia: FilmAdjustmentParams_Lumia,
        isCustom_Lumia: Bool = false,
        isCached_Lumia: Bool = true
    ) {
        self.presetId_Lumia = presetId_Lumia
        self.brand_Lumia = brand_Lumia
        self.filmName_Lumia = filmName_Lumia
        self.stockType_Lumia = stockType_Lumia
        self.category_Lumia = category_Lumia
        self.params_Lumia = params_Lumia
        self.isCustom_Lumia = isCustom_Lumia
        self.isCached_Lumia = isCached_Lumia
    }
}

/// 漏光模拟风格
enum LightLeakStyle_Lumia: String, Codable, CaseIterable {
    case none_Lumia = "None"
    case warm_Lumia = "Red/Orange"
    case cool_Lumia = "Purple/Blue"
    case rainbow_Lumia = "Multi-Color"
    case edge_Lumia = "Edge Gradient"
    case random_Lumia = "Random Spots"
}

/// 镜头瑕疵风格
enum LensFlawStyle_Lumia: String, Codable, CaseIterable {
    case none_Lumia = "None"
    case chromatic_Lumia = "Chromatic Aberration"
    case glare_Lumia = "Glare"
    case ghost_Lumia = "Ghosting"
    case vintageSoft_Lumia = "Vintage Soft"
    case spherical_Lumia = "Spherical Distortion"
}

/// 底片瑕疵风格
enum NegativeFlawStyle_Lumia: String, Codable, CaseIterable {
    case none_Lumia = "None"
    case dust_Lumia = "Dust"
    case scratches_Lumia = "Scratches"
    case waterMark_Lumia = "Water Marks"
    case mold_Lumia = "Mold Spots"
    case pinhole_Lumia = "Pinholes"
}

/// 相纸边框风格
enum FilmBorderStyle_Lumia: String, Codable, CaseIterable {
    case none_Lumia = "None"
    case frame135_Lumia = "135 Format"
    case frame120_Lumia = "120 Format"
    case polaroid_Lumia = "Polaroid Peel-Apart"
    case halfFrame_Lumia = "Half Frame"
    case twinLensSquare_Lumia = "Twin-Lens Square"
    case disposable_Lumia = "Disposable White Edge"
}

/// 硬件特效参数集合（漏光 / 镜头瑕疵 / 底片瑕疵 / 相纸边框）
/// 核心作用：模拟胶片硬件特效面板的完整状态，供 FilmEffectsEngine_Lumia 叠加渲染
struct HardwareEffectParams_Lumia: Codable {
    var lightLeakStyle_Lumia: LightLeakStyle_Lumia = .none_Lumia
    var lightLeakIntensity_Lumia: Double = 0.5
    var lensFlawStyle_Lumia: LensFlawStyle_Lumia = .none_Lumia
    var lensFlawIntensity_Lumia: Double = 0.5
    var negativeFlawStyle_Lumia: NegativeFlawStyle_Lumia = .none_Lumia
    var negativeFlawIntensity_Lumia: Double = 0.5
    var borderStyle_Lumia: FilmBorderStyle_Lumia = .none_Lumia
    /// 边框厚度（0...1，映射到实际像素宽度）
    var borderThickness_Lumia: Double = 0.4
    /// 是否显示底片齿孔（仅 135/半格 边框有效）
    var showPerforations_Lumia: Bool = false
    /// 编号水印文字（留空则不绘制）
    var watermarkText_Lumia: String = ""

    /// 中性（无任何硬件特效）参数
    static let neutral_Lumia = HardwareEffectParams_Lumia()
}

/// 曝光三角计算所用的标准级数（快门 / 光圈 / ISO）
struct ExposureScale_Lumia {
    /// 标准快门速度级数（秒）
    static let shutterSpeeds_Lumia: [Double] = [
        1 / 4000, 1 / 2000, 1 / 1000, 1 / 500, 1 / 250, 1 / 125, 1 / 60,
        1 / 30, 1 / 15, 1 / 8, 1 / 4, 1 / 2, 1, 2, 4, 8, 15, 30
    ]
    /// 标准光圈级数
    static let apertures_Lumia: [Double] = [1.0, 1.4, 2, 2.8, 4, 5.6, 8, 11, 16, 22, 32]
    /// 标准 ISO 感光度级数
    static let isoValues_Lumia: [Double] = [25, 50, 100, 200, 400, 800, 1600, 3200, 6400]
}

/// 胶片冲洗配方（型号 + 药水 + 稀释比例 + 温度 → 显影/停显/定影时长）
/// 核心作用：胶片冲洗时长计算器的计算结果记录，支持用户保存多种自制药水配方
class DevelopingRecipeModel_Lumia: NSObject, Codable {
    var recipeId_Lumia: Int
    var filmStockName_Lumia: String
    var developerName_Lumia: String
    var dilution_Lumia: String
    var temperatureC_Lumia: Double
    var developTimeSec_Lumia: Int
    var stopTimeSec_Lumia: Int
    var fixTimeSec_Lumia: Int
    var createdAt_Lumia: String
    /// 是否为用户自制保存的配方（预制示例配方为 false）
    var isCustom_Lumia: Bool

    init(
        recipeId_Lumia: Int,
        filmStockName_Lumia: String,
        developerName_Lumia: String,
        dilution_Lumia: String,
        temperatureC_Lumia: Double,
        developTimeSec_Lumia: Int,
        stopTimeSec_Lumia: Int,
        fixTimeSec_Lumia: Int,
        isCustom_Lumia: Bool = true
    ) {
        self.recipeId_Lumia = recipeId_Lumia
        self.filmStockName_Lumia = filmStockName_Lumia
        self.developerName_Lumia = developerName_Lumia
        self.dilution_Lumia = dilution_Lumia
        self.temperatureC_Lumia = temperatureC_Lumia
        self.developTimeSec_Lumia = developTimeSec_Lumia
        self.stopTimeSec_Lumia = stopTimeSec_Lumia
        self.fixTimeSec_Lumia = fixTimeSec_Lumia
        self.isCustom_Lumia = isCustom_Lumia
        let f_Lumia = DateFormatter()
        f_Lumia.dateFormat = "yyyy-MM-dd HH:mm"
        self.createdAt_Lumia = f_Lumia.string(from: Date())
    }
}
