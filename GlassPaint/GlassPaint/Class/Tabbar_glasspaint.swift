import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 底部导航页面
class TabBar_Glasspaint: UITabBarController {
    
    /// 黄色背景视图
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
    
    // MARK: - UI设置
    private func setupUI_Glasspaint() {
        // 配置黄色背景视图
        tabBgView_Glasspaint.backgroundColor = UIColor(hexstring_Glasspaint: "#FFD700")
        tabBgView_Glasspaint.layer.masksToBounds = true
        view.addSubview(tabBgView_Glasspaint)
        
        // 配置StackView
        tabStackView_Glasspaint.axis = .horizontal
        tabStackView_Glasspaint.distribution = .equalSpacing
        tabStackView_Glasspaint.alignment = .center
        tabStackView_Glasspaint.spacing = 20
        view.addSubview(tabStackView_Glasspaint)
        
        // 配置首页按钮
        btnHome_Glasspaint.setImage(UIImage(named: "home_select"), for: .selected)
        btnHome_Glasspaint.setImage(UIImage(named: "home_normal")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnHome_Glasspaint.tintColor = .gray
        btnHome_Glasspaint.tag = 0
        btnHome_Glasspaint.addTarget(self, action: #selector(tabButtonTapped_Glasspaint(_:)), for: .touchUpInside)
        tabStackView_Glasspaint.addArrangedSubview(btnHome_Glasspaint)
        
        // 配置发现页按钮
        btnDiscover_Glasspaint.setImage(UIImage(named: "discover_select"), for: .selected)
        btnDiscover_Glasspaint.setImage(UIImage(named: "discover_normal")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnDiscover_Glasspaint.tintColor = .gray
        btnDiscover_Glasspaint.tag = 1
        btnDiscover_Glasspaint.addTarget(self, action: #selector(tabButtonTapped_Glasspaint(_:)), for: .touchUpInside)
        tabStackView_Glasspaint.addArrangedSubview(btnDiscover_Glasspaint)
        
        // 配置发布按钮
        btnRelease_Glasspaint.setImage(UIImage(named: "publish"), for: .normal)
        btnRelease_Glasspaint.tag = 2
        btnRelease_Glasspaint.addTarget(self, action: #selector(tabButtonTapped_Glasspaint(_:)), for: .touchUpInside)
        tabStackView_Glasspaint.addArrangedSubview(btnRelease_Glasspaint)
        
        // 配置消息按钮
        btnMessage_Glasspaint.setImage(UIImage(named: "message_select"), for: .selected)
        btnMessage_Glasspaint.setImage(UIImage(named: "message_normal")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnMessage_Glasspaint.tintColor = .gray
        btnMessage_Glasspaint.tag = 3
        btnMessage_Glasspaint.addTarget(self, action: #selector(tabButtonTapped_Glasspaint(_:)), for: .touchUpInside)
        tabStackView_Glasspaint.addArrangedSubview(btnMessage_Glasspaint)
        
        // 配置我的按钮
        btnMe_Glasspaint.setImage(UIImage(named: "me_select"), for: .selected)
        btnMe_Glasspaint.setImage(UIImage(named: "me_normal")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnMe_Glasspaint.tintColor = .gray
        btnMe_Glasspaint.tag = 4
        btnMe_Glasspaint.addTarget(self, action: #selector(tabButtonTapped_Glasspaint(_:)), for: .touchUpInside)
        tabStackView_Glasspaint.addArrangedSubview(btnMe_Glasspaint)
        
        // 设置初始选中状态
        btnHome_Glasspaint.isSelected = true
    }
    
    /// 设置约束布局
    private func setupConstraints_Glasspaint() {
        // StackView约束
        tabStackView_Glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(50)
        }
        
        // 按钮尺寸约束
        btnHome_Glasspaint.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        btnDiscover_Glasspaint.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        btnRelease_Glasspaint.snp.makeConstraints { make in
            make.width.height.equalTo(45)
        }
        
        btnMessage_Glasspaint.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        btnMe_Glasspaint.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        // 黄色背景视图约束（上下各距离StackView 15）
        tabBgView_Glasspaint.snp.makeConstraints { make in
            make.leading.trailing.equalTo(tabStackView_Glasspaint)
            make.top.equalTo(tabStackView_Glasspaint).offset(-15)
            make.bottom.equalTo(tabStackView_Glasspaint).offset(15)
        }
        
        // 设置圆角为高度的一半
        tabBgView_Glasspaint.layoutIfNeeded()
        let bgHeight = 50 + 30 // StackView高度50 + 上下各15
        tabBgView_Glasspaint.layer.cornerRadius = CGFloat(bgHeight) / 2.0
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
        btnHome_Glasspaint.isSelected = (selectedIndex_glasspaint == 0)
        btnDiscover_Glasspaint.isSelected = (selectedIndex_glasspaint == 1)
        btnRelease_Glasspaint.isSelected = (selectedIndex_glasspaint == 2)
        btnMessage_Glasspaint.isSelected = (selectedIndex_glasspaint == 3)
        btnMe_Glasspaint.isSelected = (selectedIndex_glasspaint == 4)
        
        currentIndex_Glasspaint = selectedIndex_glasspaint
    }
    
    /// 重写 selectedIndex 以监听外部变化
    override var selectedIndex: Int {
        didSet {
            updateButtonStates_Glasspaint(selectedIndex_glasspaint: selectedIndex)
        }
    }
}
