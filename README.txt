Dermot Duncan
70857251
IOS Students Choice
Pub Crawl App

This App makes use of StoryBoards so the layout of the app can be seen visually in the storyboard.
Below is a brief description of each scene.

On Startup, the app loads the Address Selection Scene.
This scene allows the user to specify an address or use their current location. By default their
current location is used and the rest of the address fields are disabled. To enable the fields,
the user must click the enter address button of the switch. Clicking the current location button
disables and clears all the address field. Clicking the Find Nearby Pubs button launches the
Pub Results scene.

Within the Location folder there are 2 models. The first, LocationObject is a singleton object.
This contains a few values which are used across multiple view controllers.
	1. Address: contains the address specified by the user if one is specified
	2. Latitude: latitude of the location the user is looking for pubs in
	3. Longitude: longitude of the location the user is looking for pubs in
	4. Pubs: An array of GooglePlacesObjects which contains the pub results

The Pub Results Scene contains a tableview along with an options bar at the bottom which has 2
buttons. I'll describe them in more detail below. The scene is tied to the PubListTableViewController.
On initialize an instance of the GooglePlacesConnection class is created. We also check the address
field in the singleton to see if it has a value. If it doesn't we get the location from the users
device and then call the getGoogleObject method with the users current location. If there is an
address specified we use the CLGeocoder to check if the address is valid, get it's co-ordinates
and use them to search for pubs. Within the GooglePlacesConnection class we generate a google places
url out of the location, looking for bars and nightclubs within a 2 mile radius and use my API key. Note,
google has a cap of 100 calls within a 24 hour period using the one API key so this could be the
reason if you continually see no results found. Assuming results are found the tableView displays
the pubs name and it's distance from the specified or current location.

Clicking on a pub in the tableview launches the Pub Detail scene which uses the PubDetailViewController.
This makes use of the getGoogleObjectDetails method in the GooglePlacesConnection class and displays the pubs details in labels. Users can also add a comment on the pub which is stored in an amazon simpleDB. 

Clicking on the viewComments button launches another table view which shows all comments entered for a specific pub. These are read from an Amazon SimpleDB.

Clicking on the showPhotos button launches a collection view with custom image cells to display all photos uploaded on that pub. These are read directly from an Amazon S3 bucket.

Clicking on the uploadPhoto buttons launches another view which allows a user to either take a photo or select one from the phones library. When a photo's selected it's uploaded to an Amazon S3 bucket.

Please note, use was made of some open source libraries in this project which weren't touched or
enhanced in any way.
 - MBProgressHUD
 - GTM
 - SBJSON

Also the GooglePlacesObject model was open source and not changed at all as part of this project.
The GooglePlacesConnection is also based on an open source class but was enhanced to be allowed
specify a location along with using the devices current location.

Some enhancements which there weren't time for in this project
- Adding a filter to the tableview to filter by rating and distance from location.
- Adding a sort to the tableview to sort by distance from location and rating.
- Adding a search to the tableview to be able to filter the results based on the pubs name
- Removing pubs from the list. This will likely be implemented in the details controller. After the
  user has viewed the details of the pub they'd have an option to remove it from the list or
  keep it in the list
- Embedding the pub route map in the email.