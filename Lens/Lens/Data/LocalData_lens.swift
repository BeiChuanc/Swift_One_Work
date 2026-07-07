import Foundation

// MARK: 本地数据存放类, 预制数据存放

/// 本地数据管理类
/// 功能：管理预制用户与帖子数据，提供查询过滤方法
/// 设计：单例 + 内部 DataGenerator 负责批量生成
class LocalData_Lens {
    
    static let shared_Lens = LocalData_Lens()
    
    /// 用户列表
    var userList_Lens: [PrewUserModel_Lens] = []
    
    /// 帖子列表
    var titleList_Lens: [TitleModel_Lens] = []

    /// 预制作品集
    var artworkList_Lens: [ArtworkModel_Lens] = []

    /// 预制亚克力层
    var defaultLayers_Lens: [AcrylicLayerModel_Lens] = []

    /// 预制弹幕
    var defaultDanmakus_Lens: [DanmakuModel_Lens] = []
    
    private lazy var generator_Lens = DataGenerator_Lens(dataLocal_lens: self)
    
    private init() {}
    
    /// 初始化所有预制数据
    func initData_Lens() {
        generator_Lens.initUsers_Lens()
        generator_Lens.initPosts_Lens()
        generator_Lens.setUserLikes_Lens()
        generator_Lens.initStudioData_Lens()
        generator_Lens.initDanmaku_Lens()
    }
    
    /// 获取排除指定用户的帖子列表
    func getPostsExcludingUser_Lens(userId_lens: Int) -> [TitleModel_Lens] {
        titleList_Lens.filter { $0.titleUserId_Lens != userId_lens }
    }
    
    /// 获取可评论的用户列表（排除帖子作者）
    func getAvailableCommenters_Lens(postAuthorUserId_lens: Int) -> [PrewUserModel_Lens] {
        userList_Lens.filter { $0.userId_Lens != postAuthorUserId_lens }
    }
}

// MARK: - 静态数据源

/// 预制用户与帖子原始数据（主题：棱镜透彩画）
private enum DataSource_Lens {
    
    /// 用户信息列表 (用户名, 简介, 头像URL, 相册URL)
    static let usersInfo_Lens: [(String, String, String, String)] = [
        ("PrismDrifter", "Chasing rainbows through every glass pane — art is just light finding its angle", "head1", "head1"),
        ("ChromaWeaver", "Weaving color stories with prisms and paint, one refraction at a time", "head2", "head2"),
        ("SpectrumSoul", "Every hue tells a truth. I paint with light, shadows, and wonder", "head3", "head3"),
        ("LensAlchemist", "Turning ordinary light into extraordinary color — photography meets prismatic art", "head4", "head4"),
        ("IridescentMind", "Where pigment meets prism — exploring the alchemy of color and emotion", "head5", "head5"),
    ]
    
    /// 帖子信息列表 (标题, 内容, 媒体URL)，主题：棱镜透彩画 · 画后日常
    static let postsInfo_Lens: [(String, String, String)] = [
        ("After the Last Stroke", "Finally signed this prism piece tonight. I propped it against the kitchen window and made tea while the last acrylic layer dried — every few minutes the sunset shifted and the whole painting looked like a different work. That quiet half hour after finishing might be my favorite part of the process.", "title1"),
        ("Studio Cleanup Hour", "Brushes rinsed, palette wiped, hands still faintly blue. I always slow down after a painting session and just look at the wet layers one more time before closing Light Studio. Today the violet edge caught the desk lamp exactly right — almost worth the mess on my sleeves.", "title2"),
        ("Balcony Light Check", "Carried the finished canvas to the balcony right after drying. Morning light hits differently than my studio lamp, and I needed to know the refraction still reads in real life. Neighbor walked by, paused, and said it looked like a little rainbow had moved in next door.", "title3"),
        ("Logged Before Dinner", "Painted for three hours straight, then uploaded the cover and saved each layer step to my Creation Timeline before cooking pasta. There is something grounding about closing the creative loop while the apartment still smells like acrylic and coffee.", "title4"),
        ("Sleep on the Colors", "Stopped before overworking the golden highlight — hard lesson learned. Left the piece leaning on the bookshelf overnight and checked it first thing this morning. The overnight settle made the layers feel softer, more honest. Sometimes the best edit is a good night's sleep.", "title5"),
        ("Walk After Finishing", "Closed my sketchbook, washed up, and took a long walk without headphones. Finished a prism study an hour earlier and suddenly every shop window, puddle, and glass door felt like part of the same painting. I think that is how I know a piece is truly done.", "title6"),
        ("Shared Over Breakfast", "Finished this one last night and could not wait to show my roommate at breakfast. She pointed at the amber wash and said it looked like late-afternoon toast light — best review I have gotten all month. We hung it in the hallway before I left for work.", "title7"),
        ("Post-Session Polaroids", "After the final layer dried, I took a few polaroids in different corners of the room — by the window, on the floor, near the lamp. Same painting, four moods. I tape these snapshots inside my studio notebook so I remember how light changes everything after the brush stops moving.", "title8"),
        ("Late Night Studio Glow", "It was past midnight when I finally stepped back and called it finished. I dimmed everything except the studio soft light and sat on the floor for ten minutes just watching the colors breathe. No posting, no editing — only the quiet satisfaction of a day well painted.", "title9"),
        ("Weekend Wrap-Up", "Sunday evening ritual: clean the desk, archive today's color tests, write one line in my timeline about what worked. Finished a small prism piece this weekend — nothing grand, just honest layers and good light. Already thinking about Monday's palette before I turn off the lamp.", "title10"),
    ]
    
    /// 评论列表 (评论1, 评论2)，主题：画后日常
    static let comments_Lens: [(String, String)] = [
        ("That post-painting tea moment sounds so peaceful — watching light change on fresh layers is the best reward", "The quiet half hour after finishing is underrated. Your window setup sounds perfect"),
        ("I do the same slow cleanup ritual — there is always one last glance at the wet color before closing the studio", "Blue hands and a perfect violet edge — honestly the true artist uniform"),
        ("Taking finished work outside for a light check is such a smart habit. Real daylight tells the truth", "A little rainbow next door — what a lovely reaction from your neighbor"),
        ("Logging to Creation Timeline before dinner feels so satisfying. Closing the loop makes the day feel complete", "Acrylic and coffee in the same apartment — that is a lifestyle I understand"),
        ("Leaving a piece overnight instead of overworking it is real wisdom. Morning light always knows best", "Soft layers after sleep hit differently. Thank you for sharing that reminder"),
        ("The post-painting walk sounds amazing — when the whole city starts looking like your canvas, you know it worked", "No headphones, just color everywhere. That is the best kind of finished feeling"),
        ("Late-afternoon toast light is such a perfect description. Hanging it in the hallway was the right move", "Breakfast reviews hit different — your roommate has great eyes"),
        ("Polaroids in different corners is such a thoughtful habit. I might steal that for my own notebook", "Same painting, four moods — that is exactly how light keeps teaching us after we stop painting"),
        ("Sitting on the floor in studio glow after midnight sounds deeply peaceful. Love that you did not rush to post", "Ten minutes of just looking — that might be the real final layer of every piece"),
        ("Sunday archive rituals are so wholesome. Honest layers and good light is a perfect weekend summary", "Already thinking about Monday's palette — the sign of a good creative weekend"),
    ]

    /// 预制作品集（已移除，由用户登录后自行创建）
    static let artworksInfo_Lens: [(String, String, String)] = []

    /// 默认亚克力层配置（名称, 色值, 透明度, 饱和度, 笔触厚度, 边缘光泽, 堆叠顺序）
    static let defaultLayersInfo_Lens: [(String, String, Double, Double, Double, Double, Int)] = [
        ("Base Wash", "#4D96FF", 0.35, 0.72, 2.0, 0.15, 0),
        ("Crimson Veil", "#FF6B6B", 0.48, 0.85, 3.5, 0.32, 1),
        ("Golden Highlight", "#FFD93D", 0.28, 0.95, 1.8, 0.55, 2),
        ("Violet Prism", "#C77DFF", 0.42, 0.78, 4.2, 0.40, 3)
    ]
}

// MARK: - 随机数工具

/// 随机数工具（仅供数据生成使用）
private enum RandomUtil_Lens {
    
    /// 生成 [min, min + range) 范围内的随机整数
    static func nextInt_Lens(min_lens: Int, range_lens: Int) -> Int {
        Int.random(in: min_lens..<(min_lens + range_lens))
    }
    
    /// 从列表中随机选取不重复的 N 个元素
    static func selectRandomItems_Lens<T>(from list_lens: [T], count_lens: Int) -> [T] {
        guard !list_lens.isEmpty else { return [] }
        guard list_lens.count > count_lens else { return list_lens }
        
        var selected_lens: [T] = []
        var usedIndices_lens = Set<Int>()
        while selected_lens.count < count_lens {
            let index_lens = Int.random(in: 0..<list_lens.count)
            if usedIndices_lens.insert(index_lens).inserted {
                selected_lens.append(list_lens[index_lens])
            }
        }
        return selected_lens
    }
}

// MARK: - 数据生成器

/// 预制数据生成器（仅 LocalData 内部使用）
private class DataGenerator_Lens {
    
    private weak var dataLocal_Lens: LocalData_Lens?
    
    init(dataLocal_lens: LocalData_Lens) {
        self.dataLocal_Lens = dataLocal_lens
    }
    
    /// 根据静态数据源生成用户列表
    func initUsers_Lens() {
        guard let dataLocal_lens = dataLocal_Lens else { return }
        dataLocal_lens.userList_Lens = DataSource_Lens.usersInfo_Lens.enumerated().map { index, info in
            let (name, intro, head, album) = info
            let user_lens = PrewUserModel_Lens()
            user_lens.userId_Lens = index + 10
            user_lens.userName_Lens = name
            user_lens.userIntroduce_Lens = intro
            user_lens.userHead_Lens = head
            user_lens.userMedia_Lens = [album]
            user_lens.userLike_Lens = []
            user_lens.userFollow_Lens = 15 + Int.random(in: 1...50)
            user_lens.userFans_Lens = 20 + Int.random(in: 1...50)
            return user_lens
        }
    }
    
    /// 根据静态数据源生成帖子列表（循环分配作者）
    func initPosts_Lens() {
        guard let dataLocal_lens = dataLocal_Lens else { return }
        let users_lens = dataLocal_lens.userList_Lens
        guard !users_lens.isEmpty else {
            dataLocal_lens.titleList_Lens = []
            return
        }
        
        dataLocal_lens.titleList_Lens = DataSource_Lens.postsInfo_Lens.enumerated().map { index, info in
            let (title, content, media) = info
            let author_lens = users_lens[index % users_lens.count]
            let authorId_lens = author_lens.userId_Lens ?? 0
            
            return TitleModel_Lens(
                titleId_Lens: index + 20,
                titleUserId_Lens: authorId_lens,
                titleUserName_Lens: author_lens.userName_Lens ?? "",
                titleMeidas_Lens: [media],
                title_Lens: title,
                titleContent_Lens: content,
                reviews_Lens: generateComments_Lens(postIndex_lens: index, postAuthorUserId_lens: authorId_lens),
                likes_Lens: RandomUtil_Lens.nextInt_Lens(min_lens: 10, range_lens: 150)
            )
        }
    }
    
    /// 为帖子生成两条评论
    private func generateComments_Lens(postIndex_lens: Int, postAuthorUserId_lens: Int) -> [Comment_Lens] {
        guard let dataLocal_lens = dataLocal_Lens else { return [] }
        let available_lens = dataLocal_lens.getAvailableCommenters_Lens(postAuthorUserId_lens: postAuthorUserId_lens)
        guard available_lens.count >= 2 else { return [] }
        
        let commenter1_lens = available_lens[postIndex_lens % available_lens.count]
        let commenter2_lens = available_lens[(postIndex_lens + 1) % available_lens.count]
        let (text1, text2) = DataSource_Lens.comments_Lens[postIndex_lens % DataSource_Lens.comments_Lens.count]
        
        return [
            makeComment_Lens(id: postIndex_lens * 2 + 1, user: commenter1_lens, content: text1),
            makeComment_Lens(id: postIndex_lens * 2 + 2, user: commenter2_lens, content: text2)
        ]
    }
    
    /// 为每个用户随机分配喜欢的帖子（排除自己的帖子）
    func setUserLikes_Lens() {
        guard let dataLocal_lens = dataLocal_Lens else { return }
        for i in dataLocal_lens.userList_Lens.indices {
            let userId_lens = dataLocal_lens.userList_Lens[i].userId_Lens ?? 0
            dataLocal_lens.userList_Lens[i].userLike_Lens = RandomUtil_Lens.selectRandomItems_Lens(
                from: dataLocal_lens.getPostsExcludingUser_Lens(userId_lens: userId_lens),
                count_lens: 2
            )
        }
    }
    
    /// 构建评论模型
    private func makeComment_Lens(id: Int, user: PrewUserModel_Lens, content: String) -> Comment_Lens {
        Comment_Lens(
            commentId_Lens: id,
            commentUserId_Lens: user.userId_Lens ?? 0,
            commentUserName_Lens: user.userName_Lens ?? "",
            commentContent_Lens: content
        )
    }

    /// 初始化调制画盘预制数据（默认亚克力层，作品集由用户创建）
    func initStudioData_Lens() {
        guard let dataLocal_lens = dataLocal_Lens else { return }

        dataLocal_lens.artworkList_Lens = []

        dataLocal_lens.defaultLayers_Lens = DataSource_Lens.defaultLayersInfo_Lens.enumerated().map { index, info in
            let (name, hex, opacity, saturation, thickness, gloss, order) = info
            return AcrylicLayerModel_Lens(
                layerId_Lens: 200 + index,
                layerName_Lens: name,
                tintHex_Lens: hex,
                opacity_Lens: opacity,
                saturation_Lens: saturation,
                brushThickness_Lens: thickness,
                edgeGloss_Lens: gloss,
                stackOrder_Lens: order
            )
        }
    }

    /// 为作品生成创作过程事件序列（预制数据已移除，保留空实现供扩展）
    private func buildCreationEvents_Lens(artworkIndex_Lens: Int) -> [CreationEvent_Lens] {
        []
    }

    /// 将归一化坐标转为笔触轨迹点数组
    private func brushPath_Lens(points_Lens: [(Double, Double)]) -> [BrushPoint_Lens] {
        points_Lens.map { BrushPoint_Lens(x_Lens: $0.0, y_Lens: $0.1) }
    }

    /// 初始化预制弹幕数据（其他用户发言，Lens Studio 主题）
    func initDanmaku_Lens() {
        guard let dataLocal_lens = dataLocal_Lens else { return }
        dataLocal_lens.defaultDanmakus_Lens = [
            DanmakuModel_Lens(danmakuId_Lens: 1, userId_Lens: 10, userName_Lens: "PrismDrifter", content_Lens: "Love the refraction preview!", colorHex_Lens: "#4D96FF", time_Lens: "10:24"),
            DanmakuModel_Lens(danmakuId_Lens: 2, userId_Lens: 11, userName_Lens: "ChromaWeaver", content_Lens: "Morning sun mode is stunning", colorHex_Lens: "#FFD93D", time_Lens: "11:02"),
            DanmakuModel_Lens(danmakuId_Lens: 3, userId_Lens: 12, userName_Lens: "SpectrumSoul", content_Lens: "Stacking layers feels so real", colorHex_Lens: "#C77DFF", time_Lens: "12:18"),
            DanmakuModel_Lens(danmakuId_Lens: 4, userId_Lens: 13, userName_Lens: "LensAlchemist", content_Lens: "Acrylic test colors are gorgeous", colorHex_Lens: "#FF6B6B", time_Lens: "13:05"),
            DanmakuModel_Lens(danmakuId_Lens: 5, userId_Lens: 14, userName_Lens: "IridescentMind", content_Lens: "Light studio angle looks perfect", colorHex_Lens: "#6BCB77", time_Lens: "14:22"),
            DanmakuModel_Lens(danmakuId_Lens: 6, userId_Lens: 10, userName_Lens: "PrismDrifter", content_Lens: "Creation timeline is so detailed", colorHex_Lens: "#00D4FF", time_Lens: "15:08"),
            DanmakuModel_Lens(danmakuId_Lens: 7, userId_Lens: 11, userName_Lens: "ChromaWeaver", content_Lens: "Saving color snapshots is brilliant", colorHex_Lens: "#FFD93D", time_Lens: "16:31"),
            DanmakuModel_Lens(danmakuId_Lens: 8, userId_Lens: 12, userName_Lens: "SpectrumSoul", content_Lens: "The prism carousel is beautiful", colorHex_Lens: "#C77DFF", time_Lens: "17:45"),
            DanmakuModel_Lens(danmakuId_Lens: 9, userId_Lens: 13, userName_Lens: "LensAlchemist", content_Lens: "Layer blend feels like real acrylic", colorHex_Lens: "#4D96FF", time_Lens: "18:12"),
            DanmakuModel_Lens(danmakuId_Lens: 10, userId_Lens: 14, userName_Lens: "IridescentMind", content_Lens: "Weekly stats keep me motivated", colorHex_Lens: "#FF6B9D", time_Lens: "19:27"),
            DanmakuModel_Lens(danmakuId_Lens: 11, userId_Lens: 10, userName_Lens: "PrismDrifter", content_Lens: "Swipe the arc — so smooth!", colorHex_Lens: "#6BCB77", time_Lens: "20:03"),
            DanmakuModel_Lens(danmakuId_Lens: 12, userId_Lens: 11, userName_Lens: "ChromaWeaver", content_Lens: "Golden highlight layer is my favorite", colorHex_Lens: "#FFD93D", time_Lens: "21:18")
        ]
    }
}
