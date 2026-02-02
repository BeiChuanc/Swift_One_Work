import Foundation
import SwiftUI

// MARK: - 数据模型定义

// MARK: - 枚举定义

/// 帖子类型枚举
enum PostType_blisslink: String, Codable {
    /// 普通分享
    case normal_blisslink = "Normal"
    /// 练习成果
    case practiceAchievement_blisslink = "Practice Achievement"
    /// 心得体会
    case experience_blisslink = "Experience"
}

/// 预览用户数据模型
class PrewUserModel_baseswiftui: NSObject, Codable {
    
    /// 用户ID
    var userId_baseswiftui: Int?
    
    /// 用户名字
    var userName_baseswiftui: String?
    
    /// 用户简介
    var userIntroduce_baseswiftui: String?
    
    /// 用户头像
    var userHead_baseswiftui: String?
    
    /// 用户媒体
    var userMedia_baseswiftui: [String]?
    
    /// 用户喜欢帖子列表
    var userLike_baseswiftui: [TitleModel_baseswiftui] = []
    
    /// 用户关注数
    var userFollow_baseswiftui: Int?
    
    /// 用户粉丝数
    var userFans_baseswiftui: Int?
    
    /// 瑜伽垫背景设置（用于串门功能）
    var yogaMatBackground_blisslink: YogaMatBackground_blisslink?
    
    /// 总练习时长（用于串门展示）
    var totalPracticeDuration_blisslink: Int?
    
    /// 获得的徽章数量
    var badgeCount_blisslink: Int?
    
    /// 初始化方法
    override init() {
        super.init()
    }
    
    /// 自定义初始化方法
    init(userId_baseswiftui: Int? = nil,
         userName_baseswiftui: String? = nil,
         userIntroduce_baseswiftui: String? = nil,
         userHead_baseswiftui: String? = nil,
         userMedia_baseswiftui: [String]? = nil,
         userLike_baseswiftui: [TitleModel_baseswiftui] = [],
         userFollow_baseswiftui: Int? = nil,
         userFans_baseswiftui: Int? = nil,
         yogaMatBackground_blisslink: YogaMatBackground_blisslink? = nil,
         totalPracticeDuration_blisslink: Int? = nil,
         badgeCount_blisslink: Int? = nil) {
        self.userId_baseswiftui = userId_baseswiftui
        self.userName_baseswiftui = userName_baseswiftui
        self.userIntroduce_baseswiftui = userIntroduce_baseswiftui
        self.userHead_baseswiftui = userHead_baseswiftui
        self.userMedia_baseswiftui = userMedia_baseswiftui
        self.userLike_baseswiftui = userLike_baseswiftui
        self.userFollow_baseswiftui = userFollow_baseswiftui
        self.userFans_baseswiftui = userFans_baseswiftui
        self.yogaMatBackground_blisslink = yogaMatBackground_blisslink
        self.totalPracticeDuration_blisslink = totalPracticeDuration_blisslink
        self.badgeCount_blisslink = badgeCount_blisslink
        super.init()
    }
}

/// 帖子数据模型
class TitleModel_baseswiftui: NSObject, Codable, Identifiable {
    
    /// 帖子唯一标识符，用于 Identifiable 协议
    var id: Int { titleId_baseswiftui }
    
    /// 帖子ID
    var titleId_baseswiftui: Int
    
    /// 拥有者ID
    var titleUserId_baseswiftui: Int
    
    /// 拥有者昵称
    var titleUserName_baseswiftui: String
    
    /// 帖子媒体资源数组
    var titleMeidas_baseswiftui: [String]
    
    /// 帖子标题
    var title_baseswiftui: String
    
    /// 帖子内容
    var titleContent_baseswiftui: String
    
    /// 帖子评论列表
    var reviews_baseswiftui: [Comment_baseswiftui]
    
    /// 喜欢个数
    var likes_baseswiftui: Int
    
    /// 帖子类型（扩展字段）
    var postType_blisslink: PostType_blisslink?
    
    /// 关联的课程ID（如果是练习成果分享）
    var relatedCourseId_blisslink: Int?
    
    /// 练习时长（如果是练习成果，单位：分钟）
    var practiceDuration_blisslink: Int?
    
    /// 初始化方法
    init(titleId_baseswiftui: Int,
         titleUserId_baseswiftui: Int,
         titleUserName_baseswiftui: String,
         titleMeidas_baseswiftui: [String],
         title_baseswiftui: String,
         titleContent_baseswiftui: String,
         reviews_baseswiftui: [Comment_baseswiftui],
         likes_baseswiftui: Int,
         postType_blisslink: PostType_blisslink? = nil,
         relatedCourseId_blisslink: Int? = nil,
         practiceDuration_blisslink: Int? = nil) {
        self.titleId_baseswiftui = titleId_baseswiftui
        self.titleUserId_baseswiftui = titleUserId_baseswiftui
        self.titleUserName_baseswiftui = titleUserName_baseswiftui
        self.titleMeidas_baseswiftui = titleMeidas_baseswiftui
        self.title_baseswiftui = title_baseswiftui
        self.titleContent_baseswiftui = titleContent_baseswiftui
        self.reviews_baseswiftui = reviews_baseswiftui
        self.likes_baseswiftui = likes_baseswiftui
        self.postType_blisslink = postType_blisslink
        self.relatedCourseId_blisslink = relatedCourseId_blisslink
        self.practiceDuration_blisslink = practiceDuration_blisslink
        super.init()
    }
}

/// 登录用户数据模型
class LoginUserModel_baseswiftui: NSObject, Codable, Identifiable {
    
    /// 用户唯一标识符，用于 Identifiable 协议
    var id: Int? { userId_baseswiftui }
    
    /// 用户ID
    var userId_baseswiftui: Int?
    
    /// 用户密码
    var userPwd_baseswiftui: String?
    
    /// 用户名称
    var userName_baseswiftui: String?
    
    /// 用户头像
    var userHead_baseswiftui: String?
    
    /// 用户发布帖子列表
    var userPosts_baseswiftui: [TitleModel_baseswiftui]
    
    /// 用户喜欢帖子列表
    var userLike_baseswiftui: [TitleModel_baseswiftui]
    
    /// 用户关注列表
    var userFollow_baseswiftui: [PrewUserModel_baseswiftui]
    
    /// 瑜伽垫背景设置
    var yogaMatBackground_blisslink: YogaMatBackground_blisslink
    
    /// 获得的徽章列表
    var badges_blisslink: [MeditationBadge_blisslink]
    
    /// 纪念贴纸列表
    var memoryStickers_blisslink: [MemorySticker_blisslink]
    
    /// 初始化方法
    init(userId_baseswiftui: Int? = nil,
         userPwd_baseswiftui: String? = nil,
         userName_baseswiftui: String? = nil,
         userHead_baseswiftui: String? = nil,
         userPosts_baseswiftui: [TitleModel_baseswiftui],
         userLike_baseswiftui: [TitleModel_baseswiftui],
         userFollow_baseswiftui: [PrewUserModel_baseswiftui],
         yogaMatBackground_blisslink: YogaMatBackground_blisslink = .forestZen_blisslink,
         badges_blisslink: [MeditationBadge_blisslink] = [],
         memoryStickers_blisslink: [MemorySticker_blisslink] = []) {
        self.userId_baseswiftui = userId_baseswiftui
        self.userPwd_baseswiftui = userPwd_baseswiftui
        self.userName_baseswiftui = userName_baseswiftui
        self.userHead_baseswiftui = userHead_baseswiftui
        self.userPosts_baseswiftui = userPosts_baseswiftui
        self.userLike_baseswiftui = userLike_baseswiftui
        self.userFollow_baseswiftui = userFollow_baseswiftui
        self.yogaMatBackground_blisslink = yogaMatBackground_blisslink
        self.badges_blisslink = badges_blisslink
        self.memoryStickers_blisslink = memoryStickers_blisslink
        super.init()
    }
}

/// 消息数据模型
class MessageModel_baseswiftui: Codable, Identifiable {
    
    /// 消息唯一标识符，用于 Identifiable 协议
    var id: Int? { messageId_baseswiftui }
    
    /// 消息ID
    var messageId_baseswiftui: Int?
    
    /// 消息内容
    var content_baseswiftui: String?
    
    /// 用户头像
    var userHead_baseswiftui: String?
    
    /// 是否是我发送的
    var isMine_baseswiftui: Bool?
    
    /// 消息时间
    var time_baseswiftui: String?
    
    /// 初始化方法
    init(messageId_baseswiftui: Int? = nil,
         content_baseswiftui: String? = nil,
         userHead_baseswiftui: String? = nil,
         isMine_baseswiftui: Bool? = nil,
         time_baseswiftui: String? = nil) {
        self.messageId_baseswiftui = messageId_baseswiftui
        self.content_baseswiftui = content_baseswiftui
        self.userHead_baseswiftui = userHead_baseswiftui
        self.isMine_baseswiftui = isMine_baseswiftui
        self.time_baseswiftui = time_baseswiftui
    }
}

/// 评论数据模型
class Comment_baseswiftui: NSObject, Codable, Identifiable {
    
    /// 评论唯一标识符，用于 Identifiable 协议
    var id: Int { commentId_baseswiftui }
    
    /// 评论ID
    var commentId_baseswiftui: Int
    
    /// 评论用户ID
    var commentUserId_baseswiftui: Int
    
    /// 评论用户昵称
    var commentUserName_baseswiftui: String
    
    /// 评论内容
    var commentContent_baseswiftui: String
    
    /// 初始化方法
    init(commentId_baseswiftui: Int,
         commentUserId_baseswiftui: Int,
         commentUserName_baseswiftui: String,
         commentContent_baseswiftui: String) {
        self.commentId_baseswiftui = commentId_baseswiftui
        self.commentUserId_baseswiftui = commentUserId_baseswiftui
        self.commentUserName_baseswiftui = commentUserName_baseswiftui
        self.commentContent_baseswiftui = commentContent_baseswiftui
        super.init()
    }
}

// MARK: - 瑜伽冥想相关模型

/// 课程类型枚举
enum CourseType_blisslink: String, Codable {
    /// 瑜伽练习
    case yoga_blisslink = "Yoga"
    /// 冥想练习
    case meditation_blisslink = "Meditation"
    /// 呼吸练习
    case breathing_blisslink = "Breathing"
}

/// 课程难度枚举
enum CourseDifficulty_blisslink: String, Codable {
    /// 初级
    case beginner_blisslink = "Beginner"
    /// 中级
    case intermediate_blisslink = "Intermediate"
    /// 高级
    case advanced_blisslink = "Advanced"
}

/// 瑜伽冥想课程数据模型
/// 核心作用：存储课程的基本信息、难度、类型、媒体资源等
/// 设计思路：提供完整的课程信息，支持筛选和排序
class YogaCourseModel_blisslink: NSObject, Codable, Identifiable {
    
    /// 课程唯一标识符，用于 Identifiable 协议
    var id: Int { courseId_blisslink }
    
    /// 课程ID
    var courseId_blisslink: Int
    
    /// 课程标题
    var courseTitle_blisslink: String
    
    /// 课程描述
    var courseDescription_blisslink: String
    
    /// 课程时长（分钟）
    var courseDuration_blisslink: Int
    
    /// 课程类型
    var courseType_blisslink: CourseType_blisslink
    
    /// 课程难度
    var courseDifficulty_blisslink: CourseDifficulty_blisslink
    
    /// 课程封面图片
    var courseCoverImage_blisslink: String
    
    /// 音频URL（可选）
    var audioUrl_blisslink: String?
    
    /// 视频URL（可选）
    var videoUrl_blisslink: String?
    
    /// 导师名称
    var instructorName_blisslink: String
    
    /// 导师头像
    var instructorAvatar_blisslink: String
    
    /// 热度值（用于排行榜）
    var popularityScore_blisslink: Int
    
    /// 完成人数
    var completedCount_blisslink: Int
    
    /// 是否被收藏
    var isFavorite_blisslink: Bool
    
    /// 初始化方法
    init(courseId_blisslink: Int,
         courseTitle_blisslink: String,
         courseDescription_blisslink: String,
         courseDuration_blisslink: Int,
         courseType_blisslink: CourseType_blisslink,
         courseDifficulty_blisslink: CourseDifficulty_blisslink,
         courseCoverImage_blisslink: String,
         audioUrl_blisslink: String? = nil,
         videoUrl_blisslink: String? = nil,
         instructorName_blisslink: String,
         instructorAvatar_blisslink: String,
         popularityScore_blisslink: Int,
         completedCount_blisslink: Int,
         isFavorite_blisslink: Bool = false) {
        self.courseId_blisslink = courseId_blisslink
        self.courseTitle_blisslink = courseTitle_blisslink
        self.courseDescription_blisslink = courseDescription_blisslink
        self.courseDuration_blisslink = courseDuration_blisslink
        self.courseType_blisslink = courseType_blisslink
        self.courseDifficulty_blisslink = courseDifficulty_blisslink
        self.courseCoverImage_blisslink = courseCoverImage_blisslink
        self.audioUrl_blisslink = audioUrl_blisslink
        self.videoUrl_blisslink = videoUrl_blisslink
        self.instructorName_blisslink = instructorName_blisslink
        self.instructorAvatar_blisslink = instructorAvatar_blisslink
        self.popularityScore_blisslink = popularityScore_blisslink
        self.completedCount_blisslink = completedCount_blisslink
        self.isFavorite_blisslink = isFavorite_blisslink
        super.init()
    }
}

/// 练习记录数据模型
/// 核心作用：记录用户的练习历史，用于统计和分析
/// 设计思路：关联用户和课程，记录完整的练习信息
class PracticeSessionModel_blisslink: NSObject, Codable, Identifiable {
    
    /// 记录唯一标识符
    var id: Int { sessionId_blisslink }
    
    /// 记录ID
    var sessionId_blisslink: Int
    
    /// 用户ID
    var userId_blisslink: Int
    
    /// 课程ID
    var courseId_blisslink: Int
    
    /// 开始时间
    var startTime_blisslink: Date
    
    /// 结束时间
    var endTime_blisslink: Date
    
    /// 练习时长（分钟）
    var duration_blisslink: Int
    
    /// 是否完成
    var isCompleted_blisslink: Bool
    
    /// 心情评分（1-5）
    var moodRating_blisslink: Int?
    
    /// 初始化方法
    init(sessionId_blisslink: Int,
         userId_blisslink: Int,
         courseId_blisslink: Int,
         startTime_blisslink: Date,
         endTime_blisslink: Date,
         duration_blisslink: Int,
         isCompleted_blisslink: Bool,
         moodRating_blisslink: Int? = nil) {
        self.sessionId_blisslink = sessionId_blisslink
        self.userId_blisslink = userId_blisslink
        self.courseId_blisslink = courseId_blisslink
        self.startTime_blisslink = startTime_blisslink
        self.endTime_blisslink = endTime_blisslink
        self.duration_blisslink = duration_blisslink
        self.isCompleted_blisslink = isCompleted_blisslink
        self.moodRating_blisslink = moodRating_blisslink
        super.init()
    }
}

/// 挑战计划数据模型
/// 核心作用：存储挑战活动的信息和进度
/// 设计思路：支持不同天数的挑战，记录参与和完成情况
class ChallengeModel_blisslink: NSObject, Codable, Identifiable {
    
    /// 挑战唯一标识符
    var id: Int { challengeId_blisslink }
    
    /// 挑战ID
    var challengeId_blisslink: Int
    
    /// 挑战标题
    var challengeTitle_blisslink: String
    
    /// 挑战描述
    var challengeDescription_blisslink: String
    
    /// 挑战天数
    var challengeDays_blisslink: Int
    
    /// 挑战类型
    var challengeType_blisslink: CourseType_blisslink
    
    /// 挑战封面图片
    var challengeCoverImage_blisslink: String
    
    /// 参与人数
    var participantCount_blisslink: Int
    
    /// 完成人数
    var completedCount_blisslink: Int
    
    /// 奖励描述
    var rewardDescription_blisslink: String
    
    /// 开始日期
    var startDate_blisslink: Date?
    
    /// 当前进度（已完成天数）
    var currentProgress_blisslink: Int
    
    /// 是否已参加
    var isJoined_blisslink: Bool
    
    /// 是否已完成
    var isCompleted_blisslink: Bool
    
    /// 初始化方法
    init(challengeId_blisslink: Int,
         challengeTitle_blisslink: String,
         challengeDescription_blisslink: String,
         challengeDays_blisslink: Int,
         challengeType_blisslink: CourseType_blisslink,
         challengeCoverImage_blisslink: String,
         participantCount_blisslink: Int,
         completedCount_blisslink: Int,
         rewardDescription_blisslink: String,
         startDate_blisslink: Date? = nil,
         currentProgress_blisslink: Int = 0,
         isJoined_blisslink: Bool = false,
         isCompleted_blisslink: Bool = false) {
        self.challengeId_blisslink = challengeId_blisslink
        self.challengeTitle_blisslink = challengeTitle_blisslink
        self.challengeDescription_blisslink = challengeDescription_blisslink
        self.challengeDays_blisslink = challengeDays_blisslink
        self.challengeType_blisslink = challengeType_blisslink
        self.challengeCoverImage_blisslink = challengeCoverImage_blisslink
        self.participantCount_blisslink = participantCount_blisslink
        self.completedCount_blisslink = completedCount_blisslink
        self.rewardDescription_blisslink = rewardDescription_blisslink
        self.startDate_blisslink = startDate_blisslink
        self.currentProgress_blisslink = currentProgress_blisslink
        self.isJoined_blisslink = isJoined_blisslink
        self.isCompleted_blisslink = isCompleted_blisslink
        super.init()
    }
}

/// 练习统计数据模型
/// 核心作用：汇总用户的练习数据，用于展示统计信息
/// 设计思路：提供各种维度的统计数据
class PracticeStatsModel_blisslink: NSObject, Codable {
    
    /// 用户ID
    var userId_blisslink: Int
    
    /// 总练习时长（分钟）
    var totalDuration_blisslink: Int
    
    /// 连续打卡天数
    var streakDays_blisslink: Int
    
    /// 本周练习次数
    var weeklySessionCount_blisslink: Int
    
    /// 本月练习次数
    var monthlySessionCount_blisslink: Int
    
    /// 本周练习时长（分钟）
    var weeklyDuration_blisslink: Int
    
    /// 最喜欢的课程类型
    var favoriteCourseType_blisslink: CourseType_blisslink?
    
    /// 总完成课程数
    var totalCompletedCourses_blisslink: Int
    
    /// 最后练习日期
    var lastPracticeDate_blisslink: Date?
    
    /// 初始化方法
    init(userId_blisslink: Int,
         totalDuration_blisslink: Int = 0,
         streakDays_blisslink: Int = 0,
         weeklySessionCount_blisslink: Int = 0,
         monthlySessionCount_blisslink: Int = 0,
         weeklyDuration_blisslink: Int = 0,
         favoriteCourseType_blisslink: CourseType_blisslink? = nil,
         totalCompletedCourses_blisslink: Int = 0,
         lastPracticeDate_blisslink: Date? = nil) {
        self.userId_blisslink = userId_blisslink
        self.totalDuration_blisslink = totalDuration_blisslink
        self.streakDays_blisslink = streakDays_blisslink
        self.weeklySessionCount_blisslink = weeklySessionCount_blisslink
        self.monthlySessionCount_blisslink = monthlySessionCount_blisslink
        self.weeklyDuration_blisslink = weeklyDuration_blisslink
        self.favoriteCourseType_blisslink = favoriteCourseType_blisslink
        self.totalCompletedCourses_blisslink = totalCompletedCourses_blisslink
        self.lastPracticeDate_blisslink = lastPracticeDate_blisslink
        super.init()
    }
}

/// 瑜伽垫背景类型枚举
enum YogaMatBackground_blisslink: String, Codable, CaseIterable {
    /// 森林禅院
    case forestZen_blisslink = "Forest Zen"
    /// 海边日落
    case beachSunset_blisslink = "Beach Sunset"
    /// 樱花庭院
    case sakuraGarden_blisslink = "Sakura Garden"
    /// 星空冥想
    case starryNight_blisslink = "Starry Night"
    /// 山间晨雾
    case mountainMist_blisslink = "Mountain Mist"
    
    /// 获取对应的渐变色
    var gradientColors_blisslink: [Color] {
        switch self {
        case .forestZen_blisslink:
            return [Color(hex: "134E5E"), Color(hex: "71B280")]
        case .beachSunset_blisslink:
            return [Color(hex: "FA8BFF"), Color(hex: "2BD2FF"), Color(hex: "2BFF88")]
        case .sakuraGarden_blisslink:
            return [Color(hex: "FFB7B2"), Color(hex: "FF9A9E"), Color(hex: "FAD0C4")]
        case .starryNight_blisslink:
            return [Color(hex: "0F2027"), Color(hex: "203A43"), Color(hex: "2C5364")]
        case .mountainMist_blisslink:
            return [Color(hex: "C9D6FF"), Color(hex: "E2E2E2")]
        }
    }
    
    /// 获取对应的图标
    var iconName_blisslink: String {
        switch self {
        case .forestZen_blisslink:
            return "tree.fill"
        case .beachSunset_blisslink:
            return "sunset.fill"
        case .sakuraGarden_blisslink:
            return "leaf.fill"
        case .starryNight_blisslink:
            return "sparkles"
        case .mountainMist_blisslink:
            return "cloud.fill"
        }
    }
    
    /// 是否为深色背景（决定文字颜色）
    var isDarkBackground_blisslink: Bool {
        switch self {
        case .forestZen_blisslink, .starryNight_blisslink:
            return true
        case .beachSunset_blisslink, .sakuraGarden_blisslink, .mountainMist_blisslink:
            return false
        }
    }
    
    /// 获取文字颜色
    var textColor_blisslink: Color {
        return isDarkBackground_blisslink ? .white : .primary
    }
    
    /// 获取次要文字颜色
    var secondaryTextColor_blisslink: Color {
        return isDarkBackground_blisslink ? .white.opacity(0.8) : .secondary
    }
}

/// 冥想徽章数据模型
/// 核心作用：记录用户获得的成就徽章
/// 设计思路：通过完成特定任务解锁徽章
class MeditationBadge_blisslink: NSObject, Codable, Identifiable {
    
    /// 徽章唯一标识符
    var id: Int { badgeId_blisslink }
    
    /// 徽章ID
    var badgeId_blisslink: Int
    
    /// 徽章名称
    var badgeName_blisslink: String
    
    /// 徽章描述
    var badgeDescription_blisslink: String
    
    /// 徽章图标
    var badgeIcon_blisslink: String
    
    /// 解锁条件描述
    var unlockCondition_blisslink: String
    
    /// 是否已解锁
    var isUnlocked_blisslink: Bool
    
    /// 解锁日期
    var unlockDate_blisslink: Date?
    
    /// 徽章颜色
    var badgeColor_blisslink: [String]
    
    /// 初始化方法
    init(badgeId_blisslink: Int,
         badgeName_blisslink: String,
         badgeDescription_blisslink: String,
         badgeIcon_blisslink: String,
         unlockCondition_blisslink: String,
         isUnlocked_blisslink: Bool = false,
         unlockDate_blisslink: Date? = nil,
         badgeColor_blisslink: [String]) {
        self.badgeId_blisslink = badgeId_blisslink
        self.badgeName_blisslink = badgeName_blisslink
        self.badgeDescription_blisslink = badgeDescription_blisslink
        self.badgeIcon_blisslink = badgeIcon_blisslink
        self.unlockCondition_blisslink = unlockCondition_blisslink
        self.isUnlocked_blisslink = isUnlocked_blisslink
        self.unlockDate_blisslink = unlockDate_blisslink
        self.badgeColor_blisslink = badgeColor_blisslink
        super.init()
    }
}

/// 纪念贴纸数据模型
/// 核心作用：用户上传的练习照片作为瑜伽垫装饰
/// 设计思路：让首页成为个人成长纪念馆
class MemorySticker_blisslink: NSObject, Codable, Identifiable {
    
    /// 贴纸唯一标识符
    var id: Int { stickerId_blisslink }
    
    /// 贴纸ID
    var stickerId_blisslink: Int
    
    /// 用户ID
    var userId_blisslink: Int
    
    /// 照片图片URL（相册图片名称）
    var photoUrl_blisslink: String
    
    /// 纪念标题
    var title_blisslink: String
    
    /// 纪念日期
    var memoryDate_blisslink: Date
    
    /// 位置（用于在瑜伽垫上的摆放，0-1的比例）
    var positionX_blisslink: CGFloat
    var positionY_blisslink: CGFloat
    
    /// 旋转角度
    var rotation_blisslink: Double
    
    /// 初始化方法
    init(stickerId_blisslink: Int,
         userId_blisslink: Int,
         photoUrl_blisslink: String,
         title_blisslink: String,
         memoryDate_blisslink: Date,
         positionX_blisslink: CGFloat = 0.5,
         positionY_blisslink: CGFloat = 0.5,
         rotation_blisslink: Double = 0) {
        self.stickerId_blisslink = stickerId_blisslink
        self.userId_blisslink = userId_blisslink
        self.photoUrl_blisslink = photoUrl_blisslink
        self.title_blisslink = title_blisslink
        self.memoryDate_blisslink = memoryDate_blisslink
        self.positionX_blisslink = positionX_blisslink
        self.positionY_blisslink = positionY_blisslink
        self.rotation_blisslink = rotation_blisslink
        super.init()
    }
}

/// 好友动态数据模型
/// 核心作用：展示好友的瑜伽垫活动
/// 设计思路：轻社交互动，分享成就和变化
class FriendActivity_blisslink: NSObject, Codable, Identifiable {
    
    /// 动态唯一标识符
    var id: Int { activityId_blisslink }
    
    /// 动态ID
    var activityId_blisslink: Int
    
    /// 好友用户ID
    var friendUserId_blisslink: Int
    
    /// 好友名称
    var friendName_blisslink: String
    
    /// 好友头像
    var friendAvatar_blisslink: String
    
    /// 动态类型（更换背景/解锁徽章/完成挑战）
    var activityType_blisslink: FriendActivityType_blisslink
    
    /// 动态内容
    var activityContent_blisslink: String
    
    /// 发生时间
    var activityTime_blisslink: Date
    
    /// 初始化方法
    init(activityId_blisslink: Int,
         friendUserId_blisslink: Int,
         friendName_blisslink: String,
         friendAvatar_blisslink: String,
         activityType_blisslink: FriendActivityType_blisslink,
         activityContent_blisslink: String,
         activityTime_blisslink: Date) {
        self.activityId_blisslink = activityId_blisslink
        self.friendUserId_blisslink = friendUserId_blisslink
        self.friendName_blisslink = friendName_blisslink
        self.friendAvatar_blisslink = friendAvatar_blisslink
        self.activityType_blisslink = activityType_blisslink
        self.activityContent_blisslink = activityContent_blisslink
        self.activityTime_blisslink = activityTime_blisslink
        super.init()
    }
}

/// 好友动态类型枚举
enum FriendActivityType_blisslink: String, Codable {
    /// 更换背景
    case changedBackground_blisslink = "Changed Background"
    /// 解锁徽章
    case unlockedBadge_blisslink = "Unlocked Badge"
    /// 完成挑战
    case completedChallenge_blisslink = "Completed Challenge"
    /// 添加纪念贴纸
    case addedMemory_blisslink = "Added Memory"
    
    /// 获取对应图标
    var iconName_blisslink: String {
        switch self {
        case .changedBackground_blisslink:
            return "paintpalette.fill"
        case .unlockedBadge_blisslink:
            return "star.fill"
        case .completedChallenge_blisslink:
            return "trophy.fill"
        case .addedMemory_blisslink:
            return "photo.fill"
        }
    }
}
