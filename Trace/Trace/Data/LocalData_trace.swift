import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Trace {
    /// ID起始值
    static let userIdStart_Trace = 10
    static let postIdStart_Trace = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Trace = 2
}

/// 本地数据管理类
class LocalData_Trace {
    
    /// 单例
    static let shared_Trace = LocalData_Trace()
    
    /// 用户列表
    var userList_Trace: [PrewUserModel_Trace] = []
    
    /// 帖子列表
    var titleList_Trace: [TitleModel_Trace] = []
    
    /// 数据生成器
    private lazy var generator_Trace: DataGenerator_Trace = {
        return DataGenerator_Trace(dataLocal_trace: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Trace() {
        generator_Trace.initUsers_Trace()
        generator_Trace.initPosts_Trace()
        generator_Trace.setUserLikes_Trace()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Trace(userId_trace: Int) -> [TitleModel_Trace] {
        return titleList_Trace.filter { $0.titleUserId_Trace != userId_trace }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Trace(postAuthorUserId_trace: Int) -> [PrewUserModel_Trace] {
        return userList_Trace.filter { $0.userId_Trace != postAuthorUserId_trace }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Trace {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Trace: [(String, String, String, String)] = [
        ("DawnJournal", "Capturing quiet mornings before the world wakes up", "user_head_1", "user_album_1"),
        ("MomentKeeper", "Every ordinary day holds a story worth saving", "user_head_2", "user_album_2"),
        ("SoftGrowth", "Growing slowly, noticing everything along the way", "user_head_3", "user_album_3"),
        ("TraceOfLight", "Collecting sunsets, coffee rings, and small victories", "user_head_4", "user_album_4"),
        ("StillWaters", "Finding depth in the smallest ripples of everyday life", "user_head_5", "user_album_5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL, 标签)
    static let postsInfo_Trace: [(String, String, String, String)] = [
        ("Morning Light in a Cup", "The kettle hums, the light hits the table at exactly the right angle, and for a moment nothing needs fixing. This is my daily reset—five minutes with a warm cup before the world starts asking things of me. Some mornings the ritual is all that holds the day together.", "post_media_1", "Warmth"),
        ("Three Seconds Before It Fades", "There's a kind of light that only lasts for three seconds—the kind that catches on wet leaves or slants through a train window just so. I've started keeping my phone in my pocket and just watching. Some things are worth more than a photo. Some moments are meant only for you.", "post_media_2", "Moments"),
        ("2 AM and Still Writing", "The quietest version of a city is the one you only hear past midnight. Tonight I opened my old notebook and let things spill out—not pretty thoughts, just honest ones. I think writing at 2 AM is my way of talking to myself without interruption. It doesn't solve anything. It just makes the weight lighter.", "post_media_3", "Night"),
        ("Same Table, Different Seasons", "Every month we come back to the same corner booth, order too much food, and talk for three hours straight. We've sat here through new jobs, breakups, and unexplained bad weeks. The booth looks the same. We don't. I think that's what friendship is—a constant place to track how much you've grown.", "post_media_4", "Friends"),
        ("Found in an Old Notebook", "I was looking for a pen and found a journal from three years ago. My handwriting was messier, my worries smaller-sounding now. I wrote things like 'I hope I figure this out.' It did. Not all of it—but enough. Reading old entries feels like sending a postcard back to yourself: you made it.", "post_media_5", "Memory"),
        ("The Walk I Almost Skipped", "I told myself ten more minutes at the desk, then another ten, then I just put on my shoes and went anyway. The street had that specific late-afternoon light that only shows up in autumn. I walked for an hour without checking my phone. Sometimes the best thing you can do is leave the house with no plan.", "post_media_6", "Life"),
        ("We Don't Need an Occasion", "We decided at 7 PM to get food, and four of us ended up in someone's kitchen eating noodles and talking about everything—childhood, mistakes, what we'd do differently. No one planned it. No one wanted it to end. The best moments of my adult life have started with someone saying 'do you want to just...'", "post_media_7", "Friends"),
        ("The Light Just Then", "Standing at the window between two meetings—the light fell across the desk in a way that felt deliberate. Gold and quiet and impossibly brief. I didn't take a photo. I just stood there and let it land on me. It's the kind of beauty that asks nothing of you except to notice it.", "post_media_8", "Moments"),
        ("What I Told the Stars Tonight", "I make a habit of looking up before I go in. Tonight the sky was clear and enormous, and I thought about everything I want and haven't said yet. Standing under that much space, the things that felt heavy this week started to loosen. I didn't ask for anything. I just stayed out a little longer than I needed to.", "post_media_9", "Stars"),
        ("Autumn Is Patient", "The leaves don't rush. They go through every shade of red and orange before they finally let go. I've been trying to learn that from them—that change doesn't have to be fast to be real. I sat under a tree today and watched one leaf make its whole descent. It took almost a minute. I didn't look at my phone once.", "post_media_10", "Nature"),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_Trace: [(String, String)] = [
        ("This is exactly the energy I try to start my day with. The cup, the quiet—you captured it.", "That morning reset ritual is sacred. Five minutes that make everything feel more possible."),
        ("This reminded me to put the phone down sometimes. Some moments really are just for us.", "Three seconds of perfect light. Now I'll be looking for mine every single day."),
        ("2 AM honesty hits different. Something about the silence makes the real thoughts come out.", "The weight getting lighter through writing—I felt this in my whole chest. Thank you."),
        ("That corner booth sounds like home. The kind of place that holds your whole timeline.", "Growing together while staying anchored to the same spot. This is what I want from friendship."),
        ("'You made it'—I'm tearing up. I need to dig out my old journals right now.", "The past-you would be so relieved reading your life now. Such a beautiful thing to find."),
        ("You described that autumn light so exactly. I felt like I was walking right beside you.", "The no-plan walk is always the best walk. I'm putting on my shoes after reading this."),
        ("The spontaneous kitchen dinner—that's the entire adult friendship experience in one story.", "'Do you want to just...' really is the greatest sentence. Planning ruins half the magic."),
        ("'Beauty that asks nothing of you except to notice it.' Writing that down forever.", "I love that you didn't photograph it. You let it exist just for you. That's rare."),
        ("Things always loosen under a big sky. I felt this one somewhere deep.", "The habit of looking up before going in—I'm quietly stealing this for myself."),
        ("One minute watching a leaf fall. I think this might genuinely cure something in me.", "Autumn teaching us that slow change is still change. I really needed to read this today."),
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
/// 功能：提供各种随机数生成方法
private struct RandomUtil_Trace {
    
    /// 生成指定范围的随机整数
    static func nextInt_Trace(min_trace: Int, range_trace: Int) -> Int {
        return Int.random(in: min_trace..<(min_trace + range_trace))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Trace<T>(from list_trace: [T], count_trace: Int) -> [T] {
        guard !list_trace.isEmpty else { return [] }
        guard list_trace.count > count_trace else { return list_trace }
        
        var selected_trace: [T] = []
        var indices_trace: Set<Int> = []
        
        while selected_trace.count < count_trace && indices_trace.count < list_trace.count {
            let index_trace = Int.random(in: 0..<list_trace.count)
            if !indices_trace.contains(index_trace) {
                indices_trace.insert(index_trace)
                selected_trace.append(list_trace[index_trace])
            }
        }
        
        return selected_trace
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Trace {
    
    private weak var dataLocal_Trace: LocalData_Trace?
    
    init(dataLocal_trace: LocalData_Trace) {
        self.dataLocal_Trace = dataLocal_trace
    }
    
    /// 初始化生成用户数据
    func initUsers_Trace() {
        guard let dataLocal_trace = dataLocal_Trace else { return }
        dataLocal_trace.userList_Trace.removeAll()
        
        for (index_trace, userInfo_trace) in DataSource_Trace.usersInfo_Trace.enumerated() {
            let (username_trace, introduce_trace, userHead_trace, userAlbum_trace) = userInfo_trace
            
            let user_trace = PrewUserModel_Trace()
            user_trace.userId_Trace = index_trace + DataConfig_Trace.userIdStart_Trace
            user_trace.userName_Trace = username_trace
            user_trace.userIntroduce_Trace = introduce_trace
            user_trace.userHead_Trace = userHead_trace
            user_trace.userMedia_Trace = [userAlbum_trace]
            user_trace.userLike_Trace = []
            user_trace.userFollow_Trace = 15 + Int.random(in: 1...50)
            user_trace.userFans_Trace = 20 + Int.random(in: 1...50)
            
            dataLocal_trace.userList_Trace.append(user_trace)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Trace() {
        guard let dataLocal_trace = dataLocal_Trace else { return }
        dataLocal_trace.titleList_Trace.removeAll()
        
        for (index_trace, postInfo_trace) in DataSource_Trace.postsInfo_Trace.enumerated() {
            let (title_trace, content_trace, media_trace, tag_trace) = postInfo_trace
            
            // 循环分配作者
            let authorIndex_trace = index_trace % dataLocal_trace.userList_Trace.count
            guard authorIndex_trace < dataLocal_trace.userList_Trace.count else { continue }
            let author_trace = dataLocal_trace.userList_Trace[authorIndex_trace]
            
            // 生成评论
            let comments_trace = generateComments_Trace(
                postIndex_trace: index_trace,
                postAuthorUserId_trace: author_trace.userId_Trace ?? 0
            )
            
            // 创建帖子
            let post_trace = TitleModel_Trace(
                titleId_Trace: index_trace + DataConfig_Trace.postIdStart_Trace,
                titleUserId_Trace: author_trace.userId_Trace ?? 0,
                titleUserName_Trace: author_trace.userName_Trace ?? "",
                titleMeidas_Trace: [media_trace],
                title_Trace: title_trace,
                titleContent_Trace: content_trace,
                reviews_Trace: comments_trace,
                likes_Trace: RandomUtil_Trace.nextInt_Trace(min_trace: 10, range_trace: 150),
                titleTag_Trace: tag_trace
            )
            
            dataLocal_trace.titleList_Trace.append(post_trace)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Trace(postIndex_trace: Int, postAuthorUserId_trace: Int) -> [Comment_Trace] {
        guard let dataLocal_trace = dataLocal_Trace else { return [] }
        
        let availableUsers_trace = dataLocal_trace.getAvailableCommenters_Trace(postAuthorUserId_trace: postAuthorUserId_trace)
        guard availableUsers_trace.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_trace = availableUsers_trace[postIndex_trace % availableUsers_trace.count]
        let commenter2_trace = availableUsers_trace[(postIndex_trace + 1) % availableUsers_trace.count]
        
        // 获取评论内容
        let commentIndex_trace = postIndex_trace % DataSource_Trace.comments_Trace.count
        let (comment1_trace, comment2_trace) = DataSource_Trace.comments_Trace[commentIndex_trace]
        
        return [
            Comment_Trace(
                commentId_Trace: postIndex_trace * 2 + 1,
                commentUserId_Trace: commenter1_trace.userId_Trace ?? 0,
                commentUserName_Trace: commenter1_trace.userName_Trace ?? "",
                commentContent_Trace: comment1_trace
            ),
            Comment_Trace(
                commentId_Trace: postIndex_trace * 2 + 2,
                commentUserId_Trace: commenter2_trace.userId_Trace ?? 0,
                commentUserName_Trace: commenter2_trace.userName_Trace ?? "",
                commentContent_Trace: comment2_trace
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Trace() {
        guard let dataLocal_trace = dataLocal_Trace else { return }
        
        for i_trace in 0..<dataLocal_trace.userList_Trace.count {
            let user_trace = dataLocal_trace.userList_Trace[i_trace]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_trace = dataLocal_trace.getPostsExcludingUser_Trace(
                userId_trace: user_trace.userId_Trace ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_trace = RandomUtil_Trace.selectRandomItems_Trace(
                from: availablePosts_trace,
                count_trace: DataConfig_Trace.likePostCount_Trace
            )
            
            dataLocal_trace.userList_Trace[i_trace].userLike_Trace = likePosts_trace
        }
    }
}
