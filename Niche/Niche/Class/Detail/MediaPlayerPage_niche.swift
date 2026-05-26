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
///   - 媒体路径与 MediaDisplayView_Niche 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Niche:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Niche:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Niche: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Niche: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Niche: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Niche: MediaType_Niche = .none_Niche

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Niche = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Niche: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Niche: AVPlayer?
    private var playerLayer_Niche: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Niche: Any?
    /// 是否处于播放状态
    private var isPlaying_Niche = false

    // MARK: - UI：黑色背景

    private let backgroundView_Niche: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Niche: UIScrollView = {
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

    private let imageView_Niche: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Niche: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Niche: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Niche = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_Niche), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_Niche), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Niche: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Niche: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Niche: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Niche: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Niche: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Niche: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Niche = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Niche), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Niche: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Niche: UILabel = {
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
        buildUI_Niche()
        buildConstraints_Niche()
        bindGestures_Niche()
        loadMedia_Niche()
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
        cleanupPlayer_Niche()
    }

    deinit {
        cleanupPlayer_Niche()
    }

    // MARK: - UI 搭建

    private func buildUI_Niche() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Niche)

        // 图片容器
        view.addSubview(scrollView_Niche)
        scrollView_Niche.addSubview(imageView_Niche)
        scrollView_Niche.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Niche)
        videoContainerView_Niche.addSubview(playPauseButton_Niche)
        videoContainerView_Niche.addSubview(progressBg_Niche)
        progressBg_Niche.addSubview(progressFill_Niche)

        // 通用
        view.addSubview(loadingIndicator_Niche)
        view.addSubview(topBar_Niche)
        topBar_Niche.addSubview(closeButton_Niche)
        topBar_Niche.addSubview(mediaTypeLabel_Niche)
        view.addSubview(bottomHint_Niche)
    }

    private func buildConstraints_Niche() {
        backgroundView_Niche.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Niche.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Niche.frame = view.bounds

        videoContainerView_Niche.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Niche.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Niche.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Niche.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Niche = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Niche.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Niche.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Niche.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Niche.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Niche.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Niche.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Niche?.frame = videoContainerView_Niche.bounds
        updateImageLayout_Niche()
    }

    // MARK: - 手势

    private func bindGestures_Niche() {
        // 双击缩放（图片）
        let doubleTap_Niche = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Niche(_:)))
        doubleTap_Niche.numberOfTapsRequired = 2
        scrollView_Niche.addGestureRecognizer(doubleTap_Niche)

        // 单击关闭 / 视频播放切换
        let singleTap_Niche = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Niche))
        singleTap_Niche.numberOfTapsRequired = 1
        singleTap_Niche.require(toFail: doubleTap_Niche)
        scrollView_Niche.addGestureRecognizer(singleTap_Niche)

        // 视频区单击切换播放/暂停
        let videoTap_Niche = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Niche))
        videoContainerView_Niche.addGestureRecognizer(videoTap_Niche)

        // 下滑关闭
        let pan_Niche = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Niche(_:)))
        pan_Niche.delegate = self
        view.addGestureRecognizer(pan_Niche)

        // 播放/暂停按钮
        playPauseButton_Niche.addTarget(self, action: #selector(togglePlayPause_Niche), for: .touchUpInside)
        closeButton_Niche.addTarget(self, action: #selector(closeTapped_Niche), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Niche 和 isVideo_Niche 加载媒体
    private func loadMedia_Niche() {
        guard let path_Niche = mediaPath_Niche, !path_Niche.isEmpty else { showEmpty_Niche(); return }
        loadingIndicator_Niche.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Niche, let url_Niche = resolveVideoURL_Niche(path_Niche) {
            setupVideoPlayer_Niche(url_Niche: url_Niche)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_Niche = resolveVideoURL_Niche(path_Niche) {
            setupVideoPlayer_Niche(url_Niche: url_Niche)
            return
        }

        // 图片加载流程
        resolvedType_Niche = .image_Niche
        loadImage_Niche(path_Niche: path_Niche)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_Niche: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Niche(_ path_Niche: String) -> URL? {
        // Bundle 资源
        if let url_Niche = MediaDisplayView_Niche.bundleVideoURL_Niche(named: path_Niche) {
            return url_Niche
        }
        // Documents 目录视频文件
        let docs_Niche = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Niche in ["mp4", "mov", "m4v"] {
            let url_Niche = docs_Niche.appendingPathComponent("\(path_Niche).\(ext_Niche)")
            if FileManager.default.fileExists(atPath: url_Niche.path) { return url_Niche }
        }
        // 已带扩展名的文档目录文件
        let direct_Niche = docs_Niche.appendingPathComponent(path_Niche)
        if FileManager.default.fileExists(atPath: direct_Niche.path) { return direct_Niche }
        // 网络视频 URL
        if (path_Niche.hasPrefix("http://") || path_Niche.hasPrefix("https://")),
           let url_Niche = URL(string: path_Niche) {
            let ext_Niche = (path_Niche as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_Niche) { return url_Niche }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Niche 策略对齐）
    /// - Parameter path_Niche: 媒体路径
    private func loadImage_Niche(path_Niche: String) {
        // SF Symbols
        if let img_Niche = UIImage(systemName: path_Niche) { applyImage_Niche(img_Niche); return }
        // Assets
        if let img_Niche = UIImage(named: path_Niche) { applyImage_Niche(img_Niche); return }
        // 网络
        if path_Niche.hasPrefix("http://") || path_Niche.hasPrefix("https://") {
            guard let url_Niche = URL(string: path_Niche) else { showEmpty_Niche(); return }
            imageView_Niche.kf.setImage(with: url_Niche, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Niche.stopAnimating()
                if case .success(let v_Niche) = result { self?.onImageLoaded_Niche(v_Niche.image) }
                else { self?.showEmpty_Niche() }
            }
            return
        }
        // Documents 文件名
        let docs_Niche = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_Niche = docs_Niche.appendingPathComponent(path_Niche)
        if let img_Niche = UIImage(contentsOfFile: docURL_Niche.path) { applyImage_Niche(img_Niche); return }
        // 完整路径
        if let img_Niche = UIImage(contentsOfFile: path_Niche) { applyImage_Niche(img_Niche); return }
        showEmpty_Niche()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_Niche: 视频文件 URL
    private func setupVideoPlayer_Niche(url_Niche: URL) {
        resolvedType_Niche = .video_Niche

        // 切换到视频容器
        scrollView_Niche.isHidden         = true
        videoContainerView_Niche.isHidden = false
        progressBg_Niche.isHidden         = false

        mediaTypeLabel_Niche.text = "Video"

        let player_Niche  = AVPlayer(url: url_Niche)
        self.player_Niche = player_Niche
        let layer_Niche   = AVPlayerLayer(player: player_Niche)
        layer_Niche.videoGravity  = .resizeAspect
        layer_Niche.frame         = videoContainerView_Niche.bounds
        layer_Niche.backgroundColor = UIColor.black.cgColor
        videoContainerView_Niche.layer.insertSublayer(layer_Niche, at: 0)
        playerLayer_Niche = layer_Niche

        // 视频就绪后淡入播放按钮
        player_Niche.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_Niche = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Niche = player_Niche.addPeriodicTimeObserver(
            forInterval: interval_Niche,
            queue: .main
        ) { [weak self] time_Niche in
            self?.updateProgress_Niche(currentTime_Niche: time_Niche)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Niche),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_Niche.currentItem
        )

        loadingIndicator_Niche.stopAnimating()
        player_Niche.play()
        isPlaying_Niche = true
        playPauseButton_Niche.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Niche.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_Niche: AVPlayer 当前时间
    private func updateProgress_Niche(currentTime_Niche: CMTime) {
        guard let duration_Niche = player_Niche?.currentItem?.duration,
              duration_Niche.isNumeric, duration_Niche.seconds > 0 else { return }
        let progress_Niche = CGFloat(currentTime_Niche.seconds / duration_Niche.seconds)
        let totalW_Niche   = progressBg_Niche.bounds.width
        progressWidthCon_Niche?.update(offset: totalW_Niche * min(max(progress_Niche, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Niche() {
        player_Niche?.seek(to: .zero)
        isPlaying_Niche = false
        playPauseButton_Niche.isSelected = false
        progressWidthCon_Niche?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Niche() {
        if let token_Niche = timeObserverToken_Niche {
            player_Niche?.removeTimeObserver(token_Niche)
            timeObserverToken_Niche = nil
        }
        player_Niche?.removeObserver(self, forKeyPath: "status")
        player_Niche?.pause()
        player_Niche = nil
        playerLayer_Niche?.removeFromSuperlayer()
        playerLayer_Niche = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_Niche = object as? AVPlayer,
              player_Niche.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Niche() }
    }

    // MARK: - 图片辅助

    private func applyImage_Niche(_ image_Niche: UIImage) {
        loadingIndicator_Niche.stopAnimating()
        imageView_Niche.image = image_Niche
        imageSize_Niche       = image_Niche.size
        mediaTypeLabel_Niche.text = "Photo"
        updateImageLayout_Niche()
    }

    private func onImageLoaded_Niche(_ image_Niche: UIImage) {
        imageSize_Niche = image_Niche.size
        mediaTypeLabel_Niche.text = "Photo"
        updateImageLayout_Niche()
    }

    private func showEmpty_Niche() {
        loadingIndicator_Niche.stopAnimating()
        imageView_Niche.image       = UIImage(systemName: "photo.slash")
        imageView_Niche.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Niche.contentMode = .center
    }

    private func updateImageLayout_Niche() {
        guard imageSize_Niche != .zero else {
            imageView_Niche.frame = view.bounds
            scrollView_Niche.contentSize = view.bounds.size
            return
        }
        let screenW_Niche = view.bounds.width
        let screenH_Niche = view.bounds.height
        let ratio_Niche   = imageSize_Niche.height / imageSize_Niche.width
        let imgH_Niche    = screenW_Niche * ratio_Niche
        let y_Niche       = max(0, (screenH_Niche - imgH_Niche) / 2)
        imageView_Niche.frame        = CGRect(x: 0, y: y_Niche, width: screenW_Niche, height: imgH_Niche)
        scrollView_Niche.contentSize = CGSize(width: screenW_Niche,
                                              height: max(imgH_Niche + y_Niche * 2, screenH_Niche))
        scrollView_Niche.zoomScale   = 1.0
        centerImageIfNeeded_Niche()
    }

    private func centerImageIfNeeded_Niche() {
        let offX_Niche = max(0, (scrollView_Niche.bounds.width  - scrollView_Niche.contentSize.width)  / 2)
        let offY_Niche = max(0, (scrollView_Niche.bounds.height - scrollView_Niche.contentSize.height) / 2)
        imageView_Niche.center = CGPoint(
            x: scrollView_Niche.contentSize.width  / 2 + offX_Niche,
            y: scrollView_Niche.contentSize.height / 2 + offY_Niche
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Niche(_ gesture_Niche: UITapGestureRecognizer) {
        guard resolvedType_Niche == .image_Niche else { return }
        if scrollView_Niche.zoomScale > 1.0 {
            scrollView_Niche.setZoomScale(1.0, animated: true)
        } else {
            let pt_Niche    = gesture_Niche.location(in: imageView_Niche)
            let rect_Niche  = zoomRect_Niche(scale_Niche: 2.5, center_Niche: pt_Niche)
            scrollView_Niche.zoom(to: rect_Niche, animated: true)
        }
    }

    @objc private func handleSingleTap_Niche() {
        guard resolvedType_Niche != .video_Niche,
              scrollView_Niche.zoomScale <= 1.01 else { return }
        dismissPage_Niche(velocity_Niche: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Niche() {
        togglePlayPause_Niche()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Niche() {
        guard let player_Niche = player_Niche else { return }
        if isPlaying_Niche {
            player_Niche.pause()
            isPlaying_Niche = false
            playPauseButton_Niche.isSelected = false
        } else {
            player_Niche.play()
            isPlaying_Niche = true
            playPauseButton_Niche.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Niche.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Niche else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Niche.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Niche() {
        dismissPage_Niche(velocity_Niche: 0)
    }

    @objc private func handlePan_Niche(_ gesture_Niche: UIPanGestureRecognizer) {
        guard scrollView_Niche.zoomScale <= 1.01 else { return }
        let translation_Niche = gesture_Niche.translation(in: view)
        let velocity_Niche    = gesture_Niche.velocity(in: view).y
        switch gesture_Niche.state {
        case .changed:
            let progress_Niche         = max(0, translation_Niche.y / view.bounds.height)
            backgroundView_Niche.alpha = max(0, 1 - progress_Niche * 1.5)
            topBar_Niche.alpha         = max(0, 1 - progress_Niche * 2)
            bottomHint_Niche.alpha     = max(0, 1 - progress_Niche * 2)
            let activeView_Niche: UIView = resolvedType_Niche == .video_Niche
                ? videoContainerView_Niche : scrollView_Niche
            activeView_Niche.transform = CGAffineTransform(
                translationX: translation_Niche.x * 0.3,
                y: max(0, translation_Niche.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_Niche = translation_Niche.y > view.bounds.height * 0.25 || velocity_Niche > 900
            if shouldDismiss_Niche {
                dismissPage_Niche(velocity_Niche: velocity_Niche)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Niche.transform         = .identity
                    self.videoContainerView_Niche.transform = .identity
                    self.backgroundView_Niche.alpha  = 1
                    self.topBar_Niche.alpha           = 1
                    self.bottomHint_Niche.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_Niche: 下拉速度（影响动画时长）
    private func dismissPage_Niche(velocity_Niche: CGFloat) {
        guard !isDismissing_Niche else { return }
        isDismissing_Niche = true
        player_Niche?.pause()
        let duration_Niche = velocity_Niche > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_Niche, animations: {
            self.view.alpha = 0
            let activeView_Niche: UIView = self.resolvedType_Niche == .video_Niche
                ? self.videoContainerView_Niche : self.scrollView_Niche
            activeView_Niche.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Niche(scale_Niche: CGFloat, center_Niche: CGPoint) -> CGRect {
        let w_Niche = scrollView_Niche.bounds.width  / scale_Niche
        let h_Niche = scrollView_Niche.bounds.height / scale_Niche
        return CGRect(x: center_Niche.x - w_Niche / 2,
                      y: center_Niche.y - h_Niche / 2,
                      width: w_Niche, height: h_Niche)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Niche: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Niche }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Niche() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Niche: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_Niche = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Niche.zoomScale <= 1.01 else { return false }
        let vel_Niche = pan_Niche.velocity(in: view)
        return abs(vel_Niche.y) > abs(vel_Niche.x) && vel_Niche.y > 0
    }
}
