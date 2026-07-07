import Foundation

// MARK: 数据模型定义

/// 用户数据模型
class PrewUserModel_Lens: NSObject, Codable {
    
    /// 用户ID
    var userId_Lens: Int?
    
    /// 用户名字
    var userName_Lens: String?
    
    /// 用户简介
    var userIntroduce_Lens: String?
    
    /// 用户头像
    var userHead_Lens: String?
    
    /// 用户媒体
    var userMedia_Lens: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_Lens: [TitleModel_Lens] = []

    /// 用户关注数
    var userFollow_Lens: Int?

    /// 用户粉丝数
    var userFans_Lens: Int?

    /// 初始化
    override init() {
        super.init()
    }
    
    /// 初始化
    init(userId_Lens: Int? = nil,
         userName_Lens: String? = nil,
         userIntroduce_Lens: String? = nil,
         userHead_Lens: String? = nil,
         userMedia_Lens: [String]? = nil,
         userLike_Lens: [TitleModel_Lens] = [],
         userFollow_Lens: Int? = nil,
         userFans_Lens: Int? = nil) {
        self.userId_Lens = userId_Lens
        self.userName_Lens = userName_Lens
        self.userIntroduce_Lens = userIntroduce_Lens
        self.userHead_Lens = userHead_Lens
        self.userMedia_Lens = userMedia_Lens
        self.userLike_Lens = userLike_Lens
        self.userFollow_Lens = userFollow_Lens
        self.userFans_Lens = userFans_Lens
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_Lens: NSObject, Codable {
    
    /// 帖子ID
    var titleId_Lens: Int
    
    /// 拥有者ID
    var titleUserId_Lens: Int
    
    /// 拥有者昵称
    var titleUserName_Lens: String
    
    /// 帖子媒体
    var titleMeidas_Lens: [String]
    
    /// 帖子标题
    var title_Lens: String
    
    /// 帖子内容
    var titleContent_Lens: String
    
    /// 帖子评论列表
    var reviews_Lens: [Comment_Lens]
    
    /// 喜欢个数
    var likes_Lens: Int
    
    init(titleId_Lens: Int,
         titleUserId_Lens: Int,
         titleUserName_Lens: String,
         titleMeidas_Lens: [String],
         title_Lens: String,
         titleContent_Lens: String,
         reviews_Lens: [Comment_Lens],
         likes_Lens: Int) {
        self.titleId_Lens = titleId_Lens
        self.titleUserId_Lens = titleUserId_Lens
        self.titleUserName_Lens = titleUserName_Lens
        self.titleMeidas_Lens = titleMeidas_Lens
        self.title_Lens = title_Lens
        self.titleContent_Lens = titleContent_Lens
        self.reviews_Lens = reviews_Lens
        self.likes_Lens = likes_Lens
    }
    
}

/// 登录用户数据模型
class LoginUserModel_Lens: NSObject, Codable {
    
    /// 用户ID
    var userId_Lens: Int?
    
    /// 用户密码
    var userPwd_Lens: String?
    
    /// 用户名称
    var userName_Lens: String?
    
    /// 用户自我介绍
    var userIntroduce_Lens: String?
    
    /// 用户头像
    var userHead_Lens: String?
    
    /// 用户发布帖子列表
    var userPosts_Lens: [TitleModel_Lens]
    
    /// 用户喜欢帖子列表
    var userLike_Lens: [TitleModel_Lens]

    /// 用户关注列表
    var userFollow_Lens: [PrewUserModel_Lens]

    /// 工作室作品数量
    var studioArtworkCount_Lens: Int = 0

    /// 工作室最近活跃日期 yyyy-MM-dd
    var studioLastActiveDate_Lens: String?

    /// 工作室默认封面媒体路径
    var studioDefaultCover_Lens: String?
    
    /// 初始化
    init(userId_Lens: Int? = nil,
         userPwd_Lens: String? = nil,
         userName_Lens: String? = nil,
         userIntroduce_Lens: String? = nil,
         userHead_Lens: String? = nil,
         userPosts_Lens: [TitleModel_Lens],
         userLike_Lens: [TitleModel_Lens],
         userFollow_Lens: [PrewUserModel_Lens],
         studioArtworkCount_Lens: Int = 0,
         studioLastActiveDate_Lens: String? = nil,
         studioDefaultCover_Lens: String? = nil) {
        self.userId_Lens = userId_Lens
        self.userPwd_Lens = userPwd_Lens
        self.userName_Lens = userName_Lens
        self.userIntroduce_Lens = userIntroduce_Lens
        self.userHead_Lens = userHead_Lens
        self.userPosts_Lens = userPosts_Lens
        self.userLike_Lens = userLike_Lens
        self.userFollow_Lens = userFollow_Lens
        self.studioArtworkCount_Lens = studioArtworkCount_Lens
        self.studioLastActiveDate_Lens = studioLastActiveDate_Lens
        self.studioDefaultCover_Lens = studioDefaultCover_Lens
    }
}

/// 消息数据模型
class MessageModel_Lens: Codable {
    
    /// 消息ID
    var messageId_Lens: Int?
    
    /// 消息内容
    var content_Lens: String?
    
    /// 用户头像
    var userHead_Lens: String?
    
    /// 是否是我发送的
    var isMine_Lens: Bool?
    
    /// 消息时间
    var time_Lens: String?
    
    /// 初始化
    init(messageId_lens: Int? = nil,
         content_lens: String? = nil,
         userHead_lens: String? = nil,
         isMine_lens: Bool? = nil,
         time_lens: String? = nil) {
        self.messageId_Lens = messageId_lens
        self.content_Lens = content_lens
        self.userHead_Lens = userHead_lens
        self.isMine_Lens = isMine_lens
        self.time_Lens = time_lens
    }
}

/// 评论模型
class Comment_Lens: NSObject, Codable {
    
    /// 评论ID
    var commentId_Lens: Int
    
    /// 评论用户uid
    var commentUserId_Lens: Int
    
    /// 评论用户昵称
    var commentUserName_Lens: String
    
    /// 评论内容
    var commentContent_Lens: String
    
    /// 初始化
    init(commentId_Lens: Int,
         commentUserId_Lens: Int,
         commentUserName_Lens: String,
         commentContent_Lens: String) {
        self.commentId_Lens = commentId_Lens
        self.commentUserId_Lens = commentUserId_Lens
        self.commentUserName_Lens = commentUserName_Lens
        self.commentContent_Lens = commentContent_Lens
    }
}

/// 商店模型
class StoreModel_Lens: NSObject {
    
    /// ID编号
    var id_Lens: Int?
    
    /// 商品ID
    var goodsId_Lens: String?
    
    /// 商品名字
    var goodsName_Lens: String?
    
    /// 商品价格
    var goodsPrice_Lens: String?
    
    /// 是否顶部商品
    var goodIsTop_Lens: Bool?
    
    /// 是否特殊商品
    var goodIsSpecial_Lens: Bool?
    
    /// 是否VIP商品
    var goodIsVIP_Lens: Bool?
    
    init(id_Lens: Int? = nil,
         goodsId_Lens: String? = nil,
         goodsName_Lens: String? = nil,
         goodsPrice_Lens: String? = nil,
         goodIsTop_Lens: Bool? = false,
         goodIsLimit_Lens: Bool? = false,
         goodIsVIP_Lens: Bool? = false) {
        self.id_Lens = id_Lens
        self.goodsId_Lens = goodsId_Lens
        self.goodsName_Lens = goodsName_Lens
        self.goodsPrice_Lens = goodsPrice_Lens
        self.goodIsTop_Lens = goodIsTop_Lens
        self.goodIsSpecial_Lens = goodIsLimit_Lens
        self.goodIsVIP_Lens = goodIsVIP_Lens
        super.init()
    }
}

// MARK: - 调制画盘数据模型

/// 光源模式枚举（12 种真实光源 + 专属光影）
enum LightModeType_Lens: Int, Codable, CaseIterable {
    case morningSun_Lens = 0
    case afternoonSun_Lens
    case eveningWarm_Lens
    case nightLamp_Lens
    case candleLight_Lens
    case neonPulse_Lens
    case studioSoft_Lens
    case overcastDay_Lens
    case goldenHour_Lens
    case moonlight_Lens
    case gallerySpot_Lens
    case exclusiveLight_Lens

    /// 英文展示标题
    var displayTitle_Lens: String {
        switch self {
        case .morningSun_Lens:     return "Morning Sun"
        case .afternoonSun_Lens:   return "Afternoon Sun"
        case .eveningWarm_Lens:    return "Evening Warm"
        case .nightLamp_Lens:      return "Night Lamp"
        case .candleLight_Lens:    return "Candlelight"
        case .neonPulse_Lens:      return "Neon Pulse"
        case .studioSoft_Lens:     return "Studio Soft"
        case .overcastDay_Lens:    return "Overcast Day"
        case .goldenHour_Lens:     return "Golden Hour"
        case .moonlight_Lens:      return "Moonlight"
        case .gallerySpot_Lens:    return "Gallery Spot"
        case .exclusiveLight_Lens: return "Exclusive Light"
        }
    }

    /// SF Symbol 图标名
    var iconName_Lens: String {
        switch self {
        case .morningSun_Lens:     return "sunrise.fill"
        case .afternoonSun_Lens:   return "sun.max.fill"
        case .eveningWarm_Lens:    return "sunset.fill"
        case .nightLamp_Lens:      return "lamp.desk.fill"
        case .candleLight_Lens:    return "flame.fill"
        case .neonPulse_Lens:      return "bolt.fill"
        case .studioSoft_Lens:     return "light.panel.fill"
        case .overcastDay_Lens:    return "cloud.fill"
        case .goldenHour_Lens:     return "sparkles"
        case .moonlight_Lens:      return "moon.stars.fill"
        case .gallerySpot_Lens:    return "scope"
        case .exclusiveLight_Lens: return "photo.on.rectangle.angled"
        }
    }

    /// 默认主色调（十六进制）
    var defaultTintHex_Lens: String {
        switch self {
        case .morningSun_Lens:     return "#FFE8B0"
        case .afternoonSun_Lens:   return "#FFD166"
        case .eveningWarm_Lens:    return "#FF9F6B"
        case .nightLamp_Lens:      return "#FFB347"
        case .candleLight_Lens:    return "#FF8C42"
        case .neonPulse_Lens:      return "#C77DFF"
        case .studioSoft_Lens:     return "#F5F5FF"
        case .overcastDay_Lens:    return "#B8C4D9"
        case .goldenHour_Lens:     return "#F4C95D"
        case .moonlight_Lens:      return "#8EB8FF"
        case .gallerySpot_Lens:    return "#FFFFFF"
        case .exclusiveLight_Lens: return "#E8D5FF"
        }
    }
}

/// 创作事件类型
enum CreationEventType_Lens: String, Codable {
    case brushStroke_Lens
    case colorAdjust_Lens
    case layerAdd_Lens
    case layerModify_Lens
    case acrylicTest_Lens
    case lightAdjust_Lens
    case customNote_Lens
}

/// 笔触轨迹点
struct BrushPoint_Lens: Codable {
    var x_Lens: Double
    var y_Lens: Double
}

/// 创作过程事件记录
struct CreationEvent_Lens: Codable {
    var eventId_Lens: Int
    var type_Lens: CreationEventType_Lens
    var timestamp_Lens: String
    /// 事件日期 yyyy-MM-dd
    var eventDate_Lens: String?
    var detail_Lens: String
    var brushPoints_Lens: [BrushPoint_Lens]?
    var fromColorHex_Lens: String?
    var toColorHex_Lens: String?
    var layerName_Lens: String?

    init(
        eventId_Lens: Int,
        type_Lens: CreationEventType_Lens,
        timestamp_Lens: String,
        eventDate_Lens: String? = nil,
        detail_Lens: String,
        brushPoints_Lens: [BrushPoint_Lens]? = nil,
        fromColorHex_Lens: String? = nil,
        toColorHex_Lens: String? = nil,
        layerName_Lens: String? = nil
    ) {
        self.eventId_Lens = eventId_Lens
        self.type_Lens = type_Lens
        self.timestamp_Lens = timestamp_Lens
        self.eventDate_Lens = eventDate_Lens
        self.detail_Lens = detail_Lens
        self.brushPoints_Lens = brushPoints_Lens
        self.fromColorHex_Lens = fromColorHex_Lens
        self.toColorHex_Lens = toColorHex_Lens
        self.layerName_Lens = layerName_Lens
    }

    init(from decoder_Lens: Decoder) throws {
        let c_Lens = try decoder_Lens.container(keyedBy: CodingKeys.self)
        eventId_Lens = try c_Lens.decode(Int.self, forKey: .eventId_Lens)
        type_Lens = try c_Lens.decode(CreationEventType_Lens.self, forKey: .type_Lens)
        timestamp_Lens = try c_Lens.decode(String.self, forKey: .timestamp_Lens)
        eventDate_Lens = try c_Lens.decodeIfPresent(String.self, forKey: .eventDate_Lens)
        detail_Lens = try c_Lens.decode(String.self, forKey: .detail_Lens)
        brushPoints_Lens = try c_Lens.decodeIfPresent([BrushPoint_Lens].self, forKey: .brushPoints_Lens)
        fromColorHex_Lens = try c_Lens.decodeIfPresent(String.self, forKey: .fromColorHex_Lens)
        toColorHex_Lens = try c_Lens.decodeIfPresent(String.self, forKey: .toColorHex_Lens)
        layerName_Lens = try c_Lens.decodeIfPresent(String.self, forKey: .layerName_Lens)
    }
}

/// 作品数据模型（含完整创作过程）
struct ArtworkModel_Lens: Codable {
    var artworkId_Lens: Int
    var userId_Lens: Int
    var title_Lens: String
    var coverMedia_Lens: String
    var createdAt_Lens: String
    var totalStrokes_Lens: Int
    var totalLayers_Lens: Int
    var events_Lens: [CreationEvent_Lens]
    /// 是否为用户自定义创建
    var isUserCreated_Lens: Bool?

    init(
        artworkId_Lens: Int,
        userId_Lens: Int = 0,
        title_Lens: String,
        coverMedia_Lens: String,
        createdAt_Lens: String,
        totalStrokes_Lens: Int,
        totalLayers_Lens: Int,
        events_Lens: [CreationEvent_Lens],
        isUserCreated_Lens: Bool? = nil
    ) {
        self.artworkId_Lens = artworkId_Lens
        self.userId_Lens = userId_Lens
        self.title_Lens = title_Lens
        self.coverMedia_Lens = coverMedia_Lens
        self.createdAt_Lens = createdAt_Lens
        self.totalStrokes_Lens = totalStrokes_Lens
        self.totalLayers_Lens = totalLayers_Lens
        self.events_Lens = events_Lens
        self.isUserCreated_Lens = isUserCreated_Lens
    }

    init(from decoder_Lens: Decoder) throws {
        let c_Lens = try decoder_Lens.container(keyedBy: CodingKeys.self)
        artworkId_Lens = try c_Lens.decode(Int.self, forKey: .artworkId_Lens)
        userId_Lens = try c_Lens.decodeIfPresent(Int.self, forKey: .userId_Lens) ?? 0
        title_Lens = try c_Lens.decode(String.self, forKey: .title_Lens)
        coverMedia_Lens = try c_Lens.decode(String.self, forKey: .coverMedia_Lens)
        createdAt_Lens = try c_Lens.decode(String.self, forKey: .createdAt_Lens)
        totalStrokes_Lens = try c_Lens.decode(Int.self, forKey: .totalStrokes_Lens)
        totalLayers_Lens = try c_Lens.decode(Int.self, forKey: .totalLayers_Lens)
        events_Lens = try c_Lens.decode([CreationEvent_Lens].self, forKey: .events_Lens)
        isUserCreated_Lens = try c_Lens.decodeIfPresent(Bool.self, forKey: .isUserCreated_Lens)
    }
}

/// 色彩测试保存快照
struct ColorTestSnapshot_Lens: Codable {
    var snapshotId_Lens: Int
    var tintHex_Lens: String
    var opacity_Lens: Double
    var saturation_Lens: Double
    var refractionHex_Lens: String
    var savedAt_Lens: String
}

/// 周期汇总数据
struct StudioPeriodSummary_Lens {
    var weekArtworks_Lens: Int
    var weekEvents_Lens: Int
    var weekLayerTests_Lens: Int
    var weekLightSessions_Lens: Int
    var totalArtworks_Lens: Int
}

/// 弹幕消息模型
struct DanmakuModel_Lens: Codable {
    var danmakuId_Lens: Int
    var userId_Lens: Int
    var userName_Lens: String
    var content_Lens: String
    var colorHex_Lens: String
    var time_Lens: String

    init(
        danmakuId_Lens: Int,
        userId_Lens: Int = 0,
        userName_Lens: String,
        content_Lens: String,
        colorHex_Lens: String,
        time_Lens: String
    ) {
        self.danmakuId_Lens = danmakuId_Lens
        self.userId_Lens = userId_Lens
        self.userName_Lens = userName_Lens
        self.content_Lens = content_Lens
        self.colorHex_Lens = colorHex_Lens
        self.time_Lens = time_Lens
    }

    init(from decoder_Lens: Decoder) throws {
        let container_Lens = try decoder_Lens.container(keyedBy: CodingKeys.self)
        danmakuId_Lens = try container_Lens.decode(Int.self, forKey: .danmakuId_Lens)
        userId_Lens = try container_Lens.decodeIfPresent(Int.self, forKey: .userId_Lens) ?? 0
        userName_Lens = try container_Lens.decode(String.self, forKey: .userName_Lens)
        content_Lens = try container_Lens.decode(String.self, forKey: .content_Lens)
        colorHex_Lens = try container_Lens.decode(String.self, forKey: .colorHex_Lens)
        time_Lens = try container_Lens.decode(String.self, forKey: .time_Lens)
    }
}

/// 亚克力透明层模型
struct AcrylicLayerModel_Lens: Codable {
    var layerId_Lens: Int
    var layerName_Lens: String
    var tintHex_Lens: String
    var opacity_Lens: Double
    var saturation_Lens: Double
    var brushThickness_Lens: Double
    var edgeGloss_Lens: Double
    var stackOrder_Lens: Int
}

/// 光源环境配置
struct LightEnvironmentModel_Lens: Codable {
    var modeRaw_Lens: Int
    var angle_Lens: Double
    var intensity_Lens: Double
    var referencePhotoPath_Lens: String?
    var extractedTintHex_Lens: String?

    /// 当前光源模式
    var mode_Lens: LightModeType_Lens {
        LightModeType_Lens(rawValue: modeRaw_Lens) ?? .morningSun_Lens
    }
}
