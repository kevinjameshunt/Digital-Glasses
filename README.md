# Digital-Glasses
Digital Glasses for Low Vision - Eyewear for the legally blind

Overview
========
This software was built to work with an inexpensive Google Cardboard headset to digitally enhance the sight of people who are visually impaired using augmented reality. My father is nearly blind and we were looking at a similar product by eSight, but they charge $10,000 USD for their headset. Frustrated by the ridiculous cost, I built my own using an iPod touch, Pebble Watch, and a Google Cardboard, the total cost of which was about $320. I have since included support for a more affordable $25 bluetooth remote instead of a Pebble, reducing the total price to under $300. I've also added support for AppleWatch as well. The custom software will allow people to adjust brightness, contrast, saturation, and zoom from the iPhone/iPods camera using the watch/remote as a control. These features can greatly improve what a person with severe visually disabilities is able to see at a tiny fraction of the cost of both existing and upcoming commercial hardware. 

Using a customized version of the FastttCamera, the application uses preset "lookup images" to add filters to what the iOS camera preview presents to the viewer. This is essentially how apps like Instagram allow users to add color filters to photos. With this software, however, we are using it to augment and enhance what an individual is able to see on-the-fly while wearing a headset. 

More information in this video: 

[![Video of the app in action](https://img.youtube.com/vi/xJJuWGkk544/0.jpg)](http://www.youtube.com/watch?v=xJJuWGkk544)

Features
========
* Use the Magnifier mode to zoom and enlarge text and everyday objects. You can also increase/decrease brightness, color saturation, contrast, and activate/deactivate the flashlight on the phone for increased visibility. 
* Use the Headset mode with any compatible AR/VR headset to enhance your sight hands-free. 
* Support for compatible iCade Bluetooth remote controller, Apple Watches, and Pebble Smartwatches (excluding Round watches)
* Use remotes or smartwatches to zoom, increase/decrease brightness, color saturation, contrast, and activate/deactivate the flashlight on the phone for increased visibility
* Instructional How-To videos for all features!

Hardware Requirements
========
Ideally, an iPod touch is the best device to use for your headset. Fourth generation and up ([which can be found here](https://www.amazon.com/gp/search?ie=UTF8&tag=prophetstud07-20&linkCode=ur2&linkId=c1c173d0e74c5e7bcce4dabd5cf667bd&camp=1789&creative=9325&index=aps&keywords=ipod%20touch)) is ideal because the camera is superb from this version onward. 

[AR/VR Headsets can be found here](https://www.amazon.com/gp/product/B072JJDV3G/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B072JJDV3G&linkCode=as2&tag=prophetstud07-20&linkId=0650f88eed6de2b4379d3255daba2b50). Be sure to purchase a headset that has a strap so that it will stay on your head hands-free and, most importantly, does not block the camera of the iPhone/iPod. 

[Bluetooth remotes are the cheapest way to control the app while wearing a headset, and can be found here](https://www.amazon.com/gp/search?ie=UTF8&tag=prophetstud07-20&linkCode=ur2&linkId=de3a9866fb0a7bdb9863629a4e3ec8f8&camp=1789&creative=9325&index=aps&keywords=iCade%20bluetooth%20remote). Any iCade Bluetooth remote will should be compatible with this app. If you have one that is not compatible, please contact me so I can add support! 

Alternatively, Apple Watches ([found here](https://www.amazon.com/gp/search?ie=UTF8&tag=prophetstud07-20&linkCode=ur2&linkId=c1c173d0e74c5e7bcce4dabd5cf667bd&camp=1789&creative=9325&index=aps&keywords=apple%20watch)) and the significantly cheaper Pebble Watches ([found here](https://www.amazon.com/gp/search?ie=UTF8&tag=prophetstud07-20&linkCode=ur2&linkId=c1c173d0e74c5e7bcce4dabd5cf667bd&camp=1789&creative=9325&index=aps&keywords=pebble%20watch)) are also supported as remotes for the headset. 

TODO
========
This version features the basic, essential features that I wanted to provide my father. But there are still many things that need to be done in order to make application an exceptional tool for visually impaired individuals. 

In the next phase of this application. I would love to integrate this with the Google Cardboard Unity framework or the new Apple ARKit. When I first started building the application, I had tried to use Unity, but at the time there seemed to be no way to remove the background from a 3D scene to allow me to show the camera preview. Between that and my complete inexperience with Unity as a whole, I was unable to find a way to integrate the camera preview into what was essentially a "VR" scene.  However, I have great faith that the technology has improved over the last year and a half, so this is something I will revisit.  

Additionally, I would like to explore other types of filters that would be helpful to sufferers or specific visual impairments. For instance, I've been told that being able to increase the intensity of a certain colors for color-blind individuals would be extremely useful. 

I also wish to clean up the linking of the various components. Using cocoapods to handle the dependencies of the FastttCamera lirary and git submodules to handle my forks of that and other third-party libraries is messy an I dont like it. 

FastttCamera
========
The filtering software behind this application is the FastttCamera library by [Laura Skelton](https://github.com/lauraskelton) at [IFTTT](https://ifttt.com/), which I forked in order to expose the camera preview layer so that I could duplicate it to provide an AR-like interface.  This is fantastic software that wraps the core AVFoundation and GPUImage APIs, making it extremely easy to enhance and filter data from the camera. 
