import Foundation
import UIKit
import SnapKit

// MARK: - 拍摄预设列表弹窗

/// 拍摄预设列表底部弹窗
/// 核心作用：展示已保存的全部拍摄参数预设，支持一键还原到拍摄工具页，支持删除
/// 设计思路：拖动条 + 标题 + 空状态提示 + 纵向列表（名称/网格类型/滤镜摘要 + 删除按钮）
/// 关键属性/方法：
///   - onPresetSelected_Tidy：点击某条预设时的回调，由外部（ShootStudio_Tidy）注入还原逻辑
class PresetListSheet_Tidy: UIViewController {

    /// 点击预设行时的回调，携带被选中的预设数据
    var onPresetSelected_Tidy: ((ShootPreset_Tidy) -> Void)?

    private var presets_Tidy: [ShootPreset_Tidy] = []

    private let dragBar_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Tidy: "#CBD5E0")
        v.layer.cornerRadius = 2.5
        return v
    }()
    private let titleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Saved Presets"
        lb.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lb.textColor = ColorConfig_Tidy.textPrimary_Tidy
        return lb
    }()
    private let subtitleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Tap to reload a shooting setup instantly"
        lb.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lb.textColor = ColorConfig_Tidy.textSecondary_Tidy
        return lb
    }()
    /// 空状态图标（圆形底衬 + 相机图标，替代纯文字提示）
    private let emptyIconBg_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.tidyMint_Tidy.withAlphaComponent(0.08)
        v.layer.cornerRadius = 40
        return v
    }()
    private let emptyIcon_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "bookmark.slash",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .light))
        iv.tintColor = ColorConfig_Tidy.tidyMint_Tidy.withAlphaComponent(0.55)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let emptyLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "No presets yet.\nSave your current setup from the studio."
        lb.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lb.textColor = ColorConfig_Tidy.textPlaceholder_Tidy
        lb.textAlignment = .center
        lb.numberOfLines = 2
        return lb
    }()
    /// 相对时间格式化器（"2 hours ago" 一类的展示）
    private let relativeTimeFormatter_Tidy: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f
    }()
    private let scrollView_Tidy = UIScrollView()
    private let contentStack_Tidy: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        return sv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        setupUI_Tidy()
        loadPresets_Tidy()
        NotificationCenter.default.addObserver(
            self, selector: #selector(loadPresets_Tidy),
            name: ShootViewModel_Tidy.shootPresetsDidChangeNotification_Tidy, object: nil
        )
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    private func setupUI_Tidy() {
        view.addSubview(dragBar_Tidy)
        view.addSubview(titleLabel_Tidy)
        view.addSubview(subtitleLabel_Tidy)
        view.addSubview(emptyIconBg_Tidy)
        emptyIconBg_Tidy.addSubview(emptyIcon_Tidy)
        view.addSubview(emptyLabel_Tidy)
        view.addSubview(scrollView_Tidy)
        scrollView_Tidy.addSubview(contentStack_Tidy)
        scrollView_Tidy.showsVerticalScrollIndicator = false

        dragBar_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(5)
        }
        titleLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(dragBar_Tidy.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
        }
        subtitleLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Tidy.snp.bottom).offset(3)
            make.leading.equalToSuperview().offset(20)
        }
        emptyIconBg_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(subtitleLabel_Tidy.snp.bottom).offset(50)
            make.width.height.equalTo(80)
        }
        emptyIcon_Tidy.snp.makeConstraints { make in make.center.equalToSuperview() }
        emptyLabel_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyIconBg_Tidy.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(40)
        }
        scrollView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Tidy.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
        contentStack_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-40)
            make.width.equalTo(scrollView_Tidy).offset(-40)
        }
    }

    /// 从本地存储重新加载预设列表并刷新展示
    @objc private func loadPresets_Tidy() {
        presets_Tidy = ShootViewModel_Tidy.shared_Tidy.getAllPresets_Tidy()
        let isEmpty_tidy = presets_Tidy.isEmpty
        emptyIconBg_Tidy.isHidden = !isEmpty_tidy
        emptyLabel_Tidy.isHidden = !isEmpty_tidy
        scrollView_Tidy.isHidden = isEmpty_tidy
        renderList_Tidy()
    }

    /// 重新渲染预设行列表
    private func renderList_Tidy() {
        contentStack_Tidy.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index_tidy, preset_tidy) in presets_Tidy.enumerated() {
            contentStack_Tidy.addArrangedSubview(makeRow_Tidy(preset_tidy: preset_tidy, index_tidy: index_tidy))
        }
    }

    /// 创建单条预设行视图
    /// 参数：
    /// - preset_tidy: 预设数据
    /// - index_tidy: 在当前列表中的下标，用于点击/删除事件定位
    private func makeRow_Tidy(preset_tidy: ShootPreset_Tidy, index_tidy: Int) -> UIView {
        // 每条预设按其构图网格类型的主题色着色（图标底色/边框/左侧强调条），提升不同预设间的辨识度
        let themeColor_tidy = preset_tidy.gridType_Tidy.themeColor_Tidy

        let card_tidy = UIView()
        card_tidy.backgroundColor = .white
        card_tidy.layer.cornerRadius = 16
        card_tidy.layer.borderWidth = 1
        card_tidy.layer.borderColor = themeColor_tidy.withAlphaComponent(0.14).cgColor
        card_tidy.layer.shadowColor = themeColor_tidy.withAlphaComponent(0.18).cgColor
        card_tidy.layer.shadowOffset = CGSize(width: 0, height: 3)
        card_tidy.layer.shadowRadius = 8
        card_tidy.layer.shadowOpacity = 1
        card_tidy.snp.makeConstraints { make in make.height.equalTo(78) }

        // 左侧主题色强调条
        let accentStrip_tidy = UIView()
        accentStrip_tidy.backgroundColor = themeColor_tidy
        accentStrip_tidy.layer.cornerRadius = 2
        accentStrip_tidy.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]

        let iconBg_tidy = UIView()
        iconBg_tidy.backgroundColor = themeColor_tidy.withAlphaComponent(0.14)
        iconBg_tidy.layer.cornerRadius = 20
        iconBg_tidy.clipsToBounds = true
        let iconView_tidy = UIImageView()
        iconView_tidy.image = UIImage(systemName: preset_tidy.gridType_Tidy.iconName_Tidy,
                                       withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold))
        iconView_tidy.tintColor = themeColor_tidy
        iconView_tidy.contentMode = .scaleAspectFit

        // 若预设保存时关联了照片，用照片缩略图取代纯图标底色，让每条预设更直观地"看得到"当时的画面
        let thumbnailView_tidy = UIImageView()
        thumbnailView_tidy.contentMode = .scaleAspectFill
        thumbnailView_tidy.isHidden = true
        if let imageFileName_tidy = preset_tidy.imageFileName_Tidy,
           let thumbnail_tidy = ShootViewModel_Tidy.shared_Tidy.loadPresetImage_Tidy(fileName_tidy: imageFileName_tidy) {
            thumbnailView_tidy.image = thumbnail_tidy
            thumbnailView_tidy.isHidden = false
            iconView_tidy.isHidden = true
        }

        let nameLabel_tidy = UILabel()
        nameLabel_tidy.text = preset_tidy.name_Tidy
        nameLabel_tidy.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        nameLabel_tidy.textColor = ColorConfig_Tidy.textPrimary_Tidy

        var summary_tidy = preset_tidy.gridType_Tidy.displayName_Tidy
        if let filterId_tidy = preset_tidy.filterPresetId_Tidy,
           let filterPreset_tidy = ShootViewModel_Tidy.shared_Tidy.getFilmFilterPreset_Tidy(id_tidy: filterId_tidy) {
            summary_tidy += " · \(filterPreset_tidy.name_Tidy)"
        }
        if preset_tidy.gradientConfig_Tidy != nil { summary_tidy += " · Gradient" }
        let summaryLabel_tidy = UILabel()
        summaryLabel_tidy.text = summary_tidy
        summaryLabel_tidy.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        summaryLabel_tidy.textColor = ColorConfig_Tidy.textSecondary_Tidy
        summaryLabel_tidy.numberOfLines = 1

        // 相对保存时间（如 "2 hr. ago"），帮助区分多条相似预设
        let timeLabel_tidy = UILabel()
        timeLabel_tidy.text = "Saved " + relativeTimeFormatter_Tidy.localizedString(for: preset_tidy.createdAt_Tidy, relativeTo: Date())
        timeLabel_tidy.font = UIFont.systemFont(ofSize: 10.5, weight: .medium)
        timeLabel_tidy.textColor = ColorConfig_Tidy.textPlaceholder_Tidy

        let deleteButton_tidy = UIButton(type: .custom)
        deleteButton_tidy.setImage(UIImage(systemName: "trash",
                                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)),
                                    for: .normal)
        deleteButton_tidy.tintColor = ColorConfig_Tidy.textPlaceholder_Tidy

        card_tidy.addSubview(accentStrip_tidy)
        card_tidy.addSubview(iconBg_tidy)
        iconBg_tidy.addSubview(thumbnailView_tidy)
        iconBg_tidy.addSubview(iconView_tidy)
        thumbnailView_tidy.snp.makeConstraints { make in make.edges.equalToSuperview() }
        card_tidy.addSubview(nameLabel_tidy)
        card_tidy.addSubview(summaryLabel_tidy)
        card_tidy.addSubview(timeLabel_tidy)
        card_tidy.addSubview(deleteButton_tidy)

        accentStrip_tidy.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(4)
        }
        iconBg_tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        iconView_tidy.snp.makeConstraints { make in make.center.equalToSuperview() }
        deleteButton_tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        nameLabel_tidy.snp.makeConstraints { make in
            make.leading.equalTo(iconBg_tidy.snp.trailing).offset(12)
            make.trailing.equalTo(deleteButton_tidy.snp.leading).offset(-8)
            make.top.equalToSuperview().offset(12)
        }
        summaryLabel_tidy.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel_tidy)
            make.trailing.equalTo(nameLabel_tidy)
            make.top.equalTo(nameLabel_tidy.snp.bottom).offset(3)
        }
        timeLabel_tidy.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel_tidy)
            make.top.equalTo(summaryLabel_tidy.snp.bottom).offset(3)
        }

        let tap_tidy = UITapGestureRecognizer(target: self, action: #selector(onRowTapped_Tidy(_:)))
        card_tidy.addGestureRecognizer(tap_tidy)
        card_tidy.tag = index_tidy
        deleteButton_tidy.tag = index_tidy
        deleteButton_tidy.addTarget(self, action: #selector(onDeleteTapped_Tidy(_:)), for: .touchUpInside)

        return card_tidy
    }

    @objc private func onRowTapped_Tidy(_ gesture: UITapGestureRecognizer) {
        guard let index_tidy = gesture.view?.tag, index_tidy < presets_Tidy.count else { return }
        let preset_tidy = presets_Tidy[index_tidy]
        Navigation_Tidy.dismiss_Tidy(completion: { [weak self] in
            self?.onPresetSelected_Tidy?(preset_tidy)
        }, from: self)
    }

    @objc private func onDeleteTapped_Tidy(_ sender: UIButton) {
        guard sender.tag < presets_Tidy.count else { return }
        let preset_tidy = presets_Tidy[sender.tag]
        ShootViewModel_Tidy.shared_Tidy.deletePreset_Tidy(id_tidy: preset_tidy.id_Tidy)
    }
}
