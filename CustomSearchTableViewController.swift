import UIKit
import RealmSwift

class CustomSearchTableViewController <entity: CustomClass, cell: CustomCell> : UITableViewController,
    UISearchControllerDelegate,
    UISearchResultsUpdating,
    UISearchBarDelegate {
    
    typealias Entity = CustomClass
    typealias TableCell = CustomCell
    typealias ResultVC = CustomResult
    typealias DetailVC = CustomDetails
    
    let cellHeight = CGFloat(59.0)
    let searchKeyPaths = ["name","code"]
    
    // MARK: - Instance Variables
    var objects = try! Realm().objects(Entity) {
        didSet {
            tableView.reloadData()
        }
    }
    var detailViewController: DetailVC? = nil
    var searchController: UISearchController!
    var resultsTableViewController: ResultVC?
    
    // MARK: - Run Loop
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(TableCell.self, forCellReuseIdentifier: "\(TableCell.self)")
        tableView.registerNib(UINib(nibName: "\(TableCell.self)", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "\(TableCell.self)")
        
        resultsTableViewController = ResultVC()
        setupSearchControllerWith(resultsTableViewController!)
        searchController?.loadViewIfNeeded()
        
        // Table Variable Row Heights
        tableView.estimatedRowHeight = cellHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell =
            tableView.dequeueReusableCellWithIdentifier(
                "\(TableCell.self)", forIndexPath: indexPath) as! TableCell
        cell.object = objects[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView,
                            didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if tableView == resultsTableViewController?.tableView {
            performSegueWithIdentifier("showDetail", sender: resultsTableViewController!.searchResults[indexPath.row])
        } else {
            performSegueWithIdentifier("showDetail", sender: objects[indexPath.row])
        }
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
        let strippedString = searchController.searchBar.text!.stringByTrimmingCharactersInSet(whitespaceCharacterSet)
        let searchItems = strippedString.componentsSeparatedByString(" ") as [String]
        
        // Build all the "OR" expressions for each value in the searchString.
        var orMatchPredicates = [NSPredicate]()
        
        for searchString in searchItems {
            var searchItemsPredicate = [NSPredicate]()
            if searchString != "" {
                // Name field matching
                for searchKeyPath in searchKeyPaths {
                    let lhs = NSExpression(forKeyPath: searchKeyPath)
                    let rhs = NSExpression(forConstantValue: searchString)
                    let finalPredicate = NSComparisonPredicate(
                        leftExpression: lhs,
                        rightExpression: rhs,
                        modifier: .DirectPredicateModifier,
                        type: .ContainsPredicateOperatorType,
                        options: .CaseInsensitivePredicateOption)
                    searchItemsPredicate.append(finalPredicate)
                }
            }
            // Add this OR predicate to our master predicate.
            let orSearchItemsPredicates = NSCompoundPredicate(orPredicateWithSubpredicates: searchItemsPredicate)
            orMatchPredicates.append(orSearchItemsPredicates)
        }
        
        // Match up the fields of the Product object.
        let finalCompoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates:orMatchPredicates)
        
        let resultsController = searchController.searchResultsController as! ResultVC
        resultsController.searchString = searchController.searchBar.text!
        resultsController.searchResults = objects.filter(finalCompoundPredicate)
    }
    
    func setupSearchControllerWith(resultsTableViewController: ResultVC) {
        // Register Cells
        resultsTableViewController.tableView.registerClass(TableCell.self, forCellReuseIdentifier: "\(TableCell.self)")
        resultsTableViewController.tableView.registerNib(UINib(nibName: "\(TableCell.self)", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "\(TableCell.self)")
        
        // Cell Height
        resultsTableViewController.tableView.estimatedRowHeight = cellHeight
        resultsTableViewController.tableView.rowHeight = UITableViewAutomaticDimension
        //        resultsTableViewController.textForEmptyLabel = textForEmptyLabel
        
        // We want to be the delegate for our filtered table so didSelectRowAtIndexPath(_:) is called for both tables.
        resultsTableViewController.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsTableViewController)
        
        // Set Scope Bar Buttons
//        searchController.searchBar.scopeButtonTitles = ["European", "All"]
        
        // Set Search Bar
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        
        // Set delegates
        searchController.delegate = self
        searchController.searchBar.delegate = self    // so we can monitor text changes + others
        
        // Configure Interface
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        searchController.searchBar.translucent = false
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.barTintColor = UIColor(hue: 0.0, saturation: 0.0, brightness: 0.97, alpha: 1.00)
        
        // Search is now just presenting a view controller. As such, normal view controller
        // presentation semantics apply. Namely that presentation will walk up the view controller
        // hierarchy until it finds the root view controller or one that defines a presentation context.
        definesPresentationContext = true
    }
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if (segue.identifier == "showDetail") {
            
            var nextViewController = DetailVC()
            if let navViewController = segue.destinationViewController as? UINavigationController {
                nextViewController = navViewController.viewControllers[0] as! DetailVC
            } else
                if let nextVC = segue.destinationViewController as? DetailVC {
                    nextViewController = nextVC
            }
            
            if let selectedObject = sender as? Entity {
                nextViewController.object = selectedObject
                nextViewController.navigationItem.title = selectedObject.acronym
            }
        }
    }
    
}

// Uncomment to have UISplitView for iPad version
//
//extension GlossarySearch: UISplitViewControllerDelegate {
//
//    // MARK: - UISplitView Controller
//
//    func splitViewController(splitViewController: UISplitViewController,
//                             collapseSecondaryViewController secondaryViewController: UIViewController,
//                                                             ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
//        return true
//    }
//
//}
