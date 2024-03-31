//Created by Lugalu on 31/03/24.

import Foundation

package let GeneralizedKuwahara: String = """
            
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
