import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Moode {
    /// ID起始值
    static let userIdStart_Moode = 10
    static let postIdStart_Moode = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Moode = 2
}

/// 本地数据管理类
class LocalData_Moode {
    
    /// 单例
    static let shared_Moode = LocalData_Moode()
    
    /// 用户列表
    var userList_Moode: [PrewUserModel_Moode] = []
    
    /// 全部帖子列表（普通帖子 + 情绪帖子）
    var titleList_Moode: [TitleModel_Moode] = []

    /// 情绪帖子列表（首页情绪流专用，postType == .mood_moode）
    var moodTitleList_Moode: [TitleModel_Moode] = []
    
    /// 数据生成器
    private lazy var generator_Moode: DataGenerator_Moode = {
        return DataGenerator_Moode(dataLocal_moode: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Moode() {
        generator_Moode.initUsers_Moode()
        generator_Moode.initPosts_Moode()
        generator_Moode.initMoodPosts_Moode()
        generator_Moode.setUserLikes_Moode()
    }
    
    /// 情绪挑战列表（官方 + 社区）
    let challengeList_Moode: [MoodChallenge_Moode] = DataSource_Moode.challenges_Moode

    /// 挑战评论预制数据：key 为 challengeId，value 为 2 条评论
    lazy var challengeComments_Moode: [Int: [Comment_Moode]] = {
        var dict_moode: [Int: [Comment_Moode]] = [:]
        let users_moode = userList_Moode
        guard users_moode.count >= 2 else { return dict_moode }
        let commentPairs_moode = DataSource_Moode.challengeComments_Moode
        for challenge_moode in challengeList_Moode {
            let idx_moode = (challenge_moode.challengeId_Moode - 1) % commentPairs_moode.count
            let u1_moode = users_moode[idx_moode % users_moode.count]
            let u2_moode = users_moode[(idx_moode + 1) % users_moode.count]
            let (c1_moode, c2_moode) = commentPairs_moode[idx_moode]
            dict_moode[challenge_moode.challengeId_Moode] = [
                Comment_Moode(
                    commentId_Moode: 9000 + challenge_moode.challengeId_Moode * 2,
                    commentUserId_Moode: u1_moode.userId_Moode ?? 0,
                    commentUserName_Moode: u1_moode.userName_Moode ?? "User",
                    commentContent_Moode: c1_moode
                ),
                Comment_Moode(
                    commentId_Moode: 9000 + challenge_moode.challengeId_Moode * 2 + 1,
                    commentUserId_Moode: u2_moode.userId_Moode ?? 0,
                    commentUserName_Moode: u2_moode.userName_Moode ?? "User",
                    commentContent_Moode: c2_moode
                )
            ]
        }
        return dict_moode
    }()

    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Moode(userId_moode: Int) -> [TitleModel_Moode] {
        return titleList_Moode.filter { $0.titleUserId_Moode != userId_moode }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Moode(postAuthorUserId_moode: Int) -> [PrewUserModel_Moode] {
        return userList_Moode.filter { $0.userId_Moode != postAuthorUserId_moode }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Moode {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Moode: [(String, String, String, String)] = [
        ("EmberSeeker", "Love exploring around bonfires", "user_head_1", "user_album_1"),
        ("ForestWhisper", "Nature enthusiast and storyteller", "user_head_2", "user_album_2"),
        ("FlameJumper", "Adventure seeker and fire dancer", "user_head_3", "user_album_3"),
        ("AshesToArt", "Turning moments into memories", "user_head_4", "user_album_4"),
        ("NightGlow", "Capturing the magic of firelight", "user_head_5", "user_album_5"),
    ]
    
    /// 普通帖子信息列表（无情绪标签）(标题, 内容, 媒体URL)
    static let postsInfo_Moode: [(String, String, String)] = [
        ("Perfect Bonfire Night", "The bonfire crackles softly, wrapping every face in warm light; we pass around s'mores, and stories flow as freely as the laughter. This is the kind of night that stays with you long after the embers fade.", "post_media_1"),
        ("Magical Firelight", "There's something magical about firelight—it turns ordinary moments into treasures. Sitting here, feeling the warmth on my hands and listening to friends chat, I realize happiness is just this simple.", "post_media_2"),
        ("Dancing Flames", "The flames dance and flicker, casting gentle shadows on the grass. No loud noises, no rush—just the glow of fire, the breeze, and people who make the night feel like home.", "post_media_3"),
        ("Warm Hearts", "As the night grows darker, the bonfire burns brighter. It's not just the fire that warms us, but the company, the shared smiles, and the quiet connection between every heart here.", "post_media_4"),
        ("Glowing Memories", "Look at this glowing fire and the grinning faces around it—this is what good nights are made of! Tag the person you'd drag to sit with you by such a bonfire.", "post_media_5"),
        ("Absolute Perfection", "Last night's bonfire was absolute perfection: great friends, crispy marshmallows, and a fire that burned steady till midnight. Who's got a bonfire story to top this?", "post_media_6"),
        ("Fire Family", "I used to think bonfires were just about fire, but now I know it's about the people. This crew turned a simple fire into an unforgettable night.", "post_media_7"),
        ("Fun Activities", "We spent hours around this bonfire: singing off-key, playing silly games, and even debating whether the fire is orange or red. What's your go-to bonfire activity?", "post_media_8"),
        ("Stars and Fire", "Above us, the sky is dotted with stars; below us, the bonfire paints the night in warm hues. The universe feels so big, yet this little circle of fire and friends makes everything feel so close.", "post_media_9"),
        ("Peaceful Embers", "Embers drift up like tiny fireflies, mixing with the stars in the dark. I sit here, quiet, and let the warmth seep into my bones—this is the peace I've been craving.", "post_media_10"),
    ]

    /// 情绪帖子信息列表（携带情绪标签，用于首页情绪流展示）(标题, 内容, 媒体URL, 情绪类型)
    static let moodPostsInfo_Moode: [(String, String, String, MoodType_Moode)] = [
        ("Gratitude in the Little Things",
         "Today I paused to notice the warmth of sunlight on my hands, the smell of my morning coffee, the sound of birds outside my window. These tiny moments—when you actually stop to feel them—hold such profound peace.",
         "mood_media_1", .grateful_moode),
        ("Riding the Wave of Excitement",
         "There's this buzzing energy coursing through me right now, like electricity in my fingertips. Big things are coming, and I can feel it in every heartbeat. This is what being truly alive feels like.",
         "mood_media_2", .excited_moode),
        ("Wrapped in Calm",
         "The world outside is loud and fast, but here, in this quiet corner of my day, I feel still. Not numb—just peacefully present. Breathing in, breathing out. This stillness is enough.",
         "mood_media_3", .calm_moode),
        ("Letting the Sadness Flow",
         "Some days feel heavier than others. Today, I'm sitting with my sadness instead of fighting it. It's okay to feel this. Sadness means something mattered. I'll let it pass through gently.",
         "mood_media_4", .sad_moode),
        ("Burst of Pure Joy",
         "Unexpected laughter erupted from somewhere deep today—the kind that makes your eyes water and your stomach hurt. I don't even remember what started it. But for a few perfect minutes, nothing else existed.",
         "mood_media_5", .joy_moode),
        ("Surprised by Beauty",
         "I turned a corner and the sky was this impossible shade of violet and gold, and for a moment the world just stopped. Sometimes beauty hits you so suddenly, so completely, it almost hurts.",
         "mood_media_6", .surprised_moode),
    ]
    
    /// 情绪挑战列表（官方/社区，含极简社区记录）
    static let challenges_Moode: [MoodChallenge_Moode] = [
        MoodChallenge_Moode(
            challengeId_Moode: 1,
            title_Moode: "Healing Flow",
            emoji_Moode: "🌿",
            moodType_Moode: .calm_moode,
            isOfficial_Moode: true,
            records_Moode: [
                "Sat by the window with tea, watching rain.",
                "Drew something random — felt surprisingly light."
            ],
            participantCount_Moode: 2841
        ),
        MoodChallenge_Moode(
            challengeId_Moode: 2,
            title_Moode: "Still Waters",
            emoji_Moode: "🪷",
            moodType_Moode: .calm_moode,
            isOfficial_Moode: true,
            records_Moode: [
                "Turned off notifications and just breathed.",
                "Five minutes of silence — it was enough."
            ],
            participantCount_Moode: 1763
        ),
        MoodChallenge_Moode(
            challengeId_Moode: 3,
            title_Moode: "Let It Go",
            emoji_Moode: "🍂",
            moodType_Moode: .sad_moode,
            isOfficial_Moode: true,
            records_Moode: [
                "Wrote it down, then closed the book.",
                "Cried a little. It was okay."
            ],
            participantCount_Moode: 3210
        ),
        MoodChallenge_Moode(
            challengeId_Moode: 4,
            title_Moode: "Sunrise Energy",
            emoji_Moode: "🌅",
            moodType_Moode: .excited_moode,
            isOfficial_Moode: false,
            records_Moode: [
                "Woke before the alarm — started dancing.",
                "Made coffee, watched the sky turn pink."
            ],
            participantCount_Moode: 987
        ),
        MoodChallenge_Moode(
            challengeId_Moode: 5,
            title_Moode: "Gratitude Jar",
            emoji_Moode: "🫙",
            moodType_Moode: .grateful_moode,
            isOfficial_Moode: true,
            records_Moode: [
                "One small thing: my favorite mug.",
                "Grateful for soft blankets and quiet evenings."
            ],
            participantCount_Moode: 4102
        ),
        MoodChallenge_Moode(
            challengeId_Moode: 6,
            title_Moode: "Gentle Joy",
            emoji_Moode: "🌸",
            moodType_Moode: .joy_moode,
            isOfficial_Moode: false,
            records_Moode: [
                "Laughed at something silly for five minutes.",
                "Sent a good-morning text — got three back."
            ],
            participantCount_Moode: 1544
        ),
    ]

    /// 评论列表 (评论1, 评论2)
    /// 前10对对应普通帖子，后6对对应情绪帖子
    static let comments_Moode: [(String, String)] = [
        // 普通帖子评论
        ("This looks absolutely magical! Nothing beats a bonfire with good friends", "S'mores and stories by the fire—that's the perfect night right there!"),
        ("You captured the essence of what makes bonfires special! Love this vibe", "The simplicity of firelight and friendship is truly magical. Beautiful moment!"),
        ("Those dancing flames and peaceful vibes—I can feel the warmth through the screen!", "This is exactly what I needed to see today. Time to plan a bonfire night!"),
        ("The connection between hearts around a fire is something special. Beautifully said!", "Love how you describe the warmth coming from both the fire and the company"),
        ("Already know who I'd tag for this! Nothing beats bonfire nights with the right people", "First thing I'd share? Probably my terrible ghost stories! Who's with me?"),
        ("Our bonfire story: We accidentally used green wood and it wouldn't stop smoking!", "Crispy marshmallows till midnight sounds perfect! Need to organize one soon"),
        ("Your fire family sounds amazing! Count me in for round two", "It really is all about the people. The fire is just an excuse to gather!"),
        ("Off-key singing is mandatory at our bonfires too! Also love the fire color debate", "My go-to activity: trying to roast the perfect marshmallow"),
        ("The stars above and fire below—this is poetry in real life!", "That feeling of the universe being big yet feeling so close... perfectly captured!"),
        ("The embers mixing with stars is such a beautiful image. Pure peace", "Sometimes we just need warmth seeping into our bones and quiet moments"),
        // 情绪帖子评论
        ("This completely changed my perspective on my morning routine", "Gratitude really does shift everything—beautifully expressed!"),
        ("That electric feeling you describe—I know it so well!", "Chasing that feeling is what gets me out of bed every morning"),
        ("This is exactly the reminder I needed today. Breathe and be still.", "There's so much power in choosing stillness over chaos"),
        ("Thank you for being brave enough to share this. Feeling it is healing it.", "Being gentle with sadness is such a beautiful form of self-love"),
        ("The best laughs are always the unexpected ones! This is pure gold.", "This made me smile so hard — laughter really is the best medicine"),
        ("Those accidental moments of beauty are life's greatest gifts", "I needed this reminder to look up and around more often. So beautiful!"),
    ]

    /// 挑战专属评论预制数据（每个挑战 2 条，与 challenges_Moode 一一对应）
    static let challengeComments_Moode: [(String, String)] = [
        // Healing Flow
        ("This challenge helped me find my flow again — highly recommend!", "Tea and rain are my new healing ritual after joining this 🌿"),
        // Still Waters
        ("Five minutes of silence changed my whole day. Thank you for this!", "I turned off every notification and felt the tension just melt away."),
        // Let It Go
        ("Writing it down and closing the book — that was surprisingly healing.", "Letting go is hard but this challenge made it feel possible 🍂"),
        // Sunrise Energy
        ("Best morning I've had in months. Sunrise energy is real!", "Made my coffee, watched the sky turn pink — joined this and never looked back."),
        // Gratitude Jar
        ("My gratitude jar is almost full and my heart feels lighter every day 🫙", "Starting with one small thing made gratitude feel so achievable."),
        // Gentle Joy
        ("Sent a silly meme to my friend and we laughed for an hour. Gentle joy wins!", "This challenge reminded me that joy doesn't have to be grand 🌸"),
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
/// 功能：提供各种随机数生成方法
private struct RandomUtil_Moode {
    
    /// 生成指定范围的随机整数
    static func nextInt_Moode(min_moode: Int, range_moode: Int) -> Int {
        return Int.random(in: min_moode..<(min_moode + range_moode))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Moode<T>(from list_moode: [T], count_moode: Int) -> [T] {
        guard !list_moode.isEmpty else { return [] }
        guard list_moode.count > count_moode else { return list_moode }
        
        var selected_moode: [T] = []
        var indices_moode: Set<Int> = []
        
        while selected_moode.count < count_moode && indices_moode.count < list_moode.count {
            let index_moode = Int.random(in: 0..<list_moode.count)
            if !indices_moode.contains(index_moode) {
                indices_moode.insert(index_moode)
                selected_moode.append(list_moode[index_moode])
            }
        }
        
        return selected_moode
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Moode {
    
    private weak var dataLocal_Moode: LocalData_Moode?
    
    init(dataLocal_moode: LocalData_Moode) {
        self.dataLocal_Moode = dataLocal_moode
    }
    
    /// 初始化生成用户数据
    func initUsers_Moode() {
        guard let dataLocal_moode = dataLocal_Moode else { return }
        dataLocal_moode.userList_Moode.removeAll()
        
        for (index_moode, userInfo_moode) in DataSource_Moode.usersInfo_Moode.enumerated() {
            let (username_moode, introduce_moode, userHead_moode, userAlbum_moode) = userInfo_moode
            
            let user_moode = PrewUserModel_Moode()
            user_moode.userId_Moode = index_moode + DataConfig_Moode.userIdStart_Moode
            user_moode.userName_Moode = username_moode
            user_moode.userIntroduce_Moode = introduce_moode
            user_moode.userHead_Moode = userHead_moode
            user_moode.userMedia_Moode = [userAlbum_moode]
            user_moode.userLike_Moode = []
            user_moode.userFollow_Moode = 15 + Int.random(in: 1...50)
            user_moode.userFans_Moode = 20 + Int.random(in: 1...50)
            
            dataLocal_moode.userList_Moode.append(user_moode)
        }
    }
    
    /// 初始化生成普通帖子数据（postType = .normal_moode，无情绪标签）
    func initPosts_Moode() {
        guard let dataLocal_moode = dataLocal_Moode else { return }
        dataLocal_moode.titleList_Moode.removeAll()

        for (index_moode, postInfo_moode) in DataSource_Moode.postsInfo_Moode.enumerated() {
            let (title_moode, content_moode, media_moode) = postInfo_moode

            // 循环分配作者
            let authorIndex_moode = index_moode % dataLocal_moode.userList_Moode.count
            guard authorIndex_moode < dataLocal_moode.userList_Moode.count else { continue }
            let author_moode = dataLocal_moode.userList_Moode[authorIndex_moode]

            // 生成评论（使用前10对）
            let comments_moode = generateComments_Moode(
                postIndex_moode: index_moode,
                postAuthorUserId_moode: author_moode.userId_Moode ?? 0
            )

            // 创建普通帖子（不携带情绪类型）
            let post_moode = TitleModel_Moode(
                titleId_Moode: index_moode + DataConfig_Moode.postIdStart_Moode,
                titleUserId_Moode: author_moode.userId_Moode ?? 0,
                titleUserName_Moode: author_moode.userName_Moode ?? "",
                titleMeidas_Moode: [media_moode],
                title_Moode: title_moode,
                titleContent_Moode: content_moode,
                reviews_Moode: comments_moode,
                likes_Moode: RandomUtil_Moode.nextInt_Moode(min_moode: 10, range_moode: 150),
                postType_Moode: .normal_moode
            )

            dataLocal_moode.titleList_Moode.append(post_moode)
        }
    }

    /// 初始化生成情绪帖子数据（postType = .mood_moode，携带情绪标签，用于首页情绪流）
    func initMoodPosts_Moode() {
        guard let dataLocal_moode = dataLocal_Moode else { return }
        dataLocal_moode.moodTitleList_Moode.removeAll()

        // 情绪帖子 ID 接在普通帖子之后
        let idOffset_moode = DataConfig_Moode.postIdStart_Moode + DataSource_Moode.postsInfo_Moode.count

        for (index_moode, postInfo_moode) in DataSource_Moode.moodPostsInfo_Moode.enumerated() {
            let (title_moode, content_moode, media_moode, moodType_moode) = postInfo_moode

            // 循环分配作者
            let authorIndex_moode = index_moode % dataLocal_moode.userList_Moode.count
            guard authorIndex_moode < dataLocal_moode.userList_Moode.count else { continue }
            let author_moode = dataLocal_moode.userList_Moode[authorIndex_moode]

            // 生成评论（使用后6对，偏移量为普通帖子评论数量）
            let commentOffset_moode = DataSource_Moode.postsInfo_Moode.count + index_moode
            let comments_moode = generateComments_Moode(
                postIndex_moode: commentOffset_moode,
                postAuthorUserId_moode: author_moode.userId_Moode ?? 0
            )

            // 创建情绪帖子（携带情绪类型）
            let post_moode = TitleModel_Moode(
                titleId_Moode: index_moode + idOffset_moode,
                titleUserId_Moode: author_moode.userId_Moode ?? 0,
                titleUserName_Moode: author_moode.userName_Moode ?? "",
                titleMeidas_Moode: [media_moode],
                title_Moode: title_moode,
                titleContent_Moode: content_moode,
                reviews_Moode: comments_moode,
                likes_Moode: RandomUtil_Moode.nextInt_Moode(min_moode: 20, range_moode: 200),
                postType_Moode: .mood_moode,
                moodType_Moode: moodType_moode
            )

            dataLocal_moode.moodTitleList_Moode.append(post_moode)
            // 同时加入全量列表，方便统一查询
            dataLocal_moode.titleList_Moode.append(post_moode)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Moode(postIndex_moode: Int, postAuthorUserId_moode: Int) -> [Comment_Moode] {
        guard let dataLocal_moode = dataLocal_Moode else { return [] }
        
        let availableUsers_moode = dataLocal_moode.getAvailableCommenters_Moode(postAuthorUserId_moode: postAuthorUserId_moode)
        guard availableUsers_moode.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_moode = availableUsers_moode[postIndex_moode % availableUsers_moode.count]
        let commenter2_moode = availableUsers_moode[(postIndex_moode + 1) % availableUsers_moode.count]
        
        // 获取评论内容
        let commentIndex_moode = postIndex_moode % DataSource_Moode.comments_Moode.count
        let (comment1_moode, comment2_moode) = DataSource_Moode.comments_Moode[commentIndex_moode]
        
        return [
            Comment_Moode(
                commentId_Moode: postIndex_moode * 2 + 1,
                commentUserId_Moode: commenter1_moode.userId_Moode ?? 0,
                commentUserName_Moode: commenter1_moode.userName_Moode ?? "",
                commentContent_Moode: comment1_moode
            ),
            Comment_Moode(
                commentId_Moode: postIndex_moode * 2 + 2,
                commentUserId_Moode: commenter2_moode.userId_Moode ?? 0,
                commentUserName_Moode: commenter2_moode.userName_Moode ?? "",
                commentContent_Moode: comment2_moode
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Moode() {
        guard let dataLocal_moode = dataLocal_Moode else { return }
        
        for i_moode in 0..<dataLocal_moode.userList_Moode.count {
            let user_moode = dataLocal_moode.userList_Moode[i_moode]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_moode = dataLocal_moode.getPostsExcludingUser_Moode(
                userId_moode: user_moode.userId_Moode ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_moode = RandomUtil_Moode.selectRandomItems_Moode(
                from: availablePosts_moode,
                count_moode: DataConfig_Moode.likePostCount_Moode
            )
            
            dataLocal_moode.userList_Moode[i_moode].userLike_Moode = likePosts_moode
        }
    }
}
