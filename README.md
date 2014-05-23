CPImageView
===========

A small, lightweight subclass of `UIImageView` which supports async loading from URLs and caching both in memory and storage.

Features
===========

	* Loading images asynchronously from a web server without interrupting the UI thread
	* Automatic caching images on the file system and using cache where needed
	* Additional automatic caching of newly downloaded files in-memory for faster access and releasing them if app receives memory warning
	* Optionally clearing previous image while loading, and checking if downloaded image is still the image to be displayed on the view upon download (ideal for using in reusable table view cells)
	* Optional logging about download and caching events

Usage
===========

CPImageView is a subclass of the standard `UIImageView`. Just change your UIImageView instance to `CPImageView` whether it's in code or in Interface Builder.

	* For changing/settings an existing image view's image, use `setImageFromURL:` to set the source image from a URL. You can both pass in an `NSString` or an `NSURL`, the method (and all the other similar methods) accepts both. You can pass in `nil` to clear the image.

	* To create a new image view, you can use `initWithImageURL:` method directly to initialize an instance and start loading the image.

	* You may use the convenience methods `storedImageForURL:` and `storeImage:forURL:` methods to access file system cache for images.

Alternatives
===========

There are many more alternatives to `CPImageView`, use whatever you need. There are more advanced, and even lighther alternatives to `CPImageView`. If they suit your needs, use them. If `CPImageView` is just what you need, feel free to use it. If you like to contribute to `CPImageView`, you are more than welcome to!