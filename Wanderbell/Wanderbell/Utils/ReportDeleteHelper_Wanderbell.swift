import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
/// 功能：提供举报用户、帖子、评论以及删除帖子、评论的统一接口
/// 设计：参考业务逻辑，提供清晰的操作流程
class ReportDeleteHelper_Wanderbell {
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Wanderbell {
        case block_Wanderbell       // 拉黑用户
        case post_Wanderbell        // 举报帖子
        case comment_Wanderbell     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    /// - Parameters:
    ///   - user_wanderbell: 要拉黑的用户模型
    ///   - viewController_wanderbell: 当前视图控制器
    ///   - completion_wanderbell: 拉黑完成回调
    static func block_Wanderbell(
        user_wanderbell: PrewUserModel_Wanderbell,
        from viewController_wanderbell: UIViewController,
        completion_wanderbell: (() -> Void)? = nil
    ) {
        UIAlertController.report_Wanderbell(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Wanderbell(
                user_wanderbell: user_wanderbell,
                viewController_wanderbell: viewController_wanderbell
            )
            completion_wanderbell?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    /// - Parameters:
    ///   - post_wanderbell: 被举报的帖子模型
    ///   - viewController_wanderbell: 当前视图控制器
    ///   - completion_wanderbell: 举报完成回调
    static func report_Wanderbell(
        post_wanderbell: TitleModel_Wanderbell,
        from viewController_wanderbell: UIViewController,
        completion_wanderbell: (() -> Void)? = nil
    ) {
        UIAlertController.report_Wanderbell(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Wanderbell(
                post_wanderbell: post_wanderbell,
                viewController_wanderbell: viewController_wanderbell,
                completion_wanderbell: completion_wanderbell)
        })
    }
    
    /// 举报评论
    /// - Parameters:
    ///   - comment_wanderbell: 被举报的评论模型
    ///   - post_wanderbell: 评论所属的帖子
    ///   - viewController_wanderbell: 当前视图控制器
    ///   - completion_wanderbell: 举报完成回调
    static func report_Wanderbell(
        comment_wanderbell: Comment_Wanderbell,
        post_wanderbell: TitleModel_Wanderbell,
        from viewController_wanderbell: UIViewController,
        completion_wanderbell: (() -> Void)? = nil
    ) {
        UIAlertController.report_Wanderbell(with: false, completeBlock: {
            performReportComment_Wanderbell(
                comment_wanderbell: comment_wanderbell,
                post_wanderbell: post_wanderbell,
                viewController_wanderbell: viewController_wanderbell,
                completion_wanderbell: completion_wanderbell)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    /// - Parameters:
    ///   - post_wanderbell: 要删除的帖子模型
    ///   - viewController_wanderbell: 当前视图控制器
    ///   - completion_wanderbell: 删除完成回调
    static func delete_Wanderbell(
        post_wanderbell: TitleModel_Wanderbell,
        from viewController_wanderbell: UIViewController,
        completion_wanderbell: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Wanderbell(
            title_wanderbell: "Delete Post",
            message_wanderbell: "Are you sure you want to delete this post? This action cannot be undone.",
            from: viewController_wanderbell
        ) {
            // 执行删除帖子逻辑，操作完成后调用回调
            performDeletePost_Wanderbell(
                post_wanderbell: post_wanderbell,
                viewController_wanderbell: viewController_wanderbell,
                completion_wanderbell: completion_wanderbell
            )
        }
    }
    
    /// 删除评论
    /// - Parameters:
    ///   - comment_wanderbell: 要删除的评论模型
    ///   - post_wanderbell: 评论所属的帖子
    ///   - viewController_wanderbell: 当前视图控制器
    ///   - completion_wanderbell: 删除完成回调
    static func delete_Wanderbell(
        comment_wanderbell: Comment_Wanderbell,
        post_wanderbell: TitleModel_Wanderbell,
        from viewController_wanderbell: UIViewController,
        completion_wanderbell: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Wanderbell(
            title_wanderbell: "Delete Comment",
            message_wanderbell: "Are you sure you want to delete this comment? This action cannot be undone.",
            from: viewController_wanderbell
        ) {
            // 执行删除评论逻辑，操作完成后调用回调
            performDeleteComment_Wanderbell(
                comment_wanderbell: comment_wanderbell,
                post_wanderbell: post_wanderbell,
                viewController_wanderbell: viewController_wanderbell,
                completion_wanderbell: completion_wanderbell
            )
        }
    }
    
    /// 显示删除确认对话框
    /// - Parameters:
    ///   - title_wanderbell: 对话框标题
    ///   - message_wanderbell: 对话框消息
    ///   - viewController_wanderbell: 当前视图控制器
    ///   - completion_wanderbell: 确认删除回调
    private static func showDeleteConfirmAlert_Wanderbell(
        title_wanderbell: String,
        message_wanderbell: String,
        from viewController_wanderbell: UIViewController,
        completion_wanderbell: @escaping () -> Void
    ) {
        let alert_wanderbell = UIAlertController(
            title: title_wanderbell,
            message: message_wanderbell,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_wanderbell = UIAlertAction(
            title: "Delete",
            style: .destructive
        ) { _ in
            completion_wanderbell()
        }
        
        // 取消按钮
        let cancelAction_wanderbell = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        )
        
        alert_wanderbell.addAction(deleteAction_wanderbell)
        alert_wanderbell.addAction(cancelAction_wanderbell)
        
        viewController_wanderbell.present(alert_wanderbell, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 执行拉黑用户操作
    /// - Parameters:
    ///   - user_wanderbell: 要拉黑的用户
    ///   - viewController_wanderbell: 当前视图控制器
    private static func performBlockUser_Wanderbell(
        user_wanderbell: PrewUserModel_Wanderbell,
        viewController_wanderbell: UIViewController
    ) {
        // 模拟网络请求延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UserViewModel_Wanderbell.shared_Wanderbell.reportUser_Wanderbell(user_wanderbell: user_wanderbell)
            print("已拉黑用户: \(user_wanderbell.userName_Wanderbell ?? "Unknown")")
        }
    }
    
    /// 执行举报帖子操作
    /// - Parameters:
    ///   - post_wanderbell: 被举报的帖子
    ///   - viewController_wanderbell: 当前视图控制器
    ///   - completion_wanderbell: 操作完成回调
    private static func performReportPost_Wanderbell(
        post_wanderbell: TitleModel_Wanderbell,
        viewController_wanderbell: UIViewController,
        completion_wanderbell: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            TitleViewModel_Wanderbell.shared_Wanderbell.deletePost_Wanderbell(post_wanderbell: post_wanderbell)
            print("已举报帖子: \(post_wanderbell.title_Wanderbell)")
            
            // 确保在主线程上执行回调
            DispatchQueue.main.async {
                completion_wanderbell?()
            }
        }
    }
    
    /// 执行举报评论操作
    /// - Parameters:
    ///   - comment_wanderbell: 被举报的评论
    ///   - post_wanderbell: 评论所属帖子
    ///   - viewController_wanderbell: 当前视图控制器
    ///   - completion_wanderbell: 操作完成回调
    private static func performReportComment_Wanderbell(
        comment_wanderbell: Comment_Wanderbell,
        post_wanderbell: TitleModel_Wanderbell,
        viewController_wanderbell: UIViewController,
        completion_wanderbell: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            TitleViewModel_Wanderbell.shared_Wanderbell.deleteComment_Wanderbell(post_wanderbell: post_wanderbell, comment_wanderbell: comment_wanderbell)
            print("已举报评论: \(comment_wanderbell.commentContent_Wanderbell)")
            
            // 确保在主线程上执行回调
            DispatchQueue.main.async {
                completion_wanderbell?()
            }
        }
    }
    
    /// 执行删除帖子操作
    /// - Parameters:
    ///   - post_wanderbell: 要删除的帖子
    ///   - viewController_wanderbell: 当前视图控制器
    ///   - completion_wanderbell: 操作完成回调
    private static func performDeletePost_Wanderbell(
        post_wanderbell: TitleModel_Wanderbell,
        viewController_wanderbell: UIViewController,
        completion_wanderbell: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 调用 ViewModel 删除帖子
            TitleViewModel_Wanderbell.shared_Wanderbell.deletePost_Wanderbell(
                post_wanderbell: post_wanderbell,
                isDelete_wanderbell: true
            )
            print("已删除帖子: \(post_wanderbell.title_Wanderbell)")
            
            // 确保在主线程上执行回调
            DispatchQueue.main.async {
                completion_wanderbell?()
            }
        }
    }
    
    /// 执行删除评论操作
    /// - Parameters:
    ///   - comment_wanderbell: 要删除的评论
    ///   - post_wanderbell: 评论所属帖子
    ///   - viewController_wanderbell: 当前视图控制器
    ///   - completion_wanderbell: 操作完成回调
    private static func performDeleteComment_Wanderbell(
        comment_wanderbell: Comment_Wanderbell,
        post_wanderbell: TitleModel_Wanderbell,
        viewController_wanderbell: UIViewController,
        completion_wanderbell: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 调用 ViewModel 删除评论
            TitleViewModel_Wanderbell.shared_Wanderbell.deleteComment_Wanderbell(
                post_wanderbell: post_wanderbell,
                comment_wanderbell: comment_wanderbell,
                isDelete_wanderbell: true
            )
            print("已删除评论: \(comment_wanderbell.commentContent_Wanderbell)")
            
            // 确保在主线程上执行回调
            DispatchQueue.main.async {
                completion_wanderbell?()
            }
        }
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    /// 功能：根据帖子信息创建举报或删除按钮
    /// 参数：
    /// - post_wanderbell: 帖子模型
    /// - size_wanderbell: 按钮大小（默认25）
    /// - color_wanderbell: 按钮颜色（默认黑色）
    /// - viewController_wanderbell: 当前视图控制器
    /// - completion_wanderbell: 操作完成回调
    /// 返回值：配置好的按钮
    @MainActor static func createPostReportButton_Wanderbell(
        post_wanderbell: TitleModel_Wanderbell,
        size_wanderbell: CGFloat = 25,
        color_wanderbell: UIColor = .black,
        from viewController_wanderbell: UIViewController,
        completion_wanderbell: (() -> Void)? = nil
    ) -> UIButton {
        let button_wanderbell = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.isCurrentUser_Wanderbell(
            userId_wanderbell: post_wanderbell.titleUserId_Wanderbell
        )
        
        // 配置按钮图标
        let config_wanderbell = UIImage.SymbolConfiguration(pointSize: size_wanderbell, weight: .semibold)
        let iconName_wanderbell = isMyPost_wanderbell ? "trash" : "ellipsis"
        let image_wanderbell = UIImage(systemName: iconName_wanderbell, withConfiguration: config_wanderbell)
        button_wanderbell.setImage(image_wanderbell, for: .normal)
        button_wanderbell.tintColor = color_wanderbell
        
        // 添加点击事件
        if #available(iOS 14.0, *) {
            button_wanderbell.addAction(UIAction { _ in
                // 添加按钮点击动画
                addButtonAnimation_Wanderbell(button_wanderbell: button_wanderbell)
                
                if isMyPost_wanderbell {
                    // 删除自己的帖子
                    delete_Wanderbell(
                        post_wanderbell: post_wanderbell,
                        from: viewController_wanderbell,
                        completion_wanderbell: completion_wanderbell
                    )
                } else {
                    // 举报别人的帖子
                    report_Wanderbell(
                        post_wanderbell: post_wanderbell,
                        from: viewController_wanderbell,
                        completion_wanderbell: completion_wanderbell
                    )
                }
            }, for: .touchUpInside)
        } else {
            // iOS 13 及更早版本的兼容处理
            let action_wanderbell = PostButtonAction_Wanderbell(
                post_wanderbell: post_wanderbell,
                isMyPost_wanderbell: isMyPost_wanderbell,
                viewController_wanderbell: viewController_wanderbell,
                completion_wanderbell: completion_wanderbell
            )
            
            // 使用关联对象保存action，防止被释放
            objc_setAssociatedObject(
                button_wanderbell,
                &AssociatedKeys_Wanderbell.postAction_wanderbell,
                action_wanderbell,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            
            button_wanderbell.addTarget(
                action_wanderbell,
                action: #selector(PostButtonAction_Wanderbell.handleTap_Wanderbell),
                for: .touchUpInside
            )
        }
        
        return button_wanderbell
    }
    
    /// 创建评论举报按钮
    /// 功能：根据评论信息创建举报或删除按钮
    /// 参数：
    /// - comment_wanderbell: 评论模型
    /// - post_wanderbell: 评论所属帖子
    /// - size_wanderbell: 按钮大小（默认25）
    /// - color_wanderbell: 按钮颜色（默认黑色）
    /// - viewController_wanderbell: 当前视图控制器
    /// - completion_wanderbell: 操作完成回调
    /// 返回值：配置好的按钮
    @MainActor static func createCommentReportButton_Wanderbell(
        comment_wanderbell: Comment_Wanderbell,
        post_wanderbell: TitleModel_Wanderbell,
        size_wanderbell: CGFloat = 25,
        color_wanderbell: UIColor = .black,
        from viewController_wanderbell: UIViewController,
        completion_wanderbell: (() -> Void)? = nil
    ) -> UIButton {
        let button_wanderbell = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.isCurrentUser_Wanderbell(
            userId_wanderbell: comment_wanderbell.commentUserId_Wanderbell
        )
        
        // 配置按钮图标
        let config_wanderbell = UIImage.SymbolConfiguration(pointSize: size_wanderbell, weight: .semibold)
        let iconName_wanderbell = isMyComment_wanderbell ? "trash" : "ellipsis"
        let image_wanderbell = UIImage(systemName: iconName_wanderbell, withConfiguration: config_wanderbell)
        button_wanderbell.setImage(image_wanderbell, for: .normal)
        button_wanderbell.tintColor = color_wanderbell
        
        // 添加点击事件
        if #available(iOS 14.0, *) {
            button_wanderbell.addAction(UIAction { _ in
                // 添加按钮点击动画
                addButtonAnimation_Wanderbell(button_wanderbell: button_wanderbell)
                
                if isMyComment_wanderbell {
                    // 删除自己的评论
                    delete_Wanderbell(
                        comment_wanderbell: comment_wanderbell,
                        post_wanderbell: post_wanderbell,
                        from: viewController_wanderbell,
                        completion_wanderbell: completion_wanderbell
                    )
                } else {
                    // 举报别人的评论
                    report_Wanderbell(
                        comment_wanderbell: comment_wanderbell,
                        post_wanderbell: post_wanderbell,
                        from: viewController_wanderbell,
                        completion_wanderbell: completion_wanderbell
                    )
                }
            }, for: .touchUpInside)
        } else {
            // iOS 13 及更早版本的兼容处理
            let action_wanderbell = CommentButtonAction_Wanderbell(
                comment_wanderbell: comment_wanderbell,
                post_wanderbell: post_wanderbell,
                isMyComment_wanderbell: isMyComment_wanderbell,
                viewController_wanderbell: viewController_wanderbell,
                completion_wanderbell: completion_wanderbell
            )
            
            // 使用关联对象保存action，防止被释放
            objc_setAssociatedObject(
                button_wanderbell,
                &AssociatedKeys_Wanderbell.commentAction_wanderbell,
                action_wanderbell,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            
            button_wanderbell.addTarget(
                action_wanderbell,
                action: #selector(CommentButtonAction_Wanderbell.handleTap_Wanderbell),
                for: .touchUpInside
            )
        }
        
        return button_wanderbell
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    /// 功能：创建用户举报按钮，带有现代化UI设计
    /// 参数：
    /// - size_wanderbell: 按钮大小（默认44）
    /// - backgroundColor_wanderbell: 背景颜色（可选，默认半透明白色）
    /// - tintColor_wanderbell: 图标颜色（默认白色）
    /// - withShadow_wanderbell: 是否添加阴影（默认false）
    /// 返回值：配置好的按钮
    static func createUserReportButton_Wanderbell(
        size_wanderbell: CGFloat = 44,
        backgroundColor_wanderbell: UIColor? = nil,
        tintColor_wanderbell: UIColor = .white,
        withShadow_wanderbell: Bool = false
    ) -> UIButton {
        let button_wanderbell = UIButton(type: .system)
        
        // 配置图标
        let iconSize_wanderbell = size_wanderbell * 0.5
        let config_wanderbell = UIImage.SymbolConfiguration(pointSize: iconSize_wanderbell, weight: .semibold)
        let image_wanderbell = UIImage(systemName: "ellipsis", withConfiguration: config_wanderbell)
        button_wanderbell.setImage(image_wanderbell, for: .normal)
        button_wanderbell.tintColor = tintColor_wanderbell
        
        // 设置背景
        let bgColor_wanderbell = backgroundColor_wanderbell ?? UIColor.white.withAlphaComponent(0.2)
        button_wanderbell.backgroundColor = bgColor_wanderbell
        button_wanderbell.layer.cornerRadius = size_wanderbell / 2
        
        // 添加阴影
        if withShadow_wanderbell {
            button_wanderbell.layer.shadowColor = UIColor.black.cgColor
            button_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_wanderbell.layer.shadowOpacity = 0.15
            button_wanderbell.layer.shadowRadius = 8
        }
        
        return button_wanderbell
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    /// 功能：为按钮添加缩放动画效果
    /// 参数：
    /// - button_wanderbell: 需要添加动画的按钮
    fileprivate static func addButtonAnimation_Wanderbell(button_wanderbell: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button_wanderbell.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button_wanderbell.transform = .identity
            }
        }
    }
}

// MARK: - iOS 13 兼容辅助类

/// 关联对象键
private struct AssociatedKeys_Wanderbell {
    static var postAction_wanderbell: UInt8 = 0
    static var commentAction_wanderbell: UInt8 = 0
}

/// 帖子按钮动作类（iOS 13 兼容）
/// 功能：封装帖子按钮点击事件，用于 target-action 模式
private class PostButtonAction_Wanderbell {
    let post_Wanderbell: TitleModel_Wanderbell
    let isMyPost_Wanderbell: Bool
    weak var viewController_Wanderbell: UIViewController?
    let completion_Wanderbell: (() -> Void)?
    
    init(
        post_wanderbell: TitleModel_Wanderbell,
        isMyPost_wanderbell: Bool,
        viewController_wanderbell: UIViewController,
        completion_wanderbell: (() -> Void)?
    ) {
        self.post_Wanderbell = post_wanderbell
        self.isMyPost_Wanderbell = isMyPost_wanderbell
        self.viewController_Wanderbell = viewController_wanderbell
        self.completion_Wanderbell = completion_wanderbell
    }
    
    @objc func handleTap_Wanderbell(_ sender: UIButton) {
        // 添加按钮动画
        ReportDeleteHelper_Wanderbell.addButtonAnimation_Wanderbell(button_wanderbell: sender)
        
        guard let viewController_wanderbell = viewController_Wanderbell else { return }
        
        if isMyPost_Wanderbell {
            // 删除自己的帖子
            ReportDeleteHelper_Wanderbell.delete_Wanderbell(
                post_wanderbell: post_Wanderbell,
                from: viewController_wanderbell,
                completion_wanderbell: completion_Wanderbell
            )
        } else {
            // 举报别人的帖子
            ReportDeleteHelper_Wanderbell.report_Wanderbell(
                post_wanderbell: post_Wanderbell,
                from: viewController_wanderbell,
                completion_wanderbell: completion_Wanderbell
            )
        }
    }
}

/// 评论按钮动作类（iOS 13 兼容）
/// 功能：封装评论按钮点击事件，用于 target-action 模式
private class CommentButtonAction_Wanderbell {
    let comment_Wanderbell: Comment_Wanderbell
    let post_Wanderbell: TitleModel_Wanderbell
    let isMyComment_Wanderbell: Bool
    weak var viewController_Wanderbell: UIViewController?
    let completion_Wanderbell: (() -> Void)?
    
    init(
        comment_wanderbell: Comment_Wanderbell,
        post_wanderbell: TitleModel_Wanderbell,
        isMyComment_wanderbell: Bool,
        viewController_wanderbell: UIViewController,
        completion_wanderbell: (() -> Void)?
    ) {
        self.comment_Wanderbell = comment_wanderbell
        self.post_Wanderbell = post_wanderbell
        self.isMyComment_Wanderbell = isMyComment_wanderbell
        self.viewController_Wanderbell = viewController_wanderbell
        self.completion_Wanderbell = completion_wanderbell
    }
    
    @objc func handleTap_Wanderbell(_ sender: UIButton) {
        // 添加按钮动画
        ReportDeleteHelper_Wanderbell.addButtonAnimation_Wanderbell(button_wanderbell: sender)
        
        guard let viewController_wanderbell = viewController_Wanderbell else { return }
        
        if isMyComment_Wanderbell {
            // 删除自己的评论
            ReportDeleteHelper_Wanderbell.delete_Wanderbell(
                comment_wanderbell: comment_Wanderbell,
                post_wanderbell: post_Wanderbell,
                from: viewController_wanderbell,
                completion_wanderbell: completion_Wanderbell
            )
        } else {
            // 举报别人的评论
            ReportDeleteHelper_Wanderbell.report_Wanderbell(
                comment_wanderbell: comment_Wanderbell,
                post_wanderbell: post_Wanderbell,
                from: viewController_wanderbell,
                completion_wanderbell: completion_Wanderbell
            )
        }
    }
}
