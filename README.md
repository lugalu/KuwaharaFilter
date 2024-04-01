# KuwaharaFilter
Project focused on Implementing the KuwaharaFilter in Swift for Apple Platforms

## Features
The current List of features is:
- CI Filter for all the Kuwahara Types (Standard, Generalized, Polynomial, and Anisotropic).


## Image Examples
**Zooming in is recommended!**

<img src= "https://i.imgur.com/yifMsZ9.jpg"/>
    - Photo by <a href="https://www.pexels.com/@nejc-kosir-108379/">Nejc Košir</a> on <a href="https://www.pexels.com/photo/green-leafed-tree-338936/">Pexels</a><br>
         


<img src= "https://i.imgur.com/xtORE67.png"/>
    - Photo by <a href="https://www.pexels.com/@josh-hild-1270765/">Josh Hild</a> on <a href="https://www.pexels.com/photo/bird-s-eye-view-photography-of-lighted-city-3573383/">Pexels</a>
    
    
## How to use

To register the filter to use as any other CI do the following:
```Swift
    //AppDelegate
     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DispatchQueue.global().async {
            FilterRegister.registerFilters()
        }
        return true
    }
```
if you don't want or can't you can use:
```Swift
    let filter = Kuwara()
    kuwahara.setValue(image, forKey: "inputImage")
    let img = kuwahara?.outputImage //also optional remember to guard or don't I'm dev not a cop
    
```

All is Done via CIFilters meaning that you can use on any platform:

macOS:
```Swift
import SwiftDithering

function yourFunction() {
//Highly Recommended
    DispatchQueue.global().async{
        guard let data: Data =  NSImage(named:"testImage").tiffRepresentation,
        let bit = NSBitmapImageRep(data: data),
        let cImage: CIImage = CIImage(bitmapImageRep: bit),
        let filter = CIFilter(name: "Kuwahara", parameters: ["inputImage": image])
         else {
        // handle this case
        }
        //can also add values like this
        filter.setValue(value, forKey: "keyHere")
        ...
        guard let out = filter.outputImage else {
            //handle this
        }
        let rep = NSCIImageRep(ciImage: out)
        let img = NSImage(size: rep.size)
        img.addRepresentation(rep)
    }
  
}
```

iOS:
```Swift
import SwiftDithering

function yourFunction() {
//Highly Recommended
    DispatchQueue.global().async{
        guard let image: UIImage =  UIImage(named:"testImage") else {
        // handle this case
        }
        var ciImage:CIImage
        if image.ciImage == nil {
            guard let cg = image.cgImage else{
                //handle
            }
            ciImage = CIImage(cgImage: image.cgImage)
        } else{
            ciImage = image.ciImage!
        }
        
        guard let filter = CIFilter(name: "Kuwahara", parameters: ["inputImage": ciImage]) else {
            //handle this
        }
        //can also add values like this
        filter.setValue(value, forKey: "keyHere")
        ...
        guard let out = filter.outputImage,
            let cg = CIContext().createCGImage(out, from: out.extent) else {
            //handle this
        }
        
        let result = UIImage(cgImage: cg)
    }
}
```

There's also a Sample app on the package(for now I plan to move it later) showing a basic implementation.


## Thanks
This project was possible by the great video and implementation of [acerola](https://www.youtube.com/watch?v=LDhN-JK3U9g) and other resources that I found online.


### Others
 Any images attached are not of my creation, I try to get everything from Pexels and credit everyone, if I forgot to do that please create an issue here on git, while is not mandatory according to Pexels rules and license is the least I can do for the amazing art these people created.

