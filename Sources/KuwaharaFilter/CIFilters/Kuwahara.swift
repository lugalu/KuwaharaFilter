//Created by Lugalu on 14/03/24.

import CoreImage

fileprivate extension KuwaharaTypes {
    func getKernel() -> String {
        switch self {
        case .basic:
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
        case .Polynomial:
            return """
            
            kernel float4 Kuwahara(sampler s, int kernelSize, float zeroCross, float hardness, float sharpness){
                float2 uv = destCoord();
                int radius = kernelSize / 2;
            
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
                    float w = 1 / (1 + pow(hardness * 1000. * sigma2, 0.5 * sharpness));
                    
                    result += float4(mean[k].rgb * w, w);
                }
            
                result /= result.w;
                return clamp(result,0.,1.);
            
            }
            
            """
        case .Generalized:
            return """
            
            kernel float4 Kuwahara(sampler s, sampler weights, int kernelSize, float sharpness) {
                int k = 0;
                float2 uv = destCoord();
                int radius = kernelSize / 2;
            
                float piN = 2.0f * PI / float(SECTORS);
                float2x2 X = float2x2(
                    float2(cos(piN), sin(piN)),
                    float2(-sin(piN), cos(piN))
                );
            
                float4 mean[SECTORS];
                float3 std[SECTORS];
                
                for (k = 0; k < SECTORS; k++) {
                    mean[k] = vec4(0);
                    std[k] = vec3(0);
                }
            
                for (int x = -radius; x <= radius; x++) {
                    for (int y = -radius; y <= radius; y++) {
                        float2 v = 0.5 * float2(x,y) / float(radius);
                        float3 c = sample(s, samplerTransform(s, uv + float2(x,y))).rgb;
                        
                        for (k = 0; k < SECTORS; k++){
                            float w = sample(weights, v ).r;
                    
                            mean[k] += float4(c * w, w);
                            std[k] += c * c * w;
                            
                            v = X * v;
                        }
                    }
                }
            
                float4 result = float4(0);
                
                for(k = 0; k < SECTORS; k++){
                    mean[k].rgb /= mean[k].a;
                    std[k] = abs(std[k] / mean[k].a - (mean[k].rgb * mean[k].rgb));
            
                    float sigma2 = std[k].r + std[k].g + std[k].b;
                    float w = 1. / (1. + pow(abs(1000. * sigma2), 0.5 * sharpness));
                    
                    result += float4(mean[k].rgb * w, w);
                }
            
                result /= result.a;
                return result;
            }
            """
        case .Anisotropic:
            return """
                kernel float4 Kuwahara(sampler s, sampler anisotropic, float kernelRadius, float alpha, float zeroCross, float sharpness ){
                    float4 t = sample(anisotropic, samplerCoord(s));
                    int radius = int(kernelRadius) / 2;
                    float zeta = 2. / (kernelRadius/2.);
                    float sinZeroCross = sin(zeroCross);
                    float eta = (zeta + cos(zeroCross)) / pow(sinZeroCross,2.);
                    int k;
                    float4 mean[SECTORS];
                    float3 std[SECTORS];
            
                    for(k = 0; k < SECTORS; k++){
                        mean[k] = float4(0);
                        std[k] = float3(0);
                    }
                    
                    float a = radius * clamp((alpha + t.a) / alpha, 0.1, 2.);
                    float b = radius * clamp(alpha / (alpha + t.a), 0.1, 2.);
            
                    float cosPhi = cos(t.b);
                    float sinPhi = sin(t.b);
            
                    float2x2 R = float2x2(
                        float2(cosPhi, -sinPhi),
                        float2(sinPhi, cosPhi)
                    );

                    float2x2 S = float2x2(
                        float2(0.5f / a, 0.0f),
                        float2(0.0f, 0.5f / b)
                    );
            
                    float2x2 SR = S * R;
            
                    int maxX = int( sqrt(pow(a, 2.) * pow(cosPhi, 2.) + pow(b, 2.) * pow(sinPhi, 2.) ));
                    int maxY = int( sqrt(pow(a, 2.) * pow(sinPhi, 2.) + pow(b, 2.) * pow(cosPhi, 2.) ));
            
                    for (int x = -maxX; x <= maxX; x++){
                        for (int y = -maxY; y <= maxY; y++){
            
                            float2 v = SR * float2(x,y);
                            if( dot(v,v) > 0.25) {
                                continue;
                            }
                        
                            float3 c = sample(s, samplerTransform(s, destCoord() + float2(x,y))).rgb;
                            float sum = 0;
                            float w[8];
                            float vxx,vyy;
            
                            vxx = zeta - eta * pow(v.x,2.);
                            vyy = zeta - eta * pow(v.y,2.);
                            
                            w[0] = getSquaredZFor(v.y + vxx);
                        
                            w[2] = getSquaredZFor(-v.x + vyy);
                
                            w[4] = getSquaredZFor(-v.y + vxx);
                            
                            w[6] = getSquaredZFor(v.x + vyy);
                            
                            v = sqrt(2.) / 2. * float2(v.x-v.y, v.x + v.y);
                            vxx = zeta - eta * pow(v.x,2.);
                            vyy = zeta - eta * pow(v.y,2.);
                
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
                    
                    for(k = 0; k < SECTORS; k++){
                        mean[k].rgb /= mean[k].a;
                        std[k] = abs(std[k] / mean[k].a - (mean[k].rgb * mean[k].rgb));
                
                        float sigma2 = std[k].r + std[k].g + std[k].b;
                        float w = 1. / (1. + pow(abs(1000. * sigma2), 0.5 * sharpness));
                        
                        result += float4(mean[k].rgb * w, w);
                    }
                
                    result /= result.a;
                    return result;
                }
            """
        }
    }
}

public class Kuwahara: CIFilter {
    //Standard
    @objc dynamic var inputImage: CIImage?
        /** Kernel Matrix around each pixel, should be 2<=n, note that higher values take more time to compute.*/
    @objc dynamic var inputKernelSize: Int = 2
    /** The operation to be used, read the enum cases for a general explanation. */
    @objc var inputKernelType: KuwaharaTypes = .basic
    /** if image should become grayscale. */
    @objc var inputIsGrayscale: Bool = false
    
    //Generalized
    /** Defines the overlap between 2 sectors of kuwahara, should be 0.01 <= n <= 2. affects Polynomial and Anisotropic*/
    @objc dynamic var inputZeroCross: Float = 0.58

    /** Image Hardness, should be between 1 <= n <= 100. affects Polynomial */
    @objc dynamic var inputHardness: Float = 100
    
    /** Image Sharpness, should be 1 <= n <= 18. affects all except for basic.*/
    @objc dynamic var inputSharpness: Float = 18
    
    /** Blur prepass, should be 1 <= n <= 6. affects Anisotropic.*/
    @objc dynamic var inputBlurRadius: Int = 2
    
    /** Blur prepass, should be 0.1 <= n <= 2. affects Anisotropic */
    @objc dynamic var inputAlpha: Float = 1
    
    
    static package let baseKernelCode: String = """
    #define SECTORS 8
    #define PI 3.14159265358979323846f

    float getLuminance(float3 color) {
        return max(color.r, max(color.g,color.b));

    }

    float gaussian(float sigma, float2 pos) {
        return ( 1.0f / (2.0f * PI * sigma * sigma) ) * exp( -( (pos.x * pos.x + pos.y * pos.y ) / (2.0f * sigma * sigma) ) );
    }

    float gaussian(float sigma, float pos) {
        return (1.0f / sqrt(2.0f * PI * sigma * sigma)) * exp(-(pos * pos) / (2.0f * sigma * sigma));
    }

    float getSquaredZFor(float x){
        float z = max(0.0, x);
        return z * z;
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
 
    private var kernel: CIKernel {
        return CIKernel(source: Kuwahara.baseKernelCode + inputKernelType.getKernel()) ?? CIKernel()
    }
        
    public override var outputImage : CIImage? {
            get {
                guard var input = inputImage else {
                    return nil
                }
                let callback: CIKernelROICallback = {_,rect in
                    return rect
                }
                
                if inputIsGrayscale {
                    let filter = CIFilter(name: "CIColorMonochrome")
                    filter?.setValue(input, forKey: "inputImage")
                    filter?.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")
                    filter?.setValue(1.0, forKey: "inputIntensity")
                    
                    guard let out = filter?.outputImage else { return nil }
                    input = out
                }
                
                var args: [Any] = [input, inputKernelSize]
                
                switch inputKernelType {
                case .basic:
                    break
                case .Generalized:
                    guard let url = Bundle.module.url(forResource: "blackSquare", withExtension: "jpg"),
                          let ciBase = CIImage(contentsOf: url) else {
                        return nil
                    }
                    let sectorPrePass = preSectorPass.apply(extent: ciBase.extent, roiCallback: callback, arguments: [ciBase])
                    let gaussPrePass = preGaussianPass.apply(extent: ciBase.extent, roiCallback: callback, arguments: [sectorPrePass])
                    args.insert(gaussPrePass, at: 1)
                    args.append(inputSharpness)
                    
                case .Polynomial:
                    args.append(contentsOf: [inputZeroCross, inputHardness, inputSharpness])
                    
                case .Anisotropic:

                    let tensor = preTensorPass.apply(extent: input.extent, roiCallback: callback, arguments: [input])
                    let blur = preHorizontalBlur.apply(extent: input.extent, roiCallback: callback, arguments: [tensor, inputBlurRadius])
                    let anisotropic = preAnisotropyCalc.apply(extent: input.extent, roiCallback: callback, arguments: [blur,inputBlurRadius])
                    //return anisotropic
                    //kernel float4 Kuwahara(sampler s, sampler anisotropic, float kernelRadius, float alpha, float zeroCross, float sharpness )
                    args.insert(anisotropic, at: 1)
                    args.append(contentsOf: [inputAlpha,inputZeroCross, inputSharpness])
                }
                
                let out = kernel.apply(extent: input.extent,
                                                roiCallback: callback,
                                                 arguments: args)
                return out
            }
        }
}











//MARK: Key-Value coding compliance methods
extension Kuwahara {
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
                                 kCIAttributeDefault: KuwaharaTypes.basic],
             
             "inputIsGrayscale": [kCIAttributeIdentity: 0,
                                 kCIAttributeClass: "Bool",
                                 kCIAttributeDisplayName: "is Grayscale",
                                 kCIAttributeDefault: false,
                                 kCIAttributeDefault: kCIAttributeTypeBoolean],
             
             "inputZeroCross": [kCIAttributeIdentity: 0,
                                kCIAttributeClass: "NSNumber",
                                kCIAttributeDisplayName: "Zero Crossing value",
                                kCIAttributeDefault: 0.58,
                                kCIAttributeMin: 0.01,
                                kCIAttributeMax: 2,
                                kCIAttributeDefault: kCIAttributeTypeScalar],
             
             "inputHardness": [kCIAttributeIdentity: 0,
                               kCIAttributeClass: "NSNumber",
                               kCIAttributeDisplayName: "Hardness value",
                               kCIAttributeDefault: 100,
                               kCIAttributeMin: 1,
                               kCIAttributeMax: 100,
                               kCIAttributeDefault: kCIAttributeTypeScalar],
             
             "inputSharpness": [kCIAttributeIdentity: 0,
                              kCIAttributeClass: "NSNumber",
                              kCIAttributeDisplayName: "Sharpness value",
                              kCIAttributeDefault: 15,
                              kCIAttributeMin: 0,
                              kCIAttributeMax: 18,
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
            
        case "inputIsGrayscale":
            guard let type = value as? Bool else {
                return
            }
            inputIsGrayscale = type
            
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
            inputSharpness = type
            
            default:
                break
        }
    }
    
    public override class func value(forKey key: String) -> Any? {
        return switch key {
        case "inputImage":
            nil
            
        case "inputKernelSize":
            2
            
        case "inputIsGrayscale":
            false
      
        case "inputKernelType":
            KuwaharaTypes.basic
            
        case "inputZeroCross":
            0.58
          
            
        case "inputHardness":
            100
            
        case "inputQuality":
            18
            
        default:
            nil
        }
    }
}
