import Foundation
import Combine

// MARK: - 本地数据存放类, 预制数据存放

/// 数据配置常量结构体
private struct DataConfig_lite {
    /// ID起始值
    static let userIdStart_lite = 10
    static let postIdStart_lite = 20
    
    /// 喜欢帖子数量
    static let likePostCount_lite = 2
}

/// 本地数据管理类
class LocalData_lite: ObservableObject {
    
    /// 单例实例
    static let shared_lite = LocalData_lite()
    
    /// 用户列表
    @Published var userList_lite: [PrewUserModel_lite] = []
    
    /// 帖子列表
    @Published var titleList_lite: [TitleModel_lite] = []
    
    /// 数据生成器
    private lazy var generator_lite: DataGenerator_lite = {
        return DataGenerator_lite(dataLocal_lite: self)
    }()
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    /// 初始化所有数据
    func initData_lite() {
        generator_lite.initUsers_lite()
        generator_lite.initPosts_lite()
        generator_lite.setUserLikes_lite()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_lite(userId_lite: Int) -> [TitleModel_lite] {
        return titleList_lite.filter { $0.titleUserId_lite != userId_lite }
    }
    
    /// 获取可评论的用户列表
    func getAvailableCommenters_lite(postAuthorUserId_lite: Int) -> [PrewUserModel_lite] {
        return userList_lite.filter { $0.userId_lite != postAuthorUserId_lite }
    }
}

// MARK: - 静态数据源

/// 静态数据源类
private struct DataSource_lite {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_lite: [(String, String, String, String)] = [
        ("TechExplorer", "Passionate about technology and innovation", "user_head_1", "user_album_1"),
        ("CreativeMinds", "Designer and creative thinker", "user_head_2", "user_album_2"),
        ("CodeMaster", "Full-stack developer and problem solver", "user_head_3", "user_album_3"),
        ("DigitalNomad", "Traveling the world while working remotely", "user_head_4", "user_album_4"),
        ("UXWizard", "Crafting seamless user experiences", "user_head_5", "user_album_5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)
    static let postsInfo_lite: [(String, String, String)] = [
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
    static let comments_lite: [(String, String)] = [
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
private struct RandomUtil_lite {
    
    /// 生成指定范围的随机整数
    static func nextInt_lite(min_lite: Int, range_lite: Int) -> Int {
        return Int.random(in: min_lite..<(min_lite + range_lite))
    }
    
    /// 从列表中随机选择不重复的N个元素
    static func selectRandomItems_lite<T>(from list_lite: [T], count_lite: Int) -> [T] {
        guard !list_lite.isEmpty else { return [] }
        guard list_lite.count > count_lite else { return list_lite }
        
        var selected_lite: [T] = []
        var indices_lite: Set<Int> = []
        
        while selected_lite.count < count_lite && indices_lite.count < list_lite.count {
            let index_lite = Int.random(in: 0..<list_lite.count)
            if !indices_lite.contains(index_lite) {
                indices_lite.insert(index_lite)
                selected_lite.append(list_lite[index_lite])
            }
        }
        
        return selected_lite
    }
}

// MARK: - 数据生成器类

/// 数据生成器类
class DataGenerator_lite {
    
    /// 弱引用本地数据管理器，避免循环引用
    private weak var dataLocal_lite: LocalData_lite?
    
    /// 初始化方法
    init(dataLocal_lite: LocalData_lite) {
        self.dataLocal_lite = dataLocal_lite
    }
    
    /// 初始化生成用户数据
    func initUsers_lite() {
        guard let dataLocal_lite = dataLocal_lite else { return }
        dataLocal_lite.userList_lite.removeAll()
        
        for (index_lite, userInfo_lite) in DataSource_lite.usersInfo_lite.enumerated() {
            let (username_lite, introduce_lite, userHead_lite, userAlbum_lite) = userInfo_lite
            
            let user_lite = PrewUserModel_lite()
            user_lite.userId_lite = index_lite + DataConfig_lite.userIdStart_lite
            user_lite.userName_lite = username_lite
            user_lite.userIntroduce_lite = introduce_lite
            user_lite.userHead_lite = userHead_lite
            user_lite.userMedia_lite = [userAlbum_lite]
            user_lite.userLike_lite = []
            user_lite.userFollow_lite = 15 + Int.random(in: 1...50)
            user_lite.userFans_lite = 20 + Int.random(in: 1...50)
            
            dataLocal_lite.userList_lite.append(user_lite)
        }
    }
    
    /// 初始化生成帖子数据
    func initPosts_lite() {
        guard let dataLocal_lite = dataLocal_lite else { return }
        dataLocal_lite.titleList_lite.removeAll()
        
        for (index_lite, postInfo_lite) in DataSource_lite.postsInfo_lite.enumerated() {
            let (title_lite, content_lite, media_lite) = postInfo_lite
            
            // 循环分配作者
            let authorIndex_lite = index_lite % dataLocal_lite.userList_lite.count
            guard authorIndex_lite < dataLocal_lite.userList_lite.count else { continue }
            let author_lite = dataLocal_lite.userList_lite[authorIndex_lite]
            
            // 生成评论
            let comments_lite = generateComments_lite(
                postIndex_lite: index_lite,
                postAuthorUserId_lite: author_lite.userId_lite ?? 0
            )
            
            // 创建帖子
            let post_lite = TitleModel_lite(
                titleId_lite: index_lite + DataConfig_lite.postIdStart_lite,
                titleUserId_lite: author_lite.userId_lite ?? 0,
                titleUserName_lite: author_lite.userName_lite ?? "",
                titleMeidas_lite: [media_lite],
                title_lite: title_lite,
                titleContent_lite: content_lite,
                reviews_lite: comments_lite,
                likes_lite: RandomUtil_lite.nextInt_lite(min_lite: 10, range_lite: 150)
            )
            
            dataLocal_lite.titleList_lite.append(post_lite)
        }
    }
    
    /// 为帖子生成评论
    private func generateComments_lite(postIndex_lite: Int, postAuthorUserId_lite: Int) -> [Comment_lite] {
        guard let dataLocal_lite = dataLocal_lite else { return [] }
        
        let availableUsers_lite = dataLocal_lite.getAvailableCommenters_lite(postAuthorUserId_lite: postAuthorUserId_lite)
        guard availableUsers_lite.count >= 2 else { return [] }
        
        // 获取评论者
        let commenter1_lite = availableUsers_lite[postIndex_lite % availableUsers_lite.count]
        let commenter2_lite = availableUsers_lite[(postIndex_lite + 1) % availableUsers_lite.count]
        
        // 获取评论内容
        let commentIndex_lite = postIndex_lite % DataSource_lite.comments_lite.count
        let (comment1_lite, comment2_lite) = DataSource_lite.comments_lite[commentIndex_lite]
        
        return [
            Comment_lite(
                commentId_lite: postIndex_lite * 2 + 1,
                commentUserId_lite: commenter1_lite.userId_lite ?? 0,
                commentUserName_lite: commenter1_lite.userName_lite ?? "",
                commentContent_lite: comment1_lite
            ),
            Comment_lite(
                commentId_lite: postIndex_lite * 2 + 2,
                commentUserId_lite: commenter2_lite.userId_lite ?? 0,
                commentUserName_lite: commenter2_lite.userName_lite ?? "",
                commentContent_lite: comment2_lite
            )
        ]
    }
    
    /// 更新用户的喜欢帖子列表
    func setUserLikes_lite() {
        guard let dataLocal_lite = dataLocal_lite else { return }
        
        for i_lite in 0..<dataLocal_lite.userList_lite.count {
            let user_lite = dataLocal_lite.userList_lite[i_lite]
            
            // 获取可喜欢的帖子（排除自己的）
            let availablePosts_lite = dataLocal_lite.getPostsExcludingUser_lite(
                userId_lite: user_lite.userId_lite ?? 0
            )
            
            // 随机选择喜欢的帖子
            let likePosts_lite = RandomUtil_lite.selectRandomItems_lite(
                from: availablePosts_lite,
                count_lite: DataConfig_lite.likePostCount_lite
            )
            
            dataLocal_lite.userList_lite[i_lite].userLike_lite = likePosts_lite
        }
    }
}
