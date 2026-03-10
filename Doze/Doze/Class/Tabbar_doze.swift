import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 底部导航页面
class TabBar_Doze: UITabBarController {
    
    /// 黄色背景视图
    private var tabBgView_Doze = UIView()
    
    /// 按钮容器栈视图
    private var tabStackView_Doze = UIStackView()
    
    /// 首页按钮
    private var btnHome_Doze = UIButton(type: .custom)
    
    /// 发现页按钮
    private var btnDiscover_Doze = UIButton(type: .custom)
    
    /// 发布按钮
    private var btnRelease_Doze = UIButton(type: .custom)
    
    /// 消息按钮
    private var btnMessage_Doze = UIButton(type: .custom)
    
    /// 我的按钮
    private var btnMe_Doze = UIButton(type: .custom)
    
    /// 当前选中索引
    private var currentIndex_Doze: Int = 0
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图控制器
        viewControllers = [Home_Doze(), Discover_Doze(), Release_Doze(), MessageList_Doze(), Me_Doze()]
        
        setupUI_Doze()
        setupConstraints_Doze()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }
    
    // MARK: - UI设置
    private func setupUI_Doze() {
        // 配置黄色背景视图
        tabBgView_Doze.backgroundColor = UIColor(hexstring_Doze: "#FFD700")
        tabBgView_Doze.layer.masksToBounds = true
        view.addSubview(tabBgView_Doze)
        
        // 配置StackView
        tabStackView_Doze.axis = .horizontal
        tabStackView_Doze.distribution = .equalSpacing
        tabStackView_Doze.alignment = .center
        tabStackView_Doze.spacing = 20
        view.addSubview(tabStackView_Doze)
        
        // 配置首页按钮
        btnHome_Doze.setImage(UIImage(named: "front_select"), for: .selected)
        btnHome_Doze.setImage(UIImage(named: "front_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnHome_Doze.tintColor = .gray
        btnHome_Doze.tag = 0
        btnHome_Doze.addTarget(self, action: #selector(tabButtonTapped_Doze(_:)), for: .touchUpInside)
        tabStackView_Doze.addArrangedSubview(btnHome_Doze)
        
        // 配置发现页按钮
        btnDiscover_Doze.setImage(UIImage(named: "pu_select"), for: .selected)
        btnDiscover_Doze.setImage(UIImage(named: "pu_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnDiscover_Doze.tintColor = .gray
        btnDiscover_Doze.tag = 1
        btnDiscover_Doze.addTarget(self, action: #selector(tabButtonTapped_Doze(_:)), for: .touchUpInside)
        tabStackView_Doze.addArrangedSubview(btnDiscover_Doze)
        
        // 配置发布按钮
        btnRelease_Doze.setImage(UIImage(named: "publish"), for: .normal)
        btnRelease_Doze.tag = 2
        btnRelease_Doze.addTarget(self, action: #selector(tabButtonTapped_Doze(_:)), for: .touchUpInside)
        tabStackView_Doze.addArrangedSubview(btnRelease_Doze)
        
        // 配置消息按钮
        btnMessage_Doze.setImage(UIImage(named: "mes_select"), for: .selected)
        btnMessage_Doze.setImage(UIImage(named: "mes_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnMessage_Doze.tintColor = .gray
        btnMessage_Doze.tag = 3
        btnMessage_Doze.addTarget(self, action: #selector(tabButtonTapped_Doze(_:)), for: .touchUpInside)
        tabStackView_Doze.addArrangedSubview(btnMessage_Doze)
        
        // 配置我的按钮
        btnMe_Doze.setImage(UIImage(named: "me_select"), for: .selected)
        btnMe_Doze.setImage(UIImage(named: "me_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnMe_Doze.tintColor = .gray
        btnMe_Doze.tag = 4
        btnMe_Doze.addTarget(self, action: #selector(tabButtonTapped_Doze(_:)), for: .touchUpInside)
        tabStackView_Doze.addArrangedSubview(btnMe_Doze)
        
        // 设置初始选中状态
        btnHome_Doze.isSelected = true
    }
    
    /// 设置约束布局
    private func setupConstraints_Doze() {
        // StackView约束
        tabStackView_Doze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(50)
        }
        
        // 按钮尺寸约束
        btnHome_Doze.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        btnDiscover_Doze.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        btnRelease_Doze.snp.makeConstraints { make in
            make.width.height.equalTo(45)
        }
        
        btnMessage_Doze.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        btnMe_Doze.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        // 黄色背景视图约束（上下各距离StackView 15）
        tabBgView_Doze.snp.makeConstraints { make in
            make.leading.trailing.equalTo(tabStackView_Doze)
            make.top.equalTo(tabStackView_Doze).offset(-15)
            make.bottom.equalTo(tabStackView_Doze).offset(15)
        }
        
        // 设置圆角为高度的一半
        tabBgView_Doze.layoutIfNeeded()
        let bgHeight = 50 + 30 // StackView高度50 + 上下各15
        tabBgView_Doze.layer.cornerRadius = CGFloat(bgHeight) / 2.0
    }
    
    @objc private func tabButtonTapped_Doze(_ sender: UIButton) {
        let index = sender.tag
        
        // 更新选中状态
        currentIndex_Doze = index
        selectedIndex = index
        
        // 更新所有按钮的选中状态
        btnHome_Doze.isSelected = (index == 0)
        btnDiscover_Doze.isSelected = (index == 1)
        btnRelease_Doze.isSelected = (index == 2)
        btnMessage_Doze.isSelected = (index == 3)
        btnMe_Doze.isSelected = (index == 4)
    }
}
