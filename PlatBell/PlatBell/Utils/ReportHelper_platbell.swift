import SwiftUI

// MARK: - 举报/删除助手类
// 核心作用：提供举报用户、帖子、评论以及删除帖子、评论的统一接口
// 设计思路：参考业务逻辑，提供清晰的操作流程，SwiftUI版本
// 关键功能：举报、删除、拉黑用户

/// 举报/删除助手类
class ReportHelper_platbell {
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_platbell {
        case block_platbell       // 拉黑用户
        case post_platbell        // 举报帖子
        case comment_platbell     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    /// - Parameters:
    ///   - user_platbell: 要拉黑的用户模型
    ///   - completion_platbell: 拉黑完成回调
    static func blockUser_platbell(
        user_platbell: PrewUserModel_platbell,
        completion_platbell: (() -> Void)? = nil
    ) {
        // 执行拉黑用户逻辑
        performBlockUser_platbell(user_platbell: user_platbell)
        completion_platbell?()
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    /// - Parameters:
    ///   - post_platbell: 被举报的帖子模型
    ///   - completion_platbell: 举报完成回调
    static func reportPost_platbell(
        post_platbell: TitleModel_platbell,
        completion_platbell: (() -> Void)? = nil
    ) {
        // 执行举报帖子逻辑，操作完成后调用回调
        performReportPost_platbell(
            post_platbell: post_platbell,
            completion_platbell: completion_platbell
        )
    }
    
    /// 举报评论
    /// - Parameters:
    ///   - comment_platbell: 被举报的评论模型
    ///   - post_platbell: 评论所属的帖子
    ///   - completion_platbell: 举报完成回调
    static func reportComment_platbell(
        comment_platbell: Comment_platbell,
        post_platbell: TitleModel_platbell,
        completion_platbell: (() -> Void)? = nil
    ) {
        performReportComment_platbell(
            comment_platbell: comment_platbell,
            post_platbell: post_platbell,
            completion_platbell: completion_platbell
        )
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    /// - Parameters:
    ///   - post_platbell: 要删除的帖子模型
    ///   - completion_platbell: 删除完成回调
    static func deletePost_platbell(
        post_platbell: TitleModel_platbell,
        completion_platbell: (() -> Void)? = nil
    ) {
        // 执行删除帖子逻辑，操作完成后调用回调
        performDeletePost_platbell(
            post_platbell: post_platbell,
            completion_platbell: completion_platbell
        )
    }
    
    /// 删除评论
    /// - Parameters:
    ///   - comment_platbell: 要删除的评论模型
    ///   - post_platbell: 评论所属的帖子
    ///   - completion_platbell: 删除完成回调
    static func deleteComment_platbell(
        comment_platbell: Comment_platbell,
        post_platbell: TitleModel_platbell,
        completion_platbell: (() -> Void)? = nil
    ) {
        // 执行删除评论逻辑，操作完成后调用回调
        performDeleteComment_platbell(
            comment_platbell: comment_platbell,
            post_platbell: post_platbell,
            completion_platbell: completion_platbell
        )
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 执行拉黑用户操作
    /// - Parameter user_platbell: 要拉黑的用户
    private static func performBlockUser_platbell(user_platbell: PrewUserModel_platbell) {
        // 模拟网络请求延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UserViewModel_platbell.shared_platbell.reportUser_platbell(user_platbell: user_platbell)
            print("✅ 已拉黑用户: \(user_platbell.userName_platbell ?? "Unknown")")
        }
    }
    
    /// 执行举报帖子操作
    /// - Parameters:
    ///   - post_platbell: 被举报的帖子
    ///   - completion_platbell: 操作完成回调
    private static func performReportPost_platbell(
        post_platbell: TitleModel_platbell,
        completion_platbell: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            TitleViewModel_platbell.shared_platbell.deletePost_platbell(post_platbell: post_platbell)
            print("✅ 已举报帖子: \(post_platbell.title_platbell)")
            
            // 确保在主线程上执行回调
            DispatchQueue.main.async {
                completion_platbell?()
            }
        }
    }
    
    /// 执行举报评论操作
    /// - Parameters:
    ///   - comment_platbell: 被举报的评论
    ///   - post_platbell: 评论所属帖子
    ///   - completion_platbell: 操作完成回调
    private static func performReportComment_platbell(
        comment_platbell: Comment_platbell,
        post_platbell: TitleModel_platbell,
        completion_platbell: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            TitleViewModel_platbell.shared_platbell.deleteComment_platbell(
                post_platbell: post_platbell,
                comment_platbell: comment_platbell
            )
            print("✅ 已举报评论: \(comment_platbell.commentContent_platbell)")
            
            // 确保在主线程上执行回调
            DispatchQueue.main.async {
                completion_platbell?()
            }
        }
    }
    
    /// 执行删除帖子操作
    /// - Parameters:
    ///   - post_platbell: 要删除的帖子
    ///   - completion_platbell: 操作完成回调
    private static func performDeletePost_platbell(
        post_platbell: TitleModel_platbell,
        completion_platbell: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 调用 ViewModel 删除帖子
            TitleViewModel_platbell.shared_platbell.deletePost_platbell(
                post_platbell: post_platbell,
                isDelete_platbell: true
            )
            print("✅ 已删除帖子: \(post_platbell.title_platbell)")
            
            // 确保在主线程上执行回调
            DispatchQueue.main.async {
                completion_platbell?()
            }
        }
    }
    
    /// 执行删除评论操作
    /// - Parameters:
    ///   - comment_platbell: 要删除的评论
    ///   - post_platbell: 评论所属帖子
    ///   - completion_platbell: 操作完成回调
    private static func performDeleteComment_platbell(
        comment_platbell: Comment_platbell,
        post_platbell: TitleModel_platbell,
        completion_platbell: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 调用 ViewModel 删除评论
            TitleViewModel_platbell.shared_platbell.deleteComment_platbell(
                post_platbell: post_platbell,
                comment_platbell: comment_platbell,
                isDelete_platbell: true
            )
            print("✅ 已删除评论: \(comment_platbell.commentContent_platbell)")
            
            // 确保在主线程上执行回调
            DispatchQueue.main.async {
                completion_platbell?()
            }
        }
    }
}

// MARK: - 举报ActionSheet组件

/// 举报菜单组件
/// 功能：展示举报选项的ActionSheet
struct ReportActionSheet_platbell: View {
    
    /// 是否显示
    @Binding var isShowing_platbell: Bool
    
    /// 是否是拉黑用户（true=拉黑用户, false=举报内容）
    let isBlockUser_platbell: Bool
    
    /// 确认回调
    let onConfirm_platbell: () -> Void
    
    var body: some View {
        VStack {}
            .actionSheet(isPresented: $isShowing_platbell) {
                ActionSheet(
                    title: Text("More"),
                    message: nil,
                    buttons: actionButtons_platbell
                )
            }
    }
    
    /// 构建操作按钮列表
    private var actionButtons_platbell: [ActionSheet.Button] {
        var buttons_platbell: [ActionSheet.Button] = []
        
        // 举报内容选项
        buttons_platbell.append(contentsOf: [
            .default(Text("Report Sexually Explicit Material")) {
                onConfirm_platbell()
                isShowing_platbell = false
            },
            .default(Text("Report spam")) {
                onConfirm_platbell()
                isShowing_platbell = false
            },
            .default(Text("Report something else")) {
                onConfirm_platbell()
                isShowing_platbell = false
            },
            .destructive(Text(isBlockUser_platbell ? "Block" : "Report")) {
                onConfirm_platbell()
                isShowing_platbell = false
            }
        ])
        
        // 添加取消按钮
        buttons_platbell.append(
            .cancel {
                isShowing_platbell = false
            }
        )
        
        return buttons_platbell
    }
}
