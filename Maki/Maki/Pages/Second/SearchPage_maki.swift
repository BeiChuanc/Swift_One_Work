import Foundation
import UIKit
import SnapKit

// MARK: - 发现页搜索视图控制器

/// 发现页搜索页面
/// 功能：全屏搜索覆盖层，实时过滤帖子标题与内容，点击结果跳转帖子详情
/// 设计：顶部搜索输入栏 + 结果列表；以 overFullScreen 模式展示，背景半透明模糊
/// 逻辑：监听输入框文本变化，实时更新 filteredPosts_Maki；空状态展示引导提示
class SearchPage_Maki: UIViewController {

    // MARK: - 私有常量

    private enum K_Maki {
        static let primary = UIColor(hexstring_Maki: "#FF8C00")
        static let bg      = UIColor(hexstring_Maki: "#FFFBF4")
        static let tp      = UIColor(hexstring_Maki: "#1A0A00")
        static let ts      = UIColor(hexstring_Maki: "#8B7355")
        static let cellId  = "SearchResultCell_Maki"
    }

    // MARK: - UI 属性

    /// 全屏半透明背景遮罩（点击关闭）
    private let dimBg_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return v_maki
    }()

    /// 搜索面板容器（顶部圆角白卡）
    private let panelView_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = K_Maki.bg
        v_maki.layer.cornerRadius = 24
        v_maki.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        v_maki.layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: 8)
        v_maki.layer.shadowRadius = 20
        v_maki.layer.shadowOpacity = 1
        return v_maki
    }()

    /// 搜索栏容器（胶囊背景）
    private let searchBarWrap_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor.white
        v_maki.layer.cornerRadius = 22
        v_maki.layer.borderWidth = 1.5
        v_maki.layer.borderColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.3).cgColor
        v_maki.layer.shadowColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.12).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: 3)
        v_maki.layer.shadowRadius = 8
        v_maki.layer.shadowOpacity = 1
        return v_maki
    }()

    /// 搜索图标
    private let searchIcon_Maki: UIImageView = {
        let iv_maki = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iv_maki.tintColor = UIColor(hexstring_Maki: "#FF8C00")
        iv_maki.contentMode = .scaleAspectFit
        return iv_maki
    }()

    /// 搜索输入框
    private let searchField_Maki: UITextField = {
        let tf_maki = UITextField()
        tf_maki.placeholder = "Search posts by title or content..."
        tf_maki.font = .systemFont(ofSize: 15)
        tf_maki.textColor = UIColor(hexstring_Maki: "#1A0A00")
        tf_maki.clearButtonMode = .whileEditing
        tf_maki.returnKeyType = .search
        tf_maki.autocorrectionType = .no
        if let color_maki = UIColor(hexstring_Maki: "#8B7355") as UIColor? {
            tf_maki.attributedPlaceholder = NSAttributedString(
                string: "Search posts by title or content...",
                attributes: [.foregroundColor: color_maki.withAlphaComponent(0.55)]
            )
        }
        return tf_maki
    }()

    /// 取消按钮
    private let cancelBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setTitle("Cancel", for: .normal)
        btn_maki.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        btn_maki.setTitleColor(UIColor(hexstring_Maki: "#FF8C00"), for: .normal)
        return btn_maki
    }()

    /// 搜索结果数量标签
    private let resultCountLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 12, weight: .medium)
        lb_maki.textColor = UIColor(hexstring_Maki: "#8B7355")
        return lb_maki
    }()

    /// 搜索结果列表
    private lazy var tableView_Maki: UITableView = {
        let tv_maki = UITableView(frame: .zero, style: .plain)
        tv_maki.backgroundColor = .clear
        tv_maki.separatorStyle = .none
        tv_maki.showsVerticalScrollIndicator = false
        tv_maki.keyboardDismissMode = .onDrag
        tv_maki.register(SearchResultCell_Maki.self, forCellReuseIdentifier: K_Maki.cellId)
        return tv_maki
    }()

    /// 空状态占位视图
    private let emptyView_Maki: UIView = {
        let v_maki = UIView()
        v_maki.isHidden = true
        return v_maki
    }()

    // MARK: - 数据

    /// 当前过滤后的帖子结果列表
    private var filteredPosts_Maki: [TitleModel_Maki] = []

    /// 当前搜索关键词
    private var keyword_Maki: String = ""

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        buildUI_Maki()
        bindActions_Maki()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playEntranceAnimation_Maki()
        searchField_Maki.becomeFirstResponder()
    }

    // MARK: - UI 构建

    /// 构建全部 UI 层级与约束
    private func buildUI_Maki() {
        // 半透明背景
        view.addSubview(dimBg_Maki)
        dimBg_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 点击背景关闭
        let tapBg_maki = UITapGestureRecognizer(target: self, action: #selector(onBgTap_Maki))
        dimBg_Maki.addGestureRecognizer(tapBg_maki)

        // 搜索面板
        view.addSubview(panelView_Maki)
        panelView_Maki.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        buildSearchBar_Maki()
        buildResultArea_Maki()
        buildEmptyView_Maki()
    }

    /// 构建顶部搜索栏（图标 + 输入框 + 取消按钮）
    private func buildSearchBar_Maki() {
        // 状态栏占位高度
        let statusH_maki = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44

        // 标题区
        let titleLb_maki = UILabel()
        titleLb_maki.text = "Search"
        titleLb_maki.font = UIFont(name: "Georgia-Bold", size: 20) ?? .systemFont(ofSize: 20, weight: .bold)
        titleLb_maki.textColor = K_Maki.tp
        panelView_Maki.addSubview(titleLb_maki)
        titleLb_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(statusH_maki + 12)
        }

        // 搜索栏容器
        panelView_Maki.addSubview(searchBarWrap_Maki)
        searchBarWrap_Maki.snp.makeConstraints { make in
            make.top.equalTo(titleLb_maki.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(44)
        }

        // 取消按钮
        cancelBtn_Maki.addTarget(self, action: #selector(onCancelTap_Maki), for: .touchUpInside)
        panelView_Maki.addSubview(cancelBtn_Maki)
        cancelBtn_Maki.snp.makeConstraints { make in
            make.centerY.equalTo(searchBarWrap_Maki)
            make.trailing.equalToSuperview().offset(-16)
            make.leading.equalTo(searchBarWrap_Maki.snp.trailing).offset(10)
        }
        cancelBtn_Maki.setContentHuggingPriority(.required, for: .horizontal)

        // 搜索图标
        searchBarWrap_Maki.addSubview(searchIcon_Maki)
        searchIcon_Maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }

        // 输入框
        searchField_Maki.delegate = self
        searchField_Maki.addTarget(self, action: #selector(onTextChange_Maki), for: .editingChanged)
        searchBarWrap_Maki.addSubview(searchField_Maki)
        searchField_Maki.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon_Maki.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }

        // 结果数量标签
        panelView_Maki.addSubview(resultCountLb_Maki)
        resultCountLb_Maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(searchBarWrap_Maki.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    /// 构建搜索结果列表区域
    private func buildResultArea_Maki() {
        view.addSubview(tableView_Maki)
        tableView_Maki.dataSource = self
        tableView_Maki.delegate   = self
        tableView_Maki.snp.makeConstraints { make in
            make.top.equalTo(panelView_Maki.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    /// 构建空状态占位视图
    private func buildEmptyView_Maki() {
        view.addSubview(emptyView_Maki)
        emptyView_Maki.snp.makeConstraints { make in
            make.top.equalTo(panelView_Maki.snp.bottom).offset(60)
            make.centerX.equalToSuperview()
        }

        let iconLb_maki = UILabel()
        iconLb_maki.text = "🔍"
        iconLb_maki.font = .systemFont(ofSize: 44)
        iconLb_maki.textAlignment = .center

        let msgLb_maki = UILabel()
        msgLb_maki.font = .systemFont(ofSize: 15, weight: .semibold)
        msgLb_maki.textColor = K_Maki.tp
        msgLb_maki.textAlignment = .center

        let hintLb_maki = UILabel()
        hintLb_maki.font = .systemFont(ofSize: 13)
        hintLb_maki.textColor = K_Maki.ts.withAlphaComponent(0.7)
        hintLb_maki.textAlignment = .center
        hintLb_maki.numberOfLines = 2

        emptyView_Maki.addSubview(iconLb_maki)
        emptyView_Maki.addSubview(msgLb_maki)
        emptyView_Maki.addSubview(hintLb_maki)

        iconLb_maki.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
        }
        msgLb_maki.snp.makeConstraints { make in
            make.top.equalTo(iconLb_maki.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        hintLb_maki.snp.makeConstraints { make in
            make.top.equalTo(msgLb_maki.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.width.equalTo(240)
            make.bottom.equalToSuperview()
        }

        // 保存子标签引用便于后续更新
        emptyView_Maki.tag = 999
        msgLb_maki.tag = 1
        hintLb_maki.tag = 2
        emptyView_Maki.subviews.forEach { $0.isUserInteractionEnabled = false }

        // 初始提示（未输入关键词时）
        msgLb_maki.text = "Start typing to discover"
        hintLb_maki.text = "Search by post title or content keywords"
        emptyView_Maki.isHidden = false
    }

    // MARK: - 动画

    /// 进场动画：面板从顶部滑入，背景遮罩淡入
    private func playEntranceAnimation_Maki() {
        panelView_Maki.transform = CGAffineTransform(translationX: 0, y: -panelView_Maki.bounds.height - 40)
        dimBg_Maki.alpha = 0
        tableView_Maki.alpha = 0

        UIView.animate(
            withDuration: 0.42,
            delay: 0,
            usingSpringWithDamping: 0.82,
            initialSpringVelocity: 0.4,
            options: [],
            animations: {
                self.panelView_Maki.transform = .identity
                self.dimBg_Maki.alpha = 1
            }
        )
        UIView.animate(withDuration: 0.3, delay: 0.25, options: .curveEaseOut) {
            self.tableView_Maki.alpha = 1
        }
    }

    /// 退场动画：面板向上收起，背景遮罩淡出
    private func playExitAnimation_Maki(completion_maki: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.32,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                self.panelView_Maki.transform = CGAffineTransform(translationX: 0, y: -self.panelView_Maki.bounds.height - 20)
                self.dimBg_Maki.alpha = 0
                self.tableView_Maki.alpha = 0
            },
            completion: { _ in completion_maki() }
        )
    }

    // MARK: - 数据过滤

    /// 根据关键词实时过滤帖子列表（匹配标题或内容）
    /// - Parameter keyword_maki: 用户输入的搜索词（不区分大小写）
    private func filterPosts_Maki(keyword_maki: String) {
        keyword_Maki = keyword_maki.trimmingCharacters(in: .whitespacesAndNewlines)
        let all_maki = TitleViewModel_Maki.shared_Maki.getPosts_Maki()

        if keyword_Maki.isEmpty {
            // 未输入：清空结果，显示初始引导
            filteredPosts_Maki = []
            updateEmptyState_Maki(isEmpty_maki: true, isNoResult_maki: false)
        } else {
            // 按标题或内容匹配（不区分大小写）
            let lower_maki = keyword_Maki.lowercased()
            filteredPosts_Maki = all_maki.filter {
                $0.title_Maki.lowercased().contains(lower_maki)
                || $0.titleContent_Maki.lowercased().contains(lower_maki)
            }
            updateEmptyState_Maki(isEmpty_maki: filteredPosts_Maki.isEmpty, isNoResult_maki: true)
        }

        // 更新结果数量标签
        if keyword_Maki.isEmpty {
            resultCountLb_Maki.text = "Enter keywords to search"
        } else if filteredPosts_Maki.isEmpty {
            resultCountLb_Maki.text = "No results found"
            resultCountLb_Maki.textColor = UIColor(hexstring_Maki: "#E74C3C").withAlphaComponent(0.8)
        } else {
            resultCountLb_Maki.text = "\(filteredPosts_Maki.count) result\(filteredPosts_Maki.count > 1 ? "s" : "") found"
            resultCountLb_Maki.textColor = K_Maki.ts
        }

        tableView_Maki.reloadData()

        // 有结果时滚动至顶部
        if !filteredPosts_Maki.isEmpty {
            tableView_Maki.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }

    /// 更新空状态占位视图的文案与显示状态
    /// - Parameters:
    ///   - isEmpty_maki: 是否需要展示空状态
    ///   - isNoResult_maki: true = 搜索无结果；false = 未输入关键词
    private func updateEmptyState_Maki(isEmpty_maki: Bool, isNoResult_maki: Bool) {
        emptyView_Maki.isHidden = !isEmpty_maki
        tableView_Maki.isHidden = isEmpty_maki

        guard let msgLb_maki = emptyView_Maki.viewWithTag(1) as? UILabel,
              let hintLb_maki = emptyView_Maki.viewWithTag(2) as? UILabel else { return }

        if isNoResult_maki {
            // 搜索无结果
            (emptyView_Maki.subviews.first as? UILabel)?.text = "😶‍🌫️"
            msgLb_maki.text = "No posts found"
            hintLb_maki.text = "Try different keywords or check the spelling"
        } else {
            // 未输入关键词
            (emptyView_Maki.subviews.first as? UILabel)?.text = "🔍"
            msgLb_maki.text = "Start typing to discover"
            hintLb_maki.text = "Search by post title or content keywords"
        }
    }

    // MARK: - 事件绑定

    private func bindActions_Maki() {
        cancelBtn_Maki.addTarget(self, action: #selector(onCancelTap_Maki), for: .touchUpInside)
    }

    /// 点击背景遮罩关闭搜索页
    @objc private func onBgTap_Maki() {
        dismissSearch_Maki()
    }

    /// 点击取消按钮关闭搜索页
    @objc private func onCancelTap_Maki() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismissSearch_Maki()
    }

    /// 执行退场动画后关闭
    private func dismissSearch_Maki() {
        searchField_Maki.resignFirstResponder()
        playExitAnimation_Maki { [weak self] in
            self?.dismiss(animated: false)
        }
    }

    /// 输入框文本变化实时触发过滤
    @objc private func onTextChange_Maki() {
        filterPosts_Maki(keyword_maki: searchField_Maki.text ?? "")
    }
}

// MARK: - UITextFieldDelegate

extension SearchPage_Maki: UITextFieldDelegate {

    /// 点击键盘 Search 按钮收起键盘
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDataSource & Delegate

extension SearchPage_Maki: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredPosts_Maki.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_maki = tableView.dequeueReusableCell(
            withIdentifier: K_Maki.cellId,
            for: indexPath
        ) as! SearchResultCell_Maki
        let post_maki = filteredPosts_Maki[indexPath.row]
        cell_maki.configure_Maki(post_maki: post_maki, keyword_maki: keyword_Maki)
        return cell_maki
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        84
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let post_maki = filteredPosts_Maki[indexPath.row]
        // 先关闭搜索页再跳转详情，避免导航层级混乱
        searchField_Maki.resignFirstResponder()
        playExitAnimation_Maki { [weak self] in
            self?.dismiss(animated: false) {
                Navigation_Maki.toTitleDetail_Maki(titleModel_maki: post_maki)
            }
        }
    }
}

// MARK: - SearchResultCell_Maki（搜索结果列表行）

/// 搜索结果列表 Cell
/// 功能：展示帖子缩略图、标题（高亮关键词）、内容摘要（高亮关键词）、作者名
/// 设计：左侧方形缩略图 + 右侧文字区，白色圆角卡片样式
final class SearchResultCell_Maki: UITableViewCell {

    // MARK: UI 子视图

    /// 白色卡片容器
    private let cardView_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = .white
        v_maki.layer.cornerRadius = 14
        v_maki.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: 3)
        v_maki.layer.shadowRadius = 8
        v_maki.layer.shadowOpacity = 1
        return v_maki
    }()

    /// 帖子缩略图（圆角）
    private let thumbIV_Maki: UIImageView = {
        let iv_maki = UIImageView()
        iv_maki.contentMode = .scaleAspectFill
        iv_maki.clipsToBounds = true
        iv_maki.layer.cornerRadius = 10
        iv_maki.backgroundColor = UIColor(hexstring_Maki: "#FFF3E0")
        return iv_maki
    }()

    /// 帖子标题（支持关键词高亮）
    private let titleLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 14, weight: .semibold)
        lb_maki.textColor = UIColor(hexstring_Maki: "#1A0A00")
        lb_maki.numberOfLines = 1
        return lb_maki
    }()

    /// 内容摘要（支持关键词高亮）
    private let summaryLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 12)
        lb_maki.textColor = UIColor(hexstring_Maki: "#8B7355")
        lb_maki.numberOfLines = 2
        return lb_maki
    }()

    /// 作者名标签
    private let authorLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 11, weight: .medium)
        lb_maki.textColor = UIColor(hexstring_Maki: "#FF8C00")
        return lb_maki
    }()

    // MARK: 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI_Maki()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UI 搭建

    private func setupUI_Maki() {
        contentView.addSubview(cardView_Maki)
        cardView_Maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        cardView_Maki.addSubview(thumbIV_Maki)
        thumbIV_Maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(58)
        }

        cardView_Maki.addSubview(titleLb_Maki)
        titleLb_Maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(thumbIV_Maki.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }

        cardView_Maki.addSubview(summaryLb_Maki)
        summaryLb_Maki.snp.makeConstraints { make in
            make.top.equalTo(titleLb_Maki.snp.bottom).offset(3)
            make.leading.trailing.equalTo(titleLb_Maki)
        }

        cardView_Maki.addSubview(authorLb_Maki)
        authorLb_Maki.snp.makeConstraints { make in
            make.top.equalTo(summaryLb_Maki.snp.bottom).offset(4)
            make.leading.equalTo(titleLb_Maki)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
        }
    }

    // MARK: 配置方法

    /// 配置 Cell 数据，并对关键词进行橙色高亮标注
    /// - Parameters:
    ///   - post_maki: 帖子模型
    ///   - keyword_maki: 当前搜索关键词（用于高亮）
    func configure_Maki(post_maki: TitleModel_Maki, keyword_maki: String) {
        // 缩略图
        if let name_maki = post_maki.titleMeidas_Maki.first {
            thumbIV_Maki.image = UIImage(named: name_maki)
                ?? UIImage(systemName: "photo.artframe")
            thumbIV_Maki.tintColor = UIColor(hexstring_Maki: "#FF8C00")
        }

        // 高亮标题与内容摘要
        titleLb_Maki.attributedText   = highlight_Maki(text_maki: post_maki.title_Maki,
                                                        keyword_maki: keyword_maki,
                                                        baseFont_maki: .systemFont(ofSize: 14, weight: .semibold))
        summaryLb_Maki.attributedText = highlight_Maki(text_maki: post_maki.titleContent_Maki,
                                                        keyword_maki: keyword_maki,
                                                        baseFont_maki: .systemFont(ofSize: 12))
        authorLb_Maki.text = "by  \(post_maki.titleUserName_Maki)"
    }

    /// 生成带关键词高亮的富文本
    /// - Parameters:
    ///   - text_maki: 原始文本
    ///   - keyword_maki: 高亮关键词
    ///   - baseFont_maki: 基础字体
    /// - Returns: NSAttributedString，关键词部分以橙色加粗标注
    private func highlight_Maki(text_maki: String,
                                 keyword_maki: String,
                                 baseFont_maki: UIFont) -> NSAttributedString {
        let attr_maki = NSMutableAttributedString(string: text_maki, attributes: [
            .font: baseFont_maki,
            .foregroundColor: UIColor(hexstring_Maki: "#1A0A00")
        ])
        guard !keyword_maki.isEmpty else { return attr_maki }

        let lower_maki = text_maki.lowercased()
        let kw_maki    = keyword_maki.lowercased()
        var searchRange_maki = lower_maki.startIndex..<lower_maki.endIndex

        while let range_maki = lower_maki.range(of: kw_maki, range: searchRange_maki) {
            let nsRange_maki = NSRange(range_maki, in: text_maki)
            attr_maki.addAttributes([
                .foregroundColor: UIColor(hexstring_Maki: "#FF8C00"),
                .font: UIFont.systemFont(ofSize: baseFont_maki.pointSize, weight: .bold)
            ], range: nsRange_maki)
            searchRange_maki = range_maki.upperBound..<lower_maki.endIndex
        }
        return attr_maki
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbIV_Maki.image = nil
        titleLb_Maki.attributedText   = nil
        summaryLb_Maki.attributedText = nil
        authorLb_Maki.text = nil
    }
}
