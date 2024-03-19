# KuwaharaFilter
Project focused on Implementing the KuwaharaFilter in Swift for iOS

## Features
The current List of features is:
- Full CPU support for B&W and colored standard kuwahara. But this is *NOT* the recommended way of Applying to the Image (will be deprecated to reflect this recommendation)
- Full CIFilter Support for basic and B&W Kuwahara. Recommended Way of using.


## Plans

The future for this package:
- Implementation of Generalized(Gaussian) Kuwahara
- Implementation of Anisotropic Kuwahara
- Implementation of Adaptative(Anisotropic+) Kuwahara Filter
- Implement a stronger test suite & test plan
- Document

Up to Discussion:
- Removal of the CPU implementation
- make B&W a toggle instead of an Enum
- More Low pass filters?
- More Edge Preserving filters? if so a rename would be good
- Move any Sample Apps to a single Repo to save space when downloading the package
- Learn how to export binaries for better performance?(if that's a thing)

### Others

 Any images attached are not of my creation, I try to get everything from Pexels and credit everyone, if I forgot to do that please create an issue here on git, while is not mandatory according to Pexels rules and license is the least I can do for the amazing art these people created.

