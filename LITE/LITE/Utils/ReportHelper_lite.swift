import SwiftUI
import Combine

// MARK: - 举报/删除助手类
// 核心作用：提供举报用户、帖子、评论以及删除帖子、评论的统一接口
// 设计思路：参考业务逻辑，提供清晰的操作流程，SwiftUI版本
// 关键功能：举报、删除、拉黑用户

/// 举报/删除助手类
class ReportHelper_lite {
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_lite {
        case block_lite              // 拉黑用户
        case post_lite               // 举报帖子
        case comment_lite            // 举报评论
        case inspirationComment_lite // 举报灵感评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    /// - Parameters:
    ///   - user_lite: 要拉黑的用户模型
    ///   - completion_lite: 拉黑完成回调
    static func blockUser_lite(
        user_lite: PrewUserModel_lite,
        completion_lite: (() -> Void)? = nil
    ) {
        // 执行拉黑用户逻辑
        performBlockUser_lite(user_lite: user_lite)
        completion_lite?()
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    /// - Parameters:
    ///   - post_lite: 被举报的帖子模型
    ///   - completion_lite: 举报完成回调
    static func reportPost_lite(
        post_lite: TitleModel_lite,
        completion_lite: (() -> Void)? = nil
    ) {
        // 执行举报帖子逻辑，操作完成后调用回调
        performReportPost_lite(
            post_lite: post_lite,
            completion_lite: completion_lite
        )
    }
    
    /// 举报评论
    /// - Parameters:
    ///   - comment_lite: 被举报的评论模型
    ///   - post_lite: 评论所属的帖子
    ///   - completion_lite: 举报完成回调
    static func reportComment_lite(
        comment_lite: Comment_lite,
        post_lite: TitleModel_lite,
        completion_lite: (() -> Void)? = nil
    ) {
        performReportComment_lite(
            comment_lite: comment_lite,
            post_lite: post_lite,
            completion_lite: completion_lite
        )
    }
    
    /// 举报灵感评论
    /// - Parameters:
    ///   - inspirationComment_lite: 被举报的灵感评论（OutfitCombo作为承载）
    ///   - challenge_lite: 评论所属的挑战
    ///   - completion_lite: 举报完成回调
    static func reportInspirationComment_lite(
        inspirationComment_lite: OutfitCombo_lite,
        challenge_lite: OutfitChallenge_lite,
        completion_lite: (() -> Void)? = nil
    ) {
        performReportInspirationComment_lite(
            inspirationComment_lite: inspirationComment_lite,
            challenge_lite: challenge_lite,
            completion_lite: completion_lite
        )
    }
    
    /// 举报时空胶囊
    /// - Parameters:
    ///   - capsule_lite: 被举报的时空胶囊
    ///   - completion_lite: 举报完成回调
    static func reportCapsule_lite(
        capsule_lite: OutfitCapsule_lite,
        completion_lite: (() -> Void)? = nil
    ) {
        performReportCapsule_lite(
            capsule_lite: capsule_lite,
            completion_lite: completion_lite
        )
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    /// - Parameters:
    ///   - post_lite: 要删除的帖子模型
    ///   - completion_lite: 删除完成回调
    static func deletePost_lite(
        post_lite: TitleModel_lite,
        completion_lite: (() -> Void)? = nil
    ) {
        // 执行删除帖子逻辑，操作完成后调用回调
        performDeletePost_lite(
            post_lite: post_lite,
            completion_lite: completion_lite
        )
    }
    
    /// 删除评论
    /// - Parameters:
    ///   - comment_lite: 要删除的评论模型
    ///   - post_lite: 评论所属的帖子
    ///   - completion_lite: 删除完成回调
    static func deleteComment_lite(
        comment_lite: Comment_lite,
        post_lite: TitleModel_lite,
        completion_lite: (() -> Void)? = nil
    ) {
        // 执行删除评论逻辑，操作完成后调用回调
        performDeleteComment_lite(
            comment_lite: comment_lite,
            post_lite: post_lite,
            completion_lite: completion_lite
        )
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 执行拉黑用户操作
    /// - Parameter user_lite: 要拉黑的用户
    private static func performBlockUser_lite(user_lite: PrewUserModel_lite) {
        // 模拟网络请求延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UserViewModel_lite.shared_lite.reportUser_lite(user_lite: user_lite)
            print("✅ 已拉黑用户: \(user_lite.userName_lite ?? "Unknown")")
        }
    }
    
    /// 执行举报帖子操作
    /// - Parameters:
    ///   - post_lite: 被举报的帖子
    ///   - completion_lite: 操作完成回调
    private static func performReportPost_lite(
        post_lite: TitleModel_lite,
        completion_lite: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            TitleViewModel_lite.shared_lite.deletePost_lite(post_lite: post_lite)
            print("✅ 已举报帖子: \(post_lite.title_lite)")
            
            // 确保在主线程上执行回调
            DispatchQueue.main.async {
                completion_lite?()
            }
        }
    }
    
    /// 执行举报评论操作
    /// - Parameters:
    ///   - comment_lite: 被举报的评论
    ///   - post_lite: 评论所属帖子
    ///   - completion_lite: 操作完成回调
    private static func performReportComment_lite(
        comment_lite: Comment_lite,
        post_lite: TitleModel_lite,
        completion_lite: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 判断是否是自己的评论
            let currentUserId_lite = UserViewModel_lite.shared_lite.getCurrentUser_lite().userId_lite ?? 0
            let isOwnComment_lite = comment_lite.commentUserId_lite == currentUserId_lite
            
            TitleViewModel_lite.shared_lite.deleteComment_lite(
                post_lite: post_lite,
                comment_lite: comment_lite
            )
            print("✅ 已举报评论: \(comment_lite.commentContent_lite)")
            
            // 根据是否是自己的评论显示不同提示
            let message_lite = isOwnComment_lite ? "Deleted successfully." : "This comment will no longer appear."
            Utils_lite.showSuccess_lite(
                message_lite: message_lite,
                delay_lite: 1.5
            )
            
            // 确保在主线程上执行回调
            DispatchQueue.main.async {
                completion_lite?()
            }
        }
    }
    
    /// 执行删除帖子操作
    /// - Parameters:
    ///   - post_lite: 要删除的帖子
    ///   - completion_lite: 操作完成回调
    private static func performDeletePost_lite(
        post_lite: TitleModel_lite,
        completion_lite: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 调用 ViewModel 删除帖子
            TitleViewModel_lite.shared_lite.deletePost_lite(
                post_lite: post_lite,
                isDelete_lite: true
            )
            print("✅ 已删除帖子: \(post_lite.title_lite)")
            
            // 确保在主线程上执行回调
            DispatchQueue.main.async {
                completion_lite?()
            }
        }
    }
    
    /// 执行删除评论操作
    /// - Parameters:
    ///   - comment_lite: 要删除的评论
    ///   - post_lite: 评论所属帖子
    ///   - completion_lite: 操作完成回调
    private static func performDeleteComment_lite(
        comment_lite: Comment_lite,
        post_lite: TitleModel_lite,
        completion_lite: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 调用 ViewModel 删除评论
            TitleViewModel_lite.shared_lite.deleteComment_lite(
                post_lite: post_lite,
                comment_lite: comment_lite,
                isDelete_lite: true
            )
            print("✅ 已删除评论: \(comment_lite.commentContent_lite)")
            
            // 确保在主线程上执行回调
            DispatchQueue.main.async {
                completion_lite?()
            }
        }
    }
    
    /// 执行举报灵感评论操作
    /// - Parameters:
    ///   - inspirationComment_lite: 被举报的灵感评论
    ///   - challenge_lite: 评论所属挑战
    ///   - completion_lite: 操作完成回调
    private static func performReportInspirationComment_lite(
        inspirationComment_lite: OutfitCombo_lite,
        challenge_lite: OutfitChallenge_lite,
        completion_lite: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 判断是否是自己的评论（用户发布的评论 comboDescription_lite 为 "User inspiration"）
            let isOwnComment_lite = inspirationComment_lite.comboDescription_lite == "User inspiration"
            
            // 从挑战的提交列表中移除该灵感评论
            if let challengeIndex_lite = LocalData_lite.shared_lite.challengeList_lite.firstIndex(where: { $0.challengeId_lite == challenge_lite.challengeId_lite }) {
                LocalData_lite.shared_lite.challengeList_lite[challengeIndex_lite].submissions_lite.removeAll { submission_lite in
                    submission_lite.comboId_lite == inspirationComment_lite.comboId_lite
                }
                
                // 手动触发更新通知，确保视图刷新
                LocalData_lite.shared_lite.objectWillChange.send()
            }
            
            // 根据是否是自己的评论显示不同提示
            let message_lite = isOwnComment_lite ? "Deleted successfully." : "This comment will no longer appear."
            Utils_lite.showSuccess_lite(
                message_lite: message_lite,
                delay_lite: 1.5
            )
            
            // 确保在主线程上执行回调
            DispatchQueue.main.async {
                completion_lite?()
            }
        }
    }
    
    /// 执行举报时空胶囊操作
    /// - Parameters:
    ///   - capsule_lite: 被举报的时空胶囊
    ///   - completion_lite: 操作完成回调
    private static func performReportCapsule_lite(
        capsule_lite: OutfitCapsule_lite,
        completion_lite: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 判断是否是自己的时空胶囊
            let currentUserId_lite = UserViewModel_lite.shared_lite.getCurrentUser_lite().userId_lite ?? 0
            let isOwnCapsule_lite = capsule_lite.userId_lite == currentUserId_lite
            
            // 从胶囊列表中移除该胶囊
            LocalData_lite.shared_lite.capsuleList_lite.removeAll { item_lite in
                item_lite.capsuleId_lite == capsule_lite.capsuleId_lite
            }
            
            // 手动触发更新通知，确保视图刷新
            LocalData_lite.shared_lite.objectWillChange.send()
            
            print("✅ 已举报时空胶囊: \(capsule_lite.outfit_lite.comboTitle_lite)")
            
            // 根据是否是自己的胶囊显示不同提示
            let message_lite = isOwnCapsule_lite ? "Deleted successfully." : "This capsule will no longer appear."
            Utils_lite.showSuccess_lite(
                message_lite: message_lite,
                delay_lite: 1.5
            )
            
            // 确保在主线程上执行回调
            DispatchQueue.main.async {
                completion_lite?()
            }
        }
    }
}

// MARK: - 举报ActionSheet组件

/// 举报菜单组件
/// 功能：展示举报选项的ActionSheet
struct ReportActionSheet_lite: View {
    
    /// 是否显示
    @Binding var isShowing_lite: Bool
    
    /// 是否是拉黑用户（true=拉黑用户, false=举报内容）
    let isBlockUser_lite: Bool
    
    /// 确认回调
    let onConfirm_lite: () -> Void
    
    var body: some View {
        VStack {}
            .actionSheet(isPresented: $isShowing_lite) {
                ActionSheet(
                    title: Text("More"),
                    message: nil,
                    buttons: actionButtons_lite
                )
            }
    }
    
    /// 构建操作按钮列表
    private var actionButtons_lite: [ActionSheet.Button] {
        var buttons_lite: [ActionSheet.Button] = []
        
        // 举报内容选项
        buttons_lite.append(contentsOf: [
            .default(Text("Report Sexually Explicit Material")) {
                onConfirm_lite()
                isShowing_lite = false
            },
            .default(Text("Report spam")) {
                onConfirm_lite()
                isShowing_lite = false
            },
            .default(Text("Report something else")) {
                onConfirm_lite()
                isShowing_lite = false
            },
            .destructive(Text(isBlockUser_lite ? "Block" : "Report")) {
                onConfirm_lite()
                isShowing_lite = false
            }
        ])
        
        // 添加取消按钮
        buttons_lite.append(
            .cancel {
                isShowing_lite = false
            }
        )
        
        return buttons_lite
    }
}
