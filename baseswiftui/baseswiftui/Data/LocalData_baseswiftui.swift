import Foundation
import Combine

// MARK: - 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_baseswiftui {
    /// ID起始值
    static let userIdStart_baseswiftui = 10
    static let postIdStart_baseswiftui = 20
    
    /// 喜欢帖子数量
    static let likePostCount_baseswiftui = 2
}

/// 本地数据管理类
class LocalData_baseswiftui: ObservableObject {
    
    /// 单例实例
    static let shared_baseswiftui = LocalData_baseswiftui()
    
    /// 用户列表
    @Published var userList_baseswiftui: [PrewUserModel_baseswiftui] = []
    
    /// 帖子列表
    @Published var titleList_baseswiftui: [TitleModel_baseswiftui] = []
    
    /// 数据生成器
    private lazy var generator_baseswiftui: DataGenerator_baseswiftui = {
        return DataGenerator_baseswiftui(dataLocal_baseswiftui: self)
    }()
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    /// 初始化所有数据
    func initData_baseswiftui() {
        generator_baseswiftui.initUsers_baseswiftui()
        generator_baseswiftui.initPosts_baseswiftui()
        generator_baseswiftui.setUserLikes_baseswiftui()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_baseswiftui(userId_baseswiftui: Int) -> [TitleModel_baseswiftui] {
        return titleList_baseswiftui.filter { $0.titleUserId_baseswiftui != userId_baseswiftui }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_baseswiftui(postAuthorUserId_baseswiftui: Int) -> [PrewUserModel_baseswiftui] {
        return userList_baseswiftui.filter { $0.userId_baseswiftui != postAuthorUserId_baseswiftui }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_baseswiftui {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_baseswiftui: [(String, String, String, String)] = [
        ("TechExplorer", "Passionate about technology and innovation", "user_head_1", "user_album_1"),
        ("CreativeMinds", "Designer and creative thinker", "user_head_2", "user_album_2"),
        ("CodeMaster", "Full-stack developer and problem solver", "user_head_3", "user_album_3"),
        ("DigitalNomad", "Traveling the world while working remotely", "user_head_4", "user_album_4"),
        ("UXWizard", "Crafting seamless user experiences", "user_head_5", "user_album_5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)
    static let postsInfo_baseswiftui: [(String, String, String)] = [
        ("Amazing Discovery", "Just discovered this incredible new feature that's going to change everything. The attention to detail is remarkable, and the user experience is seamless. Can't wait to share more about this with everyone!", "post_media_1"),
        ("Beautiful Design", "There's something special about clean, minimal design. It's not just about looks—it's about creating an experience that feels natural and effortless. This project captures that perfectly.", "post_media_2"),
        ("Innovation at Work", "Watching innovation unfold in real-time is fascinating. The way technology seamlessly integrates into our daily lives never ceases to amaze me. Here's to the future!", "post_media_3"),
        ("Creative Process", "Behind every great project is a creative process filled with iterations, late nights, and breakthrough moments. This journey has been incredible so far.", "post_media_4"),
        ("Team Collaboration", "Look at what we built together! Collaboration brings out the best in everyone. When different perspectives come together, magic happens.", "post_media_5"),
        ("Perfect Execution", "Weeks of planning and hard work have led to this moment. Every detail was carefully considered, and the result speaks for itself. So proud of this achievement!", "post_media_6"),
        ("Learning Journey", "I used to think success was about knowing everything, but now I realize it's about being willing to learn. This experience taught me so much.", "post_media_7"),
        ("Fun Activities", "We spent today exploring new ideas, testing concepts, and pushing boundaries. What's your favorite way to stay creative and inspired?", "post_media_8"),
        ("Inspiration Everywhere", "Above us, infinite possibilities; around us, endless inspiration. The world is full of ideas waiting to be discovered and brought to life.", "post_media_9"),
        ("Peaceful Progress", "Sometimes the best work happens in quiet moments. Taking time to reflect, iterate, and improve leads to meaningful progress.", "post_media_10"),
    ]
    
    /// 评论列表 (评论1, 评论2)
    static let comments_baseswiftui: [(String, String)] = [
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
}

// MARK: - 随机数工具类

/// 随机数工具类
private struct RandomUtil_baseswiftui {
    
    /// 生成指定范围的随机整数
    static func nextInt_baseswiftui(min_baseswiftui: Int, range_baseswiftui: Int) -> Int {
        return Int.random(in: min_baseswiftui..<(min_baseswiftui + range_baseswiftui))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_baseswiftui<T>(from list_baseswiftui: [T], count_baseswiftui: Int) -> [T] {
        guard !list_baseswiftui.isEmpty else { return [] }
        guard list_baseswiftui.count > count_baseswiftui else { return list_baseswiftui }
        
        var selected_baseswiftui: [T] = []
        var indices_baseswiftui: Set<Int> = []
        
        while selected_baseswiftui.count < count_baseswiftui && indices_baseswiftui.count < list_baseswiftui.count {
            let index_baseswiftui = Int.random(in: 0..<list_baseswiftui.count)
            if !indices_baseswiftui.contains(index_baseswiftui) {
                indices_baseswiftui.insert(index_baseswiftui)
                selected_baseswiftui.append(list_baseswiftui[index_baseswiftui])
            }
        }
        
        return selected_baseswiftui
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_baseswiftui {
    
    /// 弱引用本地数据管理器，避免循环引用
    private weak var dataLocal_baseswiftui: LocalData_baseswiftui?
    
    /// 初始化方法
    init(dataLocal_baseswiftui: LocalData_baseswiftui) {
        self.dataLocal_baseswiftui = dataLocal_baseswiftui
    }
    
    /// 初始化生成用户数据
    func initUsers_baseswiftui() {
        guard let dataLocal_baseswiftui = dataLocal_baseswiftui else { return }
        dataLocal_baseswiftui.userList_baseswiftui.removeAll()
        
        for (index_baseswiftui, userInfo_baseswiftui) in DataSource_baseswiftui.usersInfo_baseswiftui.enumerated() {
            let (username_baseswiftui, introduce_baseswiftui, userHead_baseswiftui, userAlbum_baseswiftui) = userInfo_baseswiftui
            
            let user_baseswiftui = PrewUserModel_baseswiftui()
            user_baseswiftui.userId_baseswiftui = index_baseswiftui + DataConfig_baseswiftui.userIdStart_baseswiftui
            user_baseswiftui.userName_baseswiftui = username_baseswiftui
            user_baseswiftui.userIntroduce_baseswiftui = introduce_baseswiftui
            user_baseswiftui.userHead_baseswiftui = userHead_baseswiftui
            user_baseswiftui.userMedia_baseswiftui = [userAlbum_baseswiftui]
            user_baseswiftui.userLike_baseswiftui = []
            user_baseswiftui.userFollow_baseswiftui = 15 + Int.random(in: 1...50)
            user_baseswiftui.userFans_baseswiftui = 20 + Int.random(in: 1...50)
            
            dataLocal_baseswiftui.userList_baseswiftui.append(user_baseswiftui)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_baseswiftui() {
        guard let dataLocal_baseswiftui = dataLocal_baseswiftui else { return }
        dataLocal_baseswiftui.titleList_baseswiftui.removeAll()
        
        for (index_baseswiftui, postInfo_baseswiftui) in DataSource_baseswiftui.postsInfo_baseswiftui.enumerated() {
            let (title_baseswiftui, content_baseswiftui, media_baseswiftui) = postInfo_baseswiftui
            
            // 循环分配作者
            let authorIndex_baseswiftui = index_baseswiftui % dataLocal_baseswiftui.userList_baseswiftui.count
            guard authorIndex_baseswiftui < dataLocal_baseswiftui.userList_baseswiftui.count else { continue }
            let author_baseswiftui = dataLocal_baseswiftui.userList_baseswiftui[authorIndex_baseswiftui]
            
            // 生成评论
            let comments_baseswiftui = generateComments_baseswiftui(
                postIndex_baseswiftui: index_baseswiftui,
                postAuthorUserId_baseswiftui: author_baseswiftui.userId_baseswiftui ?? 0
            )
            
            // 创建帖子
            let post_baseswiftui = TitleModel_baseswiftui(
                titleId_baseswiftui: index_baseswiftui + DataConfig_baseswiftui.postIdStart_baseswiftui,
                titleUserId_baseswiftui: author_baseswiftui.userId_baseswiftui ?? 0,
                titleUserName_baseswiftui: author_baseswiftui.userName_baseswiftui ?? "",
                titleMeidas_baseswiftui: [media_baseswiftui],
                title_baseswiftui: title_baseswiftui,
                titleContent_baseswiftui: content_baseswiftui,
                reviews_baseswiftui: comments_baseswiftui,
                likes_baseswiftui: RandomUtil_baseswiftui.nextInt_baseswiftui(min_baseswiftui: 10, range_baseswiftui: 150)
            )
            
            dataLocal_baseswiftui.titleList_baseswiftui.append(post_baseswiftui)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_baseswiftui(postIndex_baseswiftui: Int, postAuthorUserId_baseswiftui: Int) -> [Comment_baseswiftui] {
        guard let dataLocal_baseswiftui = dataLocal_baseswiftui else { return [] }
        
        let availableUsers_baseswiftui = dataLocal_baseswiftui.getAvailableCommenters_baseswiftui(postAuthorUserId_baseswiftui: postAuthorUserId_baseswiftui)
        guard availableUsers_baseswiftui.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_baseswiftui = availableUsers_baseswiftui[postIndex_baseswiftui % availableUsers_baseswiftui.count]
        let commenter2_baseswiftui = availableUsers_baseswiftui[(postIndex_baseswiftui + 1) % availableUsers_baseswiftui.count]
        
        // 获取评论内容
        let commentIndex_baseswiftui = postIndex_baseswiftui % DataSource_baseswiftui.comments_baseswiftui.count
        let (comment1_baseswiftui, comment2_baseswiftui) = DataSource_baseswiftui.comments_baseswiftui[commentIndex_baseswiftui]
        
        return [
            Comment_baseswiftui(
                commentId_baseswiftui: postIndex_baseswiftui * 2 + 1,
                commentUserId_baseswiftui: commenter1_baseswiftui.userId_baseswiftui ?? 0,
                commentUserName_baseswiftui: commenter1_baseswiftui.userName_baseswiftui ?? "",
                commentContent_baseswiftui: comment1_baseswiftui
            ),
            Comment_baseswiftui(
                commentId_baseswiftui: postIndex_baseswiftui * 2 + 2,
                commentUserId_baseswiftui: commenter2_baseswiftui.userId_baseswiftui ?? 0,
                commentUserName_baseswiftui: commenter2_baseswiftui.userName_baseswiftui ?? "",
                commentContent_baseswiftui: comment2_baseswiftui
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_baseswiftui() {
        guard let dataLocal_baseswiftui = dataLocal_baseswiftui else { return }
        
        for i_baseswiftui in 0..<dataLocal_baseswiftui.userList_baseswiftui.count {
            let user_baseswiftui = dataLocal_baseswiftui.userList_baseswiftui[i_baseswiftui]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_baseswiftui = dataLocal_baseswiftui.getPostsExcludingUser_baseswiftui(
                userId_baseswiftui: user_baseswiftui.userId_baseswiftui ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_baseswiftui = RandomUtil_baseswiftui.selectRandomItems_baseswiftui(
                from: availablePosts_baseswiftui,
                count_baseswiftui: DataConfig_baseswiftui.likePostCount_baseswiftui
            )
            
            dataLocal_baseswiftui.userList_baseswiftui[i_baseswiftui].userLike_baseswiftui = likePosts_baseswiftui
        }
    }
}
