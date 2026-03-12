import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Doze {
    /// ID起始值
    static let userIdStart_Doze = 10
    static let postIdStart_Doze = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Doze = 2
}

/// 本地数据管理类
class LocalData_Doze {
    
    /// 单例
    static let shared_Doze = LocalData_Doze()
    
    /// 用户列表
    var userList_Doze: [PrewUserModel_Doze] = []
    
    /// 帖子列表
    var titleList_Doze: [TitleModel_Doze] = []
    
    /// 数据生成器
    private lazy var generator_Doze: DataGenerator_Doze = {
        return DataGenerator_Doze(dataLocal_doze: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Doze() {
        generator_Doze.initUsers_Doze()
        generator_Doze.initPosts_Doze()
        generator_Doze.setUserLikes_Doze()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Doze(userId_doze: Int) -> [TitleModel_Doze] {
        return titleList_Doze.filter { $0.titleUserId_Doze != userId_doze }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Doze(postAuthorUserId_doze: Int) -> [PrewUserModel_Doze] {
        return userList_Doze.filter { $0.userId_Doze != postAuthorUserId_doze }
    }
}

// MARK: - 静态数据源

/// 静态数据源类（宠物睡眠观察主题）
private struct DataSource_Doze {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Doze: [(String, String, String, String)] = [
        ("PawKeeper", "Dedicated cat parent tracking Luna's every snooze", "head1", "head1"),
        ("DreamyTails", "Dog mom obsessed with sleep patterns and cozy naps", "head2", "head2"),
        ("WhiskerWatch", "Certified crazy cat person & amateur sleep scientist", "head3", "head3"),
        ("NapGuardian", "Bunny dad who monitors every twitch and flop", "head4", "head4"),
        ("ZzzzLogger", "Bird owner fascinated by feathered sleep rituals", "head5", "head5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL, 宠物类别)
    static let postsInfo_Doze: [(String, String, String, PetCategory_Doze)] = [
        ("Luna's Deep Sleep Mode",
         "Luna has been in deep sleep for 3 hours straight—paws tucked in, barely moving, breathing so softly I had to double-check she was okay. Her sleep quality tracker shows 94% deep sleep. Honestly, I'm a little jealous.",
         "title1", .cat_doze),
        
        ("Buddy's Midday Nap Ritual",
         "Every day at 2 PM, Buddy finds the sunniest patch on the floor and flops down for his nap. Today I timed it: 47 minutes of blissful, twitchy-leg dog sleep. He must be chasing squirrels in his dreams again.",
         "title2", .dog_doze),
        
        ("Mochi's Sleep Flop",
         "Mochi did the full dead-bunny flop today—just toppled sideways mid-groom and was out cold. First time owners panic when bunnies do this, but it means they feel totally safe and relaxed. Pure trust.",
         "title3", .rabbit_doze),
        
        ("Kiwi's One-Legged Snooze",
         "Caught Kiwi sleeping on one leg again, head tucked deep into his feathers. Bird sleep is fascinating—one brain hemisphere stays alert while the other rests. Half asleep, fully adorable.",
         "title4", .bird_doze),
        
        ("Whisker's 5-Hour Marathon",
         "Whisker broke her personal record today: 5 hours 12 minutes of uninterrupted sleep. She shifted positions exactly three times and produced the loudest purr at hour two. Sleep quality: legendary.",
         "title5", .cat_doze),
        
        ("Max's Post-Walk Knockout",
         "After our morning hike, Max came home and didn't even make it to his bed—just crashed on the mat by the door and was snoring within 60 seconds. Sleep efficiency rating: 10/10.",
         "title6", .dog_doze),
        
        ("Coco's Synchronized Nap",
         "Coco actually fell asleep in perfect sync with me during my afternoon rest. We both woke up 20 minutes later. I think my rabbit has developed a sense of my sleep schedule. Truly bonded.",
         "title7", .rabbit_doze),
        
        ("Sunny's Midnight Lullaby",
         "At 11 PM, Sunny starts his pre-sleep routine: soft chirps, feather fluffing, then silence. By 11:15 he's completely out. I've started going to bed earlier just to match his schedule.",
         "title8", .bird_doze),
        
        ("Nala's Healing Purr Session",
         "Nala slept on my chest for two hours straight. Her purring measured 25 Hz—right in the healing frequency range. My back pain feels better. Science says cat purrs can reduce stress and promote healing.",
         "title9", .cat_doze),
        
        ("Bear's Thunderstorm Sleep",
         "A huge thunderstorm rolled through last night. Bear, my normally anxious husky, crawled under the covers, pressed against my legs, and slept deeply through the whole thing. Best night ever logged.",
         "title10", .dog_doze),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_Doze: [(String, String)] = [
        ("Luna's sleep stats are incredible! My cat barely manages 2 hours before zooming", "94% deep sleep? That's better than any human I know. Teach us your ways, Luna"),
        ("Buddy's nap schedule is more consistent than my work calendar honestly", "The twitchy legs during naps are the cutest thing. Definitely chasing squirrels!"),
        ("The dead flop scared me so much the first time. Now I know it means pure happiness", "Mochi looks so peaceful. Flopped bunnies are the ultimate sign of trust and safety"),
        ("Bird sleep is genuinely fascinating! Half the brain awake is such a cool adaptation", "Kiwi's one-leg pose is iconic. My parakeet does the same thing every evening"),
        ("5 hours 12 minutes! Whisker is living her best life. Goals honestly", "The record-breaking purr at hour two is hilarious. She was dreaming of something good"),
        ("Max's doormat crash is peak tired dog energy. So relatable after a long hike!", "60 seconds from walk to snore is impressive. Must be some kind of talent"),
        ("Synchronized napping with your pet is the ultimate bond. This is so wholesome!", "Coco matching your schedule is honestly the sweetest thing I've read all week"),
        ("Sunny's 11 PM routine is so structured! My bird has zero concept of bedtime", "Going to bed earlier to match your bird's sleep schedule is completely valid and cute"),
        ("Healing purr frequencies are real! Cat ownership is basically free therapy", "25 Hz purrs are scientifically proven to reduce anxiety. Nala is literally medicinal"),
        ("Bear sleeping through a thunderstorm pressed against you is the absolute dream", "Anxious dog + thunderstorm + cozy sleep is the character development arc we needed"),
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
/// 功能：提供各种随机数生成方法
private struct RandomUtil_Doze {
    
    /// 生成指定范围的随机整数
    static func nextInt_Doze(min_doze: Int, range_doze: Int) -> Int {
        return Int.random(in: min_doze..<(min_doze + range_doze))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Doze<T>(from list_doze: [T], count_doze: Int) -> [T] {
        guard !list_doze.isEmpty else { return [] }
        guard list_doze.count > count_doze else { return list_doze }
        
        var selected_doze: [T] = []
        var indices_doze: Set<Int> = []
        
        while selected_doze.count < count_doze && indices_doze.count < list_doze.count {
            let index_doze = Int.random(in: 0..<list_doze.count)
            if !indices_doze.contains(index_doze) {
                indices_doze.insert(index_doze)
                selected_doze.append(list_doze[index_doze])
            }
        }
        
        return selected_doze
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Doze {
    
    private weak var dataLocal_Doze: LocalData_Doze?
    
    init(dataLocal_doze: LocalData_Doze) {
        self.dataLocal_Doze = dataLocal_doze
    }
    
    /// 初始化生成用户数据
    func initUsers_Doze() {
        guard let dataLocal_doze = dataLocal_Doze else { return }
        dataLocal_doze.userList_Doze.removeAll()
        
        for (index_doze, userInfo_doze) in DataSource_Doze.usersInfo_Doze.enumerated() {
            let (username_doze, introduce_doze, userHead_doze, userAlbum_doze) = userInfo_doze
            
            let user_doze = PrewUserModel_Doze()
            user_doze.userId_Doze = index_doze + DataConfig_Doze.userIdStart_Doze
            user_doze.userName_Doze = username_doze
            user_doze.userIntroduce_Doze = introduce_doze
            user_doze.userHead_Doze = userHead_doze
            user_doze.userMedia_Doze = [userAlbum_doze]
            user_doze.userLike_Doze = []
            user_doze.userFollow_Doze = 15 + Int.random(in: 1...50)
            user_doze.userFans_Doze = 20 + Int.random(in: 1...50)
            
            dataLocal_doze.userList_Doze.append(user_doze)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Doze() {
        guard let dataLocal_doze = dataLocal_Doze else { return }
        dataLocal_doze.titleList_Doze.removeAll()
        
        for (index_doze, postInfo_doze) in DataSource_Doze.postsInfo_Doze.enumerated() {
            let (title_doze, content_doze, media_doze, category_doze) = postInfo_doze
            
            // 循环分配作者
            let authorIndex_doze = index_doze % dataLocal_doze.userList_Doze.count
            guard authorIndex_doze < dataLocal_doze.userList_Doze.count else { continue }
            let author_doze = dataLocal_doze.userList_Doze[authorIndex_doze]
            
            // 生成评论
            let comments_doze = generateComments_Doze(
                postIndex_doze: index_doze,
                postAuthorUserId_doze: author_doze.userId_Doze ?? 0
            )
            
            // 创建帖子（附带宠物类别）
            let post_doze = TitleModel_Doze(
                titleId_Doze: index_doze + DataConfig_Doze.postIdStart_Doze,
                titleUserId_Doze: author_doze.userId_Doze ?? 0,
                titleUserName_Doze: author_doze.userName_Doze ?? "",
                titleMeidas_Doze: [media_doze],
                title_Doze: title_doze,
                titleContent_Doze: content_doze,
                reviews_Doze: comments_doze,
                likes_Doze: RandomUtil_Doze.nextInt_Doze(min_doze: 10, range_doze: 150),
                petCategory_Doze: category_doze
            )
            
            dataLocal_doze.titleList_Doze.append(post_doze)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Doze(postIndex_doze: Int, postAuthorUserId_doze: Int) -> [Comment_Doze] {
        guard let dataLocal_doze = dataLocal_Doze else { return [] }
        
        let availableUsers_doze = dataLocal_doze.getAvailableCommenters_Doze(postAuthorUserId_doze: postAuthorUserId_doze)
        guard availableUsers_doze.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_doze = availableUsers_doze[postIndex_doze % availableUsers_doze.count]
        let commenter2_doze = availableUsers_doze[(postIndex_doze + 1) % availableUsers_doze.count]
        
        // 获取评论内容
        let commentIndex_doze = postIndex_doze % DataSource_Doze.comments_Doze.count
        let (comment1_doze, comment2_doze) = DataSource_Doze.comments_Doze[commentIndex_doze]
        
        return [
            Comment_Doze(
                commentId_Doze: postIndex_doze * 2 + 1,
                commentUserId_Doze: commenter1_doze.userId_Doze ?? 0,
                commentUserName_Doze: commenter1_doze.userName_Doze ?? "",
                commentContent_Doze: comment1_doze
            ),
            Comment_Doze(
                commentId_Doze: postIndex_doze * 2 + 2,
                commentUserId_Doze: commenter2_doze.userId_Doze ?? 0,
                commentUserName_Doze: commenter2_doze.userName_Doze ?? "",
                commentContent_Doze: comment2_doze
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Doze() {
        guard let dataLocal_doze = dataLocal_Doze else { return }
        
        for i_doze in 0..<dataLocal_doze.userList_Doze.count {
            let user_doze = dataLocal_doze.userList_Doze[i_doze]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_doze = dataLocal_doze.getPostsExcludingUser_Doze(
                userId_doze: user_doze.userId_Doze ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_doze = RandomUtil_Doze.selectRandomItems_Doze(
                from: availablePosts_doze,
                count_doze: DataConfig_Doze.likePostCount_Doze
            )
            
            dataLocal_doze.userList_Doze[i_doze].userLike_Doze = likePosts_doze
        }
    }
}
