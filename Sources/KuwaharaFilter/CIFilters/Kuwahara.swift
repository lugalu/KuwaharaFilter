//Created by Lugalu on 14/03/24.

import Foundation
import CoreImage

fileprivate extension KuwaharaTypes {
    func getKernel() -> String {
        switch self {
        case .basicKuwahara:
            return """
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
                
                    float4 q = float4(0);
                    q = minValue == q1.a ? q1 : q;
                    q = minValue == q2.a ? q2 : q;
                    q = minValue == q3.a ? q3 : q;
                    q = minValue == q4.a ? q4 : q;
                
                    return float4(q.rgb, 1);
                }
            """
            
        case .colored:
            return """
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
        case .generalized:
            return """
                       
            float getSquaredZFor(float x){
                float z = max(0.0, x);
                return z * z;
            }
            
            kernel float4 Kuwahara(sampler s, int kernelSize, float zeroCross, float hardness, float q){
                float2 uv = destCoord();
                int radius = kernelSize;
            
                float zeta = 2.0 / float(radius);
                float sinZero = sin(zeroCross);
                float eta = zeta + cos(zeroCross) / (sinZero * sinZero);
            
                float4 mean[SECTORS];
                float3 std[SECTORS];
                
                for (int k = 0; k < SECTORS; k++){
                    mean[k] = vec4(0);
                    std[k] = vec3(0);
                }
            
            
                for(int y = -radius; y <= radius; y++){
                    for(int x = -radius; x <= radius; x++){
                        float2 v = float2(x,y) / float(radius);
                        float3 c = sample(s, samplerTransform(s, uv + float2(x,y))).rgb;
                        c = clamp(c, 0., 1.);
            
                        float sum = 0;
                        float w[SECTORS];
                        float vxx, vyy;
            
                        vxx = zeta - eta * v.x * v.x;
                        vyy = zeta - eta * v.y * v.y;
                        
                        w[0] = getSquaredZFor(v.y + vxx);
                    
                        w[2] = getSquaredZFor(-v.x + vyy);
            
                        w[4] = getSquaredZFor(-v.y + vxx);
                        
                        w[6] = getSquaredZFor(v.x + vyy);
                        
                        v = sqrt(2.) / 2. * float2(v.x-v.y, v.x + v.y);
                        vxx = zeta - eta * v.x * v.x;
                        vyy = zeta - eta * v.y * v.y;
            
                        w[1] = getSquaredZFor(v.y + vxx);
            
                        w[3] = getSquaredZFor(-v.x + vyy);
            
                        w[5] = getSquaredZFor(-v.y + vxx);
                                    
                        w[7] = getSquaredZFor(v.x + vyy);
            
                        for(int k = 0; k < SECTORS; k++){
                            sum += w[k];
                        }
                        
                        float g = exp(-3.125f * dot(v,v)) / sum;
            
                        for(int k = 0; k < SECTORS; k++){
                            float wk = w[k] * g;
                            mean[k] += float4(c * wk,wk);
                            std[k] += c*c*wk;
                        }
                    }
                }
                
                float4 result = float4(0);
                
                for(int k = 0; k < SECTORS; k++){
                    mean[k].rgb /= mean[k].w;
                    std[k] = abs(std[k] / mean[k].w - mean[k].rgb * mean[k].rgb);
            
                    float sigma2 = std[k].r + std[k].g + std[k].b;
                    float w = 1 / (1 + pow(hardness * 1000. * sigma2, 0.5 * q));
                    
                    result += float4(mean[k].rgb * w, w);
                }
            
                result /= result.w;
                return clamp(result,0.,1.);
            
            }
            
            """
        }
    }
}

public class Kuwahara: CIFilter{
    //Standard
    var inputImage: CIImage?
    var inputKernelSize: Int = 2
    var inputKernelType: KuwaharaTypes = .colored
    
    //Generalized
    /* Defines the level of modification lower the value more blobs of the effect appear.*/
    var inputZeroCross: Float = 1

    /* Defines quality, the lower closer it is to the original, higher more stylized, but too high can accentuate blacks and create blobs. Is necessary to strike a balance between the Hardness and inputQuality */
    var inputHardness: Float = 100
    
    /* Defines quality, the lower closer it is to the original, higher more stylized, but too high can accentuate blacks and create blobs. Is necessary to strike a balance between the Hardness and inputQuality */
    var inputQuality: Float = 15
    
    static private let baseKernelCode: String = """
    #define SECTORS 8
    #define PI 3.14159265358979323846f

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
"""
    
    var kernel: CIKernel {
        
        return CIKernel(source: Kuwahara.baseKernelCode + inputKernelType.getKernel()) ?? CIKernel()
    }
    
    
    
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
                                 kCIAttributeType: kCIAttributeTypeScalar],
             
             "inputKernelType": [kCIAttributeIdentity: 0,
                                 kCIAttributeClass: "KuwaharaTypes",
                                 kCIAttributeDisplayName: "Kernel type",
                                 kCIAttributeDefault: KuwaharaTypes.colored],
             
             "inputZeroCross": [kCIAttributeIdentity: 0,
                                kCIAttributeClass: "NSNumber",
                                kCIAttributeDisplayName: "Zero Crossing value",
                                kCIAttributeDefault: 0,
                                kCIAttributeMin: 0.01,
                                kCIAttributeMax: 2,
                                kCIAttributeDefault: kCIAttributeTypeScalar],
             
             "inputHardness": [kCIAttributeIdentity: 0,
                               kCIAttributeClass: "NSNumber",
                               kCIAttributeDisplayName: "Hardness value",
                               kCIAttributeDefault: 100,
                               kCIAttributeMin: 0,
                               kCIAttributeDefault: kCIAttributeTypeScalar],
             
             "inputQuality": [kCIAttributeIdentity: 0,
                              kCIAttributeClass: "NSNumber",
                              kCIAttributeDisplayName: "Quality value",
                              kCIAttributeDefault: 15,
                              kCIAttributeMin: 0,
                              kCIAttributeDefault: kCIAttributeTypeScalar]
         ]
     }
    
    
    public override func setValue(_ value: Any?, forKey key: String) {
        switch key {
        case "inputImage":
            inputImage = value as? CIImage
            
        case "inputKernelSize":
            guard let kernelSize = value as? Int else {
                return
            }
            inputKernelSize = kernelSize
            
        case "inputKernelType":
            guard let type = value as? KuwaharaTypes else {
                return
            }
            inputKernelType = type
            
        case "inputZeroCross":
            guard let type = value as? Float else {
                return
            }
            inputZeroCross = type
            
        case "inputHardness":
            guard let type = value as? Float else {
                return
            }
            inputHardness = type
            
        case "inputQuality":
            guard let type = value as? Float else {
                return
            }
            inputQuality = type
            
            default:
                break
        }
    }
    
    public override var outputImage : CIImage? {
            get {
                guard var input = inputImage else {
                    return nil
                }
                let callback: CIKernelROICallback = {_,rect in
                    return rect
                }
                
                if inputKernelType == .basicKuwahara {
                    let filter = CIFilter(name: "CIColorMonochrome")
                    filter?.setValue(input, forKey: "inputImage")
                    filter?.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")
                    filter?.setValue(1.0, forKey: "inputIntensity")
                    
                    guard let out = filter?.outputImage else { return nil }
                    input = out
                }
                
                var args: [Any] = [input, inputKernelSize]
                
                if inputKernelType == .generalized{
                    args.append(contentsOf: [inputZeroCross, inputHardness, inputQuality])
                }
                
                let out = kernel.apply(extent: input.extent,
                                                roiCallback: callback,
                                                 arguments: args)
                return out
            }
        }
}
