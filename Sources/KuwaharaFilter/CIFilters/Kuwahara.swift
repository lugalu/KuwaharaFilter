//Created by Lugalu on 14/03/24.

import Foundation
import UIKit

public class Kuwahara: CIFilter{
    var inputImage: CIImage?
    var inputKernelSize: Int = 2
    
    
    static private let kernelCode: String = """

    float getLuminance(float3 color) {
        return max(color.r, max(color.g,color.b));
    }


    float4 sampleQuadrant(sampler s, float2 uv, int x1, int x2, int y1, int y2, int n) {
            float lum = 0;
            float lumSum = 0;
            float3 color = float3(0);
        
            for(int y = y1; y <= y2; ++y ) {
                for(int x = x1; x <= x2; ++x ) {
                    float4 c = sample(s, samplerTransform(s, uv + vec2(x,y)));
                    c = unpremultiply(c);
                    color += c.rgb;
                    float l = getLuminance(c.rgb);
                    lumSum += l;
                    lum += l * l;
                }
            }
            color = color / float(n);
            float mean = lumSum / n;
            float std = abs(lum / n - mean * mean);
            return float4(color,std);

    }

    kernel float4 Kuwahara(sampler s,int kernelSize) {
        float2 uv = destCoord();
        int radius = kernelSize / 2;
        float window = 2.0 * float(radius) + 1;
        int quad = int(ceil(window/2));
        int ks = quad * quad;

        float4 q1 = sampleQuadrant(s, uv, 0, radius, 0, radius, ks);
        float4 q2 = sampleQuadrant(s, uv, -radius, 0, 0, radius, ks);
        float4 q3 = sampleQuadrant(s, uv, -radius, 0, -radius, 0, ks);
        float4 q4 = sampleQuadrant(s, uv, 0, radius, -radius, 0, ks);

        float minValue = min(q1.a, min(q2.a, min(q3.a, q4.a)));
    
        float4 q;
        q.x = minValue == q1.a ? 1 : 0;
        q.y = minValue == q2.a ? 1 : 0;
        q.z = minValue == q3.a ? 1 : 0;
        q.w = minValue == q4.a ? 1 : 0;
    
        if (dot(q, vec4(1.0)) > 1) {
            return premultiply(float4((q1.rgb + q2.rgb + q3.rgb + q4.rgb) / 4.0, 1.0));
        }else {
            return float4(q1.rgb * q.x + q2.rgb * q.y + q3.rgb * q.z + q4.rgb * q.w, 1.0);
        }
    }
"""
    
    
    
    static var kernel: CIKernel = { () -> CIKernel in
        return CIKernel(source: Kuwahara.kernelCode) ?? CIKernel()
    }()
    
    
    
    public override var attributes: [String : Any] {
         return [
             kCIAttributeFilterDisplayName: "Kuwahara",

             "inputImage": [kCIAttributeIdentity: 0,
                            kCIAttributeClass: "CIImage",
                            kCIAttributeDisplayName: "Image",
                            kCIAttributeType: kCIAttributeTypeImage],

             "inputKernelSize": [kCIAttributeIdentity: 0,
                                       kCIAttributeClass: "NSNumber",
                                       kCIAttributeDisplayName: "kernelSize",
                                       kCIAttributeDefault: 2,
                                       kCIAttributeMin: 2,
                                       kCIAttributeType: kCIAttributeTypeScalar]
         ]
     }
    
    
    public override func setValue(_ value: Any?, forKey key: String) {
        switch key {
            case "inputImage":
            inputImage = value as? CIImage
            case "inputKernelSize":
                inputKernelSize = value as! Int
            default:
                break
        }
    }
    
    public override var outputImage : CIImage? {
            get {
                guard let input = inputImage else {
                    return nil
                }
                let callback: CIKernelROICallback = {_,rect in
                    return rect
                }
                
                let out = Kuwahara.kernel.apply(extent: input.extent,
                                                roiCallback: callback,
                                                 arguments: [input, inputKernelSize])
                return out
            }
        }
}
