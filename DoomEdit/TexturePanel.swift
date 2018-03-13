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
	var selectedLineIndices: [Int] = []
	var lineIndex: Int = 0
	var texturePosition: Int = 0
	
	var window: NSWindow?
	var delegate: TexturePanelDelegate?
	
	@IBOutlet weak var collectionView: NSCollectionView!
	@IBOutlet weak var searchField: NSSearchField!
	@IBOutlet weak var titleLabel: NSTextField!
	@IBOutlet weak var sizeLabel: NSTextField!
	@IBOutlet weak var widthTextField: NSTextField!
	@IBOutlet weak var heightTextField: NSTextField!
	
	var filteredTextures: [Texture] = []
	

	
	// =================================
	// MARK: - ViewController Life Cycle
	// =================================

	override func viewDidLoad() {
		super.viewDidLoad()
				
		searchField.sendsSearchStringImmediately = true
		searchField.sendsWholeSearchString = false
		
		collectionView.dataSource = self
		collectionView.delegate = self
		configureCollectionView()
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		window = self.view.window
		searchField.stringValue = ""
		filteredTextures = wad.textures
		print(wad.sprites.count)
	}
	
	override func viewWillLayout() {
		super.viewWillLayout()
		
		if selectedTextureIndex != -1 {
			selectTexture()
		} else {
			collectionView.deselectAll(nil)
			collectionView.scrollToItems(at: indexSet(for: 0), scrollPosition: .top)
			titleLabel.stringValue = "--"
			sizeLabel.stringValue = ""
		}
	}
	

	
	// ======================
	// MARK: - Helper Methods
	// ======================

	fileprivate func configureCollectionView() {
		
		collectionView.isSelectable = true
		collectionView.allowsEmptySelection = true
		collectionView.allowsMultipleSelection = false
		
		let flowLayout = NSCollectionViewFlowLayout()
		flowLayout.scrollDirection = .vertical
		flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
		flowLayout.minimumInteritemSpacing = 20.0
		flowLayout.minimumLineSpacing = 20.0
		
		collectionView.collectionViewLayout = flowLayout
		
		view.wantsLayer = true
		collectionView.layer?.backgroundColor = NSColor.black.cgColor
	}

	func indexSet(for item: Int) -> Set<IndexPath> {
		let indexPath = IndexPath(item: item, section: 0)
		let indexSet: Set = [indexPath]
		return indexSet
	}

	
	
	// ================
	// MARK: - Textures
	// ================
	


	func selectTexture() {

		collectionView.deselectAll(nil)
		
		for i in 0..<filteredTextures.count {
			if filteredTextures[i].index == selectedTextureIndex {
				collectionView.selectItems(at: indexSet(for: i), scrollPosition: .centeredVertically)
				updateLabels(texture: filteredTextures[i])
				return
			}
		}
	}
	
	func setUpperTexture(name: String, side: Int) {
		
		for index in selectedLineIndices {
			if lines[index].side[side] != nil {
				lines[index].side[side]?.upperTexture = name
			}
		}
	}
	
	func setMiddleTexture(name: String, side: Int) {
		
		for index in selectedLineIndices {
			if lines[index].side[side] != nil {
				lines[index].side[side]?.middleTexture = name
			}
		}
	}
	
	func setLowerTexture(name: String, side: Int) {
		
		for index in selectedLineIndices {
			if lines[index].side[side] != nil {
				lines[index].side[side]?.lowerTexture = name
			}
		}
	}


	/// Sets all selected lines
	func setTexture() {
		
		if collectionView.selectionIndexes.isEmpty {
			switch texturePosition {
			case 1: setLowerTexture(name: "-", side: 0)
			case 2: setMiddleTexture(name: "-", side: 0)
			case 3: setUpperTexture(name: "-", side: 0)
			case -1: setLowerTexture(name: "-", side: 1)
			case -2: setMiddleTexture(name: "-", side: 1)
			case -3: setUpperTexture(name: "-", side: 1)
			default: print("Error. No texture position!")
			}
		} else {
			
			if selectedTextureIndex < 0 {
				print("Error. selectedTextureIndex was -1 but selecteIndexes is not empty")
				return
			}
			
			let newTextureName = wad.textures[selectedTextureIndex].name
			
			switch texturePosition {
			case 1: setLowerTexture(name: newTextureName, side: 0)
			case 2: setMiddleTexture(name: newTextureName, side: 0)
			case 3: setUpperTexture(name: newTextureName, side: 0)
			case -1: setLowerTexture(name: newTextureName, side: 1)
			case -2: setMiddleTexture(name: newTextureName, side: 1)
			case -3: setUpperTexture(name: newTextureName, side: 1)
			default:
				print("Error. No texture position!")
			}
		}
	}
	
	func updateLabels(texture: Texture) {
		titleLabel.stringValue = texture.name
		sizeLabel.stringValue = "\(texture.width) × \(texture.height)"
	}

	
	
	
	// =======================
	// MARK: - Collection View
	// =======================
	
	func numberOfSections(in collectionView: NSCollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		return filteredTextures.count
	}
	
	
	// itemForRepresentedObject
	
	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TextureCollectionViewItem"), for: indexPath)
		guard let collectionViewItem = item as? TextureCollectionViewItem else { return item }
		
		let texture = filteredTextures[indexPath.item]
		
		collectionViewItem.imageView?.image = texture.image
		collectionViewItem.name = texture.name
		collectionViewItem.width = texture.width
		collectionViewItem.height = texture.height
		
		return item
	}
	
	
	// sizeForItem
	
	func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
		let image = filteredTextures[indexPath.item].image
		
		var size = NSSize()
		size.width = image.size.width+SPACING*2
		size.height = image.size.height+SPACING*2
		
		return size
	}
	
	
	// didSelectItem
	
	func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
		
		var selectedTex = Texture()
		
		// store the selection index
		for indexPath in indexPaths {
			selectedTex = filteredTextures[indexPath.item]
			selectedTextureIndex = selectedTex.index
			print(selectedTex.index)
		}
		updateLabels(texture: selectedTex)
	}
	
	
	
	// =================
	// MARK: - IBActions
	// =================
	
	@IBAction func okClicked(_ sender: Any) {
		
		setTexture()
		window?.performClose(nil)
		delegate?.updateImageFromPanel(name: wad.textures[selectedTextureIndex].name, position: texturePosition)
		delegate?.updateTextureLabelFromPanel(name: wad.textures[selectedTextureIndex].name, position: texturePosition)
	}
	
	@IBAction func updateFilter(_ sender: Any) {
		
		print("updateFilter called")
		let searchString = searchField.stringValue
		
		if searchBarIsEmpty() {
			filteredTextures = wad.textures
			collectionView.reloadData()
			selectTexture()
		} else {
			filteredTextures = wad.textures.filter({( texture : Texture) -> Bool in
				return texture.name.lowercased().contains(searchString.lowercased())
			})
			collectionView.reloadData()
			selectTexture()
		}
	}
	
	@IBAction func filterButtonPressed(_ sender: NSButton) {
		
		searchField.stringValue = sender.title
		updateFilter(sender)
	}
	
	
	@IBAction func filterSize(_ sender: NSButton) {
		
		updateFilter(sender)
		
		var filteringWidth: Bool = false
		var filteringHeight: Bool = false
		var filteringBoth: Bool = false
		
		var sizeFilteredTextures: [Texture] = []
		
		if widthTextField.integerValue != 0 && heightTextField.integerValue == 0 {
			filteringWidth = true
		} else if widthTextField.integerValue == 0 && heightTextField.integerValue != 0 {
			filteringHeight = true
		} else if widthTextField.integerValue != 0 && heightTextField.integerValue != 0 {
			filteringBoth = true
		} else {
			updateFilter(sender)
			return
		}

		if filteringWidth {
			for texture in filteredTextures {
				if texture.width == widthTextField.integerValue {
					sizeFilteredTextures.append(texture)
				}
			}
		}
		
		if filteringHeight {
			for texture in filteredTextures {
				if texture.height == heightTextField.integerValue {
					sizeFilteredTextures.append(texture)
				}
			}
		}
		
		if filteringBoth {
			for texture in filteredTextures {
				if texture.width == widthTextField.integerValue && texture.height == heightTextField.integerValue {
					sizeFilteredTextures.append(texture)
				}
			}
		}
		
		filteredTextures = sizeFilteredTextures
		collectionView.reloadData()
		selectTexture()

	}
	
	@IBAction func clearFilters(_ sender: NSButton) {
		
		widthTextField.stringValue = ""
		heightTextField.stringValue = ""
		filterSize(sender)
	}
	
	@IBAction func removeTexture(_ sender: NSButton) {
		collectionView.deselectAll(nil)
		okClicked(sender)
	}
	
	
	// =====================================
	// MARK: - Search Field
	// =====================================

	func searchBarIsEmpty() -> Bool {

		return searchField.stringValue.isEmpty
	}

	
}
