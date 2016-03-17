import UIKit

class TableViewController: UITableViewController {
    var database: Database?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "native view"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "deleteAll")
    }

    func deleteAll() {
        self.database?.deleteAll()
        self.tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        assert(self.tableView === tableView, "should only ever get messages for itself");
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assert(self.tableView === tableView, "should only ever get messages for itself");
        assert(section == 0, "not expecting section \(section)")
        return self.database!.select().count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        assert(self.tableView === tableView, "should only ever get messages for itself");
        
        //this will read the file many times, especially with the asserts
        //but we are not in any hurry
        //so let's keep the code simple and avoid temporary variables
        //the arguments of the assert are only evaluated in debug mode just like in obj-c
        //https://developer.apple.com/swift/blog/?id=4
        //pretty cool
        
        //if you need to, start using the reuse identifier
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil);
        //like if you get a lot of cells
        
        assert(indexPath.section == 0, "not expecting section \(indexPath.section)")
        assert(indexPath.row < self.database!.select().count, "only have \(self.database!.select().count) rows but asking for row \(indexPath.row)")
        cell.textLabel?.text = self.database!.select()[indexPath.row].note

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        assert(self.tableView === tableView, "should only ever get messages for itself");
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

