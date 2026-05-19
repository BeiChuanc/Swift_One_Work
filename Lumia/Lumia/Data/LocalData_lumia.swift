import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_Lumia {
    /// ID起始值
    static let userIdStart_Lumia = 10
    static let postIdStart_Lumia = 20
    
    /// 喜欢帖子数量
    static let likePostCount_Lumia = 2
}

/// 本地数据管理类
class LocalData_Lumia {
    
    /// 单例
    static let shared_Lumia = LocalData_Lumia()
    
    /// 用户列表
    var userList_Lumia: [PrewUserModel_Lumia] = []
    
    /// 帖子列表
    var titleList_Lumia: [TitleModel_Lumia] = []
    
    /// 数据生成器
    private lazy var generator_Lumia: DataGenerator_Lumia = {
        return DataGenerator_Lumia(dataLocal_lumia: self)
    }()
    
    private init() {}
    
    /// 初始化所有数据
    func initData_Lumia() {
        generator_Lumia.initUsers_Lumia()
        generator_Lumia.initPosts_Lumia()
        generator_Lumia.setUserLikes_Lumia()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Lumia(userId_lumia: Int) -> [TitleModel_Lumia] {
        return titleList_Lumia.filter { $0.titleUserId_Lumia != userId_lumia }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_Lumia(postAuthorUserId_lumia: Int) -> [PrewUserModel_Lumia] {
        return userList_Lumia.filter { $0.userId_Lumia != postAuthorUserId_lumia }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_Lumia {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Lumia: [(String, String, String, String)] = [
        ("GrainChaser", "35mm film devotee · shooting life one frame at a time", "head1", "head1"),
        ("VelviaSoul", "Expired film enthusiast · Fuji Velvia is my love language", "head2", "head2"),
        ("DarkroomDreams", "Analog photographer · developing memories in silver and light", "head3", "head3"),
        ("SilverHalide", "Film & travel · forever chasing perfect grain and golden shadow", "head4", "head4"),
        ("LeicaMoments", "Street photography on Kodak Portra · candid over perfect", "head5", "head5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)
    static let postsInfo_Lumia: [(String, String, String)] = [
        ("First Roll of Portra 400", "Loaded my first roll of Kodak Portra 400 last weekend. There's something irreplaceable about the way film renders skin tones—warm, soft, and full of life. Every frame felt intentional, and waiting for the scans was half the magic.", "title1"),
        ("Shooting Velvia in Autumn", "Fuji Velvia 50 in autumn is pure poetry. The saturation is almost unreal—deep crimson maples, golden grass, and a sky that feels painted. I overexposed by a full stop and the colors just bloomed.", "title2"),
        ("Rainy Day Street, HP5 Plus", "Rain and Ilford HP5 Plus are a match made in heaven. The grain pops, contrast is dramatic, and puddle reflections turn every sidewalk into abstract art. Shot at box speed and pushed one stop in Rodinal.", "title3"),
        ("Darkroom Session at Midnight", "Spent three hours in the darkroom last night printing a 16x20 from my 6x6 negative. Watching the image slowly appear in the developer tray still gives me chills every single time.", "title4"),
        ("Expired Ektachrome Finds", "These were shot on a roll of Ektachrome expired in 1997 that I found in my grandmother's fridge. The color shifts are wild—cyan shadows, magenta highlights. Imperfect and absolutely beautiful.", "title5"),
        ("Golden Hour on Lomography", "Shot this golden hour sequence on Lomography 800 handheld at f/2. The light leak in the corner wasn't a mistake—I scored the cartridge on purpose. Some of the best accidents happen on film.", "title6"),
        ("Medium Format Portrait", "My Mamiya RZ67 and a single window. Portra 160 at box speed. No reflectors, no fill—just natural north light and a face with a thousand stories. Medium format detail is something digital still can't touch.", "title7"),
        ("Black & White Architecture", "There's a quiet severity to architecture on Kodak T-Max 100. Shot this facade at f/11, 1/60s, developed in D-76. The micro-contrast and shadow detail in the stone work took my breath away.", "title8"),
        ("Night Street on 3200", "Pushing Kodak T-Max 3200 to ISO 6400 for night street shooting. The grain becomes the texture of the city—gritty, alive, honest. You can almost feel the cold air and wet pavement.", "title9"),
        ("End of the Roll Light Leak", "The last frame always has that beautiful light leak from opening the camera back too early. I've started calling it the 'film goodbye.' This one hit the horizon perfectly.", "title10"),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_Lumia: [(String, String)] = [
        ("Portra 400 skin tones are just unmatched. Film really does see people differently.", "The anticipation of waiting for scans is my favorite part of shooting film!"),
        ("Velvia in autumn is on my bucket list. Did you meter for shadows or highlights?", "That overexposure trick with Velvia sounds like a game changer. Trying it this weekend."),
        ("HP5 and rain is such a classic combo. What developer ratio did you use for Rodinal?", "The puddle reflections look like abstract paintings. Street film photography at its finest."),
        ("Darkroom printing at midnight sounds like a dream. That image emerging in the tray is pure magic.", "A 16x20 from 6x6 must have incredible detail. What paper did you use for the print?"),
        ("Expired film from the 90s is like a time capsule. Those color shifts are so hauntingly beautiful.", "Your grandmother's fridge stash is better than any film lab could ever recreate. Treasure those rolls."),
        ("Intentional light leaks are such a vibe. Half the beauty of film is the unpredictability.", "Lomography 800 at golden hour sounds incredible. Love how you leaned into the analog imperfection."),
        ("Medium format portraits have a three-dimensional quality no digital sensor can replicate.", "North light and Portra 160—this is the combination I've been trying to recreate for years."),
        ("T-Max 100 architecture is so sharp and crisp. D-76 is such a reliable developer for fine grain.", "The micro-contrast in stone textures on T-Max is just remarkable. Beautiful technical shot."),
        ("Pushing T-Max 3200 to 6400 for night street is so bold. How many stops of push in development?", "The grain in night street photography captures the soul of the city better than any clean ISO."),
        ("The film goodbye light leak is the most poetic way to end a roll I've ever heard.", "Every roll has its own personality. That light leak hitting the horizon is genuinely perfect composition."),
    ]
}

// MARK: - 随机数工具类

/// 随机数工具类
/// 功能：提供各种随机数生成方法
private struct RandomUtil_Lumia {
    
    /// 生成指定范围的随机整数
    static func nextInt_Lumia(min_lumia: Int, range_lumia: Int) -> Int {
        return Int.random(in: min_lumia..<(min_lumia + range_lumia))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_Lumia<T>(from list_lumia: [T], count_lumia: Int) -> [T] {
        guard !list_lumia.isEmpty else { return [] }
        guard list_lumia.count > count_lumia else { return list_lumia }
        
        var selected_lumia: [T] = []
        var indices_lumia: Set<Int> = []
        
        while selected_lumia.count < count_lumia && indices_lumia.count < list_lumia.count {
            let index_lumia = Int.random(in: 0..<list_lumia.count)
            if !indices_lumia.contains(index_lumia) {
                indices_lumia.insert(index_lumia)
                selected_lumia.append(list_lumia[index_lumia])
            }
        }
        
        return selected_lumia
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_Lumia {
    
    private weak var dataLocal_Lumia: LocalData_Lumia?
    
    init(dataLocal_lumia: LocalData_Lumia) {
        self.dataLocal_Lumia = dataLocal_lumia
    }
    
    /// 初始化生成用户数据
    func initUsers_Lumia() {
        guard let dataLocal_lumia = dataLocal_Lumia else { return }
        dataLocal_lumia.userList_Lumia.removeAll()
        
        for (index_lumia, userInfo_lumia) in DataSource_Lumia.usersInfo_Lumia.enumerated() {
            let (username_lumia, introduce_lumia, userHead_lumia, userAlbum_lumia) = userInfo_lumia
            
            let user_lumia = PrewUserModel_Lumia()
            user_lumia.userId_Lumia = index_lumia + DataConfig_Lumia.userIdStart_Lumia
            user_lumia.userName_Lumia = username_lumia
            user_lumia.userIntroduce_Lumia = introduce_lumia
            user_lumia.userHead_Lumia = userHead_lumia
            user_lumia.userMedia_Lumia = [userAlbum_lumia]
            user_lumia.userLike_Lumia = []
            user_lumia.userFollow_Lumia = 15 + Int.random(in: 1...50)
            user_lumia.userFans_Lumia = 20 + Int.random(in: 1...50)
            
            dataLocal_lumia.userList_Lumia.append(user_lumia)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_Lumia() {
        guard let dataLocal_lumia = dataLocal_Lumia else { return }
        dataLocal_lumia.titleList_Lumia.removeAll()
        
        for (index_lumia, postInfo_lumia) in DataSource_Lumia.postsInfo_Lumia.enumerated() {
            let (title_lumia, content_lumia, media_lumia) = postInfo_lumia
            
            // 循环分配作者
            let authorIndex_lumia = index_lumia % dataLocal_lumia.userList_Lumia.count
            guard authorIndex_lumia < dataLocal_lumia.userList_Lumia.count else { continue }
            let author_lumia = dataLocal_lumia.userList_Lumia[authorIndex_lumia]
            
            // 生成评论
            let comments_lumia = generateComments_Lumia(
                postIndex_lumia: index_lumia,
                postAuthorUserId_lumia: author_lumia.userId_Lumia ?? 0
            )
            
            // 创建帖子
            let post_lumia = TitleModel_Lumia(
                titleId_Lumia: index_lumia + DataConfig_Lumia.postIdStart_Lumia,
                titleUserId_Lumia: author_lumia.userId_Lumia ?? 0,
                titleUserName_Lumia: author_lumia.userName_Lumia ?? "",
                titleMeidas_Lumia: [media_lumia],
                title_Lumia: title_lumia,
                titleContent_Lumia: content_lumia,
                reviews_Lumia: comments_lumia,
                likes_Lumia: RandomUtil_Lumia.nextInt_Lumia(min_lumia: 10, range_lumia: 150)
            )
            
            dataLocal_lumia.titleList_Lumia.append(post_lumia)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_Lumia(postIndex_lumia: Int, postAuthorUserId_lumia: Int) -> [Comment_Lumia] {
        guard let dataLocal_lumia = dataLocal_Lumia else { return [] }
        
        let availableUsers_lumia = dataLocal_lumia.getAvailableCommenters_Lumia(postAuthorUserId_lumia: postAuthorUserId_lumia)
        guard availableUsers_lumia.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_lumia = availableUsers_lumia[postIndex_lumia % availableUsers_lumia.count]
        let commenter2_lumia = availableUsers_lumia[(postIndex_lumia + 1) % availableUsers_lumia.count]
        
        // 获取评论内容
        let commentIndex_lumia = postIndex_lumia % DataSource_Lumia.comments_Lumia.count
        let (comment1_lumia, comment2_lumia) = DataSource_Lumia.comments_Lumia[commentIndex_lumia]
        
        return [
            Comment_Lumia(
                commentId_Lumia: postIndex_lumia * 2 + 1,
                commentUserId_Lumia: commenter1_lumia.userId_Lumia ?? 0,
                commentUserName_Lumia: commenter1_lumia.userName_Lumia ?? "",
                commentContent_Lumia: comment1_lumia
            ),
            Comment_Lumia(
                commentId_Lumia: postIndex_lumia * 2 + 2,
                commentUserId_Lumia: commenter2_lumia.userId_Lumia ?? 0,
                commentUserName_Lumia: commenter2_lumia.userName_Lumia ?? "",
                commentContent_Lumia: comment2_lumia
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_Lumia() {
        guard let dataLocal_lumia = dataLocal_Lumia else { return }
        
        for i_lumia in 0..<dataLocal_lumia.userList_Lumia.count {
            let user_lumia = dataLocal_lumia.userList_Lumia[i_lumia]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_lumia = dataLocal_lumia.getPostsExcludingUser_Lumia(
                userId_lumia: user_lumia.userId_Lumia ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_lumia = RandomUtil_Lumia.selectRandomItems_Lumia(
                from: availablePosts_lumia,
                count_lumia: DataConfig_Lumia.likePostCount_Lumia
            )
            
            dataLocal_lumia.userList_Lumia[i_lumia].userLike_Lumia = likePosts_lumia
        }
    }
}
