import SwiftUI

// MARK: - 举报/删除助手类
// 核心作用：提供举报用户、帖子、评论以及删除帖子、评论的统一接口
// 设计思路：参考业务逻辑，提供清晰的操作流程，SwiftUI版本
// 关键功能：举报、删除、拉黑用户

/// 举报/删除助手类
class ReportHelper_baseswiftui {
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_baseswiftui {
        case block_baseswiftui       // 拉黑用户
        case post_baseswiftui        // 举报帖子
        case comment_baseswiftui     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    /// - Parameters:
    ///   - user_baseswiftui: 要拉黑的用户模型
    ///   - completion_baseswiftui: 拉黑完成回调
    static func blockUser_baseswiftui(
        user_baseswiftui: PrewUserModel_baseswiftui,
        completion_baseswiftui: (() -> Void)? = nil
    ) {
        // 执行拉黑用户逻辑
        performBlockUser_baseswiftui(user_baseswiftui: user_baseswiftui)
        completion_baseswiftui?()
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    /// - Parameters:
    ///   - post_baseswiftui: 被举报的帖子模型
    ///   - completion_baseswiftui: 举报完成回调
    static func reportPost_baseswiftui(
        post_baseswiftui: TitleModel_baseswiftui,
        completion_baseswiftui: (() -> Void)? = nil
    ) {
        // 执行举报帖子逻辑，操作完成后调用回调
        performReportPost_baseswiftui(
            post_baseswiftui: post_baseswiftui,
            completion_baseswiftui: completion_baseswiftui
        )
    }
    
    /// 举报评论
    /// - Parameters:
    ///   - comment_baseswiftui: 被举报的评论模型
    ///   - post_baseswiftui: 评论所属的帖子
    ///   - completion_baseswiftui: 举报完成回调
    static func reportComment_baseswiftui(
        comment_baseswiftui: Comment_baseswiftui,
        post_baseswiftui: TitleModel_baseswiftui,
        completion_baseswiftui: (() -> Void)? = nil
    ) {
        performReportComment_baseswiftui(
            comment_baseswiftui: comment_baseswiftui,
            post_baseswiftui: post_baseswiftui,
            completion_baseswiftui: completion_baseswiftui
        )
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    /// - Parameters:
    ///   - post_baseswiftui: 要删除的帖子模型
    ///   - completion_baseswiftui: 删除完成回调
    static func deletePost_baseswiftui(
        post_baseswiftui: TitleModel_baseswiftui,
        completion_baseswiftui: (() -> Void)? = nil
    ) {
        // 执行删除帖子逻辑，操作完成后调用回调
        performDeletePost_baseswiftui(
            post_baseswiftui: post_baseswiftui,
            completion_baseswiftui: completion_baseswiftui
        )
    }
    
    /// 删除评论
    /// - Parameters:
    ///   - comment_baseswiftui: 要删除的评论模型
    ///   - post_baseswiftui: 评论所属的帖子
    ///   - completion_baseswiftui: 删除完成回调
    static func deleteComment_baseswiftui(
        comment_baseswiftui: Comment_baseswiftui,
        post_baseswiftui: TitleModel_baseswiftui,
        completion_baseswiftui: (() -> Void)? = nil
    ) {
        // 执行删除评论逻辑，操作完成后调用回调
        performDeleteComment_baseswiftui(
            comment_baseswiftui: comment_baseswiftui,
            post_baseswiftui: post_baseswiftui,
            completion_baseswiftui: completion_baseswiftui
        )
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 执行拉黑用户操作
    /// - Parameter user_baseswiftui: 要拉黑的用户
    private static func performBlockUser_baseswiftui(user_baseswiftui: PrewUserModel_baseswiftui) {
        // 模拟网络请求延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UserViewModel_baseswiftui.shared_baseswiftui.reportUser_baseswiftui(user_baseswiftui: user_baseswiftui)
            print("✅ 已拉黑用户: \(user_baseswiftui.userName_baseswiftui ?? "Unknown")")
        }
    }
    
    /// 执行举报帖子操作
    /// - Parameters:
    ///   - post_baseswiftui: 被举报的帖子
    ///   - completion_baseswiftui: 操作完成回调
    private static func performReportPost_baseswiftui(
        post_baseswiftui: TitleModel_baseswiftui,
        completion_baseswiftui: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            TitleViewModel_baseswiftui.shared_baseswiftui.deletePost_baseswiftui(post_baseswiftui: post_baseswiftui)
            print("✅ 已举报帖子: \(post_baseswiftui.title_baseswiftui)")
            
            // 确保在主线程上执行回调
            DispatchQueue.main.async {
                completion_baseswiftui?()
            }
        }
    }
    
    /// 执行举报评论操作
    /// - Parameters:
    ///   - comment_baseswiftui: 被举报的评论
    ///   - post_baseswiftui: 评论所属帖子
    ///   - completion_baseswiftui: 操作完成回调
    private static func performReportComment_baseswiftui(
        comment_baseswiftui: Comment_baseswiftui,
        post_baseswiftui: TitleModel_baseswiftui,
        completion_baseswiftui: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            TitleViewModel_baseswiftui.shared_baseswiftui.deleteComment_baseswiftui(
                post_baseswiftui: post_baseswiftui,
                comment_baseswiftui: comment_baseswiftui
            )
            print("✅ 已举报评论: \(comment_baseswiftui.commentContent_baseswiftui)")
            
            // 确保在主线程上执行回调
            DispatchQueue.main.async {
                completion_baseswiftui?()
            }
        }
    }
    
    /// 执行删除帖子操作
    /// - Parameters:
    ///   - post_baseswiftui: 要删除的帖子
    ///   - completion_baseswiftui: 操作完成回调
    private static func performDeletePost_baseswiftui(
        post_baseswiftui: TitleModel_baseswiftui,
        completion_baseswiftui: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 调用 ViewModel 删除帖子
            TitleViewModel_baseswiftui.shared_baseswiftui.deletePost_baseswiftui(
                post_baseswiftui: post_baseswiftui,
                isDelete_baseswiftui: true
            )
            print("✅ 已删除帖子: \(post_baseswiftui.title_baseswiftui)")
            
            // 确保在主线程上执行回调
            DispatchQueue.main.async {
                completion_baseswiftui?()
            }
        }
    }
    
    /// 执行删除评论操作
    /// - Parameters:
    ///   - comment_baseswiftui: 要删除的评论
    ///   - post_baseswiftui: 评论所属帖子
    ///   - completion_baseswiftui: 操作完成回调
    private static func performDeleteComment_baseswiftui(
        comment_baseswiftui: Comment_baseswiftui,
        post_baseswiftui: TitleModel_baseswiftui,
        completion_baseswiftui: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 调用 ViewModel 删除评论
            TitleViewModel_baseswiftui.shared_baseswiftui.deleteComment_baseswiftui(
                post_baseswiftui: post_baseswiftui,
                comment_baseswiftui: comment_baseswiftui,
                isDelete_baseswiftui: true
            )
            print("✅ 已删除评论: \(comment_baseswiftui.commentContent_baseswiftui)")
            
            // 确保在主线程上执行回调
            DispatchQueue.main.async {
                completion_baseswiftui?()
            }
        }
    }
}

// MARK: - 举报ActionSheet组件

/// 举报菜单组件
/// 功能：展示举报选项的ActionSheet
struct ReportActionSheet_baseswiftui: View {
    
    /// 是否显示
    @Binding var isShowing_baseswiftui: Bool
    
    /// 是否是拉黑用户（true=拉黑用户, false=举报内容）
    let isBlockUser_baseswiftui: Bool
    
    /// 确认回调
    let onConfirm_baseswiftui: () -> Void
    
    var body: some View {
        VStack {}
            .actionSheet(isPresented: $isShowing_baseswiftui) {
                ActionSheet(
                    title: Text("More"),
                    message: nil,
                    buttons: actionButtons_baseswiftui
                )
            }
    }
    
    /// 构建操作按钮列表
    private var actionButtons_baseswiftui: [ActionSheet.Button] {
        var buttons_baseswiftui: [ActionSheet.Button] = []
        
        // 举报内容选项
        buttons_baseswiftui.append(contentsOf: [
            .default(Text("Report Sexually Explicit Material")) {
                onConfirm_baseswiftui()
                isShowing_baseswiftui = false
            },
            .default(Text("Report spam")) {
                onConfirm_baseswiftui()
                isShowing_baseswiftui = false
            },
            .default(Text("Report something else")) {
                onConfirm_baseswiftui()
                isShowing_baseswiftui = false
            },
            .destructive(Text(isBlockUser_baseswiftui ? "Block" : "Report")) {
                onConfirm_baseswiftui()
                isShowing_baseswiftui = false
            }
        ])
        
        // 添加取消按钮
        buttons_baseswiftui.append(
            .cancel {
                isShowing_baseswiftui = false
            }
        )
        
        return buttons_baseswiftui
    }
}
