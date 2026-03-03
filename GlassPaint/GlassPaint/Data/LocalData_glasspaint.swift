import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Glasspaint {
    /// ID起始值
    static let userIdStart_Glasspaint = 10
    static let postIdStart_Glasspaint = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Glasspaint = 2
}

/// 本地数据管理类
class LocalData_Glasspaint {
    
    /// 单例
    static let shared_Glasspaint = LocalData_Glasspaint()
    
    /// 用户列表
    var userList_Glasspaint: [PrewUserModel_Glasspaint] = []
    
    /// 帖子列表
    var titleList_Glasspaint: [TitleModel_Glasspaint] = []
    
    /// 挑战列表
    var challengeList_Glasspaint: [ChallengeModel_Glasspaint] = []
    
    /// 时间胶囊列表
    var timeCapsuleList_Glasspaint: [TimeCapsulePost_Glasspaint] = []
    
    /// 数据生成器
    private lazy var generator_Glasspaint: DataGenerator_Glasspaint = {
        return DataGenerator_Glasspaint(dataLocal_glasspaint: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Glasspaint() {
        generator_Glasspaint.initUsers_Glasspaint()
        generator_Glasspaint.initPosts_Glasspaint()
        generator_Glasspaint.assignPaintingAttributes_Glasspaint()
        generator_Glasspaint.setUserLikes_Glasspaint()
        generator_Glasspaint.initChallenges_Glasspaint()
        generator_Glasspaint.initTimeCapsules_Glasspaint()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Glasspaint(userId_glasspaint: Int) -> [TitleModel_Glasspaint] {
        return titleList_Glasspaint.filter { $0.titleUserId_Glasspaint != userId_glasspaint }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Glasspaint(postAuthorUserId_glasspaint: Int) -> [PrewUserModel_Glasspaint] {
        return userList_Glasspaint.filter { $0.userId_Glasspaint != postAuthorUserId_glasspaint }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Glasspaint {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Glasspaint: [(String, String, String, String)] = [
        ("EmberSeeker", "Love exploring around bonfires", "head1", "head1"),
        ("ForestWhisper", "Nature enthusiast and storyteller", "head2", "head2"),
        ("FlameJumper", "Adventure seeker and fire dancer", "head3", "head3"),
        ("AshesToArt", "Turning moments into memories", "head4", "head4"),
        ("NightGlow", "Capturing the magic of firelight", "head5", "head5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)
    static let postsInfo_Glasspaint: [(String, String, String)] = [
        ("Perfect Bonfire Night", "The bonfire crackles softly, wrapping every face in warm light; we pass around s'mores, and stories flow as freely as the laughter. This is the kind of night that stays with you long after the embers fade.", "title1"),
        ("Magical Firelight", "There's something magical about firelight—it turns ordinary moments into treasures. Sitting here, feeling the warmth on my hands and listening to friends chat, I realize happiness is just this simple.", "title2"),
        ("Dancing Flames", "The flames dance and flicker, casting gentle shadows on the grass. No loud noises, no rush—just the glow of fire, the breeze, and people who make the night feel like home.", "title3"),
        ("Warm Hearts", "As the night grows darker, the bonfire burns brighter. It's not just the fire that warms us, but the company, the shared smiles, and the quiet connection between every heart here.", "title4"),
        ("Glowing Memories", "Look at this glowing fire and the grinning faces around it—this is what good nights are made of! Tag the person you'd drag to sit with you by such a bonfire.", "title5"),
        ("Absolute Perfection", "Last night's bonfire was absolute perfection: great friends, crispy marshmallows, and a fire that burned steady till midnight. Who's got a bonfire story to top this?", "title6"),
        ("Fire Family", "I used to think bonfires were just about fire, but now I know it's about the people. This crew turned a simple fire into an unforgettable night.", "title7"),
        ("Fun Activities", "We spent hours around this bonfire: singing off-key, playing silly games, and even debating whether the fire is orange or red. What's your go-to bonfire activity?", "title8"),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_Glasspaint: [(String, String)] = [
        ("This looks absolutely magical! Nothing beats a bonfire with good friends", "S'mores and stories by the fire—that's the perfect night right there!"),
        ("You captured the essence of what makes bonfires special! Love this vibe", "The simplicity of firelight and friendship is truly magical. Beautiful moment!"),
        ("Those dancing flames and peaceful vibes—I can feel the warmth through the screen!", "This is exactly what I needed to see today. Time to plan a bonfire night!"),
        ("The connection between hearts around a fire is something special. Beautifully said!", "Love how you describe the warmth coming from both the fire and the company"),
        ("Already know who I'd tag for this! Nothing beats bonfire nights with the right people", "First thing I'd share? Probably my terrible ghost stories! Who's with me?"),
        ("Our bonfire story: We accidentally used green wood and it wouldn't stop smoking!", "Crispy marshmallows till midnight sounds perfect! Need to organize one soon"),
        ("Your fire family sounds amazing! Count me in for round two", "It really is all about the people. The fire is just an excuse to gather!"),
        ("Off-key singing is mandatory at our bonfires too! Also love the fire color debate", "My go-to activity: trying to roast the perfect marshmallow"),
    ]
    
    // MARK: - 彩绘相关数据
    
    /// 彩绘属性配置 (难度, 风格, 场景, 载体)
    /// 覆盖所有发布页可选组合：3种难度 × 5种风格 × 5种载体
    static let paintingAttributes_Glasspaint: [(PaintingLevel_Glasspaint, PaintingStyle_Glasspaint, String, CarrierType_Glasspaint)] = [
        // Beginner级别
        (.beginner_glasspaint, .modern_glasspaint, "Home Decoration", .glassCup_glasspaint),
        (.beginner_glasspaint, .cute_glasspaint, "Festival Gift", .glassPlate_glasspaint),
        (.beginner_glasspaint, .minimalist_glasspaint, "Home Decoration", .ornament_glasspaint),
        
        // Intermediate级别
        (.intermediate_glasspaint, .retro_glasspaint, "Art Collection", .vase_glasspaint),
        (.intermediate_glasspaint, .modern_glasspaint, "Home Decoration", .glassCup_glasspaint),
        (.intermediate_glasspaint, .cute_glasspaint, "Festival Gift", .glassPlate_glasspaint),
        (.intermediate_glasspaint, .artistic_glasspaint, "Art Collection", .ornament_glasspaint),
        
        // Advanced级别
        (.advanced_glasspaint, .artistic_glasspaint, "Art Collection", .window_glasspaint),
        (.advanced_glasspaint, .retro_glasspaint, "Art Collection", .vase_glasspaint),
        (.advanced_glasspaint, .minimalist_glasspaint, "Home Decoration", .glassPlate_glasspaint),
    ]
    
    /// 用户彩绘水平和偏好 (水平, 偏好风格列表, 偏好场景列表)
    /// 根据发布页可选项配置：3种难度等级 × 5种风格
    static let userPaintingPreferences_Glasspaint: [(PaintingLevel_Glasspaint, [PaintingStyle_Glasspaint], [String])] = [
        // 用户1：新手 - 喜欢现代简约风格，用于家居装饰和节日礼物
        (.beginner_glasspaint, [.modern_glasspaint, .minimalist_glasspaint], ["Home Decoration", "Festival Gift"]),
        
        // 用户2：进阶 - 偏爱复古和艺术风格，收藏和装饰并重
        (.intermediate_glasspaint, [.retro_glasspaint, .artistic_glasspaint], ["Art Collection", "Home Decoration"]),
        
        // 用户3：新手 - 热衷可爱风格，主要用于送礼
        (.beginner_glasspaint, [.cute_glasspaint, .modern_glasspaint], ["Festival Gift", "Home Decoration"]),
        
        // 用户4：高级 - 专注艺术和复古风格，纯粹的艺术收藏
        (.advanced_glasspaint, [.artistic_glasspaint, .retro_glasspaint, .minimalist_glasspaint], ["Art Collection"]),
        
        // 用户5：进阶 - 全能型，多种风格混搭
        (.intermediate_glasspaint, [.modern_glasspaint, .cute_glasspaint, .minimalist_glasspaint], ["Home Decoration", "Festival Gift"]),
    ]
    
    /// 挑战数据 (载体, 标题, 描述)
    static let challengesInfo_Glasspaint: [(CarrierType_Glasspaint, String, String)] = [
        (.glassCup_glasspaint, "Glass Cup Magic", "Transform an ordinary glass cup into a magical masterpiece with simple patterns"),
        (.glassPlate_glasspaint, "Flat Canvas Challenge", "Create stunning art on flat glass plates - perfect for beginners"),
        (.ornament_glasspaint, "Mini Ornament Delight", "Design cute mini glass ornaments with 1-2 easy painting schemes"),
        (.vase_glasspaint, "Vase Elegance", "Paint elegant patterns on glass vases to brighten your home"),
    ]
    
    /// 时间胶囊数据 (标题, 创作心得, 背后故事, 图片, 解锁年数)
    static let timeCapsulesInfo_Glasspaint: [(String, String, String, String, Int)] = [
        (
            "Sunset Memories",
            "This piece captures the golden hour when everything feels warm and hopeful. I spent three evenings perfecting the gradient technique to match the exact colors I saw during that unforgettable sunset.",
            "Created during a challenging time in my life, this artwork represents hope and new beginnings. The warm orange tones remind me that every sunset brings the promise of a new dawn.",
            "catitle1",
            1
        ),
        (
            "Ocean Dreams",
            "Inspired by the tranquil ocean waves, I experimented with layering blues and greens to create depth. The flowing patterns took patience, but the result exceeded my expectations.",
            "This was my first attempt at marine-themed glass painting. The ocean has always been my refuge, and I wanted to capture that sense of peace and endless possibility.",
            "catitle2",
            2
        ),
        (
            "Forest Whispers",
            "Using earthy tones and organic shapes, I tried to convey the quiet magic of walking through an ancient forest. Each brushstroke represents a tree, a leaf, a whisper of nature.",
            "Painted after a memorable hiking trip where I felt truly connected to nature. This piece holds the essence of that serene morning among the trees.",
            "catitle3",
            1
        ),
        (
            "Starlight Symphony",
            "The night sky has always fascinated me. This piece combines deep purples and shimmering silvers to recreate the wonder of stargazing on a clear night.",
            "Created on my birthday night, looking up at the stars and feeling grateful for the journey. Each star represents a wish, a dream, and a memory.",
            "catitle4",
            3
        ),
        (
            "Spring Awakening",
            "Vibrant pinks and fresh greens celebrate the renewal of spring. This was a joyful piece, painted with energy and enthusiasm as flowers bloomed outside my window.",
            "Marks a period of personal growth and transformation. Like spring after winter, this artwork represents emerging into light and color after dark times.",
            "catitle5",
            2
        ),
        (
            "Autumn Harmony",
            "Golden yellows and warm browns capture the essence of autumn. This piece represents balance and transition, painted during a season of change and reflection.",
            "Created during a time of personal reflection, this artwork symbolizes the beauty of letting go and embracing new beginnings, just like trees releasing their leaves.",
            "catitle6",
            1
        ),
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
/// 功能：提供各种随机数生成方法
private struct RandomUtil_Glasspaint {
    
    /// 生成指定范围的随机整数
    static func nextInt_Glasspaint(min_glasspaint: Int, range_glasspaint: Int) -> Int {
        return Int.random(in: min_glasspaint..<(min_glasspaint + range_glasspaint))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Glasspaint<T>(from list_glasspaint: [T], count_glasspaint: Int) -> [T] {
        guard !list_glasspaint.isEmpty else { return [] }
        guard list_glasspaint.count > count_glasspaint else { return list_glasspaint }
        
        var selected_glasspaint: [T] = []
        var indices_glasspaint: Set<Int> = []
        
        while selected_glasspaint.count < count_glasspaint && indices_glasspaint.count < list_glasspaint.count {
            let index_glasspaint = Int.random(in: 0..<list_glasspaint.count)
            if !indices_glasspaint.contains(index_glasspaint) {
                indices_glasspaint.insert(index_glasspaint)
                selected_glasspaint.append(list_glasspaint[index_glasspaint])
            }
        }
        
        return selected_glasspaint
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Glasspaint {
    
    private weak var dataLocal_Glasspaint: LocalData_Glasspaint?
    
    init(dataLocal_glasspaint: LocalData_Glasspaint) {
        self.dataLocal_Glasspaint = dataLocal_glasspaint
    }
    
    /// 初始化生成用户数据
    func initUsers_Glasspaint() {
        guard let dataLocal_glasspaint = dataLocal_Glasspaint else { return }
        dataLocal_glasspaint.userList_Glasspaint.removeAll()
        
        for (index_glasspaint, userInfo_glasspaint) in DataSource_Glasspaint.usersInfo_Glasspaint.enumerated() {
            let (username_glasspaint, introduce_glasspaint, userHead_glasspaint, userAlbum_glasspaint) = userInfo_glasspaint
            
            // 获取彩绘偏好
            let preferenceIndex_glasspaint = index_glasspaint % DataSource_Glasspaint.userPaintingPreferences_Glasspaint.count
            let (paintingLevel_glasspaint, preferredStyles_glasspaint, preferredScenes_glasspaint) = 
                DataSource_Glasspaint.userPaintingPreferences_Glasspaint[preferenceIndex_glasspaint]
            
            let user_glasspaint = PrewUserModel_Glasspaint()
            user_glasspaint.userId_Glasspaint = index_glasspaint + DataConfig_Glasspaint.userIdStart_Glasspaint
            user_glasspaint.userName_Glasspaint = username_glasspaint
            user_glasspaint.userIntroduce_Glasspaint = introduce_glasspaint
            user_glasspaint.userHead_Glasspaint = userHead_glasspaint
            user_glasspaint.userMedia_Glasspaint = [userAlbum_glasspaint]
            user_glasspaint.userLike_Glasspaint = []
            user_glasspaint.userFollow_Glasspaint = 15 + Int.random(in: 1...50)
            user_glasspaint.userFans_Glasspaint = 20 + Int.random(in: 1...50)
            user_glasspaint.paintingLevel_Glasspaint = paintingLevel_glasspaint
            user_glasspaint.preferredStyles_Glasspaint = preferredStyles_glasspaint
            user_glasspaint.preferredScenes_Glasspaint = preferredScenes_glasspaint
            
            dataLocal_glasspaint.userList_Glasspaint.append(user_glasspaint)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Glasspaint() {
        guard let dataLocal_glasspaint = dataLocal_Glasspaint else { return }
        dataLocal_glasspaint.titleList_Glasspaint.removeAll()
        
        for (index_glasspaint, postInfo_glasspaint) in DataSource_Glasspaint.postsInfo_Glasspaint.enumerated() {
            let (title_glasspaint, content_glasspaint, media_glasspaint) = postInfo_glasspaint
            
            // 循环分配作者
            let authorIndex_glasspaint = index_glasspaint % dataLocal_glasspaint.userList_Glasspaint.count
            guard authorIndex_glasspaint < dataLocal_glasspaint.userList_Glasspaint.count else { continue }
            let author_glasspaint = dataLocal_glasspaint.userList_Glasspaint[authorIndex_glasspaint]
            
            // 生成评论
            let comments_glasspaint = generateComments_Glasspaint(
                postIndex_glasspaint: index_glasspaint,
                postAuthorUserId_glasspaint: author_glasspaint.userId_Glasspaint ?? 0
            )
            
            // 创建帖子
            let post_glasspaint = TitleModel_Glasspaint(
                titleId_Glasspaint: index_glasspaint + DataConfig_Glasspaint.postIdStart_Glasspaint,
                titleUserId_Glasspaint: author_glasspaint.userId_Glasspaint ?? 0,
                titleUserName_Glasspaint: author_glasspaint.userName_Glasspaint ?? "",
                titleMeidas_Glasspaint: [media_glasspaint],
                title_Glasspaint: title_glasspaint,
                titleContent_Glasspaint: content_glasspaint,
                reviews_Glasspaint: comments_glasspaint,
                likes_Glasspaint: RandomUtil_Glasspaint.nextInt_Glasspaint(min_glasspaint: 10, range_glasspaint: 150)
            )
            
            dataLocal_glasspaint.titleList_Glasspaint.append(post_glasspaint)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Glasspaint(postIndex_glasspaint: Int, postAuthorUserId_glasspaint: Int) -> [Comment_Glasspaint] {
        guard let dataLocal_glasspaint = dataLocal_Glasspaint else { return [] }
        
        let availableUsers_glasspaint = dataLocal_glasspaint.getAvailableCommenters_Glasspaint(postAuthorUserId_glasspaint: postAuthorUserId_glasspaint)
        guard availableUsers_glasspaint.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_glasspaint = availableUsers_glasspaint[postIndex_glasspaint % availableUsers_glasspaint.count]
        let commenter2_glasspaint = availableUsers_glasspaint[(postIndex_glasspaint + 1) % availableUsers_glasspaint.count]
        
        // 获取评论内容
        let commentIndex_glasspaint = postIndex_glasspaint % DataSource_Glasspaint.comments_Glasspaint.count
        let (comment1_glasspaint, comment2_glasspaint) = DataSource_Glasspaint.comments_Glasspaint[commentIndex_glasspaint]
        
        return [
            Comment_Glasspaint(
                commentId_Glasspaint: postIndex_glasspaint * 2 + 1,
                commentUserId_Glasspaint: commenter1_glasspaint.userId_Glasspaint ?? 0,
                commentUserName_Glasspaint: commenter1_glasspaint.userName_Glasspaint ?? "",
                commentContent_Glasspaint: comment1_glasspaint
            ),
            Comment_Glasspaint(
                commentId_Glasspaint: postIndex_glasspaint * 2 + 2,
                commentUserId_Glasspaint: commenter2_glasspaint.userId_Glasspaint ?? 0,
                commentUserName_Glasspaint: commenter2_glasspaint.userName_Glasspaint ?? "",
                commentContent_Glasspaint: comment2_glasspaint
            )
        ]
    }
    
    /// 为帖子分配彩绘属性
    /// 功能：为所有帖子添加难度、风格、场景、载体、日期等属性
    func assignPaintingAttributes_Glasspaint() {
        guard let dataLocal_glasspaint = dataLocal_Glasspaint else { return }
        
        let calendar_glasspaint = Calendar.current
        let now_glasspaint = Date()
        
        for i_glasspaint in 0..<dataLocal_glasspaint.titleList_Glasspaint.count {
            // 获取彩绘属性
            let attrIndex_glasspaint = i_glasspaint % DataSource_Glasspaint.paintingAttributes_Glasspaint.count
            let (level_glasspaint, style_glasspaint, scene_glasspaint, carrier_glasspaint) = 
                DataSource_Glasspaint.paintingAttributes_Glasspaint[attrIndex_glasspaint]
            
            // 生成创作日期（过去6个月内的随机日期）
            let daysAgo_glasspaint = Int.random(in: 0...180)
            let createdDate_glasspaint = calendar_glasspaint.date(byAdding: .day, value: -daysAgo_glasspaint, to: now_glasspaint) ?? now_glasspaint
            
            // 更新帖子属性
            dataLocal_glasspaint.titleList_Glasspaint[i_glasspaint].paintingLevel_Glasspaint = level_glasspaint
            dataLocal_glasspaint.titleList_Glasspaint[i_glasspaint].paintingStyle_Glasspaint = style_glasspaint
            dataLocal_glasspaint.titleList_Glasspaint[i_glasspaint].scene_Glasspaint = scene_glasspaint
            dataLocal_glasspaint.titleList_Glasspaint[i_glasspaint].carrier_Glasspaint = carrier_glasspaint
            dataLocal_glasspaint.titleList_Glasspaint[i_glasspaint].createdDate_Glasspaint = createdDate_glasspaint
        }
    }
    
    /// 初始化挑战数据
    /// 功能：生成官方挑战活动数据
    func initChallenges_Glasspaint() {
        guard let dataLocal_glasspaint = dataLocal_Glasspaint else { return }
        dataLocal_glasspaint.challengeList_Glasspaint.removeAll()
        
        let calendar_glasspaint = Calendar.current
        let now_glasspaint = Date()
        
        for (index_glasspaint, challengeInfo_glasspaint) in DataSource_Glasspaint.challengesInfo_Glasspaint.enumerated() {
            let (carrier_glasspaint, title_glasspaint, description_glasspaint) = challengeInfo_glasspaint
            
            // 设置挑战时间（开始日期：过去30天内，结束日期：未来30天内）
            let startDaysAgo_glasspaint = Int.random(in: 0...30)
            let startDate_glasspaint = calendar_glasspaint.date(byAdding: .day, value: -startDaysAgo_glasspaint, to: now_glasspaint) ?? now_glasspaint
            let endDate_glasspaint = calendar_glasspaint.date(byAdding: .day, value: 30, to: startDate_glasspaint) ?? now_glasspaint
            
            // 获取相关载体的作品（1-2个）
            let relatedPosts_glasspaint = dataLocal_glasspaint.titleList_Glasspaint
                .filter { $0.carrier_Glasspaint == carrier_glasspaint }
                .prefix(2)
            
            // 创建挑战
            let challenge_glasspaint = ChallengeModel_Glasspaint(
                challengeId_Glasspaint: index_glasspaint + 100,
                carrier_Glasspaint: carrier_glasspaint,
                challengeTitle_Glasspaint: title_glasspaint,
                challengeDescription_Glasspaint: description_glasspaint,
                participantCount_Glasspaint: Int.random(in: 50...500),
                posts_Glasspaint: Array(relatedPosts_glasspaint),
                startDate_Glasspaint: startDate_glasspaint,
                endDate_Glasspaint: endDate_glasspaint
            )
            
            dataLocal_glasspaint.challengeList_Glasspaint.append(challenge_glasspaint)
        }
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Glasspaint() {
        guard let dataLocal_glasspaint = dataLocal_Glasspaint else { return }
        
        for i_glasspaint in 0..<dataLocal_glasspaint.userList_Glasspaint.count {
            let user_glasspaint = dataLocal_glasspaint.userList_Glasspaint[i_glasspaint]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_glasspaint = dataLocal_glasspaint.getPostsExcludingUser_Glasspaint(
                userId_glasspaint: user_glasspaint.userId_Glasspaint ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_glasspaint = RandomUtil_Glasspaint.selectRandomItems_Glasspaint(
                from: availablePosts_glasspaint,
                count_glasspaint: DataConfig_Glasspaint.likePostCount_Glasspaint
            )
            
            dataLocal_glasspaint.userList_Glasspaint[i_glasspaint].userLike_Glasspaint = likePosts_glasspaint
        }
    }
    
    /// 初始化时间胶囊数据
    /// 功能：为每个用户生成一个预制的时间胶囊
    func initTimeCapsules_Glasspaint() {
        guard let dataLocal_glasspaint = dataLocal_Glasspaint else { return }
        dataLocal_glasspaint.timeCapsuleList_Glasspaint.removeAll()
        
        let calendar_glasspaint = Calendar.current
        let now_glasspaint = Date()
        
        // 为每个用户创建一个时间胶囊
        for (index_glasspaint, capsuleInfo_glasspaint) in DataSource_Glasspaint.timeCapsulesInfo_Glasspaint.enumerated() {
            guard index_glasspaint < dataLocal_glasspaint.userList_Glasspaint.count else { break }
            
            let (title_glasspaint, thoughts_glasspaint, story_glasspaint, imagePath_glasspaint, unlockYears_glasspaint) = capsuleInfo_glasspaint
            let user_glasspaint = dataLocal_glasspaint.userList_Glasspaint[index_glasspaint]
            
            // 创建日期：过去60-180天内
            let createdDaysAgo_glasspaint = Int.random(in: 60...180)
            let createdDate_glasspaint = calendar_glasspaint.date(byAdding: .day, value: -createdDaysAgo_glasspaint, to: now_glasspaint) ?? now_glasspaint
            
            // 解锁日期：从创建日期开始计算，但确保有一些已经解锁
            let unlockDate_glasspaint: Date
            if index_glasspaint < 2 {
                // 前两个已经解锁（解锁时间在过去）
                unlockDate_glasspaint = calendar_glasspaint.date(byAdding: .day, value: -Int.random(in: 1...30), to: now_glasspaint) ?? now_glasspaint
            } else {
                // 其余的未来解锁
                unlockDate_glasspaint = calendar_glasspaint.date(byAdding: .year, value: unlockYears_glasspaint, to: createdDate_glasspaint) ?? now_glasspaint
            }
            
            // 确定状态
            let status_glasspaint: TimeCapsuleStatus_Glasspaint = unlockDate_glasspaint <= now_glasspaint ? .unlocked_glasspaint : .locked_glasspaint
            
            // 创建时间胶囊
            let capsule_glasspaint = TimeCapsulePost_Glasspaint(
                title_Glasspaint: title_glasspaint,
                imagePaths_Glasspaint: [imagePath_glasspaint],
                creativeThoughts_Glasspaint: thoughts_glasspaint,
                story_Glasspaint: story_glasspaint,
                createdDate_Glasspaint: createdDate_glasspaint,
                unlockDate_Glasspaint: unlockDate_glasspaint,
                status_Glasspaint: status_glasspaint,
                userId_Glasspaint: user_glasspaint.userId_Glasspaint ?? 0,
                userName_Glasspaint: user_glasspaint.userName_Glasspaint ?? "User",
                paintingLevel_Glasspaint: user_glasspaint.paintingLevel_Glasspaint,
                paintingStyle_Glasspaint: user_glasspaint.preferredStyles_Glasspaint?.first,
                scene_Glasspaint: user_glasspaint.preferredScenes_Glasspaint?.first,
                carrier_Glasspaint: .glassCup_glasspaint
            )
            
            dataLocal_glasspaint.timeCapsuleList_Glasspaint.append(capsule_glasspaint)
        }
    }
}
