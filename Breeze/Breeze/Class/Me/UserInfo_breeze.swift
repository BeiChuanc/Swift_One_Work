import Foundation
import UIKit
import SnapKit

// MARK: 用户中心页面

/// 用户中心页面
/// 核心作用：展示目标用户资料与帖子，支持关注/取消关注、进入聊天（二次确认）、举报用户/帖子
/// 设计思路：UICollectionView 两列网格 + 区头资料卡；固定返回与举报按钮；通知驱动刷新
/// 关键属性：userModel_Breeze 目标用户、isFromChat_Breeze 是否来自聊天
class UserInfo_Breeze: UIViewController {
    
    /// 用户模型
    var userModel_Breeze: PrewUserModel_Breeze?
    
    /// 是否从聊天页进入
    var isFromChat_Breeze: Bool = false
    
    // MARK: - 数据
    
    /// 该用户的帖子
    private var posts_Breeze: [TitleModel_Breeze] = []
    
    // MARK: - UI 组件
    
    /// 网格布局
    private let flowLayout_Breeze: UICollectionViewFlowLayout = {
        let layout_breeze = UICollectionViewFlowLayout()
        layout_breeze.minimumLineSpacing = 12
        layout_breeze.minimumInteritemSpacing = 12
        layout_breeze.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 120, right: 16)
        return layout_breeze
    }()
    
    /// 网格容器
    private lazy var collectionView_Breeze: UICollectionView = {
        let collectionView_breeze = UICollectionView(frame: .zero, collectionViewLayout: flowLayout_Breeze)
        collectionView_breeze.backgroundColor = .clear
        collectionView_breeze.showsVerticalScrollIndicator = false
        collectionView_breeze.contentInsetAdjustmentBehavior = .never
        return collectionView_breeze
    }()
    
    
    /// 返回按钮（半透明白色圆形，浮于渐变上方）
    private let backButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn_breeze.setImage(UIImage(systemName: "chevron.left", withConfiguration: config_breeze), for: .normal)
        btn_breeze.tintColor = .white
        btn_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        btn_breeze.layer.cornerRadius = 18
        return btn_breeze
    }()
    
    /// 举报按钮容器（半透明白色圆形，浮于渐变上方）
    private let reportContainer_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        v_breeze.layer.cornerRadius = 18
        return v_breeze
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Breeze()
        setupObservers_Breeze()
        reloadData_Breeze()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    // MARK: - UI 设置
    
    /// 搭建用户中心 UI
    private func setupUI_Breeze() {
        view.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        
        view.addSubview(collectionView_Breeze)
        view.addSubview(backButton_Breeze)
        view.addSubview(reportContainer_Breeze)
        
        collectionView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backButton_Breeze.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }
        reportContainer_Breeze.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }
        
        backButton_Breeze.addTarget(self, action: #selector(handleBack_Breeze), for: .touchUpInside)
        
        collectionView_Breeze.dataSource = self
        collectionView_Breeze.delegate = self
        collectionView_Breeze.register(ProfileGridCell_Breeze.self, forCellWithReuseIdentifier: ProfileGridCell_Breeze.reuseId_Breeze)
        collectionView_Breeze.register(
            UserInfoHeaderView_Breeze.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: UserInfoHeaderView_Breeze.reuseId_Breeze
        )
        
        setupReportButton_Breeze()
    }
    
    /// 配置举报用户按钮
    private func setupReportButton_Breeze() {
        let button_breeze = ReportDeleteHelper_Breeze.createUserReportButton_Breeze(
            size_Breeze: 36,
            backgroundColor_Breeze: .clear,
            tintColor_Breeze: .white,
            withShadow_Breeze: false
        )
        button_breeze.addTarget(self, action: #selector(handleReportUser_Breeze), for: .touchUpInside)
        reportContainer_Breeze.addSubview(button_breeze)
        button_breeze.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }
    
    @objc private func handleBack_Breeze() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - 通知
    
    private func setupObservers_Breeze() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData_Breeze), name: TitleViewModel_Breeze.titleStateDidChangeNotification_Breeze, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData_Breeze), name: UserViewModel_Breeze.userStateDidChangeNotification_Breeze, object: nil)
    }
    
    // MARK: - 数据
    
    /// 重新加载数据
    @objc private func reloadData_Breeze() {
        guard let user_breeze = userModel_Breeze else { return }
        posts_Breeze = TitleViewModel_Breeze.shared_Breeze.getUserPosts_Breeze(user_breeze: user_breeze)
        collectionView_Breeze.reloadData()
    }
    
    // MARK: - 事件
    
    /// 举报用户
    @objc private func handleReportUser_Breeze() {
        guard let user_breeze = userModel_Breeze else { return }
        ReportDeleteHelper_Breeze.block_Breeze(user_Breeze: user_breeze, from: self) { [weak self] in
            guard let self = self else { return }
            // 举报后清理相关页面并返回安全位置
            Navigation_Breeze.popToSafeStateAfterBlock_Breeze(from: self)
        }
    }
    
    /// 关注 / 取消关注
    private func handleFollow_Breeze() {
        guard let user_breeze = userModel_Breeze else { return }
        
        // 未登录则跳转登录页
        guard UserViewModel_Breeze.shared_Breeze.isLoggedIn_Breeze else {
            Navigation_Breeze.toLogin_Breeze(style_breeze: .present_breeze)
            return
        }
        
        let wasFollowing_breeze = UserViewModel_Breeze.shared_Breeze.isFollowing_Breeze(user_breeze: user_breeze)
        
        // 执行关注/取消关注（内部发通知）
        UserViewModel_Breeze.shared_Breeze.followUser_Breeze(user_breeze: user_breeze)
        
        // 本地同步更新目标用户的粉丝数，确保 UI 立即刷新正确
        let currentFans_breeze = user_breeze.userFans_Breeze ?? 0
        user_breeze.userFans_Breeze = wasFollowing_breeze
            ? max(0, currentFans_breeze - 1)
            : currentFans_breeze + 1
        
        // 从聊天进入且执行了"取消关注"：返回消息列表并移除会话
        if isFromChat_Breeze && wasFollowing_breeze {
            if let userId_breeze = user_breeze.userId_Breeze {
                MessageViewModel_Breeze.shared_Breeze.deleteUserMessages_Breeze(userId_breeze: userId_breeze)
            }
            backToMessageList_Breeze()
            return
        }
        
        // 强制刷新列表，包含区头关注按钮状态与统计数据
        collectionView_Breeze.reloadData()
    }
    
    /// 点击消息按钮
    private func handleMessage_Breeze() {
        guard let user_breeze = userModel_Breeze else { return }
        
        // 已关注：弹出底部确认弹窗，确认后进入聊天；未关注：提示先关注
        if UserViewModel_Breeze.shared_Breeze.isFollowing_Breeze(user_breeze: user_breeze) {
            UserConfirmSheet_Breeze.show_Breeze(user_breeze: user_breeze) {
                Navigation_Breeze.toMessageUser_Breeze(with: user_breeze)
            }
        } else {
            Utils_Breeze.showInfo_Breeze(message_Breeze: "Follow this camper first to start chatting")
        }
    }
    
    /// 返回消息列表
    private func backToMessageList_Breeze() {
        guard let nav_breeze = navigationController else { return }
        if let messageListVC_breeze = nav_breeze.viewControllers.first(where: { $0 is MessageList_Breeze }) {
            nav_breeze.popToViewController(messageListVC_breeze, animated: true)
        } else {
            nav_breeze.popToRootViewController(animated: true)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionViewDataSource / Delegate / FlowLayout

extension UserInfo_Breeze: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts_Breeze.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell_breeze = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProfileGridCell_Breeze.reuseId_Breeze,
            for: indexPath
        ) as? ProfileGridCell_Breeze else {
            return UICollectionViewCell()
        }
        cell_breeze.configure_Breeze(post_breeze: posts_Breeze[indexPath.item], host_breeze: self)
        cell_breeze.onReportComplete_Breeze = { [weak self] in
            self?.reloadData_Breeze()
        }
        return cell_breeze
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Navigation_Breeze.toTitleDetail_Breeze(titleModel_breeze: posts_Breeze[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header_breeze = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: UserInfoHeaderView_Breeze.reuseId_Breeze,
                for: indexPath
              ) as? UserInfoHeaderView_Breeze, let user_breeze = userModel_Breeze else {
            return UICollectionReusableView()
        }
        let isFollowing_breeze = UserViewModel_Breeze.shared_Breeze.isFollowing_Breeze(user_breeze: user_breeze)
        header_breeze.configure_Breeze(
            user_breeze: user_breeze,
            isFromChat_breeze: isFromChat_Breeze,
            isFollowing_breeze: isFollowing_breeze,
            postsCount_breeze: posts_Breeze.count
        )
        header_breeze.onFollow_Breeze = { [weak self] in self?.handleFollow_Breeze() }
        header_breeze.onMessage_Breeze = { [weak self] in self?.handleMessage_Breeze() }
        return header_breeze
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 440)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing_breeze: CGFloat = 16 * 2 + 12
        let width_breeze = (collectionView.bounds.width - totalSpacing_breeze) / 2
        return CGSize(width: width_breeze, height: ProfileGridCell_Breeze.cellHeight_Breeze(width_breeze: width_breeze))
    }
}
