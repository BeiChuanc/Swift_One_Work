import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 底部导航页面
class TabBar_Trace: UITabBarController {
    
    /// 黄色背景视图
    private var tabBgView_Trace = UIView()
    
    /// 按钮容器栈视图
    private var tabStackView_Trace = UIStackView()
    
    /// 首页按钮
    private var btnHome_Trace = UIButton(type: .custom)
    
    /// 发现页按钮
    private var btnDiscover_Trace = UIButton(type: .custom)
    
    /// 发布按钮
    private var btnRelease_Trace = UIButton(type: .custom)
    
    /// 消息按钮
    private var btnMessage_Trace = UIButton(type: .custom)
    
    /// 我的按钮
    private var btnMe_Trace = UIButton(type: .custom)
    
    /// 当前选中索引
    private var currentIndex_Trace: Int = 0
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图控制器
        viewControllers = [Home_Trace(), Discover_Trace(), Release_Trace(), MessageList_Trace(), Me_Trace()]
        
        setupUI_Trace()
        setupConstraints_Trace()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }
    
    // MARK: - UI设置
    private func setupUI_Trace() {
        // 配置黄色背景视图
        tabBgView_Trace.backgroundColor = UIColor(hexstring_Trace: "#FFD700")
        tabBgView_Trace.layer.masksToBounds = true
        view.addSubview(tabBgView_Trace)
        
        // 配置StackView
        tabStackView_Trace.axis = .horizontal
        tabStackView_Trace.distribution = .equalSpacing
        tabStackView_Trace.alignment = .center
        tabStackView_Trace.spacing = 20
        view.addSubview(tabStackView_Trace)
        
        // 配置首页按钮
        btnHome_Trace.setImage(UIImage(named: "front_select"), for: .selected)
        btnHome_Trace.setImage(UIImage(named: "front_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnHome_Trace.tintColor = .gray
        btnHome_Trace.tag = 0
        btnHome_Trace.addTarget(self, action: #selector(tabButtonTapped_Trace(_:)), for: .touchUpInside)
        tabStackView_Trace.addArrangedSubview(btnHome_Trace)
        
        // 配置发现页按钮
        btnDiscover_Trace.setImage(UIImage(named: "pu_select"), for: .selected)
        btnDiscover_Trace.setImage(UIImage(named: "pu_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnDiscover_Trace.tintColor = .gray
        btnDiscover_Trace.tag = 1
        btnDiscover_Trace.addTarget(self, action: #selector(tabButtonTapped_Trace(_:)), for: .touchUpInside)
        tabStackView_Trace.addArrangedSubview(btnDiscover_Trace)
        
        // 配置发布按钮
        btnRelease_Trace.setImage(UIImage(named: "publish"), for: .normal)
        btnRelease_Trace.tag = 2
        btnRelease_Trace.addTarget(self, action: #selector(tabButtonTapped_Trace(_:)), for: .touchUpInside)
        tabStackView_Trace.addArrangedSubview(btnRelease_Trace)
        
        // 配置消息按钮
        btnMessage_Trace.setImage(UIImage(named: "mes_select"), for: .selected)
        btnMessage_Trace.setImage(UIImage(named: "mes_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnMessage_Trace.tintColor = .gray
        btnMessage_Trace.tag = 3
        btnMessage_Trace.addTarget(self, action: #selector(tabButtonTapped_Trace(_:)), for: .touchUpInside)
        tabStackView_Trace.addArrangedSubview(btnMessage_Trace)
        
        // 配置我的按钮
        btnMe_Trace.setImage(UIImage(named: "me_select"), for: .selected)
        btnMe_Trace.setImage(UIImage(named: "me_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnMe_Trace.tintColor = .gray
        btnMe_Trace.tag = 4
        btnMe_Trace.addTarget(self, action: #selector(tabButtonTapped_Trace(_:)), for: .touchUpInside)
        tabStackView_Trace.addArrangedSubview(btnMe_Trace)
        
        // 设置初始选中状态
        btnHome_Trace.isSelected = true
    }
    
    /// 设置约束布局
    private func setupConstraints_Trace() {
        // StackView约束
        tabStackView_Trace.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(50)
        }
        
        // 按钮尺寸约束
        btnHome_Trace.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        btnDiscover_Trace.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        btnRelease_Trace.snp.makeConstraints { make in
            make.width.height.equalTo(45)
        }
        
        btnMessage_Trace.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        btnMe_Trace.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        // 黄色背景视图约束（上下各距离StackView 15）
        tabBgView_Trace.snp.makeConstraints { make in
            make.leading.trailing.equalTo(tabStackView_Trace)
            make.top.equalTo(tabStackView_Trace).offset(-15)
            make.bottom.equalTo(tabStackView_Trace).offset(15)
        }
        
        // 设置圆角为高度的一半
        tabBgView_Trace.layoutIfNeeded()
        let bgHeight = 50 + 30 // StackView高度50 + 上下各15
        tabBgView_Trace.layer.cornerRadius = CGFloat(bgHeight) / 2.0
    }
    
    @objc private func tabButtonTapped_Trace(_ sender: UIButton) {
        let index = sender.tag
        
        // 更新选中状态
        currentIndex_Trace = index
        selectedIndex = index
        
        // 更新所有按钮的选中状态
        btnHome_Trace.isSelected = (index == 0)
        btnDiscover_Trace.isSelected = (index == 1)
        btnRelease_Trace.isSelected = (index == 2)
        btnMessage_Trace.isSelected = (index == 3)
        btnMe_Trace.isSelected = (index == 4)
    }
}
