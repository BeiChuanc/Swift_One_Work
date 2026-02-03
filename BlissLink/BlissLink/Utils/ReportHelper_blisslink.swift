import SwiftUI

// MARK: - 举报/删除助手类
// 核心作用：提供举报用户、帖子、评论以及删除帖子、评论的统一接口
// 设计思路：参考业务逻辑，提供清晰的操作流程，SwiftUI版本
// 关键功能：举报、删除、拉黑用户

/// 举报/删除助手类
class ReportHelper_blisslink {
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_blisslink {
        case block_blisslink       // 拉黑用户
        case post_blisslink        // 举报帖子
        case comment_blisslink     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    /// - Parameters:
    ///   - user_blisslink: 要拉黑的用户模型
    ///   - completion_blisslink: 拉黑完成回调
    static func blockUser_blisslink(
        user_blisslink: PrewUserModel_baseswiftui,
        completion_blisslink: (() -> Void)? = nil
    ) {
        // 执行拉黑用户逻辑
        performBlockUser_blisslink(user_blisslink: user_blisslink)
        completion_blisslink?()
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    /// - Parameters:
    ///   - post_blisslink: 被举报的帖子模型
    ///   - completion_blisslink: 举报完成回调
    static func reportPost_blisslink(
        post_blisslink: TitleModel_baseswiftui,
        completion_blisslink: (() -> Void)? = nil
    ) {
        // 执行举报帖子逻辑，操作完成后调用回调
        performReportPost_blisslink(
            post_blisslink: post_blisslink,
            completion_blisslink: completion_blisslink
        )
    }
    
    /// 举报评论
    /// - Parameters:
    ///   - comment_blisslink: 被举报的评论模型
    ///   - post_blisslink: 评论所属的帖子
    ///   - completion_blisslink: 举报完成回调
    static func reportComment_blisslink(
        comment_blisslink: Comment_baseswiftui,
        post_blisslink: TitleModel_baseswiftui,
        completion_blisslink: (() -> Void)? = nil
    ) {
        performReportComment_blisslink(
            comment_blisslink: comment_blisslink,
            post_blisslink: post_blisslink,
            completion_blisslink: completion_blisslink
        )
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    /// - Parameters:
    ///   - post_blisslink: 要删除的帖子模型
    ///   - completion_blisslink: 删除完成回调
    static func deletePost_blisslink(
        post_blisslink: TitleModel_baseswiftui,
        completion_blisslink: (() -> Void)? = nil
    ) {
        // 执行删除帖子逻辑，操作完成后调用回调
        performDeletePost_blisslink(
            post_blisslink: post_blisslink,
            completion_blisslink: completion_blisslink
        )
    }
    
    /// 删除评论
    /// - Parameters:
    ///   - comment_blisslink: 要删除的评论模型
    ///   - post_blisslink: 评论所属的帖子
    ///   - completion_blisslink: 删除完成回调
    static func deleteComment_blisslink(
        comment_blisslink: Comment_baseswiftui,
        post_blisslink: TitleModel_baseswiftui,
        completion_blisslink: (() -> Void)? = nil
    ) {
        // 执行删除评论逻辑，操作完成后调用回调
        performDeleteComment_blisslink(
            comment_blisslink: comment_blisslink,
            post_blisslink: post_blisslink,
            completion_blisslink: completion_blisslink
        )
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 执行拉黑用户操作
    /// - Parameter user_blisslink: 要拉黑的用户
    private static func performBlockUser_blisslink(user_blisslink: PrewUserModel_baseswiftui) {
        // 模拟网络请求延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UserViewModel_baseswiftui.shared_baseswiftui.reportUser_baseswiftui(user_baseswiftui: user_blisslink)
            print("✅ 已拉黑用户: \(user_blisslink.userName_baseswiftui ?? "Unknown")")
        }
    }
    
    /// 执行举报帖子操作
    /// - Parameters:
    ///   - post_blisslink: 被举报的帖子
    ///   - completion_blisslink: 操作完成回调
    private static func performReportPost_blisslink(
        post_blisslink: TitleModel_baseswiftui,
        completion_blisslink: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            TitleViewModel_baseswiftui.shared_baseswiftui.deletePost_baseswiftui(post_baseswiftui: post_blisslink)
            print("✅ 已举报帖子: \(post_blisslink.title_baseswiftui)")
            
            // 确保在主线程上执行回调
            DispatchQueue.main.async {
                completion_blisslink?()
            }
        }
    }
    
    /// 执行举报评论操作
    /// - Parameters:
    ///   - comment_blisslink: 被举报的评论
    ///   - post_blisslink: 评论所属帖子
    ///   - completion_blisslink: 操作完成回调
    private static func performReportComment_blisslink(
        comment_blisslink: Comment_baseswiftui,
        post_blisslink: TitleModel_baseswiftui,
        completion_blisslink: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            TitleViewModel_baseswiftui.shared_baseswiftui.deleteComment_baseswiftui(
                post_baseswiftui: post_blisslink,
                comment_baseswiftui: comment_blisslink
            )
            print("✅ 已举报评论: \(comment_blisslink.commentContent_baseswiftui)")
            
            // 确保在主线程上执行回调
            DispatchQueue.main.async {
                completion_blisslink?()
            }
        }
    }
    
    /// 执行删除帖子操作
    /// - Parameters:
    ///   - post_blisslink: 要删除的帖子
    ///   - completion_blisslink: 操作完成回调
    private static func performDeletePost_blisslink(
        post_blisslink: TitleModel_baseswiftui,
        completion_blisslink: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 调用 ViewModel 删除帖子
            TitleViewModel_baseswiftui.shared_baseswiftui.deletePost_baseswiftui(
                post_baseswiftui: post_blisslink,
                isDelete_baseswiftui: true
            )
            print("✅ 已删除帖子: \(post_blisslink.title_baseswiftui)")
            
            // 确保在主线程上执行回调
            DispatchQueue.main.async {
                completion_blisslink?()
            }
        }
    }
    
    /// 执行删除评论操作
    /// - Parameters:
    ///   - comment_blisslink: 要删除的评论
    ///   - post_blisslink: 评论所属帖子
    ///   - completion_blisslink: 操作完成回调
    private static func performDeleteComment_blisslink(
        comment_blisslink: Comment_baseswiftui,
        post_blisslink: TitleModel_baseswiftui,
        completion_blisslink: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 调用 ViewModel 删除评论
            TitleViewModel_baseswiftui.shared_baseswiftui.deleteComment_baseswiftui(
                post_baseswiftui: post_blisslink,
                comment_baseswiftui: comment_blisslink,
                isDelete_baseswiftui: true
            )
            print("✅ 已删除评论: \(comment_blisslink.commentContent_baseswiftui)")
            
            // 确保在主线程上执行回调
            DispatchQueue.main.async {
                completion_blisslink?()
            }
        }
    }
}

// MARK: - 举报ActionSheet组件

/// 举报菜单组件
/// 功能：展示举报选项的ActionSheet
struct ReportActionSheet_blisslink: View {
    
    /// 是否显示
    @Binding var isShowing_blisslink: Bool
    
    /// 是否是拉黑用户（true=拉黑用户, false=举报内容）
    let isBlockUser_blisslink: Bool
    
    /// 确认回调
    let onConfirm_blisslink: () -> Void
    
    var body: some View {
        VStack {}
            .actionSheet(isPresented: $isShowing_blisslink) {
                ActionSheet(
                    title: Text("More"),
                    message: nil,
                    buttons: actionButtons_blisslink
                )
            }
    }
    
    /// 构建操作按钮列表
    private var actionButtons_blisslink: [ActionSheet.Button] {
        var buttons_blisslink: [ActionSheet.Button] = []
        
        // 举报内容选项
        buttons_blisslink.append(contentsOf: [
            .default(Text("Report Sexually Explicit Material")) {
                onConfirm_blisslink()
                isShowing_blisslink = false
            },
            .default(Text("Report spam")) {
                onConfirm_blisslink()
                isShowing_blisslink = false
            },
            .default(Text("Report something else")) {
                onConfirm_blisslink()
                isShowing_blisslink = false
            },
            .destructive(Text(isBlockUser_blisslink ? "Block" : "Report")) {
                onConfirm_blisslink()
                isShowing_blisslink = false
            }
        ])
        
        // 添加取消按钮
        buttons_blisslink.append(
            .cancel {
                isShowing_blisslink = false
            }
        )
        
        return buttons_blisslink
    }
}
