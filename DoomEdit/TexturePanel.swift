//
//  TexturePanel.swift
//  DoomEdit
//
//  Created by Thomas Foster on 12/31/17.
//  Copyright © 2017 Thomas Foster. All rights reserved.
//

import Cocoa

fileprivate let SPACING: CGFloat = 5.0

/**
Displays all the WAD's textures in a collection view.
*/

class TexturePanel: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
	
	var selectedTextureIndex: Int = -1
	var lineIndex: Int = 0
	var texturePosition: Int = 0
	
	var window: NSWindow?
	var delegate: TexturePanelDelegate?
	
	@IBOutlet weak var collectionView: NSCollectionView!
	@IBOutlet weak var searchField: NSSearchField!
	@IBOutlet weak var titleLabel: NSTextField!
	@IBOutlet weak var sizeLabel: NSTextField!
	
	var filteredTextures: [Texture] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		collectionView.dataSource = self
		collectionView.delegate = self
		configureCollectionView()
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		print("texturePosition = \(texturePosition)")
		window = self.view.window
		
		collectionView.deselectAll(nil)
		
		// select texture
		if selectedTextureIndex != -1 {
			let indexPath = IndexPath(item: selectedTextureIndex, section: 0)
			let indexSet: Set = [indexPath]
			collectionView.selectItems(at: indexSet, scrollPosition: .centeredVertically)
		} else {
			collectionView.deselectAll(nil)
		}
		
	}
	
	//	override func viewDidAppear() {
	//		super.viewDidAppear()
	//
	//	}
	
	fileprivate func configureCollectionView() {
		
		collectionView.isSelectable = true
		collectionView.allowsEmptySelection = true
		collectionView.allowsMultipleSelection = false
		
		let flowLayout = NSCollectionViewFlowLayout()
		flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
		flowLayout.minimumInteritemSpacing = 20.0
		flowLayout.minimumLineSpacing = 20.0
		
		collectionView.collectionViewLayout = flowLayout
		
		view.wantsLayer = true
		collectionView.layer?.backgroundColor = NSColor.black.cgColor
	}
	
	func setTexture() {
		
		if collectionView.selectionIndexes.isEmpty {
			switch texturePosition {
			case 1: lines[lineIndex].side[0]?.lowerTexture = "-"
			case 2: lines[lineIndex].side[0]?.middleTexture = "-"
			case 3: lines[lineIndex].side[0]?.upperTexture = "-"
			case -1: lines[lineIndex].side[1]?.lowerTexture = "-"
			case -2: lines[lineIndex].side[1]?.middleTexture = "-"
			case -3: lines[lineIndex].side[1]?.upperTexture = "-"
			default: print("Error. No texture position!")
			}
		} else {
			
			if selectedTextureIndex < 0 {
				print("Error. selectedTextureIndex was -1 but selecteIndexes is not empty")
				return
			}
			
			let newTexture = data.doom1Textures[selectedTextureIndex].name
			
			switch texturePosition {
			case 1: lines[lineIndex].side[0]?.lowerTexture = newTexture
			case 2: lines[lineIndex].side[0]?.middleTexture = newTexture
			case 3: lines[lineIndex].side[0]?.upperTexture = newTexture
			case -1: lines[lineIndex].side[1]?.lowerTexture = newTexture
			case -2: lines[lineIndex].side[1]?.middleTexture = newTexture
			case -3: lines[lineIndex].side[1]?.upperTexture = newTexture
			default:
				print("Error. No texture position!")
			}
		}
	}
	
	
	
	// ======================
	// MARK: - Collection View
	// ======================
	
	func numberOfSections(in collectionView: NSCollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		return data.doom1Textures.count
	}
	
	
	// itemForRepresentedObject
	
	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TextureCollectionViewItem"), for: indexPath)
		guard let collectionViewItem = item as? TextureCollectionViewItem else { return item }
		
		let texture = data.doom1Textures[indexPath.item]
		
		collectionViewItem.imageView?.image = NSImage(named: NSImage.Name(rawValue: texture.name))
		collectionViewItem.name = texture.name
		collectionViewItem.width = texture.width
		collectionViewItem.height = texture.height
		
		return item
	}
	
	
	// sizeForItem
	
	func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
		let image = NSImage(named: NSImage.Name(rawValue: data.doom1Textures[indexPath.item].name))
		
		var size = NSSize()
		size.width = (image?.size.width)!+SPACING*2
		size.height = (image?.size.height)!+SPACING*2
		
		return size
	}
	
	
	// didSelectItem
	
	func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
		
		var selectedTex = Texture()
		
		// store the selection index
		for indexPath in indexPaths {
			selectedTex = data.doom1Textures[indexPath.item]
			selectedTextureIndex = indexPath.item
		}
		
		// Set the texture panel info
		titleLabel.stringValue = selectedTex.name
		sizeLabel.stringValue = "\(selectedTex.width) × \(selectedTex.height)"
		
	}
	
	
	
	// =================
	// MARK: - IBActions
	// =================
	
	@IBAction func okClicked(_ sender: Any) {
		
		setTexture()
		window?.performClose(nil)
		delegate?.updateImages()
		delegate?.updateTextureLabels()
	}
	
	@IBAction func updateFilter(_ sender: Any) {
		
		let searchString = searchField.stringValue
		
		filteredTextures = data.doom1Textures.filter({( texture : Texture) -> Bool in
			return texture.name.lowercased().contains(searchString.lowercased())
		})
		
		collectionView.reloadData()
		
	}
	
}



// =====================================
// MARK: - NSSearchFieldDelegate Methods
// =====================================

extension TexturePanel: NSSearchFieldDelegate {
	
	func searchBarIsEmpty() -> Bool {
		// Returns true if the text is empty or nil
		return searchField.stringValue.isEmpty
	}
	
	func filterContentForSearchText(_ searchText: String, scope: String = "All") {
		filteredTextures = data.doom1Textures.filter({( texture : Texture) -> Bool in
			return texture.name.lowercased().contains(searchText.lowercased())
		})
		
		collectionView.reloadData()
	}
	
	
}
