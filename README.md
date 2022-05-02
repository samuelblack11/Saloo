README:

GreetMe is a digital greeting card app, allowing users to create custom digital greeting cards and store special memories in the same format. This is done using a photo collage and custom formatted note or caption. These may be saved or shared for special occasions, as postcards, or just because! Each greeting card can be shared via text, email, or be shared to social media as a PDF. Photos for the collage can be added from the user’s photo library or from the Unsplash API service. 

Instructions for the App are as follows:
1. Login using Apple ID
2. Choose from menu wether to create new greeting card, or view previously sent cards 
    1. If viewing previously sent cards, those cards (stored to Core Data) are displayed in a Collection View. Each cell displays an image of the card along with the recipient’s name, the occasion, and date it was sent. 
    2. On a long press gesture, users are able to enlarge the card (which also enables the user to share it), or delete it.
3. If creating a new card, user will be prompted to import photos from their library or from the Unsplash API using the “Select Photo #” Button.
    1. If importing from the Unsplash API, the user will search for photos by keyword, then add them to the collage
4. User will finalize photo selection and write a personalized note up to 140 characters long and choose a font for the note to be written in
5. The user will perform one final review of the full card (collage and note). The note will be in a scrollable UITextView in the app. The user can save and share as they please in this view. Cards are exported as PDFs, and all text is displayed to fit the size of a 1 page PDF, rather than scrolling through as would be done in the app.

Swift Languages Version Required: Swift 5
iOS Version Required: 13.7
XCode Version Required: 13.3
