import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Wanderbell {
    /// ID起始值
    static let userIdStart_Wanderbell = 10
    static let postIdStart_Wanderbell = 20
    static let emotionRecordIdStart_Wanderbell = 100
    
    /// 喜欢帖子数量
    static let likePostCount_Wanderbell = 2
    
    /// 情绪记录数量
    static let emotionRecordCount_Wanderbell = 20
}

/// 本地数据管理类
class LocalData_Wanderbell {
    
    /// 单例
    static let shared_Wanderbell = LocalData_Wanderbell()
    
    /// 用户列表
    var userList_Wanderbell: [PrewUserModel_Wanderbell] = []
    
    /// 帖子列表
    var titleList_Wanderbell: [TitleModel_Wanderbell] = []
    
    /// 情绪记录列表
    var emotionRecordList_Wanderbell: [EmotionRecord_Wanderbell] = []
    
    /// 数据生成器
    private lazy var generator_Wanderbell: DataGenerator_Wanderbell = {
        return DataGenerator_Wanderbell(dataLocal_wanderbell: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Wanderbell() {
        generator_Wanderbell.initUsers_Wanderbell()
        generator_Wanderbell.initPosts_Wanderbell()
        generator_Wanderbell.setUserLikes_Wanderbell()
        generator_Wanderbell.initEmotionRecords_Wanderbell()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Wanderbell(userId_wanderbell: Int) -> [TitleModel_Wanderbell] {
        return titleList_Wanderbell.filter { $0.titleUserId_Wanderbell != userId_wanderbell }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Wanderbell(postAuthorUserId_wanderbell: Int) -> [PrewUserModel_Wanderbell] {
        return userList_Wanderbell.filter { $0.userId_Wanderbell != postAuthorUserId_wanderbell }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Wanderbell {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Wanderbell: [(String, String, String)] = [
        ("MindfulSoul", "Releasing emotions, finding inner peace", "head1"),
        ("CalmBreeze", "Every feeling is valid and deserves space", "head2"),
        ("HealingHeart", "Documenting my emotional journey one day at a time", "head3"),
        ("SerenitySeeker", "Learning to embrace all my emotions", "head4"),
        ("PeacefulVessel", "My safe space for emotional release", "head5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL/系统图标)
    static let postsInfo_Wanderbell: [(String, String, String)] = [
        ("Sunshine in My Heart", "Today was filled with pure joy! Everything felt lighter, and I couldn't stop smiling. Sometimes happiness finds you in the most unexpected moments.", "title1"),
        ("Finding My Calm", "Spent the afternoon by the lake, just breathing and being present. The water was so still, and for the first time in weeks, so was my mind. Peace feels like coming home.", "title2"),
        ("Heavy Heart Today", "Some days the sadness feels overwhelming. But I'm learning that it's okay to not be okay. Writing this helps me process and release what I'm holding inside.", "title3"),
        ("Anxiety Waves", "My mind won't stop racing with what-ifs and worries. Recording this to remind myself: this feeling is temporary, and I've gotten through it before.", "title4"),
        ("Fire Within", "Frustration and anger bubbling up today. Instead of holding it in, I'm letting it out here. Acknowledging these feelings so they don't consume me.", "title5"),
        ("Pure Excitement", "Can't contain this energy! Everything feels possible right now. Life is full of opportunities and I'm ready to grab them all!", "title6"),
        ("Exhausted but Healing", "So tired today, both physically and emotionally. But I'm proud of myself for showing up anyway. Rest is part of the journey.", "title7"),
        ("Grateful Heart", "Taking a moment to appreciate the small things: morning coffee, a kind text, the sunset. Gratitude shifts everything.", "title8"),
        ("Emotional Roller Coaster", "Today I felt everything at once—joy, sadness, hope, fear. And that's okay. I'm human, and my vessel holds space for all of it.", "title9"),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_Wanderbell: [(String, String)] = [
        ("I feel this so much! Your joy is contagious 🌟", "Smiling while reading this. Thank you for sharing your light!"),
        ("This is exactly what I needed today. Finding calm is such a gift 🙏", "The lake sounds perfect. I need to find my peaceful spot too."),
        ("Sending you a virtual hug. It takes courage to share this 💜", "Thank you for being vulnerable. You're not alone in this feeling."),
        ("Anxiety is so real. Proud of you for acknowledging it!", "You've got this! One breath at a time, friend."),
        ("Valid feelings! Sometimes we need to let that fire burn 🔥", "Acknowledging anger is healthy. Hope you find release soon."),
        ("Your energy is infectious! Go chase those dreams! ✨", "YES! Ride this wave of excitement, you deserve it!"),
        ("Rest is productive too. Be gentle with yourself 🌙", "Proud of you for recognizing what you need. Self-care matters."),
        ("Gratitude is a superpower. Love this perspective 🌸", "The small things really are the big things. Beautiful reminder!"),
        ("Life is messy and that's okay. Thanks for the realness 🌈", "Every emotion is part of your story. Keep being authentic!"),
    ]
    
}

// MARK: - 随机数工具类

/// 随机数工具类
/// 功能：提供各种随机数生成方法
private struct RandomUtil_Wanderbell {
    
    /// 生成指定范围的随机整数
    static func nextInt_Wanderbell(min_wanderbell: Int, range_wanderbell: Int) -> Int {
        return Int.random(in: min_wanderbell..<(min_wanderbell + range_wanderbell))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Wanderbell<T>(from list_wanderbell: [T], count_wanderbell: Int) -> [T] {
        guard !list_wanderbell.isEmpty else { return [] }
        guard list_wanderbell.count > count_wanderbell else { return list_wanderbell }
        
        var selected_wanderbell: [T] = []
        var indices_wanderbell: Set<Int> = []
        
        while selected_wanderbell.count < count_wanderbell && indices_wanderbell.count < list_wanderbell.count {
            let index_wanderbell = Int.random(in: 0..<list_wanderbell.count)
            if !indices_wanderbell.contains(index_wanderbell) {
                indices_wanderbell.insert(index_wanderbell)
                selected_wanderbell.append(list_wanderbell[index_wanderbell])
            }
        }
        
        return selected_wanderbell
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Wanderbell {
    
    private weak var dataLocal_Wanderbell: LocalData_Wanderbell?
    
    init(dataLocal_wanderbell: LocalData_Wanderbell) {
        self.dataLocal_Wanderbell = dataLocal_wanderbell
    }
    
    /// 初始化生成用户数据
    func initUsers_Wanderbell() {
        guard let dataLocal_wanderbell = dataLocal_Wanderbell else { return }
        dataLocal_wanderbell.userList_Wanderbell.removeAll()
        
        for (index_wanderbell, userInfo_wanderbell) in DataSource_Wanderbell.usersInfo_Wanderbell.enumerated() {
            let (username_wanderbell, introduce_wanderbell, userHead_wanderbell) = userInfo_wanderbell
            
            let user_wanderbell = PrewUserModel_Wanderbell()
            user_wanderbell.userId_Wanderbell = index_wanderbell + DataConfig_Wanderbell.userIdStart_Wanderbell
            user_wanderbell.userName_Wanderbell = username_wanderbell
            user_wanderbell.userIntroduce_Wanderbell = introduce_wanderbell
            user_wanderbell.userHead_Wanderbell = userHead_wanderbell
            user_wanderbell.userMedia_Wanderbell = []
            user_wanderbell.userLike_Wanderbell = []
            user_wanderbell.userFollowCount_Wanderbell = 15 + Int.random(in: 1...50)
            user_wanderbell.userFollowers_Wanderbell = 20 + Int.random(in: 1...50)
            dataLocal_wanderbell.userList_Wanderbell.append(user_wanderbell)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Wanderbell() {
        guard let dataLocal_wanderbell = dataLocal_Wanderbell else { return }
        dataLocal_wanderbell.titleList_Wanderbell.removeAll()
        
        for (index_wanderbell, postInfo_wanderbell) in DataSource_Wanderbell.postsInfo_Wanderbell.enumerated() {
            let (title_wanderbell, content_wanderbell, media_wanderbell) = postInfo_wanderbell
            
            // 循环分配作者
            let authorIndex_wanderbell = index_wanderbell % dataLocal_wanderbell.userList_Wanderbell.count
            guard authorIndex_wanderbell < dataLocal_wanderbell.userList_Wanderbell.count else { continue }
            let author_wanderbell = dataLocal_wanderbell.userList_Wanderbell[authorIndex_wanderbell]
            
            // 生成评论
            let comments_wanderbell = generateComments_Wanderbell(
                postIndex_wanderbell: index_wanderbell,
                postAuthorUserId_wanderbell: author_wanderbell.userId_Wanderbell ?? 0
            )
            
            // 创建帖子
            let post_wanderbell = TitleModel_Wanderbell(
                titleId_Wanderbell: index_wanderbell + DataConfig_Wanderbell.postIdStart_Wanderbell,
                titleUserId_Wanderbell: author_wanderbell.userId_Wanderbell ?? 0,
                titleUserName_Wanderbell: author_wanderbell.userName_Wanderbell ?? "",
                titleMeidas_Wanderbell: [media_wanderbell],
                title_Wanderbell: title_wanderbell,
                titleContent_Wanderbell: content_wanderbell,
                reviews_Wanderbell: comments_wanderbell,
                likes_Wanderbell: RandomUtil_Wanderbell.nextInt_Wanderbell(min_wanderbell: 10, range_wanderbell: 150)
            )
            
            dataLocal_wanderbell.titleList_Wanderbell.append(post_wanderbell)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Wanderbell(postIndex_wanderbell: Int, postAuthorUserId_wanderbell: Int) -> [Comment_Wanderbell] {
        guard let dataLocal_wanderbell = dataLocal_Wanderbell else { return [] }
        
        let availableUsers_wanderbell = dataLocal_wanderbell.getAvailableCommenters_Wanderbell(postAuthorUserId_wanderbell: postAuthorUserId_wanderbell)
        guard availableUsers_wanderbell.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_wanderbell = availableUsers_wanderbell[postIndex_wanderbell % availableUsers_wanderbell.count]
        let commenter2_wanderbell = availableUsers_wanderbell[(postIndex_wanderbell + 1) % availableUsers_wanderbell.count]
        
        // 获取评论内容
        let commentIndex_wanderbell = postIndex_wanderbell % DataSource_Wanderbell.comments_Wanderbell.count
        let (comment1_wanderbell, comment2_wanderbell) = DataSource_Wanderbell.comments_Wanderbell[commentIndex_wanderbell]
        
        return [
            Comment_Wanderbell(
                commentId_Wanderbell: postIndex_wanderbell * 2 + 1,
                commentUserId_Wanderbell: commenter1_wanderbell.userId_Wanderbell ?? 0,
                commentUserName_Wanderbell: commenter1_wanderbell.userName_Wanderbell ?? "",
                commentContent_Wanderbell: comment1_wanderbell
            ),
            Comment_Wanderbell(
                commentId_Wanderbell: postIndex_wanderbell * 2 + 2,
                commentUserId_Wanderbell: commenter2_wanderbell.userId_Wanderbell ?? 0,
                commentUserName_Wanderbell: commenter2_wanderbell.userName_Wanderbell ?? "",
                commentContent_Wanderbell: comment2_wanderbell
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Wanderbell() {
        guard let dataLocal_wanderbell = dataLocal_Wanderbell else { return }
        
        for i_wanderbell in 0..<dataLocal_wanderbell.userList_Wanderbell.count {
            let user_wanderbell = dataLocal_wanderbell.userList_Wanderbell[i_wanderbell]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_wanderbell = dataLocal_wanderbell.getPostsExcludingUser_Wanderbell(
                userId_wanderbell: user_wanderbell.userId_Wanderbell ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_wanderbell = RandomUtil_Wanderbell.selectRandomItems_Wanderbell(
                from: availablePosts_wanderbell,
                count_wanderbell: DataConfig_Wanderbell.likePostCount_Wanderbell
            )
            
            dataLocal_wanderbell.userList_Wanderbell[i_wanderbell].userLike_Wanderbell = likePosts_wanderbell
        }
    }
    
    /// 初始化生成情绪记录数据（从帖子数据生成）
    func initEmotionRecords_Wanderbell() {
        guard let dataLocal_wanderbell = dataLocal_Wanderbell else { return }
        dataLocal_wanderbell.emotionRecordList_Wanderbell.removeAll()
        
        let calendar_wanderbell = Calendar.current
        let emotionTypes_wanderbell = EmotionType_Wanderbell.getAllBasicTypes_Wanderbell()
        
        // 从帖子数据生成情绪记录
        for (index_wanderbell, postInfo_wanderbell) in DataSource_Wanderbell.postsInfo_Wanderbell.enumerated() {
            let (_, content_wanderbell, _) = postInfo_wanderbell
            
            // 循环分配用户
            let userIndex_wanderbell = index_wanderbell % dataLocal_wanderbell.userList_Wanderbell.count
            guard userIndex_wanderbell < dataLocal_wanderbell.userList_Wanderbell.count else { continue }
            let user_wanderbell = dataLocal_wanderbell.userList_Wanderbell[userIndex_wanderbell]
            
            // 循环分配情绪类型
            let emotionType_wanderbell = emotionTypes_wanderbell[index_wanderbell % emotionTypes_wanderbell.count]
            
            // 从内容中提取标签
            var tags_wanderbell: [String] = []
            if content_wanderbell.contains("joy") || content_wanderbell.contains("happy") || content_wanderbell.contains("smile") {
                tags_wanderbell.append("joy")
            }
            if content_wanderbell.contains("peace") || content_wanderbell.contains("calm") {
                tags_wanderbell.append("peace")
            }
            if content_wanderbell.contains("anxiety") || content_wanderbell.contains("worry") {
                tags_wanderbell.append("stress")
            }
            if content_wanderbell.contains("grateful") {
                tags_wanderbell.append("gratitude")
            }
            if tags_wanderbell.isEmpty {
                tags_wanderbell = ["reflection"]
            }
            
            // 生成随机时间戳（最近30天内）
            let daysAgo_wanderbell = RandomUtil_Wanderbell.nextInt_Wanderbell(min_wanderbell: 0, range_wanderbell: 30)
            let timestamp_wanderbell = calendar_wanderbell.date(byAdding: .day, value: -daysAgo_wanderbell, to: Date()) ?? Date()
            
            // 随机添加时间偏移（0-23小时）
            let hoursOffset_wanderbell = RandomUtil_Wanderbell.nextInt_Wanderbell(min_wanderbell: 0, range_wanderbell: 24)
            let finalTimestamp_wanderbell = calendar_wanderbell.date(byAdding: .hour, value: hoursOffset_wanderbell, to: timestamp_wanderbell) ?? timestamp_wanderbell
            
            // 随机强度（1-5）
            let intensity_wanderbell = RandomUtil_Wanderbell.nextInt_Wanderbell(min_wanderbell: 1, range_wanderbell: 5)
            
            // 创建情绪记录
            let record_wanderbell = EmotionRecord_Wanderbell(
                recordId_Wanderbell: index_wanderbell + DataConfig_Wanderbell.emotionRecordIdStart_Wanderbell,
                userId_Wanderbell: user_wanderbell.userId_Wanderbell ?? 0,
                emotionType_Wanderbell: emotionType_wanderbell,
                customEmotion_Wanderbell: nil,
                intensity_Wanderbell: intensity_wanderbell,
                note_Wanderbell: content_wanderbell,
                media_Wanderbell: [],
                timestamp_Wanderbell: finalTimestamp_wanderbell,
                tags_Wanderbell: tags_wanderbell
            )
            
            dataLocal_wanderbell.emotionRecordList_Wanderbell.append(record_wanderbell)
        }
    }
}
