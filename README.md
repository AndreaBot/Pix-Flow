# PixFlow
![180](https://github.com/AndreaBot/Pix-Flow/assets/128467098/65b65239-af70-4015-aa7f-ec6ef172cd5b)

Are you struggling to find new, cool wallpapers for your phone? Look no further: introducing Pix Flow!

Pix Flow leverages the Unsplash API to retrieve high-quality, portrait-oriented photos, perfect for your phone's wallpaper.

This was my first personal project, created to practice making network calls. As someone who enjoys regularly customizing my phone, this app was a double win: it allowed me to find fresh wallpapers while honing my skills with UICollectionViews, Core Data, API integration, and adhering to all requirements specified in the API documentation.

<img width="220" alt="Screenshot 2024-06-05 at 21 43 20" src="https://github.com/AndreaBot/Pix-Flow/assets/128467098/9f574921-96a2-49f0-a4bf-f1c8bc2d9906"> <img width="220" alt="Screenshot 2024-06-05 at 21 43 53" src="https://github.com/AndreaBot/Pix-Flow/assets/128467098/ba594b44-331f-492f-b478-88913d7fc67d">

In the Pix Flow screen, users can either perform a custom search using a UITextField or choose from pre-selected categories. Search results can then be sorted by most recent, oldest and most popular.

Upon selecting a photo, users are presented with a full-screen, high-resolution view of the image, along with a button to download and save it locally to the Photos app. At the bottom of the screen, a link directs users to the photographer's Unsplash page, as required by the API documentation.

Another requirement specified in the docs is to send a request to the download endpoint provided under the "photo.links.download_location" propertyof the image. This request is triggered when the file is downloaded.

The "Add to Favorites" button saves the details of the image to Core Data, allowing for later retrieval in the "My Favorites" screen.

<img width="220" alt="Screenshot 2024-06-05 at 21 44 15" src="https://github.com/AndreaBot/Pix-Flow/assets/128467098/8c4ebfb7-c5c9-4304-a487-22de4d26b7c9">

Allowing users to mark photos as favorites enables them to easily revisit them without needing to perform a new search or save every photo immediately. For this feature, Core Data was chosen as the persistence framework.

The "My Favorites" screen operates similarly to the search results screen, with the addition of an overlay that appears upon tapping an image. This overlay reveals buttons to download the image and to remove the photo from the database.

<img width="220" alt="Screenshot 2024-06-05 at 21 45 04" src="https://github.com/AndreaBot/Pix-Flow/assets/128467098/835118a6-1ed1-4512-8223-c6f31678c4f0">














