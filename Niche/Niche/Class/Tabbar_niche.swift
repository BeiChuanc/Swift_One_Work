import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 底部导航页面
/// 设计：圆角胶囊背景（#C197FC）+ 32×32 原图图标 + 选中时白色滑条指示器（顶部 5pt）
class TabBar_Niche: UITabBarController {

    // MARK: - 私有属性

    private var tabBgView_Niche    = UIView()
    private var tabStackView_Niche = UIStackView()

    private var btnHome_Niche     = UIButton(type: .custom)
    private var btnDiscover_Niche = UIButton(type: .custom)
    private var btnRelease_Niche  = UIButton(type: .custom)
    private var btnMessage_Niche  = UIButton(type: .custom)
    private var btnMe_Niche       = UIButton(type: .custom)

    /// 白色滑条（32×6，圆角 3，显示在选中按钮上方 5pt）
    private var indicatorBar_Niche = UIView()

    private var currentIndex_Niche: Int = 0

    /// 标志：滑条首次定位是否完成（viewDidAppear 后执行一次）
    private var _indicatorPositioned_niche = false

    private lazy var _allBtns_niche: [UIButton] = [
        btnHome_Niche, btnDiscover_Niche, btnRelease_Niche, btnMessage_Niche, btnMe_Niche
    ]

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [Home_Niche(), Discover_Niche(), Release_Niche(), MessageList_Niche(), Me_Niche()]
        setupUI_Niche()
        setupConstraints_Niche()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }

    /// viewDidAppear 保证所有子视图 frame 完全确定，此时 convert 坐标精准
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !_indicatorPositioned_niche {
            _indicatorPositioned_niche = true
            updateIndicator_Niche(animated: false)
        }
    }

    // MARK: - UI 设置

    private func setupUI_Niche() {
        // 胶囊背景
        tabBgView_Niche.backgroundColor   = UIColor(hexstring_Niche: "#C197FC")
        tabBgView_Niche.layer.masksToBounds = true
        view.addSubview(tabBgView_Niche)

        // StackView：内边距 16pt 使首尾按钮距边缘 16pt
        tabStackView_Niche.axis         = .horizontal
        tabStackView_Niche.distribution = .equalSpacing
        tabStackView_Niche.alignment    = .center
        tabStackView_Niche.isLayoutMarginsRelativeArrangement = true
        tabStackView_Niche.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.addSubview(tabStackView_Niche)

        // 白色滑条（加在 tabBgView 内，初始 frame 为零）
        indicatorBar_Niche.backgroundColor    = .white
        indicatorBar_Niche.layer.cornerRadius = 3
        tabBgView_Niche.addSubview(indicatorBar_Niche)

        // 按钮配置：Assets 原图 alwaysOriginal，32×32
        let configs_niche: [(btn: UIButton, asset: String, tag: Int)] = [
            (btnHome_Niche,     "home",     0),
            (btnDiscover_Niche, "discover", 1),
            (btnRelease_Niche,  "publish",  2),
            (btnMessage_Niche,  "message",  3),
            (btnMe_Niche,       "me",       4)
        ]
        for cfg_niche in configs_niche {
            let img_niche = UIImage(named: cfg_niche.asset)?.withRenderingMode(.alwaysOriginal)
            cfg_niche.btn.setImage(img_niche, for: .normal)
            cfg_niche.btn.setImage(img_niche, for: .selected)
            cfg_niche.btn.imageView?.contentMode = .scaleAspectFit
            cfg_niche.btn.tag = cfg_niche.tag
            cfg_niche.btn.addTarget(self, action: #selector(tabButtonTapped_Niche(_:)), for: .touchUpInside)
            tabStackView_Niche.addArrangedSubview(cfg_niche.btn)
        }

        btnHome_Niche.isSelected = true
    }

    // MARK: - 约束

    private func setupConstraints_Niche() {
        tabStackView_Niche.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(50)
        }

        for btn_niche in _allBtns_niche {
            btn_niche.snp.makeConstraints { make in
                make.width.height.equalTo(32)
            }
        }

        tabBgView_Niche.snp.makeConstraints { make in
            make.leading.trailing.equalTo(tabStackView_Niche)
            make.top.equalTo(tabStackView_Niche).offset(-15)
            make.bottom.equalTo(tabStackView_Niche).offset(15)
        }

        tabBgView_Niche.layoutIfNeeded()
        tabBgView_Niche.layer.cornerRadius = CGFloat(50 + 30) / 2.0
    }

    // MARK: - 滑条定位

    /// 将白色滑条移动到选中按钮正上方 5pt（距胶囊顶部）
    private func updateIndicator_Niche(animated: Bool) {
        guard currentIndex_Niche < _allBtns_niche.count else { return }
        let btn_niche = _allBtns_niche[currentIndex_Niche]

        // 将按钮坐标转换到 tabBgView 坐标系
        let btnFrameInBg_niche = btn_niche.convert(btn_niche.bounds, to: tabBgView_Niche)
        let newFrame_niche = CGRect(
            x: btnFrameInBg_niche.midX - 16,   // 居中，滑条宽 32
            y: 5,                                // 胶囊顶部往下 5pt
            width: 32,
            height: 6
        )

        if animated {
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                usingSpringWithDamping: 0.75,
                initialSpringVelocity: 0.5,
                options: [.curveEaseOut]
            ) { self.indicatorBar_Niche.frame = newFrame_niche }
        } else {
            indicatorBar_Niche.frame = newFrame_niche
        }
    }

    // MARK: - 事件

    @objc private func tabButtonTapped_Niche(_ sender: UIButton) {
        let idx_niche = sender.tag
        currentIndex_Niche = idx_niche
        selectedIndex = idx_niche

        for (i_niche, btn_niche) in _allBtns_niche.enumerated() {
            btn_niche.isSelected = (i_niche == idx_niche)
        }
        updateIndicator_Niche(animated: true)
    }
}
