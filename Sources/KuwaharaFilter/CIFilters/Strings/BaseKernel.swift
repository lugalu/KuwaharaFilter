//Created by Lugalu on 31/03/24.

import Foundation

package let BaseKernelCode: String = """
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
