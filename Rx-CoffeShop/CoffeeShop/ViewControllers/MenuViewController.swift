//
//  MenuViewController.swift
//  CoffeeShop
//
//  Created by Göktuğ Gümüş on 23.09.2018.
//  Edited by Korel Hayrullah on 08.10.2018.
//  Copyright © 2018 Göktuğ Gümüş. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MenuViewController: BaseViewController {
  
  @IBOutlet private weak var tableView: UITableView!
  
  private lazy var shoppingCartButton: BadgeBarButtonItem = {
    let button = BadgeBarButtonItem(image: "cart_menu_icon", badgeText: nil, target: self, action: #selector(shoppingCartButtonPressed))
    
    button!.badgeButton!.tintColor = Colors.brown
    
    return button!
  }()
  
  private let disposeBag = DisposeBag()
  
  private lazy var coffees: Observable<[Coffee]> = {
    let espresso = Coffee(name: "Espresso", icon: "espresso", price: 4.5)
    let cappuccino = Coffee(name: "Cappuccino", icon: "cappuccino", price: 11)
    let macciato = Coffee(name: "Macciato", icon: "macciato", price: 13)
    let mocha = Coffee(name: "Mocha", icon: "mocha", price: 8.5)
    let latte = Coffee(name: "Latte", icon: "latte", price: 7.5)
    
    return .just([espresso, cappuccino, macciato, mocha, latte])
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.rightBarButtonItem = shoppingCartButton
    
    configureTableView()
    
    // Rx Setup
    coffees
      .bind(to: tableView
        .rx
        .items(cellIdentifier: "coffeeCell", cellType: CoffeeCell.self)) { row, element,
          cell in
          cell.configure(with: element)
        }
        .disposed(by: disposeBag)
    
    tableView
      .rx
      .modelSelected(Coffee.self)
      .subscribe(onNext: { [weak self] coffee in
        self?.performSegue(withIdentifier: "OrderCofeeSegue", sender: coffee)
        
        if let selectedRowIndexPath = self?.tableView.indexPathForSelectedRow {
          self?.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
        }
      })
      .disposed(by: disposeBag)
    
    ShoppingCart.shared.getTotalCount()
      .subscribe(onNext: { [weak self] totalOrderCount in
        self?.shoppingCartButton.badgeText = totalOrderCount != 0 ? "\(totalOrderCount)" : nil
      })
      .disposed(by: disposeBag)
  }
  
  /*
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let totalOrderCount = ShoppingCart.shared.getTotalCount()
    
    shoppingCartButton.badgeText = totalOrderCount != 0 ? "\(totalOrderCount)" : nil
    
  }
  */
  
  private func configureTableView() {
    //tableView.delegate = self
    //tableView.dataSource = self
    tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
    tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
    tableView.rowHeight = 104
  }
  
  @objc private func shoppingCartButtonPressed() {
    performSegue(withIdentifier: "ShowCartSegue", sender: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let coffee = sender as? Coffee else { return }
    
    if segue.identifier == "OrderCofeeSegue" {
      if let viewController = segue.destination as? OrderCoffeeViewController {
        viewController.coffee = coffee
        viewController.title = coffee.name
      }
    }
  }
}

/*
extension MenuViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 104
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    guard indexPath.row < coffees.count else { return }
    
    performSegue(withIdentifier: "OrderCofeeSegue", sender: coffees[indexPath.row])
  }
}

extension MenuViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return coffees.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: "coffeeCell", for: indexPath) as? CoffeeCell {
      cell.configure(with: coffees[indexPath.row])
      
      return cell
    }
    
    return UITableViewCell()
  }
}
*/

