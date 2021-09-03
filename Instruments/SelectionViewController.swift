//
//  SelectionViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit

final class SelectionViewController: UITableViewController {

	var items = [String]() // this is the array that will store the filenames to load
	var dirty = false

    override func viewDidLoad() {
        super.viewDidLoad()

		title = "Reactionist"

		tableView.rowHeight = 90
		tableView.separatorStyle = .none
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

		// load all the JPEGs into our array
		let fm = FileManager.default

		guard let resourcesPath = Bundle.main.resourcePath,
			  let temporaryItems = try? fm.contentsOfDirectory(atPath: resourcesPath) else {
			assertionFailure("Can't load app resources")
			return
		}

		items.append(contentsOf: temporaryItems.filter { $0.contains("Large") })
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if dirty {
			// we've been marked as needing a counter reload, so reload the whole table
			tableView.reloadData()
		}
	}

    // MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return items.count * 10
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

		// find the image for this cell, and load its thumbnail
		let currentImage = items[indexPath.row % items.count]
		let imageRootName = currentImage.replacingOccurrences(of: "Large", with: "Thumb")
		guard let path = Bundle.main.path(forResource: imageRootName, ofType: nil),
			  let original = UIImage(contentsOfFile: path) else {
			assertionFailure("Can't load image")
			return cell
		}

		let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
		let renderer = UIGraphicsImageRenderer(size: renderRect.size)

		let rounded = renderer.image { context in
			context.cgContext.addEllipse(in: renderRect)
			context.cgContext.clip()

			original.draw(in: renderRect)
		}
		cell.imageView?.image = rounded

		cell.imageView?.layer.shadowColor = UIColor.black.cgColor
		cell.imageView?.layer.shadowOpacity = 1
		cell.imageView?.layer.shadowRadius = 10
		cell.imageView?.layer.shadowOffset = CGSize.zero
		cell.imageView?.layer.shadowPath = UIBezierPath(ovalIn: renderRect).cgPath

		// each image stores how often it's been tapped
		let defaults = UserDefaults.standard
		cell.textLabel?.text = "\(defaults.integer(forKey: currentImage))"

		return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = ImageViewController()
		vc.image = items[indexPath.row % items.count]
		vc.owner = self

		// mark us as not needing a counter reload when we return
		dirty = false

		navigationController?.pushViewController(vc, animated: true)
	}
}
