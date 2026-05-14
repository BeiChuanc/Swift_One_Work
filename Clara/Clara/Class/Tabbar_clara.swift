import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 底部导航页面
class TabBar_Clara: UITabBarController {
    
    /// 底部背景视图
    private var tabBgView_Clara = UIView()
    
    /// 按钮容器栈视图
    private var tabStackView_Clara = UIStackView()

    /// 首页槽位容器
    private let homeContainerView_Clara = UIView()

    /// 发现页槽位容器
    private let discoverContainerView_Clara = UIView()

    /// 发布页槽位容器
    private let releaseContainerView_Clara = UIView()

    /// 消息页槽位容器
    private let messageContainerView_Clara = UIView()

    /// 我的页槽位容器
    private let meContainerView_Clara = UIView()
    
    /// 首页按钮
    private var btnHome_Clara = UIButton(type: .custom)

    /// 首页图标视图
    private let homeImageView_Clara = UIImageView()
    
    /// 发现页按钮
    private var btnDiscover_Clara = UIButton(type: .custom)

    /// 发现页图标视图
    private let discoverImageView_Clara = UIImageView()
    
    /// 发布按钮
    private var btnRelease_Clara = UIButton(type: .custom)

    /// 发布页图标视图
    private let releaseImageView_Clara = UIImageView()
    
    /// 消息按钮
    private var btnMessage_Clara = UIButton(type: .custom)

    /// 消息页图标视图
    private let messageImageView_Clara = UIImageView()
    
    /// 我的按钮
    private var btnMe_Clara = UIButton(type: .custom)

    /// 我的图标视图
    private let meImageView_Clara = UIImageView()
    
    /// 当前选中索引
    private var currentIndex_Clara: Int = 0

    /// 常规页签按钮尺寸
    private let normalTabButtonSize_Clara = CGSize(width: 71, height: 36)

    /// 发布按钮尺寸
    private let releaseTabButtonSize_Clara = CGSize(width: 46, height: 46)
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图控制器
        viewControllers = [Home_Clara(), Discover_Clara(), Release_Clara(), MessageList_Clara(), Me_Clara()]
        
        setupUI_Clara()
        setupConstraints_Clara()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
        bringCustomTabbarToFront_Clara()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bringCustomTabbarToFront_Clara()
    }
    
    // MARK: - UI设置

    /// 配置底部导航图标视图
    /// 功能：统一设置图标视图的显示模式，确保原图资源始终按固定约束展示
    /// 参数：
    /// - imageView_Clara: 目标图标视图
    /// - inButton_Clara: 承载图标的按钮
    private func configureTabImageView_Clara(
        imageView_Clara: UIImageView,
        inButton_Clara: UIButton
    ) {
        imageView_Clara.contentMode = .scaleAspectFit
        imageView_Clara.isUserInteractionEnabled = false
        inButton_Clara.adjustsImageWhenHighlighted = false
        inButton_Clara.addSubview(imageView_Clara)
        imageView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    /// 根据选中状态更新底部导航图标
    /// 功能：通过独立 UIImageView 手动切换资源，避免 UIButton 状态图导致的尺寸抖动
    /// 参数：
    /// - index_Clara: 当前选中的页签索引
    private func updateTabImages_Clara(index_Clara: Int) {
        homeImageView_Clara.image = UIImage(
            named: index_Clara == 0 ? "home_select" : "home_nromal"
        )?.withRenderingMode(.alwaysOriginal)
        discoverImageView_Clara.image = UIImage(
            named: index_Clara == 1 ? "discover_select" : "discover_nromal"
        )?.withRenderingMode(.alwaysOriginal)
        releaseImageView_Clara.image = UIImage(
            named: "publish_normal"
        )?.withRenderingMode(.alwaysOriginal)
        messageImageView_Clara.image = UIImage(
            named: index_Clara == 3 ? "message_select" : "message_nromal"
        )?.withRenderingMode(.alwaysOriginal)
        meImageView_Clara.image = UIImage(
            named: index_Clara == 4 ? "me_select" : "me_nromal"
        )?.withRenderingMode(.alwaysOriginal)
    }

    private func setupUI_Clara() {
        // 配置底部背景视图
        tabBgView_Clara.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        tabBgView_Clara.layer.masksToBounds = true
        tabBgView_Clara.isUserInteractionEnabled = false
        view.addSubview(tabBgView_Clara)
        
        // 配置StackView
        tabStackView_Clara.axis = .horizontal
        tabStackView_Clara.distribution = .fillEqually
        tabStackView_Clara.alignment = .fill
        tabStackView_Clara.spacing = 0
        view.addSubview(tabStackView_Clara)

        [homeContainerView_Clara,
         discoverContainerView_Clara,
         releaseContainerView_Clara,
         messageContainerView_Clara,
         meContainerView_Clara].forEach {
            $0.backgroundColor = .clear
            $0.isUserInteractionEnabled = true
            tabStackView_Clara.addArrangedSubview($0)
        }
        
        // 配置首页按钮
        configureTabImageView_Clara(imageView_Clara: homeImageView_Clara, inButton_Clara: btnHome_Clara)
        btnHome_Clara.tag = 0
        btnHome_Clara.addTarget(self, action: #selector(tabButtonTapped_Clara(_:)), for: .touchUpInside)
        homeContainerView_Clara.addSubview(btnHome_Clara)
        
        // 配置发现页按钮
        configureTabImageView_Clara(imageView_Clara: discoverImageView_Clara, inButton_Clara: btnDiscover_Clara)
        btnDiscover_Clara.tag = 1
        btnDiscover_Clara.addTarget(self, action: #selector(tabButtonTapped_Clara(_:)), for: .touchUpInside)
        discoverContainerView_Clara.addSubview(btnDiscover_Clara)
        
        // 配置发布按钮
        configureTabImageView_Clara(imageView_Clara: releaseImageView_Clara, inButton_Clara: btnRelease_Clara)
        btnRelease_Clara.tag = 2
        btnRelease_Clara.addTarget(self, action: #selector(tabButtonTapped_Clara(_:)), for: .touchUpInside)
        releaseContainerView_Clara.addSubview(btnRelease_Clara)
        
        // 配置消息按钮
        configureTabImageView_Clara(imageView_Clara: messageImageView_Clara, inButton_Clara: btnMessage_Clara)
        btnMessage_Clara.tag = 3
        btnMessage_Clara.addTarget(self, action: #selector(tabButtonTapped_Clara(_:)), for: .touchUpInside)
        messageContainerView_Clara.addSubview(btnMessage_Clara)
        
        // 配置我的按钮
        configureTabImageView_Clara(imageView_Clara: meImageView_Clara, inButton_Clara: btnMe_Clara)
        btnMe_Clara.tag = 4
        btnMe_Clara.addTarget(self, action: #selector(tabButtonTapped_Clara(_:)), for: .touchUpInside)
        meContainerView_Clara.addSubview(btnMe_Clara)
        
        // 设置初始选中状态
        btnHome_Clara.isSelected = true
        updateTabImages_Clara(index_Clara: 0)
        bringCustomTabbarToFront_Clara()
    }
    
    /// 设置约束布局
    private func setupConstraints_Clara() {
        // StackView约束
        tabStackView_Clara.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(50)
        }
        
        // 按钮尺寸约束
        btnHome_Clara.snp.makeConstraints { make in
            make.width.equalTo(normalTabButtonSize_Clara.width)
            make.height.equalTo(normalTabButtonSize_Clara.height)
            make.center.equalToSuperview()
        }
        
        btnDiscover_Clara.snp.makeConstraints { make in
            make.width.equalTo(normalTabButtonSize_Clara.width)
            make.height.equalTo(normalTabButtonSize_Clara.height)
            make.center.equalToSuperview()
        }
        
        btnRelease_Clara.snp.makeConstraints { make in
            make.width.equalTo(releaseTabButtonSize_Clara.width)
            make.height.equalTo(releaseTabButtonSize_Clara.height)
            make.center.equalToSuperview()
        }
        
        btnMessage_Clara.snp.makeConstraints { make in
            make.width.equalTo(normalTabButtonSize_Clara.width)
            make.height.equalTo(normalTabButtonSize_Clara.height)
            make.center.equalToSuperview()
        }
        
        btnMe_Clara.snp.makeConstraints { make in
            make.width.equalTo(normalTabButtonSize_Clara.width)
            make.height.equalTo(normalTabButtonSize_Clara.height)
            make.center.equalToSuperview()
        }
        
        // 背景视图约束
        tabBgView_Clara.snp.makeConstraints { make in
            make.leading.trailing.equalTo(tabStackView_Clara)
            make.centerY.equalTo(tabStackView_Clara)
            make.height.equalTo(50)
        }
        
        // 设置圆角为高度的一半
        tabBgView_Clara.layoutIfNeeded()
        let bgHeight = 50
        tabBgView_Clara.layer.cornerRadius = CGFloat(bgHeight) / 2.0
    }

    /// 将自定义底部导航提升到最上层
    /// 功能：避免子控制器内容视图覆盖自定义 TabBar，导致底部按钮无法点击
    private func bringCustomTabbarToFront_Clara() {
        view.bringSubviewToFront(tabBgView_Clara)
        view.bringSubviewToFront(tabStackView_Clara)
    }
    
    @objc private func tabButtonTapped_Clara(_ sender: UIButton) {
        let index = sender.tag
        
        // 更新选中状态
        currentIndex_Clara = index
        selectedIndex = index
        
        // 更新所有按钮的选中状态
        btnHome_Clara.isSelected = (index == 0)
        btnDiscover_Clara.isSelected = (index == 1)
        btnRelease_Clara.isSelected = (index == 2)
        btnMessage_Clara.isSelected = (index == 3)
        btnMe_Clara.isSelected = (index == 4)
        updateTabImages_Clara(index_Clara: index)
    }
}
