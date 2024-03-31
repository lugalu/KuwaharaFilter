//Created by Lugalu on 31/03/24.

import Foundation

package let PolynomialKuwahara: String = """
            
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
