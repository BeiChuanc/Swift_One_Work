import Foundation
import UIKit
import SnapKit

// MARK: - Banner 轮播视图

/// Banner 轮播视图
/// 核心功能：展示精选帖子，支持自动定时翻页、手动滑动、分页指示器
/// 设计理念：全宽圆角卡片 + 渐变色封面 + 底部渐变遮罩标题
/// 关键方法：configure_Somnia / startAutoPlay_Somnia / onItemTapped_Somnia
class BannerCardView_Somnia: UIView {
    
    // MARK: - 回调
    
    /// Banner 条目点击回调（传入帖子模型）
    var onItemTapped_Somnia: ((TitleModel_Somnia) -> Void)?
    
    // MARK: - 私有属性
    
    /// 帖子数据列表
    private var posts_Somnia: [TitleModel_Somnia] = []
    
    /// 当前展示的页码
    private var currentPage_Somnia: Int = 0
    
    /// 自动播放定时器
    private var autoPlayTimer_Somnia: Timer?
    
    // MARK: - 私有 UI 属性
    
    /// 主滚动视图（水平方向）
    private let scrollView_Somnia: UIScrollView = {
        let sv_Somnia = UIScrollView()
        sv_Somnia.isPagingEnabled = true
        sv_Somnia.showsHorizontalScrollIndicator = false
        sv_Somnia.bounces = false
        sv_Somnia.layer.cornerRadius = 24
        sv_Somnia.clipsToBounds = true
        return sv_Somnia
    }()
    
    /// 分页指示器
    private let pageControl_Somnia: UIPageControl = {
        let pc_Somnia = UIPageControl()
        pc_Somnia.currentPageIndicatorTintColor = .white
        pc_Somnia.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.4)
        pc_Somnia.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        return pc_Somnia
    }()
    
    /// Banner 卡片视图数组
    private var bannerItems_Somnia: [BannerItemView_Somnia] = []
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Somnia()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard !posts_Somnia.isEmpty else { return }
        let width_Somnia = bounds.width
        let height_Somnia = bounds.height
        scrollView_Somnia.contentSize = CGSize(width: width_Somnia * CGFloat(posts_Somnia.count), height: height_Somnia)
        for (i_Somnia, item_Somnia) in bannerItems_Somnia.enumerated() {
            item_Somnia.frame = CGRect(x: CGFloat(i_Somnia) * width_Somnia, y: 0, width: width_Somnia, height: height_Somnia)
        }
        // 回到当前页
        scrollView_Somnia.contentOffset = CGPoint(x: CGFloat(currentPage_Somnia) * width_Somnia, y: 0)
    }
    
    // MARK: - UI 构建
    
    /// 初始化子视图
    private func setupUI_Somnia() {
        backgroundColor = .clear
        
        // 主滚动视图
        addSubview(scrollView_Somnia)
        scrollView_Somnia.delegate = self
        scrollView_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 分页指示器
        addSubview(pageControl_Somnia)
        pageControl_Somnia.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
        
        // 整体阴影
        layer.shadowColor = UIColor(hexstring_Somnia: "#B794F6", alpha_Somnia: 0.25).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowRadius = 20
        layer.shadowOpacity = 1
        layer.masksToBounds = false
    }
    
    // MARK: - 数据配置
    
    /// 配置 Banner 数据
    /// - Parameter posts_Somnia: 帖子数据列表（最多展示前 N 条）
    func configure_Somnia(posts_Somnia: [TitleModel_Somnia]) {
        self.posts_Somnia = Array(posts_Somnia.prefix(5))
        
        // 清除旧视图
        bannerItems_Somnia.forEach { $0.removeFromSuperview() }
        bannerItems_Somnia.removeAll()
        
        // 生成 Banner 子视图
        for (i_Somnia, post_Somnia) in self.posts_Somnia.enumerated() {
            let item_Somnia = BannerItemView_Somnia()
            item_Somnia.configure_Somnia(post_Somnia: post_Somnia, index_Somnia: i_Somnia)
            item_Somnia.onTapped_Somnia = { [weak self] in
                self?.onItemTapped_Somnia?(post_Somnia)
            }
            scrollView_Somnia.addSubview(item_Somnia)
            bannerItems_Somnia.append(item_Somnia)
        }
        
        pageControl_Somnia.numberOfPages = self.posts_Somnia.count
        pageControl_Somnia.currentPage = 0
        currentPage_Somnia = 0
        
        setNeedsLayout()
        layoutIfNeeded()
        
        startAutoPlay_Somnia()
    }
    
    // MARK: - 自动播放
    
    /// 启动自动轮播（间隔 3 秒）
    func startAutoPlay_Somnia() {
        stopAutoPlay_Somnia()
        guard posts_Somnia.count > 1 else { return }
        autoPlayTimer_Somnia = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { [weak self] _ in
            self?.scrollToNext_Somnia()
        }
    }
    
    /// 停止自动轮播
    func stopAutoPlay_Somnia() {
        autoPlayTimer_Somnia?.invalidate()
        autoPlayTimer_Somnia = nil
    }
    
    /// 滚动到下一页
    private func scrollToNext_Somnia() {
        guard posts_Somnia.count > 0 else { return }
        let next_Somnia = (currentPage_Somnia + 1) % posts_Somnia.count
        scrollToPage_Somnia(page_Somnia: next_Somnia, animated: true)
    }
    
    /// 滚动到指定页
    private func scrollToPage_Somnia(page_Somnia: Int, animated: Bool) {
        let offsetX_Somnia = CGFloat(page_Somnia) * bounds.width
        scrollView_Somnia.setContentOffset(CGPoint(x: offsetX_Somnia, y: 0), animated: animated)
        currentPage_Somnia = page_Somnia
        pageControl_Somnia.currentPage = page_Somnia
    }
    
    // MARK: - 释放
    
    deinit {
        stopAutoPlay_Somnia()
    }
}

// MARK: - UIScrollViewDelegate

extension BannerCardView_Somnia: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page_Somnia = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        currentPage_Somnia = page_Somnia
        pageControl_Somnia.currentPage = page_Somnia
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoPlay_Somnia()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startAutoPlay_Somnia()
    }
}

// MARK: - Banner 单项视图

/// Banner 单项视图
/// 功能：单张 Banner 卡片，渐变背景 + 系统图标 + 标题 + 内容摘要
private class BannerItemView_Somnia: UIView {
    
    // MARK: - 回调
    
    /// 点击回调
    var onTapped_Somnia: (() -> Void)?
    
    // MARK: - 私有 UI 属性
    
    /// 渐变背景图层
    private var gradientLayer_Somnia: CAGradientLayer?
    
    /// 装饰系统图标（大）
    private let decorIcon_Somnia = UIImageView()
    
    /// 右上角小图标
    private let smallIcon_Somnia = UIImageView()
    
    /// 底部渐变遮罩
    private let bottomMask_Somnia = UIView()
    private var maskGradientLayer_Somnia: CAGradientLayer?
    
    /// 标题标签
    private let titleLabel_Somnia = UILabel()
    
    /// 内容摘要
    private let snippetLabel_Somnia = UILabel()
    
    /// 作者名称
    private let authorLabel_Somnia = UILabel()
    
    /// 进入按钮
    private let enterButton_Somnia = UIView()
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Somnia()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Somnia?.frame = bounds
        
        // 底部遮罩：从底部往上 120pt 渐变到透明
        maskGradientLayer_Somnia?.frame = bottomMask_Somnia.bounds
    }
    
    // MARK: - UI 构建
    
    /// 初始化子视图
    private func setupUI_Somnia() {
        clipsToBounds = true
        
        // 渐变背景
        let grad_Somnia = UIColor.createPrimaryGradientLayer_Somnia(frame_Somnia: .zero)
        grad_Somnia.startPoint = CGPoint(x: 0, y: 0)
        grad_Somnia.endPoint = CGPoint(x: 1, y: 1)
        layer.insertSublayer(grad_Somnia, at: 0)
        gradientLayer_Somnia = grad_Somnia
        
        // 大装饰图标（半透明）
        decorIcon_Somnia.contentMode = .scaleAspectFit
        decorIcon_Somnia.tintColor = UIColor.white.withAlphaComponent(0.15)
        addSubview(decorIcon_Somnia)
        
        // 右上角小图标
        smallIcon_Somnia.contentMode = .scaleAspectFit
        smallIcon_Somnia.tintColor = UIColor.white.withAlphaComponent(0.8)
        addSubview(smallIcon_Somnia)
        
        // 底部渐变遮罩
        bottomMask_Somnia.isUserInteractionEnabled = false
        addSubview(bottomMask_Somnia)
        
        let maskGrad_Somnia = CAGradientLayer()
        maskGrad_Somnia.colors = [
            UIColor.clear.cgColor,
            UIColor(white: 0, alpha: 0.65).cgColor
        ]
        maskGrad_Somnia.startPoint = CGPoint(x: 0.5, y: 0)
        maskGrad_Somnia.endPoint = CGPoint(x: 0.5, y: 1)
        bottomMask_Somnia.layer.insertSublayer(maskGrad_Somnia, at: 0)
        maskGradientLayer_Somnia = maskGrad_Somnia
        
        // 作者名
        authorLabel_Somnia.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        authorLabel_Somnia.textColor = UIColor.white.withAlphaComponent(0.8)
        addSubview(authorLabel_Somnia)
        
        // 标题
        titleLabel_Somnia.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel_Somnia.textColor = .white
        titleLabel_Somnia.numberOfLines = 2
        addSubview(titleLabel_Somnia)
        
        // 内容摘要
        snippetLabel_Somnia.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        snippetLabel_Somnia.textColor = UIColor.white.withAlphaComponent(0.75)
        snippetLabel_Somnia.numberOfLines = 2
        addSubview(snippetLabel_Somnia)
        
        // 进入按钮装饰（箭头图标）
        let enterIcon_Somnia = UIImageView(image: UIImage(systemName: "arrow.right.circle.fill"))
        enterIcon_Somnia.tintColor = .white.withAlphaComponent(0.9)
        enterIcon_Somnia.contentMode = .scaleAspectFit
        addSubview(enterIcon_Somnia)
        enterIcon_Somnia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-18)
            make.width.height.equalTo(26)
        }
        
        // 点击手势
        let tap_Somnia = UITapGestureRecognizer(target: self, action: #selector(handleTap_Somnia))
        addGestureRecognizer(tap_Somnia)
        
        // 约束
        decorIcon_Somnia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(-10)
            make.width.height.equalTo(180)
        }
        
        smallIcon_Somnia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(22)
        }
        
        bottomMask_Somnia.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(160)
        }
        
        authorLabel_Somnia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-82)
        }
        
        titleLabel_Somnia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-60)
            make.bottom.equalToSuperview().offset(-44)
        }
        
        snippetLabel_Somnia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-60)
            make.bottom.equalToSuperview().offset(-18)
        }
    }
    
    // MARK: - 数据绑定
    
    /// 配置单项 Banner
    /// - Parameters:
    ///   - post_Somnia: 帖子数据模型
    ///   - index_Somnia: 当前索引（用于轮换样式）
    func configure_Somnia(post_Somnia: TitleModel_Somnia, index_Somnia: Int) {
        titleLabel_Somnia.text = post_Somnia.title_Somnia
        authorLabel_Somnia.text = "by \(post_Somnia.titleUserName_Somnia)"
        
        let snippet_Somnia = String(post_Somnia.titleContent_Somnia.prefix(60))
        snippetLabel_Somnia.text = snippet_Somnia + (post_Somnia.titleContent_Somnia.count > 60 ? "..." : "")
        
        // 大装饰图标
        let decorIcons_Somnia = ["moon.stars.fill", "sparkles", "cloud.moon.fill", "star.fill", "wind"]
        decorIcon_Somnia.image = UIImage(systemName: decorIcons_Somnia[index_Somnia % decorIcons_Somnia.count])
        
        // 小图标
        let smallIcons_Somnia = ["wand.and.stars", "heart.fill", "bookmark.fill", "flame.fill", "leaf.fill"]
        smallIcon_Somnia.image = UIImage(systemName: smallIcons_Somnia[index_Somnia % smallIcons_Somnia.count])
        
        // 渐变色轮换
        let gradColors_Somnia: [[CGColor]] = [
            [ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
             ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor],
            [ColorConfig_Somnia.secondaryGradientStart_Somnia.cgColor,
             ColorConfig_Somnia.secondaryGradientEnd_Somnia.cgColor],
            [UIColor(hexstring_Somnia: "#9F7AEA").cgColor,
             UIColor(hexstring_Somnia: "#63B3ED").cgColor],
            [ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor,
             ColorConfig_Somnia.secondaryGradientStart_Somnia.cgColor],
            [UIColor(hexstring_Somnia: "#F687B3").cgColor,
             UIColor(hexstring_Somnia: "#FBB6CE").cgColor],
        ]
        gradientLayer_Somnia?.colors = gradColors_Somnia[index_Somnia % gradColors_Somnia.count]
    }
    
    // MARK: - 事件响应
    
    @objc private func handleTap_Somnia() {
        animatePressDown_Somnia {
            self.animatePressUp_Somnia {
                self.onTapped_Somnia?()
            }
        }
    }
}
