import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Retrs {
    /// ID起始值
    static let userIdStart_Retrs = 10
    static let postIdStart_Retrs = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Retrs = 2
}

/// 本地数据管理类
class LocalData_Retrs {
    
    /// 单例
    static let shared_Retrs = LocalData_Retrs()
    
    /// 用户列表
    var userList_Retrs: [PrewUserModel_Retrs] = []
    
    /// 帖子列表
    var titleList_Retrs: [TitleModel_Retrs] = []
    
    /// 数据生成器
    private lazy var generator_Retrs: DataGenerator_Retrs = {
        return DataGenerator_Retrs(dataLocal_retrs: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Retrs() {
        generator_Retrs.initUsers_Retrs()
        generator_Retrs.initPosts_Retrs()
        generator_Retrs.setUserLikes_Retrs()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Retrs(userId_retrs: Int) -> [TitleModel_Retrs] {
        return titleList_Retrs.filter { $0.titleUserId_Retrs != userId_retrs }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Retrs(postAuthorUserId_retrs: Int) -> [PrewUserModel_Retrs] {
        return userList_Retrs.filter { $0.userId_Retrs != postAuthorUserId_retrs }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Retrs {

    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Retrs: [(String, String, String, String)] = [
        ("GrainChaser", "CCD devotee hunting perfect grain in every frame", "head1", "head1"),
        ("RetroLensGirl", "Shooting life through vintage CCD eyes since 2018", "head2", "head2"),
        ("CasioFilmboy", "Everything looks better with that early-2000s CCD glow", "head3", "head3"),
        ("NoisyPixels", "Noise is not a flaw—it's the soul of CCD photography", "head4", "head4"),
        ("PocketShooter", "Pocket-sized cameras, massive feelings. CCD forever", "head5", "head5"),
    ]

    /// 帖子信息列表 (标题, 内容, 媒体URL) - CCD摄影主题
    static let postsInfo_Retrs: [(String, String, String)] = [
        ("Golden Hour Through CCD", "There's something utterly magical about golden hour captured on a CCD sensor. The warm tones, slight overexposure, and that unmistakable grain—no modern camera replicates this feeling.", "title1"),
        ("My Beloved Sony DSC-T9", "Found my old Sony DSC-T9 in a drawer and the battery still holds. Walked around my neighborhood shooting with it for three hours. Every photo looks like a memory before it even fades.", "title2"),
        ("The Grain That Makes It Real", "People ask why I shoot CCD when smartphones are 'better.' Because better isn't always truer. That digital grain reminds me these moments actually happened.", "title3"),
        ("Night Colors Bleed Beautiful", "CCD sensors at night are pure poetry. Colors bleed into each other, highlights bloom, and low-lit scenes glow like something from a half-remembered dream.", "title4"),
        ("Casio Exilim Still Hits Different", "My Casio Exilim EX-Z750 from 2005 produces photos that look like stills from a movie I wish existed. The color science is simply irreplaceable.", "title5"),
        ("Overexposed and Perfect", "Slightly overexposed CCD shots have a painterly quality I chase constantly. Today I found three frames where it clicked—that hazy bloom around light sources is everything.", "title6"),
        ("Street Photography, CCD Style", "Walking downtown with my old Canon IXUS, shooting strangers, storefronts, puddles. CCD gives street photography an emotional weight that sharp mirrorless files just can't match.", "title7"),
        ("Blue Skies on a Sony Cybershot", "The way Sony Cybershot renders a clear blue sky with slightly blown whites and vivid saturation is the reason I never sold mine. This is what summer looks like in my memory.", "title8"),
        ("Film Emulation? I Have CCD", "Everyone pays for film presets. I just pick up my old Olympus C-series and shoot. The colors, the contrast, the imperfection—it's all already there, no editing needed.", "title9"),
        ("Late Night CCD Experiments", "Shot my apartment at midnight with a 2003-era Fujifilm Finepix. The purple shadows, the warm lamp glow, the noise dancing across the image—this is my kind of ambiance.", "title10"),
    ]

    /// 评论列表 (评论1, 评论2) - CCD摄影主题
    static let comments_Retrs: [(String, String)] = [
        ("That golden hour grain is absolutely hypnotic. CCD magic at its finest!", "No filter, no preset can ever recreate what a real CCD sensor does to light."),
        ("The Sony DSC-T9 era was peak digital photography aesthetics. Pure nostalgia!", "Those compact CCD cameras captured life with such honest imperfection. Love this!"),
        ("You said it perfectly—grain is the soul, not a flaw. More people need to hear this.", "Shot my graduation on a CCD camera and every single photo looks like a painting now."),
        ("Night CCD is genuinely unmatched. The color bleed and bloom are so romantic.", "There's a warmth in CCD night shots that makes everything feel like a secret memory."),
        ("Casio Exilim color science is legendary. My EX-Z57 still gets compliments!", "That early 2000s point-and-shoot look is having such a deserved renaissance right now."),
        ("Overexposed CCD bloom is my favorite photographic accident. Chase it always!", "The hazy glow around light sources in CCD shots—nothing else looks like that. Ever."),
        ("CCD street photography just hits different. Raw, real, emotional. Love your eye.", "The Canon IXUS was such an underrated street camera. Glad someone still uses it!"),
        ("Sony Cybershot blue skies are iconic. That slightly punchy saturation is perfection.", "Sold mine years ago and regret it every single day looking at shots like yours."),
        ("Why pay for presets when old cameras exist? The best advice I've ever seen online.", "Fujifilm Finepix color rendition is criminally underrated. Your apartment looks dreamy."),
        ("Late night CCD experiments are the best kind of insomnia. Beautiful result!", "Purple shadows and warm noise—this is exactly the aesthetic I'm always chasing. Stunning!"),
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
/// 功能：提供各种随机数生成方法
private struct RandomUtil_Retrs {
    
    /// 生成指定范围的随机整数
    static func nextInt_Retrs(min_retrs: Int, range_retrs: Int) -> Int {
        return Int.random(in: min_retrs..<(min_retrs + range_retrs))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Retrs<T>(from list_retrs: [T], count_retrs: Int) -> [T] {
        guard !list_retrs.isEmpty else { return [] }
        guard list_retrs.count > count_retrs else { return list_retrs }
        
        var selected_retrs: [T] = []
        var indices_retrs: Set<Int> = []
        
        while selected_retrs.count < count_retrs && indices_retrs.count < list_retrs.count {
            let index_retrs = Int.random(in: 0..<list_retrs.count)
            if !indices_retrs.contains(index_retrs) {
                indices_retrs.insert(index_retrs)
                selected_retrs.append(list_retrs[index_retrs])
            }
        }
        
        return selected_retrs
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Retrs {
    
    private weak var dataLocal_Retrs: LocalData_Retrs?
    
    init(dataLocal_retrs: LocalData_Retrs) {
        self.dataLocal_Retrs = dataLocal_retrs
    }
    
    /// 初始化生成用户数据
    func initUsers_Retrs() {
        guard let dataLocal_retrs = dataLocal_Retrs else { return }
        dataLocal_retrs.userList_Retrs.removeAll()
        
        for (index_retrs, userInfo_retrs) in DataSource_Retrs.usersInfo_Retrs.enumerated() {
            let (username_retrs, introduce_retrs, userHead_retrs, userAlbum_retrs) = userInfo_retrs
            
            let user_retrs = PrewUserModel_Retrs()
            user_retrs.userId_Retrs = index_retrs + DataConfig_Retrs.userIdStart_Retrs
            user_retrs.userName_Retrs = username_retrs
            user_retrs.userIntroduce_Retrs = introduce_retrs
            user_retrs.userHead_Retrs = userHead_retrs
            user_retrs.userMedia_Retrs = [userAlbum_retrs]
            user_retrs.userLike_Retrs = []
            user_retrs.userFollow_Retrs = 15 + Int.random(in: 1...50)
            user_retrs.userFans_Retrs = 20 + Int.random(in: 1...50)
            
            dataLocal_retrs.userList_Retrs.append(user_retrs)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Retrs() {
        guard let dataLocal_retrs = dataLocal_Retrs else { return }
        dataLocal_retrs.titleList_Retrs.removeAll()
        
        for (index_retrs, postInfo_retrs) in DataSource_Retrs.postsInfo_Retrs.enumerated() {
            let (title_retrs, content_retrs, media_retrs) = postInfo_retrs
            
            // 循环分配作者
            let authorIndex_retrs = index_retrs % dataLocal_retrs.userList_Retrs.count
            guard authorIndex_retrs < dataLocal_retrs.userList_Retrs.count else { continue }
            let author_retrs = dataLocal_retrs.userList_Retrs[authorIndex_retrs]
            
            // 生成评论
            let comments_retrs = generateComments_Retrs(
                postIndex_retrs: index_retrs,
                postAuthorUserId_retrs: author_retrs.userId_Retrs ?? 0
            )
            
            // 创建帖子
            let post_retrs = TitleModel_Retrs(
                titleId_Retrs: index_retrs + DataConfig_Retrs.postIdStart_Retrs,
                titleUserId_Retrs: author_retrs.userId_Retrs ?? 0,
                titleUserName_Retrs: author_retrs.userName_Retrs ?? "",
                titleMeidas_Retrs: [media_retrs],
                title_Retrs: title_retrs,
                titleContent_Retrs: content_retrs,
                reviews_Retrs: comments_retrs,
                likes_Retrs: RandomUtil_Retrs.nextInt_Retrs(min_retrs: 10, range_retrs: 150)
            )
            
            dataLocal_retrs.titleList_Retrs.append(post_retrs)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Retrs(postIndex_retrs: Int, postAuthorUserId_retrs: Int) -> [Comment_Retrs] {
        guard let dataLocal_retrs = dataLocal_Retrs else { return [] }
        
        let availableUsers_retrs = dataLocal_retrs.getAvailableCommenters_Retrs(postAuthorUserId_retrs: postAuthorUserId_retrs)
        guard availableUsers_retrs.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_retrs = availableUsers_retrs[postIndex_retrs % availableUsers_retrs.count]
        let commenter2_retrs = availableUsers_retrs[(postIndex_retrs + 1) % availableUsers_retrs.count]
        
        // 获取评论内容
        let commentIndex_retrs = postIndex_retrs % DataSource_Retrs.comments_Retrs.count
        let (comment1_retrs, comment2_retrs) = DataSource_Retrs.comments_Retrs[commentIndex_retrs]
        
        return [
            Comment_Retrs(
                commentId_Retrs: postIndex_retrs * 2 + 1,
                commentUserId_Retrs: commenter1_retrs.userId_Retrs ?? 0,
                commentUserName_Retrs: commenter1_retrs.userName_Retrs ?? "",
                commentContent_Retrs: comment1_retrs
            ),
            Comment_Retrs(
                commentId_Retrs: postIndex_retrs * 2 + 2,
                commentUserId_Retrs: commenter2_retrs.userId_Retrs ?? 0,
                commentUserName_Retrs: commenter2_retrs.userName_Retrs ?? "",
                commentContent_Retrs: comment2_retrs
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Retrs() {
        guard let dataLocal_retrs = dataLocal_Retrs else { return }
        
        for i_retrs in 0..<dataLocal_retrs.userList_Retrs.count {
            let user_retrs = dataLocal_retrs.userList_Retrs[i_retrs]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_retrs = dataLocal_retrs.getPostsExcludingUser_Retrs(
                userId_retrs: user_retrs.userId_Retrs ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_retrs = RandomUtil_Retrs.selectRandomItems_Retrs(
                from: availablePosts_retrs,
                count_retrs: DataConfig_Retrs.likePostCount_Retrs
            )
            
            dataLocal_retrs.userList_Retrs[i_retrs].userLike_Retrs = likePosts_retrs
        }
    }
}
