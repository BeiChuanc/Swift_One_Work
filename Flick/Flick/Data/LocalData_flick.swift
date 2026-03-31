import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Flick {
    /// ID起始值
    static let userIdStart_Flick = 10
    static let postIdStart_Flick = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Flick = 2
}

/// 本地数据管理类
class LocalData_Flick {
    
    /// 单例
    static let shared_Flick = LocalData_Flick()
    
    /// 用户列表
    var userList_Flick: [PrewUserModel_Flick] = []
    
    /// 帖子列表
    var titleList_Flick: [TitleModel_Flick] = []

    /// 官方半截碎念挑战列表（预设，不持久化）
    var halfChallenges_Flick: [HalfChallenge_Flick] = []
    
    /// 数据生成器
    private lazy var generator_Flick: DataGenerator_Flick = {
        return DataGenerator_Flick(dataLocal_flick: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Flick() {
        generator_Flick.initUsers_Flick()
        generator_Flick.initPosts_Flick()
        generator_Flick.setUserLikes_Flick()
        generator_Flick.initChallenges_Flick()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Flick(userId_flick: Int) -> [TitleModel_Flick] {
        return titleList_Flick.filter { $0.titleUserId_Flick != userId_flick }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Flick(postAuthorUserId_flick: Int) -> [PrewUserModel_Flick] {
        return userList_Flick.filter { $0.userId_Flick != postAuthorUserId_flick }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Flick {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Flick: [(String, String, String, String)] = [
        ("EmberSeeker", "Love exploring around bonfires", "head1", "head1"),
        ("ForestWhisper", "Nature enthusiast and storyteller", "head2", "head2"),
        ("FlameJumper", "Adventure seeker and fire dancer", "head3", "head3"),
        ("AshesToArt", "Turning moments into memories", "head4", "head4"),
        ("NightGlow", "Capturing the magic of firelight", "head5", "head5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)
    static let postsInfo_Flick: [(String, String, String)] = [
        ("Perfect Bonfire Night", "The bonfire crackles softly, wrapping every face in warm light; we pass around s'mores, and stories flow as freely as the laughter. This is the kind of night that stays with you long after the embers fade.", "title10"),
        ("Magical Firelight", "There's something magical about firelight—it turns ordinary moments into treasures. Sitting here, feeling the warmth on my hands and listening to friends chat, I realize happiness is just this simple.", "title9"),
        ("Dancing Flames", "The flames dance and flicker, casting gentle shadows on the grass. No loud noises, no rush—just the glow of fire, the breeze, and people who make the night feel like home.", "title8"),
        ("Warm Hearts", "As the night grows darker, the bonfire burns brighter. It's not just the fire that warms us, but the company, the shared smiles, and the quiet connection between every heart here.", "title7"),
        ("Glowing Memories", "Look at this glowing fire and the grinning faces around it—this is what good nights are made of! Tag the person you'd drag to sit with you by such a bonfire.", "title6"),
        ("Absolute Perfection", "Last night's bonfire was absolute perfection: great friends, crispy marshmallows, and a fire that burned steady till midnight. Who's got a bonfire story to top this?", "title5"),
        ("Fire Family", "I used to think bonfires were just about fire, but now I know it's about the people. This crew turned a simple fire into an unforgettable night.", "title4"),
        ("Fun Activities", "We spent hours around this bonfire: singing off-key, playing silly games, and even debating whether the fire is orange or red. What's your go-to bonfire activity?", "title3"),
        ("Stars and Fire", "Above us, the sky is dotted with stars; below us, the bonfire paints the night in warm hues. The universe feels so big, yet this little circle of fire and friends makes everything feel so close.", "title2"),
        ("Peaceful Embers", "Embers drift up like tiny fireflies, mixing with the stars in the dark. I sit here, quiet, and let the warmth seep into my bones—this is the peace I've been craving.", "title1"),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_Flick: [(String, String)] = [
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
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
/// 功能：提供各种随机数生成方法
private struct RandomUtil_Flick {
    
    /// 生成指定范围的随机整数
    static func nextInt_Flick(min_flick: Int, range_flick: Int) -> Int {
        return Int.random(in: min_flick..<(min_flick + range_flick))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Flick<T>(from list_flick: [T], count_flick: Int) -> [T] {
        guard !list_flick.isEmpty else { return [] }
        guard list_flick.count > count_flick else { return list_flick }
        
        var selected_flick: [T] = []
        var indices_flick: Set<Int> = []
        
        while selected_flick.count < count_flick && indices_flick.count < list_flick.count {
            let index_flick = Int.random(in: 0..<list_flick.count)
            if !indices_flick.contains(index_flick) {
                indices_flick.insert(index_flick)
                selected_flick.append(list_flick[index_flick])
            }
        }
        
        return selected_flick
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Flick {
    
    private weak var dataLocal_Flick: LocalData_Flick?
    
    init(dataLocal_flick: LocalData_Flick) {
        self.dataLocal_Flick = dataLocal_flick
    }
    
    /// 初始化生成用户数据
    func initUsers_Flick() {
        guard let dataLocal_flick = dataLocal_Flick else { return }
        dataLocal_flick.userList_Flick.removeAll()
        
        for (index_flick, userInfo_flick) in DataSource_Flick.usersInfo_Flick.enumerated() {
            let (username_flick, introduce_flick, userHead_flick, userAlbum_flick) = userInfo_flick
            
            let user_flick = PrewUserModel_Flick()
            user_flick.userId_Flick = index_flick + DataConfig_Flick.userIdStart_Flick
            user_flick.userName_Flick = username_flick
            user_flick.userIntroduce_Flick = introduce_flick
            user_flick.userHead_Flick = userHead_flick
            user_flick.userMedia_Flick = [userAlbum_flick]
            user_flick.userLike_Flick = []
            user_flick.userFollow_Flick = 15 + Int.random(in: 1...50)
            user_flick.userFans_Flick = 20 + Int.random(in: 1...50)
            
            dataLocal_flick.userList_Flick.append(user_flick)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Flick() {
        guard let dataLocal_flick = dataLocal_Flick else { return }
        dataLocal_flick.titleList_Flick.removeAll()
        
        for (index_flick, postInfo_flick) in DataSource_Flick.postsInfo_Flick.enumerated() {
            let (title_flick, content_flick, media_flick) = postInfo_flick
            
            // 循环分配作者
            let authorIndex_flick = index_flick % dataLocal_flick.userList_Flick.count
            guard authorIndex_flick < dataLocal_flick.userList_Flick.count else { continue }
            let author_flick = dataLocal_flick.userList_Flick[authorIndex_flick]
            
            // 生成评论
            let comments_flick = generateComments_Flick(
                postIndex_flick: index_flick,
                postAuthorUserId_flick: author_flick.userId_Flick ?? 0
            )
            
            // 创建帖子
            let post_flick = TitleModel_Flick(
                titleId_Flick: index_flick + DataConfig_Flick.postIdStart_Flick,
                titleUserId_Flick: author_flick.userId_Flick ?? 0,
                titleUserName_Flick: author_flick.userName_Flick ?? "",
                titleMeidas_Flick: [media_flick],
                title_Flick: title_flick,
                titleContent_Flick: content_flick,
                reviews_Flick: comments_flick,
                likes_Flick: RandomUtil_Flick.nextInt_Flick(min_flick: 10, range_flick: 150)
            )
            
            dataLocal_flick.titleList_Flick.append(post_flick)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Flick(postIndex_flick: Int, postAuthorUserId_flick: Int) -> [Comment_Flick] {
        guard let dataLocal_flick = dataLocal_Flick else { return [] }
        
        let availableUsers_flick = dataLocal_flick.getAvailableCommenters_Flick(postAuthorUserId_flick: postAuthorUserId_flick)
        guard availableUsers_flick.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_flick = availableUsers_flick[postIndex_flick % availableUsers_flick.count]
        let commenter2_flick = availableUsers_flick[(postIndex_flick + 1) % availableUsers_flick.count]
        
        // 获取评论内容
        let commentIndex_flick = postIndex_flick % DataSource_Flick.comments_Flick.count
        let (comment1_flick, comment2_flick) = DataSource_Flick.comments_Flick[commentIndex_flick]
        
        return [
            Comment_Flick(
                commentId_Flick: postIndex_flick * 2 + 1,
                commentUserId_Flick: commenter1_flick.userId_Flick ?? 0,
                commentUserName_Flick: commenter1_flick.userName_Flick ?? "",
                commentContent_Flick: comment1_flick
            ),
            Comment_Flick(
                commentId_Flick: postIndex_flick * 2 + 2,
                commentUserId_Flick: commenter2_flick.userId_Flick ?? 0,
                commentUserName_Flick: commenter2_flick.userName_Flick ?? "",
                commentContent_Flick: comment2_flick
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Flick() {
        guard let dataLocal_flick = dataLocal_Flick else { return }
        
        for i_flick in 0..<dataLocal_flick.userList_Flick.count {
            let user_flick = dataLocal_flick.userList_Flick[i_flick]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_flick = dataLocal_flick.getPostsExcludingUser_Flick(
                userId_flick: user_flick.userId_Flick ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_flick = RandomUtil_Flick.selectRandomItems_Flick(
                from: availablePosts_flick,
                count_flick: DataConfig_Flick.likePostCount_Flick
            )
            
            dataLocal_flick.userList_Flick[i_flick].userLike_Flick = likePosts_flick
        }
    }

    /// 初始化官方半截碎念挑战预设数据
    func initChallenges_Flick() {
        guard let dataLocal_flick = dataLocal_Flick else { return }
        let users_flick = dataLocal_flick.userList_Flick
        // 为每条挑战生成 2 条预设补全
        func makeCompletions_Flick(idx_flick: Int, texts_flick: (String, String)) -> [Comment_Flick] {
            guard users_flick.count >= 2 else { return [] }
            let u1_flick = users_flick[idx_flick % users_flick.count]
            let u2_flick = users_flick[(idx_flick + 2) % users_flick.count]
            return [
                Comment_Flick(commentId_Flick: 9000 + idx_flick * 2,
                              commentUserId_Flick: u1_flick.userId_Flick ?? 0,
                              commentUserName_Flick: u1_flick.userName_Flick ?? "",
                              commentContent_Flick: texts_flick.0),
                Comment_Flick(commentId_Flick: 9001 + idx_flick * 2,
                              commentUserId_Flick: u2_flick.userId_Flick ?? 0,
                              commentUserName_Flick: u2_flick.userName_Flick ?? "",
                              commentContent_Flick: texts_flick.1),
            ]
        }
        dataLocal_flick.halfChallenges_Flick = [
            HalfChallenge_Flick(
                challengeId_Flick: "hc_001",
                firstHalf_Flick: "Life is like a campfire, ___",
                tag_Flick: "Life",
                publishDate_Flick: "Mar 28",
                completions_Flick: makeCompletions_Flick(
                    idx_flick: 0,
                    texts_flick: ("it only burns bright when you gather the right people around it.",
                                  "beautiful until the wind reminds you nothing lasts forever.")
                )
            ),
            HalfChallenge_Flick(
                challengeId_Flick: "hc_002",
                firstHalf_Flick: "The things I keep to myself at 3 AM are ___",
                tag_Flick: "Midnight",
                publishDate_Flick: "Mar 27",
                completions_Flick: makeCompletions_Flick(
                    idx_flick: 1,
                    texts_flick: ("the truest version of me no one ever gets to meet.",
                                  "softer than anything I say out loud.")
                )
            ),
            HalfChallenge_Flick(
                challengeId_Flick: "hc_003",
                firstHalf_Flick: "I realized I was growing up the moment ___",
                tag_Flick: "Growth",
                publishDate_Flick: "Mar 26",
                completions_Flick: makeCompletions_Flick(
                    idx_flick: 2,
                    texts_flick: ("silence started to feel louder than noise.",
                                  "I stopped asking for permission to feel my feelings.")
                )
            ),
            HalfChallenge_Flick(
                challengeId_Flick: "hc_004",
                firstHalf_Flick: "Love is the strangest thing because ___",
                tag_Flick: "Love",
                publishDate_Flick: "Mar 25",
                completions_Flick: makeCompletions_Flick(
                    idx_flick: 3,
                    texts_flick: ("it makes the unbearable feel like home.",
                                  "you never know if you're brave or just terrified.")
                )
            ),
        ]
    }
}
