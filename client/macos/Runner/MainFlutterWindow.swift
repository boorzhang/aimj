import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    // 固定成手机尺寸（iPhone 14 设计稿基准 390x844）
    let phoneSize = NSSize(width: 390, height: 844)
    self.setContentSize(phoneSize)
    self.contentMinSize = phoneSize
    self.contentMaxSize = phoneSize

    // 禁用缩放 + 全屏按钮，固定手机形态
    self.styleMask.remove(.resizable)
    self.collectionBehavior.remove(.fullScreenPrimary)
    self.collectionBehavior.insert(.fullScreenNone)
    if let zoomButton = self.standardWindowButton(.zoomButton) {
      zoomButton.isEnabled = false
    }

    // 居中显示
    self.center()

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
