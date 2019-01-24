//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import FinniversKit

class FavoriteButtonDemoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let favoriteButton  = FavoriteButton()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: favoriteButton)
    }
}
