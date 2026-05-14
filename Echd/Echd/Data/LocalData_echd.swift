import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Echd {
    /// ID起始值
    static let userIdStart_Echd = 10
    static let postIdStart_Echd = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Echd = 2
}

/// 本地数据管理类
class LocalData_Echd {
    
    /// 单例
    static let shared_Echd = LocalData_Echd()
    
    /// 用户列表
    var userList_Echd: [PrewUserModel_Echd] = []
    
    /// 帖子列表
    var titleList_Echd: [TitleModel_Echd] = []

    /// 预制弹幕列表（Live Sparks 推荐弹幕，符合四大主题）
    var danmakuList_Echd: [DanmakuModel_Echd] = []
    
    /// 数据生成器
    private lazy var generator_Echd: DataGenerator_Echd = {
        return DataGenerator_Echd(dataLocal_echd: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Echd() {
        generator_Echd.initUsers_Echd()
        generator_Echd.initPosts_Echd()
        generator_Echd.setUserLikes_Echd()
        generator_Echd.initDanmaku_Echd()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Echd(userId_echd: Int) -> [TitleModel_Echd] {
        return titleList_Echd.filter { $0.titleUserId_Echd != userId_echd }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Echd(postAuthorUserId_echd: Int) -> [PrewUserModel_Echd] {
        return userList_Echd.filter { $0.userId_Echd != postAuthorUserId_echd }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Echd {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Echd: [(String, String, String, String)] = [
        ("TimeDrifter",   "Every spark I catch becomes a memory that lasts forever ✦", "head1", "head1"),
        ("MomentChaser",  "Running after moments before they drift away into the past", "head2", "head2"),
        ("SparkKeeper",   "Collecting warmth from every bonfire and every heartbeat 🔥", "head3", "head3"),
        ("EmberMemory",   "Turning fleeting moments into echoes that never fully fade", "head4", "head4"),
        ("DriftingLight", "Each bonfire is a page in the endless book of time 📖",     "head5", "head5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL) — 符合"时光漂流"主题
    static let postsInfo_Echd: [(String, String, String)] = [
        ("A Night Worth Remembering",
         "The bonfire crackles softly, wrapping every face in amber light. We trade s'mores for stories, and the stories drift like sparks into the night sky — this is the kind of moment that echoes across years.",
         "title1"),
        ("Where Time Stands Still",
         "Firelight has a strange power — it slows time down. Sitting here, feeling the warmth seep into my hands, I realize these are the moments I'll drift back to whenever life feels too fast.",
         "title2"),
        ("Flames That Won't Forget",
         "The flames dance and whisper, carrying fragments of our laughter up into the dark. Long after this night ends, something of it will keep burning inside us — a warm ember in the chest.",
         "title3"),
        ("The Warmth We Leave Behind",
         "The night grows deeper, but the bonfire burns brighter. Years from now I won't recall the exact words — only this warmth, this circle of light, this rare feeling of being exactly where you belong.",
         "title4"),
        ("Glow That Stays With You",
         "Some nights you look back on and wonder how a simple fire could change you. Tag the person you'd want beside you when time finally decides to slow all the way down.",
         "title5"),
        ("Until the Last Ember",
         "Last night's bonfire burned until well past midnight — as if it didn't want the moment to end either. The best sparks always refuse to fade without a fight.",
         "title6"),
        ("Time Told in Fire",
         "I used to think bonfires were just about fire. Now I know they're about time — the kind you can hold in your hands for a few precious hours before it drifts away forever.",
         "title7"),
        ("The Hours Worth Keeping",
         "We spent hours around this fire: singing off-key, arguing about stars, watching the flames color the dark. These are the hours worth keeping. What do you hold onto from your best nights?",
         "title8"),
        ("Stars and Sparks",
         "Above us, the sky is a sea of light; below us, our bonfire sends its own sparks to join them. In this moment, time feels both infinite and unbearably brief — and somehow that's enough.",
         "title9"),
        ("Drifting Into Peace",
         "The embers drift upward like tiny wishes released into the night. I let the warmth seep into my bones and stop trying to hold on — some moments are meant to drift free, and that's the point.",
         "title10"),
    ]
    
    // MARK: - 预制弹幕数据（符合四大主题，themeIndex: 0=致未来/1=毕业季/2=节日心愿/3=城市时光）
    // 格式：(content, authorName, themeIndex)
    static let danmakuData_Echd: [(String, String, Int)] = [
        // Theme 0 — To My Future Self
        ("Dear future me, I hope you're still chasing your wildest dreams ✦", "Drifter", 0),
        ("Ten years from now, will you still remember this moment? Keep going.", "Seeker", 0),
        ("To the one I'll become — don't forget where you started 🌱", "Lumina", 0),
        ("Future self, I'm leaving this spark so you remember you were brave today.", "Echo", 0),
        // Theme 1 — Graduation Season
        ("We made it through every late night and early morning 🎓", "EmberSoul", 1),
        ("Youth never ends — it just transforms into beautiful memories.", "ForestWhisper", 1),
        ("Tossing our caps up, letting our worries fall away ✨", "Wanderer", 1),
        ("The end of one chapter is just the blank page of the next.", "Skyfall", 1),
        // Theme 2 — Holiday Wishes
        ("May every wish you make under the stars come true ⭐", "NightGlow", 2),
        ("This season, I wish warmth for everyone I've ever loved.", "Ember", 2),
        ("New year, same heart — but bigger dreams 🎆", "SparkSoul", 2),
        ("Fireworks fade, but the wish stays lit inside 💫", "Lumina", 2),
        // Theme 3 — City Moments
        ("The city lights at night make me feel less alone 🌆", "UrbanDrifter", 3),
        ("Every street corner holds a story waiting to be told.", "CityEcho", 3),
        ("Rush hour ends, and the real city begins to breathe.", "Wanderer", 3),
        ("This city raised me, broke me, and rebuilt me 🏙️", "FlameJumper", 3),
        // General sparks (theme 0–3 distributed by index)
        ("Time drifts, but every spark stays forever ✦", "Drifter", 0),
        ("Catching moments before they fade away 🌊", "Seeker", 1),
        ("The bonfire crackles — we're all here, alive 🔥", "Ember", 2),
        ("Embers drift up like tiny wishes into the dark ✨", "Lumina", 3),
        ("Every second you live is a spark in the stream of time 💫", "Echo", 0),
        ("We spent hours around the fire, singing and laughing 🎶", "SparkSoul", 1),
    ]

    /// 评论列表 (评论1, 评论2) — 符合"时光漂流"主题
    static let comments_Echd: [(String, String)] = [
        ("This moment is exactly what time is made of — warmth, people, and firelight", "The sparks drifting up feel like all the good things we're afraid to let go of"),
        ("Firelight really does slow time down. You captured that feeling perfectly", "I drift back to moments like this in memory whenever life gets too loud"),
        ("Those flames will keep burning in my memory long after the fire is out", "This is the kind of night that changes you slowly, without you realizing it"),
        ("The warmth comes equally from the fire and the people. You said it beautifully", "A bonfire makes even strangers feel like they've known each other for years"),
        ("Already know who I'd want beside me when time decides to slow all the way down", "That glow stays with you for days afterward — it seeps in and doesn't leave"),
        ("Our bonfire lasted until dawn because none of us could bear to let the night end", "The sparks that refuse to fade are always the most worth catching"),
        ("Time told in fire — I'll be carrying that phrase around with me for a while", "Bonfires are the only clocks that make time feel worth measuring"),
        ("The hours worth keeping are always the ones around a fire with the right people", "I keep everything: the bad singing, the cold air, the warm glow, the laughter"),
        ("Stars above and sparks below — us, somewhere between infinity and a single night", "Infinite and unbearably brief at the same time. The truest thing I've read today"),
        ("Drifting free is the hardest kind of peace to find. These embers make it look easy", "Stop holding on and let the sparks go where they need to. I needed that reminder"),
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
/// 功能：提供各种随机数生成方法
private struct RandomUtil_Echd {
    
    /// 生成指定范围的随机整数
    static func nextInt_Echd(min_echd: Int, range_echd: Int) -> Int {
        return Int.random(in: min_echd..<(min_echd + range_echd))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Echd<T>(from list_echd: [T], count_echd: Int) -> [T] {
        guard !list_echd.isEmpty else { return [] }
        guard list_echd.count > count_echd else { return list_echd }
        
        var selected_echd: [T] = []
        var indices_echd: Set<Int> = []
        
        while selected_echd.count < count_echd && indices_echd.count < list_echd.count {
            let index_echd = Int.random(in: 0..<list_echd.count)
            if !indices_echd.contains(index_echd) {
                indices_echd.insert(index_echd)
                selected_echd.append(list_echd[index_echd])
            }
        }
        
        return selected_echd
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Echd {
    
    private weak var dataLocal_Echd: LocalData_Echd?
    
    init(dataLocal_echd: LocalData_Echd) {
        self.dataLocal_Echd = dataLocal_echd
    }
    
    /// 初始化生成用户数据
    func initUsers_Echd() {
        guard let dataLocal_echd = dataLocal_Echd else { return }
        dataLocal_echd.userList_Echd.removeAll()
        
        for (index_echd, userInfo_echd) in DataSource_Echd.usersInfo_Echd.enumerated() {
            let (username_echd, introduce_echd, userHead_echd, userAlbum_echd) = userInfo_echd
            
            let user_echd = PrewUserModel_Echd()
            user_echd.userId_Echd = index_echd + DataConfig_Echd.userIdStart_Echd
            user_echd.userName_Echd = username_echd
            user_echd.userIntroduce_Echd = introduce_echd
            user_echd.userHead_Echd = userHead_echd
            user_echd.userMedia_Echd = [userAlbum_echd]
            user_echd.userLike_Echd = []
            user_echd.userFollow_Echd = 15 + Int.random(in: 1...50)
            user_echd.userFans_Echd = 20 + Int.random(in: 1...50)
            
            dataLocal_echd.userList_Echd.append(user_echd)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Echd() {
        guard let dataLocal_echd = dataLocal_Echd else { return }
        dataLocal_echd.titleList_Echd.removeAll()
        
        for (index_echd, postInfo_echd) in DataSource_Echd.postsInfo_Echd.enumerated() {
            let (title_echd, content_echd, media_echd) = postInfo_echd
            
            // 循环分配作者
            let authorIndex_echd = index_echd % dataLocal_echd.userList_Echd.count
            guard authorIndex_echd < dataLocal_echd.userList_Echd.count else { continue }
            let author_echd = dataLocal_echd.userList_Echd[authorIndex_echd]
            
            // 生成评论
            let comments_echd = generateComments_Echd(
                postIndex_echd: index_echd,
                postAuthorUserId_echd: author_echd.userId_Echd ?? 0
            )
            
            // 创建帖子
            let post_echd = TitleModel_Echd(
                titleId_Echd: index_echd + DataConfig_Echd.postIdStart_Echd,
                titleUserId_Echd: author_echd.userId_Echd ?? 0,
                titleUserName_Echd: author_echd.userName_Echd ?? "",
                titleMeidas_Echd: [media_echd],
                title_Echd: title_echd,
                titleContent_Echd: content_echd,
                reviews_Echd: comments_echd,
                likes_Echd: RandomUtil_Echd.nextInt_Echd(min_echd: 10, range_echd: 150)
            )
            
            dataLocal_echd.titleList_Echd.append(post_echd)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Echd(postIndex_echd: Int, postAuthorUserId_echd: Int) -> [Comment_Echd] {
        guard let dataLocal_echd = dataLocal_Echd else { return [] }
        
        let availableUsers_echd = dataLocal_echd.getAvailableCommenters_Echd(postAuthorUserId_echd: postAuthorUserId_echd)
        guard availableUsers_echd.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_echd = availableUsers_echd[postIndex_echd % availableUsers_echd.count]
        let commenter2_echd = availableUsers_echd[(postIndex_echd + 1) % availableUsers_echd.count]
        
        // 获取评论内容
        let commentIndex_echd = postIndex_echd % DataSource_Echd.comments_Echd.count
        let (comment1_echd, comment2_echd) = DataSource_Echd.comments_Echd[commentIndex_echd]
        
        return [
            Comment_Echd(
                commentId_Echd: postIndex_echd * 2 + 1,
                commentUserId_Echd: commenter1_echd.userId_Echd ?? 0,
                commentUserName_Echd: commenter1_echd.userName_Echd ?? "",
                commentContent_Echd: comment1_echd
            ),
            Comment_Echd(
                commentId_Echd: postIndex_echd * 2 + 2,
                commentUserId_Echd: commenter2_echd.userId_Echd ?? 0,
                commentUserName_Echd: commenter2_echd.userName_Echd ?? "",
                commentContent_Echd: comment2_echd
            )
        ]
    }
    
    /// 初始化预制弹幕数据（符合四大主题）
    func initDanmaku_Echd() {
        guard let dataLocal_echd = dataLocal_Echd else { return }
        dataLocal_echd.danmakuList_Echd.removeAll()
        let now_Echd = Date().timeIntervalSince1970
        for (idx_Echd, item_Echd) in DataSource_Echd.danmakuData_Echd.enumerated() {
            dataLocal_echd.danmakuList_Echd.append(DanmakuModel_Echd(
                danmakuId_Echd: idx_Echd + 5000,  // 5000+ 避免与用户发布 ID 冲突
                content_Echd: item_Echd.0,
                authorName_Echd: item_Echd.1,
                authorId_Echd: 0,
                timestamp_Echd: now_Echd - Double(idx_Echd * 300)
            ))
        }
    }

    /// 更新用户的喜欢帖子列表
    func setUserLikes_Echd() {
        guard let dataLocal_echd = dataLocal_Echd else { return }
        
        for i_echd in 0..<dataLocal_echd.userList_Echd.count {
            let user_echd = dataLocal_echd.userList_Echd[i_echd]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_echd = dataLocal_echd.getPostsExcludingUser_Echd(
                userId_echd: user_echd.userId_Echd ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_echd = RandomUtil_Echd.selectRandomItems_Echd(
                from: availablePosts_echd,
                count_echd: DataConfig_Echd.likePostCount_Echd
            )
            
            dataLocal_echd.userList_Echd[i_echd].userLike_Echd = likePosts_echd
        }
    }
}
