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
///   - 媒体路径与 MediaDisplayView_Maki 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Maki:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Maki:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Maki: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Maki: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Maki: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Maki: MediaType_Maki = .none_Maki

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Maki = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Maki: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Maki: AVPlayer?
    private var playerLayer_Maki: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Maki: Any?
    /// 是否处于播放状态
    private var isPlaying_Maki = false

    // MARK: - UI：黑色背景

    private let backgroundView_Maki: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Maki: UIScrollView = {
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

    private let imageView_Maki: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Maki: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Maki: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Maki = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_Maki), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_Maki), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Maki: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Maki: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Maki: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Maki: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Maki: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Maki: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Maki = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Maki), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Maki: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Maki: UILabel = {
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
        buildUI_Maki()
        buildConstraints_Maki()
        bindGestures_Maki()
        loadMedia_Maki()
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
        cleanupPlayer_Maki()
    }

    deinit {
        cleanupPlayer_Maki()
    }

    // MARK: - UI 搭建

    private func buildUI_Maki() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Maki)

        // 图片容器
        view.addSubview(scrollView_Maki)
        scrollView_Maki.addSubview(imageView_Maki)
        scrollView_Maki.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Maki)
        videoContainerView_Maki.addSubview(playPauseButton_Maki)
        videoContainerView_Maki.addSubview(progressBg_Maki)
        progressBg_Maki.addSubview(progressFill_Maki)

        // 通用
        view.addSubview(loadingIndicator_Maki)
        view.addSubview(topBar_Maki)
        topBar_Maki.addSubview(closeButton_Maki)
        topBar_Maki.addSubview(mediaTypeLabel_Maki)
        view.addSubview(bottomHint_Maki)
    }

    private func buildConstraints_Maki() {
        backgroundView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Maki.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Maki.frame = view.bounds

        videoContainerView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Maki.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Maki.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Maki.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Maki = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Maki.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Maki.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Maki.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Maki.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Maki.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Maki.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Maki?.frame = videoContainerView_Maki.bounds
        updateImageLayout_Maki()
    }

    // MARK: - 手势

    private func bindGestures_Maki() {
        // 双击缩放（图片）
        let doubleTap_Maki = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Maki(_:)))
        doubleTap_Maki.numberOfTapsRequired = 2
        scrollView_Maki.addGestureRecognizer(doubleTap_Maki)

        // 单击关闭 / 视频播放切换
        let singleTap_Maki = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Maki))
        singleTap_Maki.numberOfTapsRequired = 1
        singleTap_Maki.require(toFail: doubleTap_Maki)
        scrollView_Maki.addGestureRecognizer(singleTap_Maki)

        // 视频区单击切换播放/暂停
        let videoTap_Maki = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Maki))
        videoContainerView_Maki.addGestureRecognizer(videoTap_Maki)

        // 下滑关闭
        let pan_Maki = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Maki(_:)))
        pan_Maki.delegate = self
        view.addGestureRecognizer(pan_Maki)

        // 播放/暂停按钮
        playPauseButton_Maki.addTarget(self, action: #selector(togglePlayPause_Maki), for: .touchUpInside)
        closeButton_Maki.addTarget(self, action: #selector(closeTapped_Maki), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Maki 和 isVideo_Maki 加载媒体
    private func loadMedia_Maki() {
        guard let path_Maki = mediaPath_Maki, !path_Maki.isEmpty else { showEmpty_Maki(); return }
        loadingIndicator_Maki.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Maki, let url_Maki = resolveVideoURL_Maki(path_Maki) {
            setupVideoPlayer_Maki(url_Maki: url_Maki)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_Maki = resolveVideoURL_Maki(path_Maki) {
            setupVideoPlayer_Maki(url_Maki: url_Maki)
            return
        }

        // 图片加载流程
        resolvedType_Maki = .image_Maki
        loadImage_Maki(path_Maki: path_Maki)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_Maki: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Maki(_ path_Maki: String) -> URL? {
        // Bundle 资源
        if let url_Maki = MediaDisplayView_Maki.bundleVideoURL_Maki(named: path_Maki) {
            return url_Maki
        }
        // Documents 目录视频文件
        let docs_Maki = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Maki in ["mp4", "mov", "m4v"] {
            let url_Maki = docs_Maki.appendingPathComponent("\(path_Maki).\(ext_Maki)")
            if FileManager.default.fileExists(atPath: url_Maki.path) { return url_Maki }
        }
        // 已带扩展名的文档目录文件
        let direct_Maki = docs_Maki.appendingPathComponent(path_Maki)
        if FileManager.default.fileExists(atPath: direct_Maki.path) { return direct_Maki }
        // 网络视频 URL
        if (path_Maki.hasPrefix("http://") || path_Maki.hasPrefix("https://")),
           let url_Maki = URL(string: path_Maki) {
            let ext_Maki = (path_Maki as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_Maki) { return url_Maki }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Maki 策略对齐）
    /// - Parameter path_Maki: 媒体路径
    private func loadImage_Maki(path_Maki: String) {
        // SF Symbols
        if let img_Maki = UIImage(systemName: path_Maki) { applyImage_Maki(img_Maki); return }
        // Assets
        if let img_Maki = UIImage(named: path_Maki) { applyImage_Maki(img_Maki); return }
        // 网络
        if path_Maki.hasPrefix("http://") || path_Maki.hasPrefix("https://") {
            guard let url_Maki = URL(string: path_Maki) else { showEmpty_Maki(); return }
            imageView_Maki.kf.setImage(with: url_Maki, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Maki.stopAnimating()
                if case .success(let v_Maki) = result { self?.onImageLoaded_Maki(v_Maki.image) }
                else { self?.showEmpty_Maki() }
            }
            return
        }
        // Documents 文件名
        let docs_Maki = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_Maki = docs_Maki.appendingPathComponent(path_Maki)
        if let img_Maki = UIImage(contentsOfFile: docURL_Maki.path) { applyImage_Maki(img_Maki); return }
        // 完整路径
        if let img_Maki = UIImage(contentsOfFile: path_Maki) { applyImage_Maki(img_Maki); return }
        showEmpty_Maki()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_Maki: 视频文件 URL
    private func setupVideoPlayer_Maki(url_Maki: URL) {
        resolvedType_Maki = .video_Maki

        // 切换到视频容器
        scrollView_Maki.isHidden         = true
        videoContainerView_Maki.isHidden = false
        progressBg_Maki.isHidden         = false

        mediaTypeLabel_Maki.text = "Video"

        let player_Maki  = AVPlayer(url: url_Maki)
        self.player_Maki = player_Maki
        let layer_Maki   = AVPlayerLayer(player: player_Maki)
        layer_Maki.videoGravity  = .resizeAspect
        layer_Maki.frame         = videoContainerView_Maki.bounds
        layer_Maki.backgroundColor = UIColor.black.cgColor
        videoContainerView_Maki.layer.insertSublayer(layer_Maki, at: 0)
        playerLayer_Maki = layer_Maki

        // 视频就绪后淡入播放按钮
        player_Maki.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_Maki = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Maki = player_Maki.addPeriodicTimeObserver(
            forInterval: interval_Maki,
            queue: .main
        ) { [weak self] time_Maki in
            self?.updateProgress_Maki(currentTime_Maki: time_Maki)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Maki),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_Maki.currentItem
        )

        loadingIndicator_Maki.stopAnimating()
        player_Maki.play()
        isPlaying_Maki = true
        playPauseButton_Maki.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Maki.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_Maki: AVPlayer 当前时间
    private func updateProgress_Maki(currentTime_Maki: CMTime) {
        guard let duration_Maki = player_Maki?.currentItem?.duration,
              duration_Maki.isNumeric, duration_Maki.seconds > 0 else { return }
        let progress_Maki = CGFloat(currentTime_Maki.seconds / duration_Maki.seconds)
        let totalW_Maki   = progressBg_Maki.bounds.width
        progressWidthCon_Maki?.update(offset: totalW_Maki * min(max(progress_Maki, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Maki() {
        player_Maki?.seek(to: .zero)
        isPlaying_Maki = false
        playPauseButton_Maki.isSelected = false
        progressWidthCon_Maki?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Maki() {
        if let token_Maki = timeObserverToken_Maki {
            player_Maki?.removeTimeObserver(token_Maki)
            timeObserverToken_Maki = nil
        }
        player_Maki?.removeObserver(self, forKeyPath: "status")
        player_Maki?.pause()
        player_Maki = nil
        playerLayer_Maki?.removeFromSuperlayer()
        playerLayer_Maki = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_Maki = object as? AVPlayer,
              player_Maki.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Maki() }
    }

    // MARK: - 图片辅助

    private func applyImage_Maki(_ image_Maki: UIImage) {
        loadingIndicator_Maki.stopAnimating()
        imageView_Maki.image = image_Maki
        imageSize_Maki       = image_Maki.size
        mediaTypeLabel_Maki.text = "Photo"
        updateImageLayout_Maki()
    }

    private func onImageLoaded_Maki(_ image_Maki: UIImage) {
        imageSize_Maki = image_Maki.size
        mediaTypeLabel_Maki.text = "Photo"
        updateImageLayout_Maki()
    }

    private func showEmpty_Maki() {
        loadingIndicator_Maki.stopAnimating()
        imageView_Maki.image       = UIImage(systemName: "photo.slash")
        imageView_Maki.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Maki.contentMode = .center
    }

    private func updateImageLayout_Maki() {
        guard imageSize_Maki != .zero else {
            imageView_Maki.frame = view.bounds
            scrollView_Maki.contentSize = view.bounds.size
            return
        }
        let screenW_Maki = view.bounds.width
        let screenH_Maki = view.bounds.height
        let ratio_Maki   = imageSize_Maki.height / imageSize_Maki.width
        let imgH_Maki    = screenW_Maki * ratio_Maki
        let y_Maki       = max(0, (screenH_Maki - imgH_Maki) / 2)
        imageView_Maki.frame        = CGRect(x: 0, y: y_Maki, width: screenW_Maki, height: imgH_Maki)
        scrollView_Maki.contentSize = CGSize(width: screenW_Maki,
                                              height: max(imgH_Maki + y_Maki * 2, screenH_Maki))
        scrollView_Maki.zoomScale   = 1.0
        centerImageIfNeeded_Maki()
    }

    private func centerImageIfNeeded_Maki() {
        let offX_Maki = max(0, (scrollView_Maki.bounds.width  - scrollView_Maki.contentSize.width)  / 2)
        let offY_Maki = max(0, (scrollView_Maki.bounds.height - scrollView_Maki.contentSize.height) / 2)
        imageView_Maki.center = CGPoint(
            x: scrollView_Maki.contentSize.width  / 2 + offX_Maki,
            y: scrollView_Maki.contentSize.height / 2 + offY_Maki
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Maki(_ gesture_Maki: UITapGestureRecognizer) {
        guard resolvedType_Maki == .image_Maki else { return }
        if scrollView_Maki.zoomScale > 1.0 {
            scrollView_Maki.setZoomScale(1.0, animated: true)
        } else {
            let pt_Maki    = gesture_Maki.location(in: imageView_Maki)
            let rect_Maki  = zoomRect_Maki(scale_Maki: 2.5, center_Maki: pt_Maki)
            scrollView_Maki.zoom(to: rect_Maki, animated: true)
        }
    }

    @objc private func handleSingleTap_Maki() {
        guard resolvedType_Maki != .video_Maki,
              scrollView_Maki.zoomScale <= 1.01 else { return }
        dismissPage_Maki(velocity_Maki: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Maki() {
        togglePlayPause_Maki()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Maki() {
        guard let player_Maki = player_Maki else { return }
        if isPlaying_Maki {
            player_Maki.pause()
            isPlaying_Maki = false
            playPauseButton_Maki.isSelected = false
        } else {
            player_Maki.play()
            isPlaying_Maki = true
            playPauseButton_Maki.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Maki.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Maki else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Maki.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Maki() {
        dismissPage_Maki(velocity_Maki: 0)
    }

    @objc private func handlePan_Maki(_ gesture_Maki: UIPanGestureRecognizer) {
        guard scrollView_Maki.zoomScale <= 1.01 else { return }
        let translation_Maki = gesture_Maki.translation(in: view)
        let velocity_Maki    = gesture_Maki.velocity(in: view).y
        switch gesture_Maki.state {
        case .changed:
            let progress_Maki         = max(0, translation_Maki.y / view.bounds.height)
            backgroundView_Maki.alpha = max(0, 1 - progress_Maki * 1.5)
            topBar_Maki.alpha         = max(0, 1 - progress_Maki * 2)
            bottomHint_Maki.alpha     = max(0, 1 - progress_Maki * 2)
            let activeView_Maki: UIView = resolvedType_Maki == .video_Maki
                ? videoContainerView_Maki : scrollView_Maki
            activeView_Maki.transform = CGAffineTransform(
                translationX: translation_Maki.x * 0.3,
                y: max(0, translation_Maki.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_Maki = translation_Maki.y > view.bounds.height * 0.25 || velocity_Maki > 900
            if shouldDismiss_Maki {
                dismissPage_Maki(velocity_Maki: velocity_Maki)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Maki.transform         = .identity
                    self.videoContainerView_Maki.transform = .identity
                    self.backgroundView_Maki.alpha  = 1
                    self.topBar_Maki.alpha           = 1
                    self.bottomHint_Maki.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_Maki: 下拉速度（影响动画时长）
    private func dismissPage_Maki(velocity_Maki: CGFloat) {
        guard !isDismissing_Maki else { return }
        isDismissing_Maki = true
        player_Maki?.pause()
        let duration_Maki = velocity_Maki > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_Maki, animations: {
            self.view.alpha = 0
            let activeView_Maki: UIView = self.resolvedType_Maki == .video_Maki
                ? self.videoContainerView_Maki : self.scrollView_Maki
            activeView_Maki.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Maki(scale_Maki: CGFloat, center_Maki: CGPoint) -> CGRect {
        let w_Maki = scrollView_Maki.bounds.width  / scale_Maki
        let h_Maki = scrollView_Maki.bounds.height / scale_Maki
        return CGRect(x: center_Maki.x - w_Maki / 2,
                      y: center_Maki.y - h_Maki / 2,
                      width: w_Maki, height: h_Maki)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Maki: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Maki }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Maki() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Maki: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_Maki = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Maki.zoomScale <= 1.01 else { return false }
        let vel_Maki = pan_Maki.velocity(in: view)
        return abs(vel_Maki.y) > abs(vel_Maki.x) && vel_Maki.y > 0
    }
}
