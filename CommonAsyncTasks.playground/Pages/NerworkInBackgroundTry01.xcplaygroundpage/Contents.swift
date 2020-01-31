import UIKit
import PlaygroundSupport
import SafariServices

struct MiniSpecialColumn {
    var id: String
    var title: String
    var description: String
    var link: URL
}

private let themeColor = UIColor(red: 255/255.0, green: 112/255.0, blue: 85/255.0, alpha: 1.0)
class ItemViewController: UIViewController {

    let itemID: String
    private var item: MiniSpecialColumn?
    private let network = FakeNetwork()

    private lazy var titleLabel = UILabel()
    private lazy var descriptionLable = UILabel()
    private lazy var subscribeButton = UIButton()
    private lazy var activityIndicatorView = UIActivityIndicatorView(style: .gray)

    init(itemID: String) {
        self.itemID = itemID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        prepareData()
    }

    private func setupUI() {
        view.backgroundColor = .white

        [titleLabel, descriptionLable, subscribeButton, activityIndicatorView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isHidden = true
        }

        titleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        descriptionLable.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        descriptionLable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        descriptionLable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        subscribeButton.topAnchor.constraint(equalTo: descriptionLable.bottomAnchor, constant: 20).isActive = true
        subscribeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        titleLabel.font = .preferredFont(forTextStyle: .headline)

        descriptionLable.numberOfLines = 0
        descriptionLable.font = .preferredFont(forTextStyle: .subheadline)

        subscribeButton.setTitleColor(themeColor, for: .normal)
        subscribeButton.setTitle("马上订阅", for: .normal)
        subscribeButton.addTarget(self, action: #selector(subscribeAction), for: .touchUpInside)
    }

    private func prepareData() {
        // 🔑 加载可感知
        activityIndicatorView.startAnimating()
        network.getMiniSpecialColumnDetail(withID: itemID) { [weak self] item in
            self?.activityIndicatorView.stopAnimating()
            self?.updateUI(withItem: item)
        }
    }

    private func updateUI(withItem item: MiniSpecialColumn) {
        self.item = item
        titleLabel.text = item.title
        descriptionLable.text = item.description
        [titleLabel, descriptionLable, subscribeButton].forEach {
            $0.isHidden = false
        }
    }

    @objc
    private func subscribeAction(_ sender: Any) {
        guard let item = item else { return }
        let vc = SFSafariViewController(url: item.link)
        present(vc, animated: true, completion: nil)
    }
}

class FakeNetwork {
    func getMiniSpecialColumnList() -> [(String, String)] {
        return [("000", "设计知录（原U程I）"),
                ("001", "设计行录：Sketch 快速入门"),
                ("002", "彻底搞定 GCD🚦并发编程")]
    }
    static let fakeResults: [String: MiniSpecialColumn] = [
        "000": .init(id: "000",
                     title: "设计知录（原U程I）",
                     description: "做接地气的设计传道者，帮助您学会解决设计问题",
                     link: URL(string: "https://xiaozhuanlan.com/ui-x")!),
        "001": .init(id: "001",
                     title: "设计行录：Sketch 快速入门",
                     description: "你知道吗？Sketch 除了能做 UI 和交互，还能画插画、绘图表和 P图哦～",
                     link: URL(string: "https://xiaozhuanlan.com/sketch-go")!),
        "002": .init(id: "002",
                     title: "彻底搞定 GCD🚦并发编程",
                     description: "本专栏旨在彻底厘清 iOS 开发中 GCD 的应用场景与涉及的API，分析并理解其背后的原理。",
                     link: URL(string: "https://xiaozhuanlan.com/complete-ios-gcd")!)
    ]
    func getMiniSpecialColumnDetail(withID id: String, completion: @escaping (MiniSpecialColumn) -> ()) {

        DispatchQueue.global().async {
            sleep(1) // ℹ️ 模拟网络耗时 1s
            if let result = FakeNetwork.fakeResults[id] {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
}

private let itemCellIdentifier = "ItemCellIdentifier"
class ListViewController : UITableViewController {

    private var items: [(String, String)]!
    private var network = FakeNetwork()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "小专栏"
        items = network.getMiniSpecialColumnList()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: itemCellIdentifier)
    }

    // MARK: - UITableView Data Source & Delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: itemCellIdentifier, for: indexPath)
        cell.textLabel?.text = items[indexPath.row].1
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        let id = items[indexPath.row].0
        // 🎯 进一步优化：即时交互，延时加载
        let vc = ItemViewController(itemID: id)
        show(vc, sender: nil)
    }
}



// Present the view controller in the Live View window
PlaygroundPage.current.liveView = UINavigationController(rootViewController: ListViewController())


