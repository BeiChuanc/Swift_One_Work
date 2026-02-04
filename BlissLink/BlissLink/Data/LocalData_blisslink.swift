import Foundation
import Combine

// MARK: - 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_blisslink {
    /// ID起始值
    static let userIdStart_blisslink = 10
    static let postIdStart_blisslink = 20
    
    /// 喜欢帖子数量
    static let likePostCount_blisslink = 2
}

/// 本地数据管理类
class LocalData_blisslink: ObservableObject {
    
    /// 单例实例
    static let shared_blisslink = LocalData_blisslink()
    
    /// 用户列表
    @Published var userList_blisslink: [PrewUserModel_blisslink] = []
    
    /// 帖子列表
    @Published var titleList_blisslink: [TitleModel_blisslink] = []
    
    /// 徽章列表
    @Published var badgeList_blisslink: [MeditationBadge_blisslink] = []
    
    /// 好友动态列表
    @Published var friendActivities_blisslink: [FriendActivity_blisslink] = []
    
    /// 数据生成器
    private lazy var generator_blisslink: DataGenerator_blisslink = {
        return DataGenerator_blisslink(dataLocal_blisslink: self)
    }()
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    /// 初始化所有数据
    func initData_blisslink() {
        generator_blisslink.initUsers_blisslink()
        generator_blisslink.initPosts_blisslink()
        generator_blisslink.setUserLikes_blisslink()
        generator_blisslink.initBadges_blisslink()
        generator_blisslink.initFriendActivities_blisslink()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_blisslink(userId_blisslink: Int) -> [TitleModel_blisslink] {
        return titleList_blisslink.filter { $0.titleUserId_blisslink != userId_blisslink }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_blisslink(postAuthorUserId_blisslink: Int) -> [PrewUserModel_blisslink] {
        return userList_blisslink.filter { $0.userId_blisslink != postAuthorUserId_blisslink }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_blisslink {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_blisslink: [(String, String, String, String)] = [
        ("TechExplorer", "Passionate about technology and innovation", "head1", "head1"),
        ("CreativeMinds", "Designer and creative thinker", "head2", "head1"),
        ("CodeMaster", "Full-stack developer and problem solver", "head3", "head1"),
        ("DigitalNomad", "Traveling the world while working remotely", "head4", "head1"),
        ("UXWizard", "Crafting seamless user experiences", "head5", "head1"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)
    static let postsInfo_blisslink: [(String, String, String)] = [
        ("Amazing Discovery", "Just discovered this incredible new feature that's going to change everything. The attention to detail is remarkable, and the user experience is seamless. Can't wait to share more about this with everyone!", "title1"),
        ("Beautiful Design", "There's something special about clean, minimal design. It's not just about looks—it's about creating an experience that feels natural and effortless. This project captures that perfectly.", "title2"),
        ("Innovation at Work", "Watching innovation unfold in real-time is fascinating. The way technology seamlessly integrates into our daily lives never ceases to amaze me. Here's to the future!", "title3"),
        ("Creative Process", "Behind every great project is a creative process filled with iterations, late nights, and breakthrough moments. This journey has been incredible so far.", "title4"),
        ("Team Collaboration", "Look at what we built together! Collaboration brings out the best in everyone. When different perspectives come together, magic happens.", "title5"),
        ("Perfect Execution", "Weeks of planning and hard work have led to this moment. Every detail was carefully considered, and the result speaks for itself. So proud of this achievement!", "title6"),
        ("Learning Journey", "I used to think success was about knowing everything, but now I realize it's about being willing to learn. This experience taught me so much.", "title7"),
        ("Fun Activities", "We spent today exploring new ideas, testing concepts, and pushing boundaries. What's your favorite way to stay creative and inspired?", "title8"),
        ("Inspiration Everywhere", "Above us, infinite possibilities; around us, endless inspiration. The world is full of ideas waiting to be discovered and brought to life.", "title9"),
        ("Peaceful Progress", "Sometimes the best work happens in quiet moments. Taking time to reflect, iterate, and improve leads to meaningful progress.", "title10"),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_blisslink: [(String, String)] = [
        ("This looks absolutely incredible! The attention to detail is remarkable", "Can't wait to learn more about this feature. Keep us updated!"),
        ("You captured the essence of great design perfectly! Love this approach", "The simplicity and elegance here is truly inspiring. Beautifully done!"),
        ("Watching technology evolve like this is fascinating. Thanks for sharing!", "This is exactly the kind of innovation we need. Excited to see where it goes!"),
        ("The creative process is always so interesting. Thanks for sharing your journey!", "Love seeing the behind-the-scenes of great work. Inspiring stuff!"),
        ("Already inspired by this collaboration! Nothing beats working with great people", "First thing I'd say? Team work makes the dream work! Who's with me?"),
        ("Your execution is flawless! The planning really shows in the final result", "Weeks of hard work definitely paid off. Congratulations on this achievement!"),
        ("Your learning journey is inspiring! Always room to grow and improve", "It really is about the willingness to learn. Keep sharing your insights!"),
        ("Exploring new ideas is my favorite too! Also love the creative energy here", "My go-to activity: brainstorming with coffee and good music"),
        ("The infinite possibilities and endless inspiration—beautifully put!", "That feeling of discovering new ideas... perfectly captured!"),
        ("The quiet moments of progress are so underrated. Pure productivity", "Sometimes we just need peaceful progress and meaningful iteration"),
    ]
    
    /// 徽章信息列表 (名称, 描述, 图标, 解锁条件, 颜色)
    static let badgesInfo_blisslink: [(String, String, String, String, [String])] = [
        ("First Post", "Share your first yoga journey", "doc.text.fill", "Publish your first post", ["667EEA", "764BA2"]),
        ("Like Explorer", "Spread positivity in the community", "heart.fill", "Give 3 posts a like", ["FF6B6B", "FFE66D"]),
        ("Practice Beginner", "Build your practice foundation", "figure.yoga", "Practice for 10 hours total", ["43E97B", "38F9D7"]),
        ("Active Sharer", "Inspire others with your journey", "sparkles", "Publish 5 posts", ["F2994A", "F2C94C"]),
        ("Community Supporter", "Show love to the community", "star.fill", "Give 10 posts a like", ["FA709A", "FEE140"]),
        ("Dedicated Practitioner", "Commit to your practice", "flame.fill", "Practice for 20 hours total", ["56CCF2", "2F80ED"]),
    ]
    
    /// 好友动态信息列表 (好友名称, 动态类型, 动态内容)
    static let friendActivitiesInfo_blisslink: [(String, FriendActivityType_blisslink, String)] = [
        ("Emma Wilson", .changedBackground_blisslink, "Changed to Beach Sunset theme"),
        ("David Park", .unlockedBadge_blisslink, "Unlocked 'Week Warrior' badge"),
        ("Sarah Chen", .completedChallenge_blisslink, "Completed 21-Day Meditation Journey"),
        ("Michael Torres", .addedMemory_blisslink, "Added first outdoor meditation memory"),
        ("TechExplorer", .unlockedBadge_blisslink, "Unlocked 'Zen Master' badge"),
        ("CreativeMinds", .changedBackground_blisslink, "Changed to Forest Zen theme"),
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
private struct RandomUtil_blisslink {
    
    /// 生成指定范围的随机整数
    static func nextInt_blisslink(min_blisslink: Int, range_blisslink: Int) -> Int {
        return Int.random(in: min_blisslink..<(min_blisslink + range_blisslink))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_blisslink<T>(from list_blisslink: [T], count_blisslink: Int) -> [T] {
        guard !list_blisslink.isEmpty else { return [] }
        guard list_blisslink.count > count_blisslink else { return list_blisslink }
        
        var selected_blisslink: [T] = []
        var indices_blisslink: Set<Int> = []
        
        while selected_blisslink.count < count_blisslink && indices_blisslink.count < list_blisslink.count {
            let index_blisslink = Int.random(in: 0..<list_blisslink.count)
            if !indices_blisslink.contains(index_blisslink) {
                indices_blisslink.insert(index_blisslink)
                selected_blisslink.append(list_blisslink[index_blisslink])
            }
        }
        
        return selected_blisslink
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_blisslink {
    
    /// 弱引用本地数据管理器，避免循环引用
    private weak var dataLocal_blisslink: LocalData_blisslink?
    
    /// 初始化方法
    init(dataLocal_blisslink: LocalData_blisslink) {
        self.dataLocal_blisslink = dataLocal_blisslink
    }
    
    /// 初始化生成用户数据
    func initUsers_blisslink() {
        guard let dataLocal_blisslink = dataLocal_blisslink else { return }
        dataLocal_blisslink.userList_blisslink.removeAll()
        
        // 可选的背景主题
        let backgrounds_blisslink: [YogaMatBackground_blisslink] = [
            .forestZen_blisslink,
            .beachSunset_blisslink,
            .sakuraGarden_blisslink,
            .starryNight_blisslink,
            .mountainMist_blisslink
        ]
        
        for (index_blisslink, userInfo_blisslink) in DataSource_blisslink.usersInfo_blisslink.enumerated() {
            let (username_blisslink, introduce_blisslink, userHead_blisslink, userAlbum_blisslink) = userInfo_blisslink
            
            let user_blisslink = PrewUserModel_blisslink()
            user_blisslink.userId_blisslink = index_blisslink + DataConfig_blisslink.userIdStart_blisslink
            user_blisslink.userName_blisslink = username_blisslink
            user_blisslink.userIntroduce_blisslink = introduce_blisslink
            user_blisslink.userHead_blisslink = userHead_blisslink
            user_blisslink.userMedia_blisslink = [userAlbum_blisslink]
            user_blisslink.userLike_blisslink = []
            user_blisslink.userFollow_blisslink = 15 + Int.random(in: 1...50)
            user_blisslink.userFans_blisslink = 20 + Int.random(in: 1...50)
            
            // 设置瑜伽垫背景
            user_blisslink.yogaMatBackground_blisslink = backgrounds_blisslink[index_blisslink % backgrounds_blisslink.count]
            
            dataLocal_blisslink.userList_blisslink.append(user_blisslink)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_blisslink() {
        guard let dataLocal_blisslink = dataLocal_blisslink else { return }
        dataLocal_blisslink.titleList_blisslink.removeAll()
        
        for (index_blisslink, postInfo_blisslink) in DataSource_blisslink.postsInfo_blisslink.enumerated() {
            let (title_blisslink, content_blisslink, media_blisslink) = postInfo_blisslink
            
            // 循环分配作者
            let authorIndex_blisslink = index_blisslink % dataLocal_blisslink.userList_blisslink.count
            guard authorIndex_blisslink < dataLocal_blisslink.userList_blisslink.count else { continue }
            let author_blisslink = dataLocal_blisslink.userList_blisslink[authorIndex_blisslink]
            
            // 生成评论
            let comments_blisslink = generateComments_blisslink(
                postIndex_blisslink: index_blisslink,
                postAuthorUserId_blisslink: author_blisslink.userId_blisslink ?? 0
            )
            
            // 创建帖子
            let post_blisslink = TitleModel_blisslink(
                titleId_blisslink: index_blisslink + DataConfig_blisslink.postIdStart_blisslink,
                titleUserId_blisslink: author_blisslink.userId_blisslink ?? 0,
                titleUserName_blisslink: author_blisslink.userName_blisslink ?? "",
                titleMeidas_blisslink: [media_blisslink],
                title_blisslink: title_blisslink,
                titleContent_blisslink: content_blisslink,
                reviews_blisslink: comments_blisslink,
                likes_blisslink: RandomUtil_blisslink.nextInt_blisslink(min_blisslink: 10, range_blisslink: 150)
            )
            
            dataLocal_blisslink.titleList_blisslink.append(post_blisslink)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_blisslink(postIndex_blisslink: Int, postAuthorUserId_blisslink: Int) -> [Comment_blisslink] {
        guard let dataLocal_blisslink = dataLocal_blisslink else { return [] }
        
        let availableUsers_blisslink = dataLocal_blisslink.getAvailableCommenters_blisslink(postAuthorUserId_blisslink: postAuthorUserId_blisslink)
        guard availableUsers_blisslink.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_blisslink = availableUsers_blisslink[postIndex_blisslink % availableUsers_blisslink.count]
        let commenter2_blisslink = availableUsers_blisslink[(postIndex_blisslink + 1) % availableUsers_blisslink.count]
        
        // 获取评论内容
        let commentIndex_blisslink = postIndex_blisslink % DataSource_blisslink.comments_blisslink.count
        let (comment1_blisslink, comment2_blisslink) = DataSource_blisslink.comments_blisslink[commentIndex_blisslink]
        
        return [
            Comment_blisslink(
                commentId_blisslink: postIndex_blisslink * 2 + 1,
                commentUserId_blisslink: commenter1_blisslink.userId_blisslink ?? 0,
                commentUserName_blisslink: commenter1_blisslink.userName_blisslink ?? "",
                commentContent_blisslink: comment1_blisslink
            ),
            Comment_blisslink(
                commentId_blisslink: postIndex_blisslink * 2 + 2,
                commentUserId_blisslink: commenter2_blisslink.userId_blisslink ?? 0,
                commentUserName_blisslink: commenter2_blisslink.userName_blisslink ?? "",
                commentContent_blisslink: comment2_blisslink
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_blisslink() {
        guard let dataLocal_blisslink = dataLocal_blisslink else { return }
        
        for i_blisslink in 0..<dataLocal_blisslink.userList_blisslink.count {
            let user_blisslink = dataLocal_blisslink.userList_blisslink[i_blisslink]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_blisslink = dataLocal_blisslink.getPostsExcludingUser_blisslink(
                userId_blisslink: user_blisslink.userId_blisslink ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_blisslink = RandomUtil_blisslink.selectRandomItems_blisslink(
                from: availablePosts_blisslink,
                count_blisslink: DataConfig_blisslink.likePostCount_blisslink
            )
            
            dataLocal_blisslink.userList_blisslink[i_blisslink].userLike_blisslink = likePosts_blisslink
        }
    }
    
    /// 初始化徽章数据
    func initBadges_blisslink() {
        guard let dataLocal_blisslink = dataLocal_blisslink else { return }
        dataLocal_blisslink.badgeList_blisslink.removeAll()
        
        for (index_blisslink, badgeInfo_blisslink) in DataSource_blisslink.badgesInfo_blisslink.enumerated() {
            let (name_blisslink, description_blisslink, icon_blisslink, condition_blisslink, colors_blisslink) = badgeInfo_blisslink
            
            // 所有徽章初始都是未解锁状态
            let badge_blisslink = MeditationBadge_blisslink(
                badgeId_blisslink: index_blisslink + 1,
                badgeName_blisslink: name_blisslink,
                badgeDescription_blisslink: description_blisslink,
                badgeIcon_blisslink: icon_blisslink,
                unlockCondition_blisslink: condition_blisslink,
                isUnlocked_blisslink: false,
                unlockDate_blisslink: nil,
                badgeColor_blisslink: colors_blisslink
            )
            
            dataLocal_blisslink.badgeList_blisslink.append(badge_blisslink)
        }
        
        print("✅ 初始化了 \(dataLocal_blisslink.badgeList_blisslink.count) 个徽章")
    }
    
    /// 初始化好友动态数据
    func initFriendActivities_blisslink() {
        guard let dataLocal_blisslink = dataLocal_blisslink else { return }
        dataLocal_blisslink.friendActivities_blisslink.removeAll()
        
        for (index_blisslink, activityInfo_blisslink) in DataSource_blisslink.friendActivitiesInfo_blisslink.enumerated() {
            let (friendName_blisslink, activityType_blisslink, content_blisslink) = activityInfo_blisslink
            
            // 获取好友ID（从用户列表中查找）
            let friendId_blisslink = (index_blisslink % dataLocal_blisslink.userList_blisslink.count) + 10
            
            let activity_blisslink = FriendActivity_blisslink(
                activityId_blisslink: index_blisslink + 1,
                friendUserId_blisslink: friendId_blisslink,
                friendName_blisslink: friendName_blisslink,
                friendAvatar_blisslink: "person.crop.circle.fill",
                activityType_blisslink: activityType_blisslink,
                activityContent_blisslink: content_blisslink,
                activityTime_blisslink: Date().addingTimeInterval(-Double(index_blisslink) * 3600)
            )
            
            dataLocal_blisslink.friendActivities_blisslink.append(activity_blisslink)
        }
        
        print("✅ 初始化了 \(dataLocal_blisslink.friendActivities_blisslink.count) 条好友动态")
    }
}
