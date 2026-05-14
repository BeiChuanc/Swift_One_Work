import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: - 全屏媒体浏览页

/// 全屏媒体浏览页
/// 核心作用：
///   - 图片模式：以沉浸式黑底全屏展示，支持双指缩放、双击放大/还原、下滑关闭
///   - 视频模式：通过 AVPlayer 播放 Bundle / Documents / 网络视频，支持播放/暂停、进度条、下滑关闭
/// 设计思路：
///   - 媒体路径与 MediaDisplayView_Echd 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Echd:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Echd:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Echd: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Echd: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Echd: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Echd: MediaType_Echd = .none_Echd

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Echd = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Echd: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Echd: AVPlayer?
    private var playerLayer_Echd: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Echd: Any?
    /// 是否处于播放状态
    private var isPlaying_Echd = false

    // MARK: - UI：黑色背景

    private let backgroundView_Echd: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Echd: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator   = false
        sv.showsHorizontalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        sv.bouncesZoom      = true
        sv.minimumZoomScale = 1.0
        sv.maximumZoomScale = 4.0
        sv.backgroundColor  = .clear
        return sv
    }()

    private let imageView_Echd: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Echd: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Echd: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_Echd), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_Echd), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Echd: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Echd: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Echd: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Echd: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Echd: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Echd: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Echd), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Echd: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Echd: UILabel = {
        let l = UILabel()
        l.text          = "Swipe down to close"
        l.font          = .systemFont(ofSize: 11, weight: .regular)
        l.textColor     = UIColor.white.withAlphaComponent(0.45)
        l.textAlignment = .center
        return l
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI_Echd()
        buildConstraints_Echd()
        bindGestures_Echd()
        loadMedia_Echd()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 进场前预设透明，由 viewDidAppear 统一淡入，避免与系统转场动画叠加导致闪烁
        view.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25) { self.view.alpha = 1 }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cleanupPlayer_Echd()
    }

    deinit {
        cleanupPlayer_Echd()
    }

    // MARK: - UI 搭建

    private func buildUI_Echd() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Echd)

        // 图片容器
        view.addSubview(scrollView_Echd)
        scrollView_Echd.addSubview(imageView_Echd)
        scrollView_Echd.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Echd)
        videoContainerView_Echd.addSubview(playPauseButton_Echd)
        videoContainerView_Echd.addSubview(progressBg_Echd)
        progressBg_Echd.addSubview(progressFill_Echd)

        // 通用
        view.addSubview(loadingIndicator_Echd)
        view.addSubview(topBar_Echd)
        topBar_Echd.addSubview(closeButton_Echd)
        topBar_Echd.addSubview(mediaTypeLabel_Echd)
        view.addSubview(bottomHint_Echd)
    }

    private func buildConstraints_Echd() {
        backgroundView_Echd.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Echd.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Echd.frame = view.bounds

        videoContainerView_Echd.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Echd.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Echd.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Echd.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Echd = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Echd.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Echd.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Echd.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Echd.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Echd.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Echd.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Echd?.frame = videoContainerView_Echd.bounds
        updateImageLayout_Echd()
    }

    // MARK: - 手势

    private func bindGestures_Echd() {
        // 双击缩放（图片）
        let doubleTap_Echd = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Echd(_:)))
        doubleTap_Echd.numberOfTapsRequired = 2
        scrollView_Echd.addGestureRecognizer(doubleTap_Echd)

        // 单击关闭 / 视频播放切换
        let singleTap_Echd = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Echd))
        singleTap_Echd.numberOfTapsRequired = 1
        singleTap_Echd.require(toFail: doubleTap_Echd)
        scrollView_Echd.addGestureRecognizer(singleTap_Echd)

        // 视频区单击切换播放/暂停
        let videoTap_Echd = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Echd))
        videoContainerView_Echd.addGestureRecognizer(videoTap_Echd)

        // 下滑关闭
        let pan_Echd = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Echd(_:)))
        pan_Echd.delegate = self
        view.addGestureRecognizer(pan_Echd)

        // 播放/暂停按钮
        playPauseButton_Echd.addTarget(self, action: #selector(togglePlayPause_Echd), for: .touchUpInside)
        closeButton_Echd.addTarget(self, action: #selector(closeTapped_Echd), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Echd 和 isVideo_Echd 加载媒体
    private func loadMedia_Echd() {
        guard let path_Echd = mediaPath_Echd, !path_Echd.isEmpty else { showEmpty_Echd(); return }
        loadingIndicator_Echd.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Echd, let url_Echd = resolveVideoURL_Echd(path_Echd) {
            setupVideoPlayer_Echd(url_Echd: url_Echd)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_Echd = resolveVideoURL_Echd(path_Echd) {
            setupVideoPlayer_Echd(url_Echd: url_Echd)
            return
        }

        // 图片加载流程
        resolvedType_Echd = .image_Echd
        loadImage_Echd(path_Echd: path_Echd)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_Echd: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Echd(_ path_Echd: String) -> URL? {
        // Bundle 资源
        if let url_Echd = MediaDisplayView_Echd.bundleVideoURL_Echd(named: path_Echd) {
            return url_Echd
        }
        // Documents 目录视频文件
        let docs_Echd = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Echd in ["mp4", "mov", "m4v"] {
            let url_Echd = docs_Echd.appendingPathComponent("\(path_Echd).\(ext_Echd)")
            if FileManager.default.fileExists(atPath: url_Echd.path) { return url_Echd }
        }
        // 已带扩展名的文档目录文件
        let direct_Echd = docs_Echd.appendingPathComponent(path_Echd)
        if FileManager.default.fileExists(atPath: direct_Echd.path) { return direct_Echd }
        // 网络视频 URL
        if (path_Echd.hasPrefix("http://") || path_Echd.hasPrefix("https://")),
           let url_Echd = URL(string: path_Echd) {
            let ext_Echd = (path_Echd as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_Echd) { return url_Echd }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Echd 策略对齐）
    /// - Parameter path_Echd: 媒体路径
    private func loadImage_Echd(path_Echd: String) {
        // SF Symbols
        if let img_Echd = UIImage(systemName: path_Echd) { applyImage_Echd(img_Echd); return }
        // Assets
        if let img_Echd = UIImage(named: path_Echd) { applyImage_Echd(img_Echd); return }
        // 网络
        if path_Echd.hasPrefix("http://") || path_Echd.hasPrefix("https://") {
            guard let url_Echd = URL(string: path_Echd) else { showEmpty_Echd(); return }
            imageView_Echd.kf.setImage(with: url_Echd, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Echd.stopAnimating()
                if case .success(let v_Echd) = result { self?.onImageLoaded_Echd(v_Echd.image) }
                else { self?.showEmpty_Echd() }
            }
            return
        }
        // Documents 文件名
        let docs_Echd = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_Echd = docs_Echd.appendingPathComponent(path_Echd)
        if let img_Echd = UIImage(contentsOfFile: docURL_Echd.path) { applyImage_Echd(img_Echd); return }
        // 完整路径
        if let img_Echd = UIImage(contentsOfFile: path_Echd) { applyImage_Echd(img_Echd); return }
        showEmpty_Echd()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_Echd: 视频文件 URL
    private func setupVideoPlayer_Echd(url_Echd: URL) {
        resolvedType_Echd = .video_Echd

        // 切换到视频容器
        scrollView_Echd.isHidden         = true
        videoContainerView_Echd.isHidden = false
        progressBg_Echd.isHidden         = false

        mediaTypeLabel_Echd.text = "Video"

        let player_Echd  = AVPlayer(url: url_Echd)
        self.player_Echd = player_Echd
        let layer_Echd   = AVPlayerLayer(player: player_Echd)
        layer_Echd.videoGravity  = .resizeAspect
        layer_Echd.frame         = videoContainerView_Echd.bounds
        layer_Echd.backgroundColor = UIColor.black.cgColor
        videoContainerView_Echd.layer.insertSublayer(layer_Echd, at: 0)
        playerLayer_Echd = layer_Echd

        // 视频就绪后淡入播放按钮
        player_Echd.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_Echd = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Echd = player_Echd.addPeriodicTimeObserver(
            forInterval: interval_Echd,
            queue: .main
        ) { [weak self] time_Echd in
            self?.updateProgress_Echd(currentTime_Echd: time_Echd)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Echd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_Echd.currentItem
        )

        loadingIndicator_Echd.stopAnimating()
        player_Echd.play()
        isPlaying_Echd = true
        playPauseButton_Echd.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Echd.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_Echd: AVPlayer 当前时间
    private func updateProgress_Echd(currentTime_Echd: CMTime) {
        guard let duration_Echd = player_Echd?.currentItem?.duration,
              duration_Echd.isNumeric, duration_Echd.seconds > 0 else { return }
        let progress_Echd = CGFloat(currentTime_Echd.seconds / duration_Echd.seconds)
        let totalW_Echd   = progressBg_Echd.bounds.width
        progressWidthCon_Echd?.update(offset: totalW_Echd * min(max(progress_Echd, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Echd() {
        player_Echd?.seek(to: .zero)
        isPlaying_Echd = false
        playPauseButton_Echd.isSelected = false
        progressWidthCon_Echd?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Echd() {
        if let token_Echd = timeObserverToken_Echd {
            player_Echd?.removeTimeObserver(token_Echd)
            timeObserverToken_Echd = nil
        }
        player_Echd?.removeObserver(self, forKeyPath: "status")
        player_Echd?.pause()
        player_Echd = nil
        playerLayer_Echd?.removeFromSuperlayer()
        playerLayer_Echd = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_Echd = object as? AVPlayer,
              player_Echd.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Echd() }
    }

    // MARK: - 图片辅助

    private func applyImage_Echd(_ image_Echd: UIImage) {
        loadingIndicator_Echd.stopAnimating()
        imageView_Echd.image = image_Echd
        imageSize_Echd       = image_Echd.size
        mediaTypeLabel_Echd.text = "Photo"
        updateImageLayout_Echd()
    }

    private func onImageLoaded_Echd(_ image_Echd: UIImage) {
        imageSize_Echd = image_Echd.size
        mediaTypeLabel_Echd.text = "Photo"
        updateImageLayout_Echd()
    }

    private func showEmpty_Echd() {
        loadingIndicator_Echd.stopAnimating()
        imageView_Echd.image       = UIImage(systemName: "photo.slash")
        imageView_Echd.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Echd.contentMode = .center
    }

    private func updateImageLayout_Echd() {
        guard imageSize_Echd != .zero else {
            imageView_Echd.frame = view.bounds
            scrollView_Echd.contentSize = view.bounds.size
            return
        }
        let screenW_Echd = view.bounds.width
        let screenH_Echd = view.bounds.height
        let ratio_Echd   = imageSize_Echd.height / imageSize_Echd.width
        let imgH_Echd    = screenW_Echd * ratio_Echd
        let y_Echd       = max(0, (screenH_Echd - imgH_Echd) / 2)
        imageView_Echd.frame        = CGRect(x: 0, y: y_Echd, width: screenW_Echd, height: imgH_Echd)
        scrollView_Echd.contentSize = CGSize(width: screenW_Echd,
                                              height: max(imgH_Echd + y_Echd * 2, screenH_Echd))
        scrollView_Echd.zoomScale   = 1.0
        centerImageIfNeeded_Echd()
    }

    private func centerImageIfNeeded_Echd() {
        let offX_Echd = max(0, (scrollView_Echd.bounds.width  - scrollView_Echd.contentSize.width)  / 2)
        let offY_Echd = max(0, (scrollView_Echd.bounds.height - scrollView_Echd.contentSize.height) / 2)
        imageView_Echd.center = CGPoint(
            x: scrollView_Echd.contentSize.width  / 2 + offX_Echd,
            y: scrollView_Echd.contentSize.height / 2 + offY_Echd
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Echd(_ gesture_Echd: UITapGestureRecognizer) {
        guard resolvedType_Echd == .image_Echd else { return }
        if scrollView_Echd.zoomScale > 1.0 {
            scrollView_Echd.setZoomScale(1.0, animated: true)
        } else {
            let pt_Echd    = gesture_Echd.location(in: imageView_Echd)
            let rect_Echd  = zoomRect_Echd(scale_Echd: 2.5, center_Echd: pt_Echd)
            scrollView_Echd.zoom(to: rect_Echd, animated: true)
        }
    }

    @objc private func handleSingleTap_Echd() {
        guard resolvedType_Echd != .video_Echd,
              scrollView_Echd.zoomScale <= 1.01 else { return }
        dismissPage_Echd(velocity_Echd: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Echd() {
        togglePlayPause_Echd()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Echd() {
        guard let player_Echd = player_Echd else { return }
        if isPlaying_Echd {
            player_Echd.pause()
            isPlaying_Echd = false
            playPauseButton_Echd.isSelected = false
        } else {
            player_Echd.play()
            isPlaying_Echd = true
            playPauseButton_Echd.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Echd.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Echd else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Echd.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Echd() {
        dismissPage_Echd(velocity_Echd: 0)
    }

    @objc private func handlePan_Echd(_ gesture_Echd: UIPanGestureRecognizer) {
        guard scrollView_Echd.zoomScale <= 1.01 else { return }
        let translation_Echd = gesture_Echd.translation(in: view)
        let velocity_Echd    = gesture_Echd.velocity(in: view).y
        switch gesture_Echd.state {
        case .changed:
            let progress_Echd         = max(0, translation_Echd.y / view.bounds.height)
            backgroundView_Echd.alpha = max(0, 1 - progress_Echd * 1.5)
            topBar_Echd.alpha         = max(0, 1 - progress_Echd * 2)
            bottomHint_Echd.alpha     = max(0, 1 - progress_Echd * 2)
            let activeView_Echd: UIView = resolvedType_Echd == .video_Echd
                ? videoContainerView_Echd : scrollView_Echd
            activeView_Echd.transform = CGAffineTransform(
                translationX: translation_Echd.x * 0.3,
                y: max(0, translation_Echd.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_Echd = translation_Echd.y > view.bounds.height * 0.25 || velocity_Echd > 900
            if shouldDismiss_Echd {
                dismissPage_Echd(velocity_Echd: velocity_Echd)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Echd.transform         = .identity
                    self.videoContainerView_Echd.transform = .identity
                    self.backgroundView_Echd.alpha  = 1
                    self.topBar_Echd.alpha           = 1
                    self.bottomHint_Echd.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_Echd: 下拉速度（影响动画时长）
    private func dismissPage_Echd(velocity_Echd: CGFloat) {
        guard !isDismissing_Echd else { return }
        isDismissing_Echd = true
        player_Echd?.pause()
        let duration_Echd = velocity_Echd > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_Echd, animations: {
            self.view.alpha = 0
            let activeView_Echd: UIView = self.resolvedType_Echd == .video_Echd
                ? self.videoContainerView_Echd : self.scrollView_Echd
            activeView_Echd.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Echd(scale_Echd: CGFloat, center_Echd: CGPoint) -> CGRect {
        let w_Echd = scrollView_Echd.bounds.width  / scale_Echd
        let h_Echd = scrollView_Echd.bounds.height / scale_Echd
        return CGRect(x: center_Echd.x - w_Echd / 2,
                      y: center_Echd.y - h_Echd / 2,
                      width: w_Echd, height: h_Echd)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Echd: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Echd }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Echd() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Echd: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_Echd = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Echd.zoomScale <= 1.01 else { return false }
        let vel_Echd = pan_Echd.velocity(in: view)
        return abs(vel_Echd.y) > abs(vel_Echd.x) && vel_Echd.y > 0
    }
}
