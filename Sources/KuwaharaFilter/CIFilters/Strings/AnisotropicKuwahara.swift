//Created by Lugalu on 31/03/24.

import Foundation

package let AnisotropicKuwahara: String = """
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
