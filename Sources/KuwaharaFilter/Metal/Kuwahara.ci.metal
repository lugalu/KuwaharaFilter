#include <metal_stdlib>
using namespace metal;
#include <CoreImage/CoreImage.h>

extern "C" {
        //    float getLuminance(float3 color){
        //        return max(color.r,max(color.g,color.b));
        //    }
        //
        //    float4 sampleQuadrant(coreimage::sampler s, float2 uv, int x1, int x2, int y1, int y2, float n) {
        //            float luminance = 0.0f;
        //            float luminance2 = 0.0f;
        //            float3 colorSum = 0.0f;
        //            //
        //            for (int x = x1; x1<x2; x++) {
        //                for (int y = y1; y1<y2; y++) {
        //
        //                    //            float2 c = coreimage::sample(uv+ float2(x,y));
        //                    //            float l = getLuminance(c);
        //                    //            luminance += l;
        //                    //            luminance2 += l * l;
        //                    //            colorSum += c;
        //                }
        //            }
        //            //
        //            //    float mean = luminance / n;
        //            //    float stdeviation = abs(luminance2 / n - mean * mean);
        //            //
        //            //    return float4(colorSum / n, stdeviation);
        //            return float4(1);
        //
        //        }
        
        
        
    float4 grayKuwahara(coreimage::sample_t src, int  kernelSize) {
        float2 pos = src.rg;
        return float4(pos,0,0);
            //        s.sample(float2(1,1));
            //coreimage::sample_t sample = coreimage::sample_t();
            //    int radius = kernelSize / 2;
            //    float window = 2.0f * radius + 1;
            //    int quadrant = int(ceil(window/2.0f));
            //    int numSamples = quadrant * quadrant;
            //
            //    float4 q1 = sampleQuadrant(sampler, sample, -radius, 0, -radius, 0, numSamples);
            //    float4 q2 = sampleQuadrant(sampler, sample, 0, radius, -radius, 0, numSamples);
            //    float4 q3 = sampleQuadrant(sampler, sample, 0, radius, 0, radius, numSamples);
            //    float4 q4 = sampleQuadrant(sampler, sample, -radius, 0, 0, radius, numSamples);
            //
            //    float min = fmin(q1.a,fmin(q2.a,fmin(q3.a,q4.a)));
            //
            //    int4 q = 0;
            //    if (q1.a == min){
            //        q = int4(q1.a);
            //    }else if (q2.a == min){
            //        q = int4(q2.a);
            //    }else if (q3.a == min){
            //        q = int4(q3.a);
            //    }else{
            //        q = int4(q4.a);
            //    }
            //
            //    if (dot(float4(q),float4(1))) {
            //        return float4((q1.rgb + q2.rgb + q3.rgb + q4.rgb) / 4.0f, 1.0f);
            //    }else{
            //        return float4(q1.rgb * q.x + q2.rgb * q.y + q3.rgb * q.z + q4.rgb * q.w, 1.0f);
            //    }
            
            return float4(1,1,1,1);
        }
}
