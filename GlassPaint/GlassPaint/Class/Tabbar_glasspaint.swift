import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 底部导航页面
class TabBar_Glasspaint: UITabBarController {
    
    /// 背景视图
    private var tabBgView_Glasspaint = UIView()
    
    /// 按钮容器栈视图
    private var tabStackView_Glasspaint = UIStackView()
    
    /// 首页按钮
    private var btnHome_Glasspaint = UIButton(type: .custom)
    
    /// 发现页按钮
    private var btnDiscover_Glasspaint = UIButton(type: .custom)
    
    /// 发布按钮
    private var btnRelease_Glasspaint = UIButton(type: .custom)
    
    /// 消息按钮
    private var btnMessage_Glasspaint = UIButton(type: .custom)
    
    /// 我的按钮
    private var btnMe_Glasspaint = UIButton(type: .custom)
    
    /// 选中背景视图（首页）
    private var homeSelectedBg_Glasspaint = UIView()
    
    /// 选中背景视图（发现）
    private var discoverSelectedBg_Glasspaint = UIView()
    
    /// 选中背景视图（消息）
    private var messageSelectedBg_Glasspaint = UIView()
    
    /// 选中背景视图（我的）
    private var meSelectedBg_Glasspaint = UIView()
    
    /// 当前选中索引
    private var currentIndex_Glasspaint: Int = 0
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图控制器
        viewControllers = [Home_Glasspaint(), Discover_Glasspaint(), Release_Glasspaint(), MessageList_Glasspaint(), Me_Glasspaint()]
        
        setupUI_Glasspaint()
        setupConstraints_Glasspaint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 更新圆角路径
        let path_glasspaint = UIBezierPath(
            roundedRect: tabBgView_Glasspaint.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 25, height: 25)
        )
        let mask_glasspaint = CAShapeLayer()
        mask_glasspaint.path = path_glasspaint.cgPath
        tabBgView_Glasspaint.layer.mask = mask_glasspaint
    }
    
    // MARK: - UI设置
    private func setupUI_Glasspaint() {
        // 配置背景视图
        tabBgView_Glasspaint.backgroundColor = UIColor(hexstring_Glasspaint: "#BE92FD")
        tabBgView_Glasspaint.layer.masksToBounds = true
        view.addSubview(tabBgView_Glasspaint)
        
        // 配置StackView
        tabStackView_Glasspaint.axis = .horizontal
        tabStackView_Glasspaint.distribution = .equalSpacing
        tabStackView_Glasspaint.alignment = .center
        tabStackView_Glasspaint.spacing = 20
        view.addSubview(tabStackView_Glasspaint)
        
        // 配置首页按钮
        setupButton_Glasspaint(
            button: btnHome_Glasspaint,
            imageName: "home",
            selectedBgView: homeSelectedBg_Glasspaint,
            tag: 0
        )
        
        // 配置发现页按钮
        setupButton_Glasspaint(
            button: btnDiscover_Glasspaint,
            imageName: "discover",
            selectedBgView: discoverSelectedBg_Glasspaint,
            tag: 1
        )
        
        // 配置发布按钮（不需要选中背景）
        btnRelease_Glasspaint.setImage(UIImage(named: "publish"), for: .normal)
        btnRelease_Glasspaint.tag = 2
        btnRelease_Glasspaint.addTarget(self, action: #selector(tabButtonTapped_Glasspaint(_:)), for: .touchUpInside)
        tabStackView_Glasspaint.addArrangedSubview(btnRelease_Glasspaint)
        
        // 配置消息按钮
        setupButton_Glasspaint(
            button: btnMessage_Glasspaint,
            imageName: "message",
            selectedBgView: messageSelectedBg_Glasspaint,
            tag: 3
        )
        
        // 配置我的按钮
        setupButton_Glasspaint(
            button: btnMe_Glasspaint,
            imageName: "me",
            selectedBgView: meSelectedBg_Glasspaint,
            tag: 4
        )
        
        // 设置初始选中状态
        btnHome_Glasspaint.isSelected = true
        homeSelectedBg_Glasspaint.isHidden = false
    }
    
    /// 配置单个按钮
    private func setupButton_Glasspaint(
        button: UIButton,
        imageName: String,
        selectedBgView: UIView,
        tag: Int
    ) {
        // 创建容器视图
        let containerView_glasspaint = UIView()
        
        // 配置选中背景视图
        selectedBgView.backgroundColor = .black
        selectedBgView.layer.cornerRadius = 10
        selectedBgView.isHidden = true
        containerView_glasspaint.addSubview(selectedBgView)
        
        selectedBgView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        // 配置按钮图标
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        button.tag = tag
        button.addTarget(self, action: #selector(tabButtonTapped_Glasspaint(_:)), for: .touchUpInside)
        containerView_glasspaint.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        tabStackView_Glasspaint.addArrangedSubview(containerView_glasspaint)
        
        // 容器视图尺寸
        containerView_glasspaint.snp.makeConstraints { make in
            make.width.height.equalTo(44)
        }
    }
    
    /// 设置约束布局
    private func setupConstraints_Glasspaint() {
        // 背景视图约束（与屏幕底部没有距离）
        tabBgView_Glasspaint.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(100)
        }
        
        // StackView约束
        tabStackView_Glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.top.equalTo(tabBgView_Glasspaint).offset(20)
            make.height.equalTo(50)
        }
        
        // 发布按钮尺寸约束（其他按钮约束已在setupButton_Glasspaint中设置）
        btnRelease_Glasspaint.snp.makeConstraints { make in
            make.width.height.equalTo(50)
        }
    }
    
    @objc private func tabButtonTapped_Glasspaint(_ sender: UIButton) {
        let index = sender.tag
        
        // 更新选中状态
        currentIndex_Glasspaint = index
        selectedIndex = index
        
        // 更新按钮状态
        updateButtonStates_Glasspaint(selectedIndex_glasspaint: index)
    }
    
    /// 更新所有按钮的选中状态
    /// 参数：
    /// - selectedIndex_glasspaint: 当前选中的索引
    private func updateButtonStates_Glasspaint(selectedIndex_glasspaint: Int) {
        // 更新按钮选中状态
        btnHome_Glasspaint.isSelected = (selectedIndex_glasspaint == 0)
        btnDiscover_Glasspaint.isSelected = (selectedIndex_glasspaint == 1)
        btnRelease_Glasspaint.isSelected = (selectedIndex_glasspaint == 2)
        btnMessage_Glasspaint.isSelected = (selectedIndex_glasspaint == 3)
        btnMe_Glasspaint.isSelected = (selectedIndex_glasspaint == 4)
        
        // 更新选中背景视图显示状态（发布按钮不显示背景）
        homeSelectedBg_Glasspaint.isHidden = (selectedIndex_glasspaint != 0)
        discoverSelectedBg_Glasspaint.isHidden = (selectedIndex_glasspaint != 1)
        messageSelectedBg_Glasspaint.isHidden = (selectedIndex_glasspaint != 3)
        meSelectedBg_Glasspaint.isHidden = (selectedIndex_glasspaint != 4)
        
        currentIndex_Glasspaint = selectedIndex_glasspaint
    }
    
    /// 重写 selectedIndex 以监听外部变化
    override var selectedIndex: Int {
        didSet {
            updateButtonStates_Glasspaint(selectedIndex_glasspaint: selectedIndex)
        }
    }
}
