import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 底部导航页面
class TabBar_Moode: UITabBarController {
    
    /// 黄色背景视图
    private var tabBgView_Moode = UIView()
    
    /// 按钮容器栈视图
    private var tabStackView_Moode = UIStackView()
    
    /// 首页按钮
    private var btnHome_Moode = UIButton(type: .custom)
    
    /// 发现页按钮
    private var btnDiscover_Moode = UIButton(type: .custom)
    
    /// 发布按钮
    private var btnRelease_Moode = UIButton(type: .custom)
    
    /// 消息按钮
    private var btnMessage_Moode = UIButton(type: .custom)
    
    /// 我的按钮
    private var btnMe_Moode = UIButton(type: .custom)
    
    /// 当前选中索引
    private var currentIndex_Moode: Int = 0
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图控制器
        viewControllers = [Home_Moode(), Discover_Moode(), Release_Moode(), MessageList_Moode(), Me_Moode()]
        
        setupUI_Moode()
        setupConstraints_Moode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }
    
    // MARK: - UI设置
    private func setupUI_Moode() {
        // 配置黄色背景视图
        tabBgView_Moode.backgroundColor = UIColor(hexstring_Moode: "#FFD700")
        tabBgView_Moode.layer.masksToBounds = true
        view.addSubview(tabBgView_Moode)
        
        // 配置StackView
        tabStackView_Moode.axis = .horizontal
        tabStackView_Moode.distribution = .equalSpacing
        tabStackView_Moode.alignment = .center
        tabStackView_Moode.spacing = 20
        view.addSubview(tabStackView_Moode)
        
        // 配置首页按钮
        btnHome_Moode.setImage(UIImage(named: "front_select"), for: .selected)
        btnHome_Moode.setImage(UIImage(named: "front_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnHome_Moode.tintColor = .gray
        btnHome_Moode.tag = 0
        btnHome_Moode.addTarget(self, action: #selector(tabButtonTapped_Moode(_:)), for: .touchUpInside)
        tabStackView_Moode.addArrangedSubview(btnHome_Moode)
        
        // 配置发现页按钮
        btnDiscover_Moode.setImage(UIImage(named: "pu_select"), for: .selected)
        btnDiscover_Moode.setImage(UIImage(named: "pu_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnDiscover_Moode.tintColor = .gray
        btnDiscover_Moode.tag = 1
        btnDiscover_Moode.addTarget(self, action: #selector(tabButtonTapped_Moode(_:)), for: .touchUpInside)
        tabStackView_Moode.addArrangedSubview(btnDiscover_Moode)
        
        // 配置发布按钮
        btnRelease_Moode.setImage(UIImage(named: "publish"), for: .normal)
        btnRelease_Moode.tag = 2
        btnRelease_Moode.addTarget(self, action: #selector(tabButtonTapped_Moode(_:)), for: .touchUpInside)
        tabStackView_Moode.addArrangedSubview(btnRelease_Moode)
        
        // 配置消息按钮
        btnMessage_Moode.setImage(UIImage(named: "mes_select"), for: .selected)
        btnMessage_Moode.setImage(UIImage(named: "mes_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnMessage_Moode.tintColor = .gray
        btnMessage_Moode.tag = 3
        btnMessage_Moode.addTarget(self, action: #selector(tabButtonTapped_Moode(_:)), for: .touchUpInside)
        tabStackView_Moode.addArrangedSubview(btnMessage_Moode)
        
        // 配置我的按钮
        btnMe_Moode.setImage(UIImage(named: "me_select"), for: .selected)
        btnMe_Moode.setImage(UIImage(named: "me_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnMe_Moode.tintColor = .gray
        btnMe_Moode.tag = 4
        btnMe_Moode.addTarget(self, action: #selector(tabButtonTapped_Moode(_:)), for: .touchUpInside)
        tabStackView_Moode.addArrangedSubview(btnMe_Moode)
        
        // 设置初始选中状态
        btnHome_Moode.isSelected = true
    }
    
    /// 设置约束布局
    private func setupConstraints_Moode() {
        // StackView约束
        tabStackView_Moode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-30)
            make.height.equalTo(50)
        }
        
        // 按钮尺寸约束
        btnHome_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        btnDiscover_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        btnRelease_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(45)
        }
        
        btnMessage_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        btnMe_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        // 黄色背景视图约束（上下各距离StackView 15）
        tabBgView_Moode.snp.makeConstraints { make in
            make.leading.trailing.equalTo(tabStackView_Moode)
            make.top.equalTo(tabStackView_Moode).offset(-15)
            make.bottom.equalTo(tabStackView_Moode).offset(15)
        }
        
        // 设置圆角为高度的一半
        tabBgView_Moode.layoutIfNeeded()
        let bgHeight = 50 + 30 // StackView高度50 + 上下各15
        tabBgView_Moode.layer.cornerRadius = CGFloat(bgHeight) / 2.0
    }
    
    @objc private func tabButtonTapped_Moode(_ sender: UIButton) {
        switchTab_Moode(to: sender.tag)
    }
    
    /// 外部调用：切换到指定 Tab 索引，并同步更新按钮选中态
    /// - Parameter index_moode: 目标 Tab 索引（0=首页 1=发现 2=发布 3=消息 4=我的）
    func switchTab_Moode(to index_moode: Int) {
        currentIndex_Moode = index_moode
        selectedIndex = index_moode
        btnHome_Moode.isSelected     = (index_moode == 0)
        btnDiscover_Moode.isSelected = (index_moode == 1)
        btnRelease_Moode.isSelected  = (index_moode == 2)
        btnMessage_Moode.isSelected  = (index_moode == 3)
        btnMe_Moode.isSelected       = (index_moode == 4)
    }
}
