//Created by Lugalu on 31/03/24.

import CoreImage


package var PreSectorPass: CIKernel{
    return CIKernel(source: BaseKernelCode + """
    kernel float4 preSectorPass(sampler s) {
        float2 uv = samplerTransform(s, destCoord());
        float2 pos = uv - 0.5f;
        float phi = atan(pos).y;
        int Xk = int((-PI / SECTORS) < phi && phi <= (PI / SECTORS));
        return float4(int(dot(pos, pos) <= 0.25f));
    }
    """)!
}

package var PreGaussianPass: CIKernel {
    return CIKernel(source: BaseKernelCode + """
    
        kernel float4 preGaussianPass(sampler s) {
        float sigmaR = 0.5 * 32.0 * 0.5;
        float sigmaS = 0.33 * sigmaR;
        float2 uv = samplerCoord(s);
        
        float weight = 0.0f;
        float kernelSum = 0.0f;
    
        for (int x = -int(floor(sigmaS)); x <= int(floor(sigmaS)); x++) {
            for (int y = -int(floor(sigmaS)); y <= int(floor(sigmaS)); y++) {
    
                float c = sample(s, uv + float2(x,y) * float2(1./32.,1./32.) ).r;
                float gauss = gaussian(sigmaS, float2(x, y));

                weight += c * gauss;
                kernelSum += gauss;
            }
        }
        float result = (weight / kernelSum); // * gaussian(sigmaR, (uv - 0.5) * sigmaR * 5.);
        return float4(result);
    }
    """)!
}

package var PreTensorPass: CIKernel {
    return CIKernel(source: BaseKernelCode + """
        kernel float4 preTensorPass(sampler s) {
            float2 d = float2(1);
            float2 uv = destCoord();
    
            float4 SX = 1. * sample(s, samplerTransform(s, uv + float2(-d.x, -d.y)));
            SX += 2. * sample(s, samplerTransform(s, uv + float2(-d.x, 0.)));
            SX += 1. * sample(s, samplerTransform(s, uv + float2(-d.x, d.y)));
            SX += -1. * sample(s, samplerTransform(s, uv + float2(d.x, -d.y)));
            SX += -2. * sample(s, samplerTransform(s, uv + float2(d.x, 0.)));
            SX += -1. * sample(s, samplerTransform(s, uv + float2(d.x, d.y)));
            SX /= 4.;
    
            float4 SY = 1. * sample(s, samplerTransform(s, uv + float2(-d.x, -d.y)));
            SY += 2. * sample(s, samplerTransform(s, uv + float2(0., -d.y)));
            SY += 1. * sample(s, samplerTransform(s, uv + float2(d.x, -d.y)));
            SY += -1. * sample(s, samplerTransform(s, uv + float2(-d.x, d.y)));
            SY += -2. * sample(s, samplerTransform(s, uv + float2(0., d.y)));
            SY += -1. * sample(s, samplerTransform(s, uv + float2(d.x, d.y)));
            SY /= 4.;
    
            return float4(dot(SX.rgb,SX.rgb), dot(SY.rgb,SY.rgb), dot(SX.rgb,SY.rgb), 1);
        }
    """)!
}

package var PreHorizontalBlur: CIKernel{
    return CIKernel(source: BaseKernelCode + """
        kernel float4 preHorizontalBlur(sampler s, int blurRadius) {
            float4 col = float4(0);
            float kernelSum = 0.;
            
            for(int x = -blurRadius; x <= blurRadius; x++) {
                float4 c = sample(s, samplerTransform(s, destCoord() + float2(x,0)));
                float g = gaussian(2.,float(x));
                
                col += c * g;
                kernelSum += g;
            }
            return col / kernelSum;
        }
    """)!
}

package var PreAnisotropyPass: CIKernel{
    return CIKernel(source: BaseKernelCode + """
        kernel float4 preAnisotropyCalc(sampler s, int blurRadius) {
            float4 col = float4(0);
            float kernelSum = 0.;
            
            for(int y = -blurRadius; y <= blurRadius; y++) {
                float4 c = sample(s, samplerTransform(s, destCoord() + float2(0,y)));
                float g = gaussian(2.,float(y));
                
                col += c * g;
                kernelSum += g;
            }
    
            float3 g = col.rgb / kernelSum;
    
            float lambda = 0.5 * (g.g + g.r + sqrt( pow(g.g,2.) - 2. * g.r * g.b + pow(g.r,2.) + 4. * pow(g.b,2.)));
            float lambda2 = 0.5 * (g.g + g.r - sqrt( pow(g.g,2.) - 2. * g.r * g.b + pow(g.r,2.) + 4. * pow(g.b,2.)));
    
            float2 v = float2(lambda - g.r, g.b);
            float2 t = length(v) > 0. ? normalize(v) : float2(0,1);
            float phi = -atan(t.y,t.x);
        
            float A = (lambda + lambda2) > 0.0f ? (lambda - lambda2) / (lambda + lambda2) : 0.0f;
            return float4(t, phi, A);
        }
    """)!
}
