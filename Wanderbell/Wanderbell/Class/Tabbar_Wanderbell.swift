import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 底部导航页面
class TabBar_Wanderbell: UITabBarController {
    
    /// 黄色背景视图
    private var tabBgView_Wanderbell = UIView()
    
    /// 按钮容器栈视图
    private var tabStackView_Wanderbell = UIStackView()
    
    /// 首页按钮
    private var btnHome_Wanderbell = UIButton(type: .custom)
    
    /// 发现页按钮
    private var btnDiscover_Wanderbell = UIButton(type: .custom)
    
    /// 发布按钮
    private var btnRelease_Wanderbell = UIButton(type: .custom)
    
    /// 消息按钮
    private var btnMessage_Wanderbell = UIButton(type: .custom)
    
    /// 我的按钮
    private var btnMe_Wanderbell = UIButton(type: .custom)
    
    /// 当前选中索引
    private var currentIndex_Wanderbell: Int = 0
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图控制器
        viewControllers = [Home_Wanderbell(), Discover_Wanderbell(), Release_Wanderbell(), MessageList_Wanderbell(), Me_Wanderbell()]
        
        setupUI_Wanderbell()
        setupConstraints_Wanderbell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }
    
    // MARK: - UI设置
    private func setupUI_Wanderbell() {
        // 配置黄色背景视图
        tabBgView_Wanderbell.backgroundColor = UIColor(hexstring_Wanderbell: "#FFD700")
        tabBgView_Wanderbell.layer.masksToBounds = true
        view.addSubview(tabBgView_Wanderbell)
        
        // 配置StackView
        tabStackView_Wanderbell.axis = .horizontal
        tabStackView_Wanderbell.distribution = .equalSpacing
        tabStackView_Wanderbell.alignment = .center
        tabStackView_Wanderbell.spacing = 20
        view.addSubview(tabStackView_Wanderbell)
        
        // 配置首页按钮
        btnHome_Wanderbell.setImage(UIImage(named: "front_select"), for: .selected)
        btnHome_Wanderbell.setImage(UIImage(named: "front_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnHome_Wanderbell.tintColor = .gray
        btnHome_Wanderbell.tag = 0
        btnHome_Wanderbell.addTarget(self, action: #selector(tabButtonTapped_Wanderbell(_:)), for: .touchUpInside)
        tabStackView_Wanderbell.addArrangedSubview(btnHome_Wanderbell)
        
        // 配置发现页按钮
        btnDiscover_Wanderbell.setImage(UIImage(named: "pu_select"), for: .selected)
        btnDiscover_Wanderbell.setImage(UIImage(named: "pu_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnDiscover_Wanderbell.tintColor = .gray
        btnDiscover_Wanderbell.tag = 1
        btnDiscover_Wanderbell.addTarget(self, action: #selector(tabButtonTapped_Wanderbell(_:)), for: .touchUpInside)
        tabStackView_Wanderbell.addArrangedSubview(btnDiscover_Wanderbell)
        
        // 配置发布按钮
        btnRelease_Wanderbell.setImage(UIImage(named: "publish"), for: .normal)
        btnRelease_Wanderbell.tag = 2
        btnRelease_Wanderbell.addTarget(self, action: #selector(tabButtonTapped_Wanderbell(_:)), for: .touchUpInside)
        tabStackView_Wanderbell.addArrangedSubview(btnRelease_Wanderbell)
        
        // 配置消息按钮
        btnMessage_Wanderbell.setImage(UIImage(named: "mes_select"), for: .selected)
        btnMessage_Wanderbell.setImage(UIImage(named: "mes_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnMessage_Wanderbell.tintColor = .gray
        btnMessage_Wanderbell.tag = 3
        btnMessage_Wanderbell.addTarget(self, action: #selector(tabButtonTapped_Wanderbell(_:)), for: .touchUpInside)
        tabStackView_Wanderbell.addArrangedSubview(btnMessage_Wanderbell)
        
        // 配置我的按钮
        btnMe_Wanderbell.setImage(UIImage(named: "me_select"), for: .selected)
        btnMe_Wanderbell.setImage(UIImage(named: "me_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnMe_Wanderbell.tintColor = .gray
        btnMe_Wanderbell.tag = 4
        btnMe_Wanderbell.addTarget(self, action: #selector(tabButtonTapped_Wanderbell(_:)), for: .touchUpInside)
        tabStackView_Wanderbell.addArrangedSubview(btnMe_Wanderbell)
        
        // 设置初始选中状态
        btnHome_Wanderbell.isSelected = true
    }
    
    /// 设置约束布局
    private func setupConstraints_Wanderbell() {
        // StackView约束
        tabStackView_Wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(50)
        }
        
        // 按钮尺寸约束
        btnHome_Wanderbell.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        btnDiscover_Wanderbell.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        btnRelease_Wanderbell.snp.makeConstraints { make in
            make.width.height.equalTo(45)
        }
        
        btnMessage_Wanderbell.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        btnMe_Wanderbell.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        // 黄色背景视图约束（上下各距离StackView 15）
        tabBgView_Wanderbell.snp.makeConstraints { make in
            make.leading.trailing.equalTo(tabStackView_Wanderbell)
            make.top.equalTo(tabStackView_Wanderbell).offset(-15)
            make.bottom.equalTo(tabStackView_Wanderbell).offset(15)
        }
        
        // 设置圆角为高度的一半
        tabBgView_Wanderbell.layoutIfNeeded()
        let bgHeight = 50 + 30 // StackView高度50 + 上下各15
        tabBgView_Wanderbell.layer.cornerRadius = CGFloat(bgHeight) / 2.0
    }
    
    @objc private func tabButtonTapped_Wanderbell(_ sender: UIButton) {
        let index = sender.tag
        
        // 更新选中状态
        currentIndex_Wanderbell = index
        selectedIndex = index
        
        // 更新所有按钮的选中状态
        btnHome_Wanderbell.isSelected = (index == 0)
        btnDiscover_Wanderbell.isSelected = (index == 1)
        btnRelease_Wanderbell.isSelected = (index == 2)
        btnMessage_Wanderbell.isSelected = (index == 3)
        btnMe_Wanderbell.isSelected = (index == 4)
    }
}
